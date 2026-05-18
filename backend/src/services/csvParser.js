const { parse } = require('csv-parse/sync');

class CSVParser {
  parseInsumosCSV(csvText) {
    const records = parse(csvText, {
      columns: false,
      skip_empty_lines: true,
    });

    if (records.length === 0) {
      throw new Error('CSV vacío');
    }

    const products = [];
    for (let i = 1; i < records.length; i++) {
      const record = records[i];
      if (record.length < 5) {
        throw new Error(`fila ${i + 1} tiene menos de 5 campos`);
      }

      const stock = parseInt(record[3], 10);
      if (isNaN(stock)) {
        throw new Error(`error convirtiendo stock en fila ${i + 1}`);
      }

      products.push({
        product: {
          name: record[1].trim(),
          type: record[2].trim(),
          unit: record[4].trim(),
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
        },
        stock,
      });
    }

    return products;
  }

  parseLotesCSV(csvText) {
    const records = parse(csvText, {
      columns: false,
      skip_empty_lines: true,
    });

    if (records.length === 0) {
      throw new Error('CSV vacío');
    }

    const batches = [];
    for (let i = 1; i < records.length; i++) {
      const record = records[i];
      if (record.length < 6) {
        throw new Error(`fila ${i + 1} tiene menos de 6 campos`);
      }

      const quantity = parseInt(record[3], 10);
      if (isNaN(quantity)) {
        throw new Error(`error convirtiendo cantidad en fila ${i + 1}`);
      }

      batches.push({
        lote: {
          product_id: record[1].trim(),
          entry_date: record[2].trim(),
          initial_quantity: quantity,
          current_quantity: quantity,
          destiny_cellar: record[4].trim(),
          state: record[5].trim(),
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
        },
      });
    }

    return batches;
  }

  parseMovimientosCSV(csvText) {
    const records = parse(csvText, {
      columns: false,
      skip_empty_lines: true,
    });

    if (records.length === 0) {
      throw new Error('CSV vacío');
    }

    const movements = [];
    for (let i = 1; i < records.length; i++) {
      const record = records[i];
      if (record.length < 7) {
        throw new Error(`fila ${i + 1} tiene menos de 7 campos`);
      }

      const quantity = parseInt(record[3], 10);
      if (isNaN(quantity)) {
        throw new Error(`error convirtiendo cantidad en fila ${i + 1}`);
      }

      movements.push({
        movement: {
          lote_id: record[1].trim(),
          movement_type: record[2].trim(),
          quantity,
          date: record[4].trim(),
          responsible: record[5].trim(),
          observation: record[6].trim(),
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
        },
      });
    }

    return movements;
  }

  parseProductosTerminadosCSV(csvText) {
    const records = parse(csvText, {
      columns: false,
      skip_empty_lines: true,
    });

    if (records.length === 0) {
      throw new Error('CSV vacío');
    }

    const products = [];
    for (let i = 1; i < records.length; i++) {
      const record = records[i];
      if (record.length < 6) {
        throw new Error(`fila ${i + 1} tiene menos de 6 campos`);
      }

      const stock = parseInt(record[3], 10);
      if (isNaN(stock)) {
        throw new Error(`error convirtiendo stock en fila ${i + 1}`);
      }

      const price = parseFloat(record[5]);
      if (isNaN(price)) {
        throw new Error(`error convirtiendo precio en fila ${i + 1}`);
      }

      products.push({
        product: {
          name: record[1].trim(),
          type: record[2].trim(),
          unit: record[4].trim(),
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
        },
        stock,
        price,
      });
    }

    return products;
  }
}

module.exports = CSVParser;
