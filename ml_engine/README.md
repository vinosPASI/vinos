# Motor de Inteligencia de Vinos (ML Data Engine) 

Este es el núcleo de inteligencia de datos de la Vinoteca. Su función es procesar inventarios complejos, limpiar datos ruidosos y preparar datasets listos para el análisis y modelos de Machine Learning.

## Guía de Operación (Cómo usar este motor)

Si quieres actualizar los datos del inventario inteligente, sigue estos pasos:

### 1. Preparar los Datos (Insumos)
Coloca los archivos Excel originales en la carpeta `ml_engine/data/raw/`. Los archivos **DEBEN** tener exactamente estos nombres para que el motor los reconozca:
- `INSUMOS SECOS.xlsx`
- `VESTIDO Y SV.xlsx`
- `Insumos Comprometidos.xlsx`
- `PENDIENTES.xlsx`
- `REMITIDOS.xlsx`

### 2. Ejecutar el Flujo de Datos (Metaflow)
Abre una terminal en la carpeta `ml_engine` y ejecuta el siguiente comando:
```bash
python flows/inventory_flow.py run
```
Este comando activará el pipeline que carga, limpia, estandariza fechas y calcula el stock neto automáticamente.

### 3. Recoger Resultados
Los datos limpios y procesados se guardarán automáticamente en la carpeta `ml_engine/data/interim/` en formato CSV. Estos son los archivos que el equipo de **Backend** debe utilizar.

---

## Estructura Técnica
- **`src/`**: Contiene la lógica modular (ingesta y motor de cálculo).
- **`flows/`**: Orquestación con Metaflow.
- **`docs/`**: Documentación interna y reportes de estado.
- **`notebooks/`**: Espacio de experimentación para nuevos modelos de IA.

## Próximas Funcionalidades (Roadmap)
1. **Fuzzy Matching**: Algoritmo para vincular automáticamente nombres de vinos con códigos `IF`.
2. **Forecasting**: Modelo de predicción de quiebre de stock basado en remitos históricos.
3. **Image Vision**: Reconocimiento de etiquetas mediante fotos.

---
**Encargado del ML Engine:** Ángel (Tester-ML)
