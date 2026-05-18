# SmartWinery - Arquitectura del Backend

## Visión General

El backend de SmartWinery ha sido **migrado** de una arquitectura Go/gRPC/Envoy a un monolito **Node.js Express** KISS. El sistema mantiene todas las rutas HTTP existentes (`/v1/*`), lo que permite migrar el frontend Flutter **sin tocar ni una línea de código**.

### Stack Tecnológico

| Aspecto | Antes (Go/gRPC/Envoy) | Después (Node.js Express) |
|---------|----------------------|---------------------------|
| Lenguaje | Go (compilado estáticamente) | JavaScript (Node.js 20) |
| Protocolo | gRPC + HTTP/2 | HTTP/1.1 + JSON nativo |
| API Gateway | Envoy Proxy (gRPC-JSON transcoding) | Express (rutas directas) |
| IDL | 6 archivos `.proto` | Contratos en código JS |
| Puerto expuesto | Envoy `:8080` → Go `:50051` | Express `:8080` directo |
| Documentación | Swagger generado desde `.proto` | Contratos en código |
| CORS | Configurado en `envoy.yaml` | Middleware `cors` npm |
| Auth | Interceptor gRPC `auth.go` | Middleware Express `auth.js` |
| Logging | Logger Zap estructurado | `console.log` |

---

## Lo que se Eliminó

| Componente | Archivos/Directorios | Razón |
|-----------|---------------------|-------|
| **Envoy Gateway** | `build/envoy/`, servicio `envoy` en compose | gRPC-JSON transcoding innecesario |
| **Protobuf IDL** | `api/proto/`, `google/`, `third_party/` | JSON nativo, contratos en código |
| **Código gRPC Go** | `cmd/server/`, `internal/*/handler_grpc.go` | Reemplazado por Express routes |
| **Interceptors gRPC** | `pkg/interceptors/` | Middleware Express estándar |
| **Logger Zap** | `pkg/logger/` | `console.log` |
| **PocketBase client Go** | `pkg/db/pocketbase.js` | `fetch` nativo en JS |
| **MinIO adapter Go** | `internal/storage/minio_adapter.go` | Paquete `minio` npm |
| **Elasticsearch** | Servicio en compose | No se usaba activamente |
| **Dockerfile Go** | `build/package/Dockerfile.backend` | Reemplazado por Dockerfile Node |
| **`go.mod`, `go.sum`** | Raíz backend | `package.json` |

---

## Lo que se Portó (Lógica de Negocio 1:1)

| Módulo Go Original | → Módulo JS Nuevo | Lógica Portada |
|-------------------|-------------------|----------------|
| `internal/identity/service.go` | `src/routes/identity.js` | Login/Register via PocketBase HTTP |
| `internal/inventory/service.go` | `src/routes/inventory.js` | CRUD + movimientos con validación de stock |
| `internal/dashboard/service.go` | `src/routes/dashboard.js` | Stats hardcodeados coherentes con CSVs |
| `internal/vision/ml_client.go` | `src/services/mlClient.js` | Llamadas a Ollama OpenAI-compatible |
| `internal/vision/service.go` | `src/routes/vision.js` | Orquestación: MinIO → base64 → LLM |
| `internal/ingestion/handler_grpc.go` | `src/routes/ingestion.js` | Download CSV de MinIO → parse → PB |
| `internal/ingestion/csv_parser.go` | `src/services/csvParser.js` | Parsers para insumos, lotes, movimientos |
| `internal/production/handler_grpc.go` | `src/routes/production.js` | Stub de orden de embotellado |
| `internal/storage/` | `src/routes/storage.js` | Upload multipart → MinIO |
| `internal/vision/mocks.go` | `src/services/mocks.js` | Datos mock secuenciales |
| `pkg/db/pocketbase.go` | `src/services/pocketbase.js` | Cliente HTTP completo para PocketBase |
| `internal/storage/minio_adapter.go` | `src/services/minio.js` | Adaptador MinIO S3 |
| `pkg/interceptors/auth.go` | `src/middleware/auth.js` | JWT validation via PocketBase |
| `pkg/interceptors/recovery.go` | `src/middleware/errorHandler.js` | Error handler global |

---

## Lo que se Creó

### Estructura del Nuevo Backend

```text
backend/
├── package.json              # Dependencias: express, cors, multer, minio, csv-parse, dotenv
├── .env.example              # Variables de entorno documentadas
├── Dockerfile                # Node.js 20 Alpine
├── src/
│   ├── index.js              # Entrypoint: Express app, middleware, routes
│   ├── middleware/
│   │   ├── auth.js           # JWT validation via PocketBase
│   │   └── errorHandler.js   # Global error handler
│   ├── services/
│   │   ├── pocketbase.js     # PocketBase HTTP client
│   │   ├── minio.js          # MinIO S3 adapter
│   │   ├── mlClient.js       # Ollama client (OpenAI-compatible)
│   │   ├── csvParser.js      # CSV parsing (csv-parse npm)
│   │   └── mocks.js          # Mock data secuencial
│   └── routes/
│       ├── identity.js       # POST /v1/identity/login, /register
│       ├── inventory.js      # CRUD /v1/inventory/*
│       ├── dashboard.js      # GET/POST /v1/dashboard/*
│       ├── vision.js         # POST /v1/vision/analyze
│       ├── ingestion.js      # POST /v1/ingestion/import
│       ├── production.js     # POST /v1/production/bottling-order
│       └── storage.js        # POST /v1/storage/upload
└── deploy/docker/
    ├── docker-compose.yml    # Backend + PocketBase + MinIO + Cloudflare
    └── .env
```

### Archivos Nuevos (15 archivos JS)

| Archivo | Descripción |
|---------|-------------|
| `src/index.js` | Entry point Express, inicializa servicios, monta middleware y rutas |
| `src/middleware/auth.js` | Valida JWT via PocketBase `/api/collections/users/auth-refresh` |
| `src/middleware/errorHandler.js` | Handler global de errores, formatea JSON de respuesta |
| `src/services/pocketbase.js` | Cliente HTTP completo: auth, CRUD, list, create, update, delete |
| `src/services/minio.js` | Adaptador MinIO: ensureBucket, uploadFile, downloadFile |
| `src/services/mlClient.js` | Cliente Ollama: analyzeLabel, structureDataVisionLLM, getSommelierRecommendation |
| `src/services/csvParser.js` | Parsers CSV: insumos, lotes, movimientos, productos terminados |
| `src/services/mocks.js` | 12 resultados secuenciales de vinos para testing |
| `src/routes/identity.js` | Login + Register via PocketBase |
| `src/routes/inventory.js` | CRUD completo + RecordMovement con validación de stock |
| `src/routes/dashboard.js` | KPIs hardcodeados (stats, holdings, market, alerts) |
| `src/routes/vision.js` | Análisis de etiquetas con IA + endpoint mock |
| `src/routes/ingestion.js` | Import CSV desde MinIO → PocketBase |
| `src/routes/production.js` | Stub de orden de embotellado |
| `src/routes/storage.js` | Upload multipart a MinIO |

---

## Flujo de Comunicación (Antes vs Después)

### Antes (Go + Envoy)

```
Flutter Web/Mobile
    ↓ HTTP/JSON :8080
Envoy Gateway (gRPC-JSON transcoding)
    ↓ gRPC :50051
Go Backend (gRPC handlers)
    ↓ HTTP
PocketBase (Auth + DB)
    ↓ S3 API
MinIO (Storage)
    ↓ HTTP
Ollama (ML)
```

### Después (Node.js Express)

```
Flutter Web/Mobile
    ↓ HTTP/JSON :8080
Node.js Express (rutas directas)
    ↓ HTTP
PocketBase (Auth + DB)
    ↓ S3 API
MinIO (Storage)
    ↓ HTTP
Ollama (ML)
```

**Reducción: 5 saltos → 3 saltos. Sin gRPC, sin Envoy, sin transcodificación.**

---

## Endpoints Mantenidos

> **Se mantienen TODAS las rutas exactas** que el frontend Flutter ya consume.

| Dominio | Método | Ruta HTTP |
|---------|--------|-----------|
| Identity | POST | `/v1/identity/login` |
| Identity | POST | `/v1/identity/register` |
| Inventory | POST | `/v1/inventory/list` |
| Inventory | GET | `/v1/inventory/:id` |
| Inventory | POST | `/v1/inventory` |
| Inventory | PUT | `/v1/inventory/:id` |
| Inventory | DELETE | `/v1/inventory/:id` |
| Inventory | POST | `/v1/inventory/movement` |
| Dashboard | GET | `/v1/dashboard/stats` |
| Dashboard | POST | `/v1/dashboard/high-value-holdings` |
| Dashboard | POST | `/v1/dashboard/market-exposure` |
| Dashboard | POST | `/v1/dashboard/forecasting-feed` |
| Vision | POST | `/v1/vision/analyze` |
| Vision | POST | `/v1/vision/analyze/mock` |
| Ingestion | POST | `/v1/ingestion/import` |
| Production | POST | `/v1/production/bottling-order` |
| Storage | POST | `/v1/storage/upload` |
| Health | GET | `/healthz` |

---

## Cambios en Docker Compose

### Servicios Eliminados
- `envoy` — API Gateway con gRPC-JSON transcoding
- `elasticsearch` — No se usaba activamente
- `backend` Go — Reemplazado por Node.js

### Servicios Modificados
- `backend` — Ahora es Node.js Express (puerto 8080)
- `cloudflared` — Apunta a `backend:8080` directamente (antes apuntaba a `envoy`)

### Servicios Mantenidos
- `pocketbase` — Sin cambios (puerto 8090)
- `minio` — Sin cambios (puertos 9000, 9001)

### Compose Simplificado
```yaml
# Antes: 5 servicios (backend, pocketbase, minio, elasticsearch, envoy) + cloudflared
# Después: 4 servicios (backend, pocketbase, minio) + cloudflared
```

---

## Decisiones de Diseño

### 1. Puerto 8080
El frontend Flutter apunta a `localhost:8080`. El nuevo backend Node.js escucha en el mismo puerto que Envoy, eliminando la necesidad de cambiar `baseUrl` en el frontend.

### 2. CORS Explícito
Se configura CORS explícitamente con `app.options('*', cors())` para manejar peticiones preflight, y el middleware de auth no intercepta peticiones OPTIONS.

### 3. Auth Middleware
- Lista blanca de rutas públicas (`/v1/identity/login`, `/healthz`)
- Extrae `Authorization: Bearer <token>`
- Valida contra PocketBase `auth-refresh`
- Inyecta `req.userId` y `req.userRole`

### 4. ML Client
- Usa `http`/`https` nativo de Node.js (sin dependencias externas)
- Timeout de 300s para llamadas a Ollama
- Misma lógica de fallback a `N/A` que el Go original
- Extracción de JSON con regex (igual que el Go)

### 5. PocketBase Client
- Usa `fetch` nativo de Node.js
- Misma interfaz que el Go original: `authAdmin`, `authUser`, `validateToken`, CRUD operations

---

## Verificación

### Health Check
```bash
curl http://localhost:8080/healthz
# → OK
```

### CORS Preflight
```bash
curl -X OPTIONS http://localhost:8080/v1/identity/login \
  -H "Origin: http://localhost:5555" \
  -H "Access-Control-Request-Method: POST"
# → 204 No Content
```

### Frontend Flutter
1. Verificar que el frontend apunta a `localhost:8080`
2. Probar login → inventario → subir imagen → analizar
3. Verificar que no hay errores CORS en consola del navegador

---

## Pendiente

- [ ] Detener viejo stack Docker (ya completado)
- [ ] Verificar funcionamiento completo del frontend con el nuevo backend
- [ ] Probar todos los endpoints con curl
- [ ] Verificar upload de archivos a MinIO
- [ ] Probar análisis de etiquetas con Ollama
