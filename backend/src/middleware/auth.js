const publicRoutes = new Set([
  '/v1/identity/login',
  '/healthz',
]);

function authMiddleware(pbClient) {
  return async (req, res, next) => {
    if (req.method === 'OPTIONS') {
      return next();
    }

    if (publicRoutes.has(req.path)) {
      return next();
    }

    const authHeader = req.headers.authorization;
    if (!authHeader) {
      return res.status(401).json({ error: 'token de autorización requerido' });
    }

    const token = authHeader.startsWith('Bearer ')
      ? authHeader.slice(7)
      : authHeader;

    try {
      const user = await pbClient.validateToken(token);
      req.userId = user.id;
      req.userRole = user.role;
      next();
    } catch (err) {
      return res.status(401).json({ error: 'token inválido o expirado' });
    }
  };
}

module.exports = authMiddleware;
