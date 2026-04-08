# Arquitectura Frontend Flutter: Feature-First (Basada en Características)

Este documento define la estructura y el flujo de trabajo para el desarrollo del frontend de la Vinoteca en Flutter Web. Se ha elegido el patrón **Feature-First** para asegurar que el código sea escalable, testeable e independiente de las dependencias externas.

---

## 1. El Concepto de "Feature"
Cada funcionalidad importante del sistema (ej: `inventory`, `dashboard`, `auth`) tendrá su propia carpeta independiente. Dentro de cada "feature", el código se divide en tres capas fundamentales:

### A. Capa de Data (Datos)
*   **Repositories:** Define la implementación real de cómo se obtienen los datos.
*   **Data Sources:** La conexión directa con el backend o bases de datos (ej: llamando a gRPC o REST).
*   **Models:** Objetos de datos con lógica de conversión (ej: `fromJson`).

### B. Capa de Domain (Dominio)
*   **Entities:** Objetos de datos puros; solo contienen lo que el negocio necesita sin importar de dónde vienen los datos.
*   **Use Cases:** (Opcional) La lógica de negocio pura que conecta los datos con la interfaz.

### C. Capa de Presentation (Presentación)
*   **Screens:** Las pantallas completas que ve el usuario.
*   **Widgets:** Componentes pequeños y reutilizables específicos de esa funcionalidad.
*   **Controllers / Providers (State Management):** El cerebro que maneja el estado de la pantalla (ej: usando Riverpod o BLoC).

---

## 2. Estructura de Carpetas (lib/src/)

```
lib/
└── src/
    ├── app/                # Configuración global del App (Router, Tema)
    ├── shared/             # Widgets y utilerías que se usan en todo el proyecto
    └── features/           # Aquí vive la inteligencia por módulos
        ├── dashboard/      # Ejemplo: Módulo de Estadísticas
        └── inventory/      # Ejemplo: Módulo de Gestión de Stock
```

---

## 3. Beneficios Técnicos
1.  **Aislamiento:** Si algo falla en el 'dashboard', no afectará al 'inventario'.
2.  **Scalability:** Es muy fácil añadir nuevas funcionalidades sin embarrar el código existente.
3.  **Team Ready:** Múltiples desarrolladores pueden trabajar en diferentes módulos al mismo tiempo sin conflictos de Git.

---
**Guía de Estilo aplicada:** Clean Code, Tipado fuerte y Naming en inglés para todo el código fuente.