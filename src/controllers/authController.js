import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import User from '../models/User.js';
import { generateUniqueAccountId } from '../utils/idGenerator.js';

// Gera token JWT assinado para o usuario
function generateToken(user) {
  const secret = process.env.JWT_SECRET || 'myc_secret_key_yu_gi_oh_default';
  return jwt.sign(
    {
      id: user._id,
      accountId: user.accountId,
      username: user.username,
      email: user.email,
    },
    secret,
    { expiresIn: '7d' }
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

    const cleanUsername = username.trim().toLowerCase();
    const cleanEmail = email.trim().toLowerCase();

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
      birthDate: new Date(birthDate),
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
    return res.status(500).json({
      success: false,
      message: 'Erro interno ao criar conta.',
      error: error.message,
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
    });

    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Credenciais invalidas.',
      });
    }

    if (!user.isActive) {
      return res.status(403).json({
        success: false,
        message: 'Esta conta foi desativada.',
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

    const token = generateToken(user);

    return res.status(200).json({
      success: true,
      message: 'Login realizado com sucesso.',
      token,
      user: user.toSafeObject(),
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: 'Erro interno ao realizar login.',
      error: error.message,
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
      error: error.message,
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
      birthDate,
      gender,
      gameOrigin,
      preferredPronoun,
    } = req.body;

    if (firstName) user.firstName = firstName.trim();
    if (lastName) user.lastName = lastName.trim();
    if (birthDate) user.birthDate = new Date(birthDate);
    if (gender) user.gender = gender;
    if (gameOrigin) user.gameOrigin = gameOrigin;
    if (preferredPronoun) user.preferredPronoun = preferredPronoun;

    await user.save();

    return res.status(200).json({
      success: true,
      message: 'Perfil atualizado com sucesso.',
      user: user.toSafeObject(),
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: 'Erro ao atualizar perfil.',
      error: error.message,
    });
  }
}

// Desativa a conta temporariamente
export async function deactivateAccount(req, res) {
  try {
    const user = req.user;
    user.isActive = false;
    await user.save();

    return res.status(200).json({
      success: true,
      message: 'Conta desativada com sucesso.',
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: 'Erro ao desativar conta.',
      error: error.message,
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
      error: error.message,
    });
  }
}
