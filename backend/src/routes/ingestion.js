const express = require('express');
const CSVParser = require('../services/csvParser');

function ingestionRoutes(pbClient, minioService) {
  const router = express.Router();
  const csvParser = new CSVParser();

  router.post('/import', async (req, res, next) => {
    try {
      const { file_reference, entity_type } = req.body;

      if (!file_reference) {
        return res.status(400).json({ error: 'file_reference es requerido' });
      }

      const parts = file_reference.split('/');
      if (parts.length < 2) {
        return res.json({
          success: false,
          inserted_rows: 0,
          errors: [{ error_message: 'formato de referencia de archivo inválido' }],
        });
      }

      const bucket = parts[0];
      const objectName = parts.slice(1).join('/');

      const csvData = await minioService.downloadFile(bucket, objectName);
      const csvText = csvData.toString('utf-8');

      const lines = csvText.split('\n').filter((l) => l.trim());
      if (lines.length < 2) {
        return res.json({ success: true, inserted_rows: 0, errors: [] });
      }

      const header = lines[0].split(',').map((h) => h.trim().toLowerCase());
      const headerMap = {};
      header.forEach((name, idx) => {
        headerMap[name] = idx;
      });

      const nameIdx = headerMap['name'];
      const typeIdx = headerMap['type'];
      const qtyIdx = headerMap['quantity'];
      const unitIdx = headerMap['unit'];

      if (nameIdx === undefined || typeIdx === undefined || qtyIdx === undefined || unitIdx === undefined) {
        return res.json({
          success: false,
          inserted_rows: 0,
          errors: [{ error_message: 'columnas faltantes en el CSV (se requiere: name, type, quantity, unit)' }],
        });
      }

      let insertedCount = 0;
      const importErrors = [];

      for (let i = 1; i < lines.length; i++) {
        const row = lines[i].split(',');

        const qty = parseInt(row[qtyIdx], 10) || 0;

        const payload = {
          name: row[nameIdx],
          type: row[typeIdx],
          quantity: qty,
          unit: row[unitIdx],
        };

        try {
          await pbClient.createRecord('inventory', payload);
          insertedCount++;
        } catch (err) {
          importErrors.push({
            row_number: i + 1,
            error_message: `error insertando en DB: ${err.message}`,
          });
        }
      }

      res.json({
        success: importErrors.length === 0,
        inserted_rows: insertedCount,
        errors: importErrors,
      });
    } catch (err) {
      next(err);
    }
  });

  return router;
}

module.exports = ingestionRoutes;
