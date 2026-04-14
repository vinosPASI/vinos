const criticalInsumosMock = [
  {'name': 'Botella Bordelesa 750ml', 'net_stock': 120, 'score': 0.85},
  {'name': 'Corcho Natural Extra', 'net_stock': 540, 'score': 0.72},
  {'name': 'Etiqueta Malbec Reserva', 'net_stock': 210, 'score': 0.92},
  {'name': 'Cápsula Plomo Roja', 'net_stock': 450, 'score': 0.65},
];

const warehouseDistributionMock = {
  'Depósito Central': 45.0,
  'Bodega Norte': 30.0,
  'Depósito Frío': 15.0,
  'Exportación': 10.0,
};

const dashboardKPIsMock = {
  'total_net_stock': '24,850',
  'stock_trend': '+12.5%',
  'out_of_stock_alerts': '14',
  'alerts_trend': '-2.1%',
  'days_to_restock': '12',
};
