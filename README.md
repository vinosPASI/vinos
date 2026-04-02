# Vinos
Proyecto para Programación Avanzada enfocado en la Automatización, Seguridad y Control de una vinoteca inteligente.

## Descripción
Este repositorio contiene el código fuente para la plataforma de inteligencia operativa. El sistema está compuesto por múltiples servicios interconectados diseñados para manejar escalabilidad, análisis de datos en tiempo real y flujos de trabajo basados en Inteligencia Artificial.

## Documentación
- [Arquitectura del Backend](docs/backend_architecture.md): Detalles profundos sobre la estructuración de la aplicación en dominios (Domain-Driven Design), la integración de comunicaciones con gRPC/Envoy y la infraestructura cloud.
- [Flujo de Trabajo con Git](docs/git_workflow.md): Guía estándar de Git detallando nomenclatura de ramas, commits atómicos, uso de stash pop, resets, squash local, y directrices para crear y revisar Pull Requests hasta el Squash & Merge.

## Stack Tecnológico Resumido
El proyecto hace uso de tecnología moderna cloud-native:
- **Lenguaje:** Go (Golang)
- **APIs y Comunicación:** Envoy Proxy, gRPC, Protocol Buffers, REST
- **Bases de Datos:** PostgreSQL (Transaccional), StarRocks (Analítico)
- **Infraestructura:** Docker, Kubernetes (Oracle OKE), CI/CD con GitHub Actions

## Reglas de Desarrollo

### Lineamientos Generales del Proyecto
- **Idioma Oficial (Inglés):** Absolutamente todo el código fuente (variables, métodos, clases, comentarios) debe escribirse en **Inglés**.
- **Jira en Inglés:** Los títulos y descripciones de los tickets de Jira deben redactarse en **Inglés**.
- **Frontend (Flutter):** Actualmente en fase de definición inicial. Arquitectura y paquetes a utilizar pendientes de confirmación.
- **Machine Learning (ML):** Repositorio y herramientas aún en evaluación. La definición de la arquitectura de modelos y el stack de extracción de características están pendientes.
- **Backend (Go):** Sigue estrictamente principios de Clean Architecture y DDD. Revisa el [Documento de Arquitectura](docs/backend_architecture.md) para conocer las reglas de contratos y aislamiento de dominios.

### Guía de Conventional Commits y Jira

Para mantener un historial limpio y autogenerar bitácoras de cambios, todo el equipo debe seguir estrictamente [Conventional Commits](https://www.conventionalcommits.org/). La estructura obligatoria de un mensaje de commit es:

`tipo(ámbito opcional): [ID-JIRA] descripción corta en minúsculas y en inglés`

#### Tipos de Commits Permitidos (`tipo`)
- `feat`: Añade una nueva funcionalidad (feature).
- `fix`: Corrige un error (bug).
- `docs`: Cambios exclusivos en manuales o documentación (ej. README).
- `style`: Cambios de formato (espacios, punto y coma, identación) que no afectan la lógica.
- `refactor`: Modificación de código que no arregla un error ni añade funcionalidad.
- `perf`: Ajustes que mejoran el rendimiento de la aplicación.
- `test`: Añade o corrige pruebas automatizadas.
- `chore`: Tareas de mantenimiento (actualizar dependencias, scripts de build).

#### Ejemplos Correctos
- `feat(vision): [VIN-45] implement open search client for image matching`
- `fix(ingestion): [VIN-12] resolve nil pointer exception on empty csv rows`
- `docs: [VIN-99] update architecture diagrams`
- `chore(deps): [VIN-10] bump grpc-go to v1.62.0`

#### Reglas para Pull Requests (PRs)
1. Antes de hacer merge, los commits se deben hacer `Squash`. El título del Squash Commit debe seguir esta misma convención para que el historial en la rama `main` quede completamente estructurado.
2. El Pull Request debe abrirse utilizando la convención de `Conventional Commits` en el título.
