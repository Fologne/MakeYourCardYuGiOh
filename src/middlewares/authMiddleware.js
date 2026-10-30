import jwt from 'jsonwebtoken';
import mongoose from 'mongoose';
import User from '../models/User.js';
import { getJwtSecret } from '../config/jwt.js';

export async function authenticateToken(req, res, next) {
  const match = /^Bearer ([^\s]+)$/.exec(req.headers.authorization || '');
  const reject = () => res.status(401).json({ success: false, message: 'Sessao invalida ou expirada. Faca login novamente.' });
  if (!match) return reject();
  let decoded;
  try {
    decoded = jwt.verify(match[1], getJwtSecret(), { algorithms: ['HS256'] });
    if (!mongoose.isValidObjectId(decoded.id) || !Number.isInteger(decoded.sessionVersion)) return reject();
  } catch (error) {
    if (error instanceof jwt.JsonWebTokenError) return reject();
    return next(error);
  }
  try {
    const user = await User.findById(decoded.id).select('+sessionVersion');
    if (!user || !user.isActive || decoded.sessionVersion !== (user.sessionVersion ?? 0)) return reject();
    req.user = user;
    return next();
  } catch (error) {
    return next(error);
  }
}
