const express = require('express');

function productionRoutes() {
  const router = express.Router();

  router.post('/bottling-order', async (req, res) => {
    const { wine_id, target_quantity, unit_type, planned_date } = req.body;

    console.log('[Production] CreateBottlingOrder invocado', {
      wine_id,
      target_quantity,
      unit_type,
      planned_date,
    });

    res.json({
      status: 'pendiente',
      material_breakdown: null,
      stock_alert: {
        stockout_probability: 0.0,
        diagnostic_message: 'Sin datos suficientes para predicción - pendiente implementación',
      },
    });
  });

  return router;
}

module.exports = productionRoutes;
