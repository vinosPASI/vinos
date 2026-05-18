function errorHandler(err, req, res, next) {
  console.error('[ERROR]', err.message, err.stack);

  if (err.type === 'entity.parse.failed') {
    return res.status(400).json({ error: 'JSON inválido en el body' });
  }

  if (err.code === 'LIMIT_FILE_SIZE') {
    return res.status(413).json({ error: 'archivo demasiado grande (máx 50MB)' });
  }

  res.status(err.status || 500).json({
    error: err.message || 'error interno del servidor',
  });
}

module.exports = errorHandler;
