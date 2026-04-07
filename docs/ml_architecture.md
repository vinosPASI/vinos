# Vinoteca - Arquitectura del Motor de Machine Learning (ML Data Engine)

## Visión General
El motor de Machine Learning de la Vinoteca está diseñado como el núcleo de inteligencia operativa y analítica del sistema. Su función principal es transformar datos heterogéneos y no estructurados (archivos de inventario, remitos y listas de producción) en información accionable para el backend y el dashboard analítico.

La arquitectura se basa en el principio de **Data-Centric AI**, priorizando la calidad y consistencia del dato mediante pipelines de ingeniería antes de la aplicación de modelos predictivos.

## Stack Tecnológico
* **Lenguaje Principal:** Python 3.x.
* **Procesamiento de Datos:** Pandas y NumPy para manipulación de estructuras matriciales y series temporales.
* **Orquestación:** **Metaflow**, utilizado para definir flujos de trabajo (pipelines) reproducibles, escalables y con seguimiento de artefactos (versado de datos).
* **Modelado Predictivo:** Scikit-learn (Fuzzy Matching) y TensorFlow/PyTorch (Forecasting), integrados como pasos dentro de los flujos de Metaflow.
* **Análisis Geométrico/Visión:** OpenCV y Pillow para la identificación futura de etiquetas mediante reconocimiento de patrones.

---

## Flujo de Datos (ML Pipeline)
El procesamiento sigue un flujo unidireccional para garantizar la integridad de los resultados:

1. **Ingesta (Raw Data):** Captura de archivos fuente en formatos Excel/CSV desde orígenes externos.
2. **Normalización y Limpieza:** Estandarización de nomenclaturas (snake_case), corrección de formatos de fecha y tratamiento de valores nulos o inconsistentes.
3. **Cálculo de Disponibilidad (Engine):** Lógica de negocio para determinar el stock neto real mediante la conciliación de existencias físicas y compromisos de salida.
4. **Mapeo Inteligente (Fuzzy Matching):** Vinculación de entidades sin identificador único (códigos IF) basada en similitud semántica.
5. **Persistencia Analítica:** Carga de resultados en **StarRocks** (Esquema en Estrella) para su consumo por el backend en Go.

---

## Estructura del Directorio (`ml_engine/`)

El módulo de ML se mantiene independiente del resto del repositorio para permitir despliegues aislados y escalabilidad horizontal:

```text
ml_engine/
├── data/           # Repositorio de datos (Raw para origen, Interim para procesado).
├── src/            # CORE: Lógica de negocio y modelos aislados por responsabilidad.
│   ├── ingestion/  #   -> Componentes de extracción y limpieza.
│   ├── engine/     #   -> Lógica analítica de inventario y stock.
│   ├── models/     #   -> Algoritmos de IA (Fuzzy Matching, Forecasting).
│   └── analytics/  #   -> Contratos de datos y esquemas SQL.
├── flows/          # ORQUESTACIÓN: Flujos de Metaflow (inventory_flow.py, etc.).
├── docs/           # Documentación interna y reportes de estado técnicos.
└── notebooks/      # Laboratorio de experimentación y análisis exploratorio (EDA).
```

---

## Reglas de Desarrollo del Motor de ML

1. **Orquestación mediante Flujos (Metaflow First)**
   - No se deben ejecutar scripts de procesamiento de forma aislada para producción. Toda tarea debe estar contenida en un `FlowSpec` de Metaflow para garantizar la trazabilidad del linaje de datos.

2. **Modularidad y Funciones Puras**
   - La lógica de negocio debe residir en `src/` como funciones puras y verificables. El flujo (`flows/`) solo actúa como orquestador de estos componentes.

3. **Inmutabilidad de Datos Originales**
   - Nunca se deben sobreescribir o modificar los archivos en `data/raw/`. Todo resultado procesado debe guardarse en `data/interim/` o persistirse en la base de datos analítica.

4. **Idioma y Estándares de Código**
   - Siguiendo los lineamientos globales del proyecto, el código fuente (variables, funciones, clases) debe escribirse en **Inglés**. La documentación interna de este módulo puede mantenerse en español para facilitar la revisión del equipo local.
