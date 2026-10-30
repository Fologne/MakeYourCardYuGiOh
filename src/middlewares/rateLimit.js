// Limitador de requisicoes em memoria por IP, sem dependencias externas
export function createRateLimiter({ maxAttempts, windowMs, message }) {
  const windows = new Map();
  const cleanupTimer = setInterval(() => {
    const now = Date.now();
    for (const [key, value] of windows) {
      if (value.resetAt <= now) windows.delete(key);
    }
  }, windowMs);
  cleanupTimer.unref();
  return function rateLimiter(req, res, next) {
    const now = Date.now();
    const key = req.ip || req.socket.remoteAddress || 'desconhecido';
    const current = windows.get(key);

    if (!current || current.resetAt <= now) {
      windows.set(key, { count: 1, resetAt: now + windowMs });
      return next();
    }

    current.count += 1;

    if (current.count > maxAttempts) {
      const retryAfter = Math.ceil((current.resetAt - now) / 1000);
      res.set('Retry-After', String(retryAfter));
      return res.status(429).json({
        success: false,
        message: message || 'Muitas requisicoes. Tente novamente mais tarde.',
      });
    }

    return next();
  };
}

export const authRateLimiter = createRateLimiter({
  maxAttempts: 15,
  windowMs: 15 * 60 * 1000,
  message: 'Muitas tentativas de autenticacao. Aguarde 15 minutos.',
});

export const apiRateLimiter = createRateLimiter({
  maxAttempts: 300,
  windowMs: 15 * 60 * 1000,
  message: 'Limite de requisicoes excedido. Tente novamente em alguns minutos.',
});
