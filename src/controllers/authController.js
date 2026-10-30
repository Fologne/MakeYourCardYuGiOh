import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import User from '../models/User.js';
import { generateUniqueAccountId } from '../utils/idGenerator.js';
import { getJwtExpiresIn, getJwtSecret } from '../config/jwt.js';

import { GENDER_OPTIONS, GAME_ORIGIN_OPTIONS, validateBirthDate } from '../utils/validation.js';

// Gera token JWT assinado para o usuario
function generateToken(user) {
  return jwt.sign(
    {
      id: user._id,
      accountId: user.accountId,
      username: user.username,
      email: user.email,
      sessionVersion: user.sessionVersion ?? 0,
    },
    getJwtSecret(),
    { expiresIn: getJwtExpiresIn() }
  );
}

// Rota de criacao de conta (Registro)
export async function register(req, res) {
  try {
    const {
      firstName,
      lastName,
      username,
      email,
      birthDate,
      gender,
      gameOrigin,
      password,
    } = req.body;

    // Validacao dos campos obrigatorios
    if (!firstName || !lastName || !username || !email || !birthDate || !password) {
      return res.status(400).json({
        success: false,
        message: 'Todos os campos obrigatorios devem ser preenchidos.',
      });
    }

    if (password.length < 6) {
      return res.status(400).json({
        success: false,
        message: 'A senha deve conter no minimo 6 caracteres.',
      });
    }

    const birthDateValidation = validateBirthDate(birthDate);
    if (!birthDateValidation.valid) {
      return res.status(400).json({
        success: false,
        message: birthDateValidation.message,
      });
    }

    if (gender && !GENDER_OPTIONS.includes(gender)) {
      return res.status(400).json({
        success: false,
        message: 'Opcao de sexo invalida.',
      });
    }

    if (gameOrigin && !GAME_ORIGIN_OPTIONS.includes(gameOrigin)) {
      return res.status(400).json({
        success: false,
        message: 'Origem no jogo invalida.',
      });
    }

    const cleanUsername = username.trim().toLowerCase();
    const cleanEmail = email.trim().toLowerCase();

    if (cleanUsername.length < 3) {
      return res.status(400).json({
        success: false,
        message: 'O nome de usuario deve ter no minimo 3 caracteres.',
      });
    }

    if (!/^\S+@\S+\.\S+$/.test(cleanEmail)) {
      return res.status(400).json({
        success: false,
        message: 'Formato de e-mail invalido.',
      });
    }

    // Verifica se ja existe usuario com mesmo e-mail ou username
    const existingUser = await User.findOne({
      $or: [{ email: cleanEmail }, { username: cleanUsername }],
    });

    if (existingUser) {
      const isEmail = existingUser.email === cleanEmail;
      return res.status(409).json({
        success: false,
        message: isEmail
          ? 'Este e-mail ja esta em uso.'
          : 'Este nome de usuario ja esta em uso.',
      });
    }

    // Criptografia da senha
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Geracao automatica e unica do ID de conta
    const accountId = await generateUniqueAccountId(User);

    // Criacao do documento no MongoDB
    const newUser = new User({
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      username: cleanUsername,
      email: cleanEmail,
      birthDate: birthDateValidation.date,
      gender: gender || 'Prefiro nao informar',
      gameOrigin: gameOrigin || 'TCG',
      password: hashedPassword,
      accountId,
      plan: 'Gratuito',
      preferredPronoun: 'Duelista',
    });

    await newUser.save();

    const token = generateToken(newUser);

    return res.status(201).json({
      success: true,
      message: 'Conta criada com sucesso.',
      token,
      user: newUser.toSafeObject(),
    });
  } catch (error) {
    if (error.code === 11000) {
      return res.status(409).json({
        success: false,
        message: 'E-mail ou nome de usuario ja esta em uso.',
      });
    }

    if (error.name === 'ValidationError') {
      return res.status(400).json({
        success: false,
        message: 'Dados invalidos para criacao da conta.',
      });
    }

    return res.status(500).json({
      success: false,
      message: 'Erro interno ao criar conta.',
    });
  }
}

// Rota de Login com geracao de token JWT
export async function login(req, res) {
  try {
    const { identifier, password } = req.body;

    if (!identifier || !password) {
      return res.status(400).json({
        success: false,
        message: 'Informe o identificador (e-mail ou usuario) e a senha.',
      });
    }

    const cleanIdentifier = identifier.trim().toLowerCase();

    // Busca usuario por e-mail ou username
    const user = await User.findOne({
      $or: [{ email: cleanIdentifier }, { username: cleanIdentifier }],
    }).select('+sessionVersion');

    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Credenciais invalidas.',
      });
    }

    // Compara senha criptografada
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        message: 'Credenciais invalidas.',
      });
    }

    // Conta desativada e reativada automaticamente apos login valido
    let reactivated = false;
    if (!user.isActive) {
      user.isActive = true;
      await user.save();
      reactivated = true;
    }

    const token = generateToken(user);

    return res.status(200).json({
      success: true,
      message: reactivated
        ? 'Conta reativada e login realizado com sucesso.'
        : 'Login realizado com sucesso.',
      reactivated,
      token,
      user: user.toSafeObject(),
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: 'Erro interno ao realizar login.',
    });
  }
}

// Retorna dados do usuario autenticado
export async function getProfile(req, res) {
  try {
    return res.status(200).json({
      success: true,
      user: req.user.toSafeObject(),
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: 'Erro ao buscar perfil.',
    });
  }
}

// Atualiza dados cadastrais
export async function updateProfile(req, res) {
  try {
    const user = req.user;
    const {
      firstName,
      lastName,
      email,
      birthDate,
      gender,
      gameOrigin,
      preferredPronoun,
    } = req.body;

    if (email) {
      const cleanEmail = email.trim().toLowerCase();

      if (!/^\S+@\S+\.\S+$/.test(cleanEmail)) {
        return res.status(400).json({
          success: false,
          message: 'Formato de e-mail invalido.',
        });
      }

      if (cleanEmail !== user.email) {
        const emailInUse = await User.findOne({
          email: cleanEmail,
          _id: { $ne: user._id },
        });

        if (emailInUse) {
          return res.status(409).json({
            success: false,
            message: 'Este e-mail ja esta em uso.',
          });
        }

        user.email = cleanEmail;
      }
    }

    if (birthDate) {
      const birthDateValidation = validateBirthDate(birthDate);
      if (!birthDateValidation.valid) {
        return res.status(400).json({
          success: false,
          message: birthDateValidation.message,
        });
      }
      user.birthDate = birthDateValidation.date;
    }

    if (gender) {
      if (!GENDER_OPTIONS.includes(gender)) {
        return res.status(400).json({
          success: false,
          message: 'Opcao de sexo invalida.',
        });
      }
      user.gender = gender;
    }

    if (gameOrigin) {
      if (!GAME_ORIGIN_OPTIONS.includes(gameOrigin)) {
        return res.status(400).json({
          success: false,
          message: 'Origem no jogo invalida.',
        });
      }
      user.gameOrigin = gameOrigin;
    }

    if (firstName) user.firstName = firstName.trim();
    if (lastName) user.lastName = lastName.trim();
    if (preferredPronoun) user.preferredPronoun = preferredPronoun;

    await user.save();

    return res.status(200).json({
      success: true,
      message: 'Perfil atualizado com sucesso.',
      user: user.toSafeObject(),
    });
  } catch (error) {
    if (error.code === 11000) {
      return res.status(409).json({ success: false, message: 'Este e-mail ja esta em uso.' });
    }
    if (error.name === 'ValidationError') {
      return res.status(400).json({
        success: false,
        message: 'Dados invalidos para atualizacao do perfil.',
      });
    }

    return res.status(500).json({
      success: false,
      message: 'Erro ao atualizar perfil.',
    });
  }
}

// Desativa a conta temporariamente
export async function deactivateAccount(req, res) {
  try {
    const user = req.user;
    await User.updateOne({ _id: user._id }, { $set: { isActive: false }, $inc: { sessionVersion: 1 } });

    return res.status(200).json({
      success: true,
      message: 'Conta desativada. Faca login novamente para reativa-la.',
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: 'Erro ao desativar conta.',
    });
  }
}

// Exclui a conta definitivamente
export async function deleteAccount(req, res) {
  try {
    await User.findByIdAndDelete(req.user._id);

    return res.status(200).json({
      success: true,
      message: 'Conta excluida definitivamente com sucesso.',
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: 'Erro ao excluir conta.',
    });
  }
}
