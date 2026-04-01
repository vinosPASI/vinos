# Vinoteca - Arquitectura del Backend

## Visión General
El backend de la vinoteca está diseñado para ser una plataforma de inteligencia operativa escalable. Utiliza **Clean Architecture** y **Domain-Driven Design** para aislar la lógica de negocio de la infraestructura subyacente. 

El sistema está orquestado para desplegarse mediante **Docker Compose** y automatizado mediante prácticas de **GitOps** con GitHub Actions (deploy vía SSH).

### Core y Desarrollo
* **Lenguaje Principal:** Go (Golang) compilado estáticamente.
* **Inteligencia Artificial (ML):** Python (Repositorio o servicio separado).
* **Comunicación Interna y Externa:** gRPC y HTTP/3 (vía Envoy Proxy).
* **Proxy / API Gateway:** Envoy Proxy, encargado de recibir peticiones HTTP/REST desde los clientes (como aplicaciones móviles o web) y transcodificarlas a gRPC al vuelo de manera transparente.
* **Documentación API:** Swagger/OpenAPI (generado automáticamente a partir de los `.proto`).

### Almacenamiento y Datos
* **Base de Datos Relacional:** PocketBase (Contenedor local) para el modelo transaccional.
* **Base de Datos Analítica:** StarRocks para consultas OLAP/analíticas de alto rendimiento.
* **Almacenamiento (Data Lake):** MinIO (Data Lake local) para subida de archivos, documentos e imágenes.
* **Búsqueda / Conciliación:** OpenSearch (Elasticsearch compatible).

### Infraestructura, Contenedores y CI/CD
* **Contenedores:** Docker (imágenes ligeras basadas en Alpine Linux).
* **Orquestador:** Docker Compose para despliegues locales y entornos.
* **CI/CD:** GitHub Actions para integración continua (pruebas, linters, compilación de protobuf) y un flujo de Continuous Deployment hacia GHCR y deploy vía SSH.

---

## Flujo de Comunicación (Data Flow)
Para mantener latencias bajas y contratos estrictos, la plataforma utiliza gRPC en el centro:
1. **Frontend a Edge:** El cliente (Web/App) envía peticiones REST/JSON estándar o sube archivos a `api.stuko.dev`.
2. **Edge a Backend:** **Envoy Proxy** intercepta el tráfico, realiza la transcodificación de JSON a gRPC binario y enruta la petición al microservicio correspondiente en Go.
3. **Backend a ML:** Si la petición requiere inteligencia artificial (ej. procesar una imagen o generar un pronóstico), el servicio de Go actúa como cliente gRPC y consulta al microservicio de Python, obteniendo una respuesta en milisegundos.

---

## Estructura del Directorio

El repositorio sigue un estándar modular basado en las convenciones de Go para separar claramente las responsabilidades:

```text
backend/
├── .github/        # Integración y Despliegue Continuo (CI/CD) usando Actions (GHCR y SSH).
├── api/            # La "fuente de la verdad". Contratos gRPC (.proto) y Swagger generado.
├── build/          # Empaquetado (Dockerfiles) y configuración del proxy Envoy (envoy.yaml).
├── cmd/            # Punto de entrada de la aplicación. Inicializa el servidor y dependencias.
├── deploy/         # Infraestructura vía docker-compose.yml para levantar el entorno completo.
├── internal/       # CORE de la aplicación. Lógica de negocio aislada por dominios (DDD).
│   ├── identity/   #   -> Gestión de usuarios, roles y autenticación (JWT).
│   ├── storage/    #   -> Cliente MinIO local para subida masiva de archivos al Data Lake.
│   ├── ingestion/  #   -> Módulo 1: ETL, limpieza de datos y normalización de CSVs.
│   ├── production/ #   -> Módulo 2: Orquestador predictivo de inventario y embotellado.
│   └── vision/     #   -> Módulo 3: Análisis de etiquetas e imágenes mediante IA.
└── pkg/            # Utilidades transversales (Conexión a BD local PocketBase, logs estructurados).
```

## Reglas de Desarrollo Backend

1. **Protocol Buffers como "Fuente de la Verdad" (Contratos First)**
   - Todo nuevo servicio, endpoint o modelo de transporte debe declararse **primero** en un archivo `.proto` en la carpeta `api/proto/`.
   - La documentación de la API y el gateway (Envoy) se basan estrictamente en estos archivos. Los contratos son inmutables dentro de una misma versión (`v1`).

2. **Aislamiento de Responsabilidades (Clean Architecture)**
   - **Handlers/Controllers (`handler_grpc.go`):** Solo validan parámetros de entrada, llaman al servicio de dominio correspondiente y devuelven la respuesta formateada. **Rechazan cualquier lógica de negocio.**
   - **Lógica de Dominio (`service.go`):** Lógica pura. No tienen contexto web, ni saben qué es gRPC, ni conocen detalles de SQL. Solamente implementan las reglas del negocio.
   - **Repositorios/Adaptadores (`repository.go`):** Implementan las interfaces esperadas por el dominio. Son los únicos que conocen de PocketBase, MinIO o llamadas a APIs externas.

3. **Independencia de Módulos (DDD - Bounded Contexts)**
   - Un dominio de negocio (ej. `internal/ingestion/`) **no debe** importar directamente implementaciones internas de otro dominio (ej. `internal/production/`).
   - La comunicación entre dominios se debe realizar por interfaces bien definidas que eviten el acoplamiento estrecho.