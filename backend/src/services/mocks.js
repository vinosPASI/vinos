let mockCounter = 0;

const mocks = [
  {
    raw_ocr_text: 'VIÑA VIEJA DESDE 1885 GRAN BORGOÑA SEMI SECO 750ml',
    classification: { label: 'wine_label', confidence_level: 0.94 },
    wine_data: { brand: 'Viña Vieja', cepa_variedad: 'Gran Borgoña', vintage_year: 0, volume_content: '750ml', sku: 'N/A', warehouse: 'N/A' },
    sommelier_note: 'Un vino versátil y amable con un toque dulzón. Perfecto para una tarde de piqueos, quesos suaves o simplemente para disfrutar solo.',
  },
  {
    raw_ocr_text: 'VINA VIEJA DE5DE 1885 GRAN BORGONA SEMI 5ECO 750 ml',
    classification: { label: 'wine_label', confidence_level: 0.88 },
    wine_data: { brand: 'Vina Vieja', cepa_variedad: 'Gran Borgona', vintage_year: 1885, volume_content: '750 ml', sku: 'N/A', warehouse: 'N/A' },
    sommelier_note: 'Este Gran Borgoña semi seco es ideal para acompañar pastas con salsas ligeras, aves o comida agridulce. Sírvelo ligeramente fresco.',
  },
  {
    raw_ocr_text: 'VIÑ4 VIEJ4 GR4N BORGOÑ4 750m1',
    classification: { label: 'wine_label', confidence_level: 0.82 },
    wine_data: { brand: 'Viñ4 Vieja', cepa_variedad: 'Borgoña Semi Seco', vintage_year: 0, volume_content: '750m1', sku: 'N/A', warehouse: 'N/A' },
    sommelier_note: 'Un vino versátil y amable con un toque dulzón. Perfecto para una tarde de piqueos, quesos suaves o simplemente para disfrutar solo.',
  },
  {
    raw_ocr_text: 'TORO VIEJO BONARDA - SIRAH Vino Tinto Red Wine 3000 ml',
    classification: { label: 'wine_label', confidence_level: 0.96 },
    wine_data: { brand: 'Toro Viejo', cepa_variedad: 'Bonarda - Sirah', vintage_year: 0, volume_content: '3000ml', sku: 'N/A', warehouse: 'N/A' },
    sommelier_note: 'Este blend en gran formato es el rey indiscutible de los asados. Marida increíble con carnes a la parrilla, choripanes y embutidos fuertes.',
  },
  {
    raw_ocr_text: 'T0R0 VIEJO BONARDA-SYRAH 3000mI PRODUCTO DE ARGENTINA',
    classification: { label: 'wine_label', confidence_level: 0.85 },
    wine_data: { brand: 'T0r0 Viejo', cepa_variedad: 'Bonarda-Syrah', vintage_year: 0, volume_content: '3000mI', sku: 'N/A', warehouse: 'N/A' },
    sommelier_note: 'Vino tinto robusto y rendidor, ideal para guisos intensos, pizzas con carne o empanadas. Al venir en Bag-in-Box, conserva su frescura por semanas.',
  },
  {
    raw_ocr_text: 'TORO VIEJO Vino Tinto 3000 m1',
    classification: { label: 'wine_label', confidence_level: 0.79 },
    wine_data: { brand: 'Toro Viejo', cepa_variedad: 'Vino Tinto', vintage_year: 0, volume_content: '3000 m1', sku: 'N/A', warehouse: 'N/A' },
    sommelier_note: 'Este blend en gran formato es el rey indiscutible de los asados. Marida increíble con carnes a la parrilla, choripanes y embutidos fuertes.',
  },
  {
    raw_ocr_text: 'MARQUÉS de VILLALBA PARDINA COSECHA 2022 75 cl. 12% Vol.',
    classification: { label: 'wine_label_back', confidence_level: 0.98 },
    wine_data: { brand: 'Marqués de Villalba', cepa_variedad: 'Pardina', vintage_year: 2022, volume_content: '75cl', sku: 'N/A', warehouse: 'N/A' },
    sommelier_note: 'La uva Pardina extremeña ofrece una acidez súper refrescante. Brillará junto a mariscos, pescados blancos al horno o arroces marineros.',
  },
  {
    raw_ocr_text: 'MARQUES de VILLALBA PARDINA C0SECHA 20Z2 750ml',
    classification: { label: 'wine_label_back', confidence_level: 0.89 },
    wine_data: { brand: 'Marques de Villalba', cepa_variedad: 'Pardina', vintage_year: 202, volume_content: '750ml', sku: 'N/A', warehouse: 'N/A' },
    sommelier_note: 'Un excelente blanco joven de Ribera del Guadiana. Sírvelo bien frío (8°C) acompañado de tapas, jamón ibérico o ensaladas frescas de verano.',
  },
  {
    raw_ocr_text: 'MARQUÉS de VILLALBA S. COOP MONTEVIRGEN PARDINA 2022 75 c1',
    classification: { label: 'wine_label_back', confidence_level: 0.84 },
    wine_data: { brand: 'Montevirgen', cepa_variedad: 'Villalba Pardina', vintage_year: 2022, volume_content: '75 c1', sku: 'N/A', warehouse: 'N/A' },
    sommelier_note: 'La uva Pardina extremeña ofrece una acidez súper refrescante. Brillará junto a mariscos, pescados blancos al horno o arroces marineros.',
  },
  {
    raw_ocr_text: 'BODEGA GIL BERZAL GLORYA RIOJA ALAVESA 2015',
    classification: { label: 'wine_label', confidence_level: 0.95 },
    wine_data: { brand: 'Bodega Gil Berzal', cepa_variedad: 'Rioja', vintage_year: 2015, volume_content: 'N/A', sku: 'N/A', warehouse: 'N/A' },
    sommelier_note: 'Un Rioja de autor excepcional y maduro. Necesita respirar unos 30 minutos antes de servir. Sublime con cordero asado o carnes rojas maduradas.',
  },
  {
    raw_ocr_text: 'GLORYA LAGUARDIA FINCA VALCAVADA 20I5',
    classification: { label: 'wine_label', confidence_level: 0.88 },
    wine_data: { brand: 'Glorya', cepa_variedad: 'Finca Valcavada', vintage_year: 2015, volume_content: 'N/A', sku: 'N/A', warehouse: 'N/A' },
    sommelier_note: 'La añada 2015 de Rioja aporta complejidad y muchísima elegancia. Acompáñalo con quesos curados de oveja o un buen jamón de bellota.',
  },
  {
    raw_ocr_text: 'GL0RYA GIL BERZAL 2015 Botella No 1428',
    classification: { label: 'wine_label', confidence_level: 0.81 },
    wine_data: { brand: 'Gl0rya Gil Berzal', cepa_variedad: 'Rioja', vintage_year: 2015, volume_content: '1500ml', sku: 'N/A', warehouse: 'N/A' },
    sommelier_note: 'Un Rioja de autor excepcional y maduro. Necesita respirar unos 30 minutos antes de servir. Sublime con cordero asado o carnes rojas maduradas.',
  },
];

function getSequentialMockResult() {
  const result = mocks[mockCounter];
  mockCounter = (mockCounter + 1) % mocks.length;
  return result;
}

module.exports = { getSequentialMockResult };
