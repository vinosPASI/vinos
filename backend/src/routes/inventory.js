const express = require('express');

function mapItem(item) {
  return {
    id: item.id,
    name: item.name,
    type: item.type,
    quantity: item.quantity,
    unit: item.unit,
    sku: item.sku || '',
    real_stock: item.real_stock,
    net_stock: item.net_stock,
    warehouse: item.warehouse || '',
    created_at: item.created || '',
    updated_at: item.updated || '',
  };
}

function inventoryRoutes(pbClient) {
  const router = express.Router();

  router.post('/list', async (req, res, next) => {
    try {
      const { page = 1, limit = 50, filter } = req.body;

      const data = await pbClient.listRecords('inventory', page, limit, filter || '');

      const items = (data.items || []).map(mapItem);

      res.json({
        items,
        total_items: data.totalItems,
        total_pages: data.totalPages,
      });
    } catch (err) {
      next(err);
    }
  });

  router.get('/:id', async (req, res, next) => {
    try {
      const item = await pbClient.getRecord('inventory', req.params.id);
      res.json({ item: mapItem(item) });
    } catch (err) {
      next(err);
    }
  });

  router.post('/', async (req, res, next) => {
    try {
      const { name, type, quantity, unit, sku, warehouse } = req.body;

      const payload = {
        name,
        type,
        quantity,
        unit,
        sku: sku || '',
        warehouse: warehouse || '',
        real_stock: quantity,
        net_stock: quantity,
      };

      const item = await pbClient.createRecord('inventory', payload);
      res.status(201).json({ item: mapItem(item) });
    } catch (err) {
      next(err);
    }
  });

  router.put('/:id', async (req, res, next) => {
    try {
      const { name, type, quantity, unit, sku, warehouse } = req.body;

      const payload = {
        name,
        type,
        quantity,
        unit,
        sku: sku || '',
        warehouse: warehouse || '',
      };

      const item = await pbClient.updateRecord('inventory', req.params.id, payload);
      res.json({ item: mapItem(item) });
    } catch (err) {
      next(err);
    }
  });

  router.delete('/:id', async (req, res, next) => {
    try {
      await pbClient.deleteRecord('inventory', req.params.id);
      res.json({ success: true });
    } catch (err) {
      next(err);
    }
  });

  router.post('/movement', async (req, res, next) => {
    try {
      const { item_id, movement_type, quantity, reason, reference_id } = req.body;

      const currentItem = await pbClient.getRecord('inventory', item_id);

      let newQuantity = currentItem.quantity;
      if (movement_type === 'OUT') {
        if (currentItem.quantity < quantity) {
          return res.status(400).json({ error: 'stock insuficiente para movimiento OUT' });
        }
        newQuantity -= quantity;
      } else if (movement_type === 'IN') {
        newQuantity += quantity;
      } else {
        return res.status(400).json({ error: 'tipo de movimiento inválido (debe ser IN o OUT)' });
      }

      await pbClient.updateRecord('inventory', item_id, { quantity: newQuantity });
      const updatedItem = await pbClient.getRecord('inventory', item_id);

      const movementPayload = {
        item: item_id,
        movement_type,
        quantity,
        reason: reason || '',
        reference_id: reference_id || '',
      };

      let movementId = '';
      try {
        const movData = await pbClient.createRecord('inventory_movements', movementPayload);
        movementId = movData.id;
      } catch (err) {
        console.error('[Inventory] Error registrando movimiento:', err.message);
      }

      res.json({
        success: true,
        updated_item: mapItem(updatedItem),
        movement_id: movementId,
      });
    } catch (err) {
      next(err);
    }
  });

  return router;
}

module.exports = inventoryRoutes;
