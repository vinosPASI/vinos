require('dotenv').config();

const express = require('express');
const cors = require('cors');

const PocketBaseClient = require('./services/pocketbase');
const MinioService = require('./services/minio');
const authMiddleware = require('./middleware/auth');
const errorHandler = require('./middleware/errorHandler');

const identityRoutes = require('./routes/identity');
const inventoryRoutes = require('./routes/inventory');
const dashboardRoutes = require('./routes/dashboard');
const visionRoutes = require('./routes/vision');
const ingestionRoutes = require('./routes/ingestion');
const productionRoutes = require('./routes/production');
const storageRoutes = require('./routes/storage');

async function main() {
  const app = express();
  const PORT = process.env.PORT || 8080;

  const pbClient = new PocketBaseClient(process.env.POCKETBASE_URL || 'http://pocketbase:8090');

  const adminEmail = process.env.POCKETBASE_ADMIN_EMAIL;
  const adminPass = process.env.POCKETBASE_ADMIN_PASSWORD;
  if (adminEmail && adminPass) {
    try {
      await pbClient.authAdmin(adminEmail, adminPass);
      console.log('[PocketBase] Conexión exitosa como Admin');
    } catch (err) {
      console.error('[PocketBase] Error autenticando:', err.message);
    }
  }

  const minioService = new MinioService(
    process.env.MINIO_ENDPOINT || 'minio:9000',
    process.env.MINIO_ACCESS_KEY || 'admin_winery',
    process.env.MINIO_SECRET_KEY || 'SmartPassword123!',
    process.env.MINIO_USE_SSL === 'true'
  );

  const corsOptions = {
    origin: process.env.CORS_ORIGIN || '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS', 'PATCH'],
    allowedHeaders: ['Content-Type', 'Authorization'],
    credentials: true,
  };

  app.use(cors(corsOptions));
  app.options('*', cors(corsOptions));
  app.use(express.json({ limit: '50mb' }));
  app.use(authMiddleware(pbClient));

  app.use('/v1/identity', identityRoutes(pbClient));
  app.use('/v1/inventory', inventoryRoutes(pbClient));
  app.use('/v1/dashboard', dashboardRoutes(pbClient));
  app.use('/v1/vision', visionRoutes(pbClient, minioService));
  app.use('/v1/ingestion', ingestionRoutes(pbClient, minioService));
  app.use('/v1/production', productionRoutes());
  app.use('/v1/storage', storageRoutes(minioService));

  app.get('/healthz', (req, res) => {
    console.log('[Server] /healthz endpoint was hit!');
    res.status(200).send('OK');
  });

  app.use(errorHandler);

  app.listen(PORT, () => {
    console.log(`[Server] SmartWinery Backend escuchando en :${PORT}`);
  });
}

main().catch((err) => {
  console.error('[FATAL] Error iniciando servidor:', err);
  process.exit(1);
});
