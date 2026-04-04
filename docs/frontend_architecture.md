# Vinoteca - Frontend (App & Web)

## Visión General
El frontend de la Vinoteca es una plataforma multiplataforma de alta fidelidad desarrollada con **Flutter**. Esta aplicación actúa como la interfaz de inteligencia operativa, conectándose a un ecosistema de microservicios mediante **Envoy Proxy** y utilizando un contrato de comunicación de alto rendimiento.

El proyecto implementa una arquitectura **Feature-First** combinada con **Clean Architecture**, lo que permite un desarrollo modular, escalable y con una separación clara de responsabilidades.

## Stack Tecnológico

* **Framework:** Flutter 
* **Gestión de Estado:** Riverpod
* **Navegación:** GoRouter
* **Networking:** Dio + HTTP/2
* **Serialización:** Freezed / JSON Serializable
## Esquema de la Arquitectura

Para mantener la coherencia con el backend y facilitar el mantenimiento, el código se organiza siguiendo el estándar de **Clean Architecture** dentro de cada funcionalidad (**Feature**):

```text
lib/
├── core/                        # Componentes globales y transversales
│   ├── config/                  # Configuración de entorno (API Keys, Endpoints)
│   ├── constants/               # Constantes de UI, Strings y Assets
│   ├── network/                 # Cliente Dio + HTTP/2 Adapter + Interceptors
│   ├── theme/                   # Sistema de diseño (Colores, Tipografía)
│   └── utils/                   # Helpers y extensiones de Dart
│
├── features/                    # Módulos de negocio (DDD + Clean Arch)
│   └── example/                 # Estructura de referencia para nuevas funcionalidades
│       ├── data/                # CAPA DE DATOS (Implementación e Infraestructura)
│       │   ├── datasources/     # Consumo directo de la API (Remote) o Local
│       │   ├── models/          # DTOs (Data Transfer Objects) y Mappers
│       │   └── repositories/    # Implementación de los contratos del dominio
│       │
│       ├── domain/              # CAPA DE DOMINIO (Lógica Pura de Negocio)
│       │   ├── entities/        # Modelos de negocio inmutables
│       │   └── repositories/    # Interfaces y contratos del repositorio
│       │
│       └── presentation/        # CAPA DE PRESENTACIÓN (Interfaz de Usuario)
│           ├── providers/       # Gestión de estado reactivo (Riverpod Notifiers)
│           ├── screens/         # Vistas principales (Páginas completas)
│           └── widgets/         # Componentes visuales atómicos del módulo
│
├── router/                      # Gestión de Navegación
│   └── app_router.dart          # Mapa de rutas y Guards de seguridad
│
└── main.dart                    # Punto de entrada (ProviderScope e inicialización)
```
## Flujo de Datos (Data Flow)

La plataforma utiliza un flujo unidireccional para garantizar la integridad de la información:
1. **UI:** El usuario interactúa con un Widget en `presentation`.
2. **Provider:** Se dispara una acción en un Notifier de **Riverpod**.
3. **Repository:** El provider solicita datos al Repositorio (Domain), el cual delega la tarea a la implementación en (Data).
4. **Networking:** **Dio** realiza la petición vía **HTTP/2** a `api.stuko.dev`.
5. **Mapping:** Los datos regresan como `Models`, se transforman en `Entities` y actualizan el estado de la UI de forma reactiva.

## Reglas de Desarrollo

1. **Protocol Buffers & Contratos:**
   * Los modelos en `data/models/` deben ser un reflejo fiel de los contratos `.proto` del backend.
2. **Independencia de Módulos:**
   * Una funcionalidad (ej. `vision`) **no debe** importar componentes internos de otra (ej. `ingestion`). La comunicación debe ser mediante providers compartidos o interfaces en `core`.
3. **Generación de Código:**
   * Es obligatorio usar `build_runner` para mantener la seguridad de tipos en Riverpod y la serialización de datos.

## Convenciones de Commits
Seguimos el estándar de **Conventional Commits**:
* `feat:` Nueva funcionalidad.
* `fix:` Corrección de errores.
* `docs:` Cambios en documentación.
* `chore:` Tareas de mantenimiento o dependencias.
* `refactor:` Cambios en el código que no alteran la funcionalidad.