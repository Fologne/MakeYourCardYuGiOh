import jwt from 'jsonwebtoken';
import User from '../models/User.js';

// Middleware para verificar e autenticar o token JWT
export async function authenticateToken(req, res, next) {
  const authHeader = req.headers.authorization;
  const token = authHeader && authHeader.startsWith('Bearer ')
    ? authHeader.split(' ')[1]
    : null;

  if (!token) {
    return res.status(401).json({
      success: false,
      message: 'Token de autenticacao nao fornecido.',
    });
  }

  try {
    const jwtSecret = process.env.JWT_SECRET || 'myc_secret_key_yu_gi_oh_default';
    const decoded = jwt.verify(token, jwtSecret);

    const user = await User.findById(decoded.id);
    if (!user || !user.isActive) {
      return res.status(401).json({
        success: false,
        message: 'Usuario inexistente ou desativado.',
      });
    }

    req.user = user;
    next();
  } catch (error) {
    return res.status(403).json({
      success: false,
      message: 'Token invalido ou expirado.',
      error: error.message,
    });
  }
}
