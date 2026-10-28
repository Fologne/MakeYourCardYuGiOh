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

const router = Router();

// Rotas publicas
router.post('/register', register);
router.post('/login', login);

// Rotas privadas protegidas por token JWT
router.get('/me', authenticateToken, getProfile);
router.put('/profile', authenticateToken, updateProfile);
router.post('/deactivate', authenticateToken, deactivateAccount);
router.delete('/account', authenticateToken, deleteAccount);

export default router;
