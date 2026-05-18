const express = require('express');
const multer = require('multer');
const crypto = require('crypto');
const path = require('path');

const upload = multer({
  limits: { fileSize: 50 * 1024 * 1024 },
  storage: multer.memoryStorage(),
});

function generateObjectName(fileName) {
  const ext = path.extname(fileName);
  const randomHex = crypto.randomBytes(8).toString('hex');
  return `${Date.now()}_${randomHex}${ext}`;
}

function storageRoutes(minioService) {
  const router = express.Router();

  router.post('/upload', upload.single('file'), async (req, res, next) => {
    try {
      if (!req.file) {
        return res.status(400).json({ error: "campo 'file' requerido" });
      }

      const bucket = req.query.bucket || 'winery-uploads';
      const objectName = generateObjectName(req.file.originalname);

      await minioService.ensureBucket(bucket);

      const url = await minioService.uploadFile(
        bucket,
        objectName,
        req.file.buffer,
        req.file.size,
        req.file.mimetype || 'application/octet-stream'
      );

      res.json({
        url,
        object_name: objectName,
        bucket,
      });
    } catch (err) {
      next(err);
    }
  });

  return router;
}

module.exports = storageRoutes;
