const express = require('express');

function dashboardRoutes(pbClient) {
  const router = express.Router();

  router.get('/stats', (req, res) => {
    res.json({
      total_bottles: 40300,
      total_value: 892500.0,
      categories_count: 4,
      pending_alerts: 3,
    });
  });

  router.post('/high-value-holdings', (req, res) => {
    res.json({
      items: [
        { name: 'Malbec Reserva 2021 750ml', category: 'Tinto Reserva', value: 246000.0, percentage_of_portfolio: 27.6 },
        { name: 'Cabernet Sauvignon 2022 750ml', category: 'Tinto Joven', value: 145600.0, percentage_of_portfolio: 16.3 },
        { name: 'Bonarda 2022 750ml', category: 'Tinto Joven', value: 115200.0, percentage_of_portfolio: 12.9 },
        { name: 'Tempranillo 2022 750ml', category: 'Tinto Joven', value: 100800.0, percentage_of_portfolio: 11.3 },
        { name: 'Torrontés 2023 750ml', category: 'Blanco Joven', value: 68000.0, percentage_of_portfolio: 7.6 },
      ],
    });
  });

  router.post('/market-exposure', (req, res) => {
    res.json({
      categories: [
        { category_name: 'Tintos Reserva / Gran Reserva', value: 375000.0, percentage: 42.0 },
        { category_name: 'Tintos Jóvenes', value: 295000.0, percentage: 33.1 },
        { category_name: 'Blancos y Rosé', value: 148500.0, percentage: 16.6 },
        { category_name: 'Blend Premium', value: 74000.0, percentage: 8.3 },
      ],
    });
  });

  router.post('/forecasting-feed', (req, res) => {
    res.json({
      alerts: [
        {
          id: 'ALR-001',
          message: 'Stock de Corcho Natural Premium al 76% — proyectado a agotarse en 22 días según ritmo de embotellado actual.',
          severity: 'HIGH',
          created_at: '2026-04-21T10:00:00Z',
          related_item_id: 'corcho-natural',
        },
        {
          id: 'ALR-002',
          message: 'Etiquetas Frontal Malbec Reserva al 45% — coordinar reimpresión con Imprenta Andina antes del próximo lote.',
          severity: 'MEDIUM',
          created_at: '2026-04-20T14:30:00Z',
          related_item_id: 'etiqueta-malbec',
        },
        {
          id: 'ALR-003',
          message: 'Cajas de Madera Premium x3 limitadas a 2,000 unidades. Insuficientes para despacho de exportación planificado.',
          severity: 'LOW',
          created_at: '2026-04-19T09:15:00Z',
          related_item_id: 'caja-madera-x3',
        },
      ],
    });
  });

  return router;
}

module.exports = dashboardRoutes;
