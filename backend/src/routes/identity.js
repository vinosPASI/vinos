const express = require('express');

function identityRoutes(pbClient) {
  const router = express.Router();

  router.post('/login', async (req, res, next) => {
    try {
      const { email, password } = req.body;

      if (!email || !password) {
        return res.status(400).json({ error: 'email y password son requeridos' });
      }

      const { token, record } = await pbClient.authUser(email, password);

      let role = 'ROLE_UNSPECIFIED';
      if (record.role === 'admin') role = 'ROLE_ADMIN';
      else if (record.role === 'operator') role = 'ROLE_OPERATOR';

      res.json({
        access_token: token,
        user_id: record.id,
        role,
      });
    } catch (err) {
      next(err);
    }
  });

  router.post('/register', async (req, res, next) => {
    try {
      const { email, password, password_confirm, name, role } = req.body;

      if (!email || !password || !password_confirm) {
        return res.status(400).json({ error: 'email, password y password_confirm son requeridos' });
      }

      if (password !== password_confirm) {
        return res.status(400).json({ error: 'las contraseñas no coinciden' });
      }

      const pbRole = role === 'ROLE_ADMIN' ? 'admin' : 'operator';
      const record = await pbClient.createUser(email, password, password_confirm, name, pbRole);

      res.json({
        user_id: record.id,
        message: 'usuario registrado exitosamente',
      });
    } catch (err) {
      next(err);
    }
  });

  return router;
}

module.exports = identityRoutes;
