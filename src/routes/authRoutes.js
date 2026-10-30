import { Router } from 'express';
import {
  register,
  login,
  getProfile,
  updateProfile,
  deactivateAccount,
  deleteAccount,
} from '../controllers/authController.js';
import { authenticateToken } from '../middlewares/authMiddleware.js';
import { authRateLimiter } from '../middlewares/rateLimit.js';
import { validateAuthBody } from '../utils/validation.js';

const router = Router();

// Rotas publicas com limite de tentativas
router.post('/register', authRateLimiter, validateAuthBody('register'), register);
router.post('/login', authRateLimiter, validateAuthBody('login'), login);

// Rotas privadas protegidas por token JWT
router.get('/me', authenticateToken, getProfile);
router.put('/profile', authenticateToken, validateAuthBody('profile'), updateProfile);
router.post('/deactivate', authenticateToken, deactivateAccount);
router.delete('/account', authenticateToken, deleteAccount);

export default router;
