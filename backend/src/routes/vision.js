const express = require('express');

const MLClient = require('../services/mlClient');
const { getSequentialMockResult } = require('../services/mocks');

function visionRoutes(pbClient, minioService) {
  const router = express.Router();

  const mlClient = new MLClient(
    process.env.ML_MODELS_URL || 'http://localhost:11434',
    process.env.VISION_LLM_MODEL || 'qwen2.5vl:3b'
  );

  router.post('/analyze', async (req, res, next) => {
    try {
      const { image_reference } = req.body;

      if (!image_reference) {
        return res.status(400).json({ error: 'image_reference es requerido' });
      }

      let bucket = 'winery-uploads';
      let objectName = image_reference;

      const parts = image_reference.split('/');
      if (parts.length >= 2) {
        bucket = parts[0];
        objectName = parts.slice(1).join('/');
      }

      const imageBytes = await minioService.downloadFile(bucket, objectName);
      const base64Image = imageBytes.toString('base64');

      const result = await mlClient.analyzeLabel(base64Image);

      res.json({
        raw_ocr_text: result.raw_ocr_text,
        classification: result.classification,
        wine_data: result.wine_data,
        sommelier_note: result.sommelier_note,
      });
    } catch (err) {
      next(err);
    }
  });

  router.post('/analyze/mock', (req, res) => {
    const mockResult = getSequentialMockResult();
    res.json({
      raw_ocr_text: mockResult.raw_ocr_text,
      classification: mockResult.classification,
      wine_data: mockResult.wine_data,
      sommelier_note: mockResult.sommelier_note,
    });
  });

  return router;
}

module.exports = visionRoutes;
