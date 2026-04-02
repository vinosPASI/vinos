# Guía de Flujo de Trabajo con Git

Esta guía detalla el flujo de trabajo estándar utilizando Git para el desarrollo en el proyecto. Su objetivo es mantener un historial limpio, trazable y atómico.

## 1. Crear la Rama de Trabajo

Las ramas deben ser creadas desde `main` (o la rama de desarrollo principal) y seguir la siguiente nomenclatura:

```bash
git checkout -b <tipo>/<ID-JIRA>-<descripcion-corta>
```

**Ejemplo:** `feat/VM-45-open-search-client` o `fix/VM-12-nil-pointer-csv`

## 2. Preparar Cambios (`add` y `rm`)

Antes de realizar un commit, los archivos deben agregarse al área de preparación (staging).

- Para agregar archivos creados o modificados:
  ```bash
  git add <archivo-o-directorio>
  ```
  *(Úsese `git add .` o `git add -A` con precaución, es preferible añadir archivos específicos).*

- Para eliminar archivos de Git:
  ```bash
  git rm <archivo>
  ```

## 3. Commits Atómicos y Mensajes

Se requiere el uso de [Conventional Commits](https://www.conventionalcommits.org/) y que, preferiblemente, cada commit represente un solo cambio funcional aislado (atómico).

La estructura del mensaje debe ser:
```
<tipo>(<alcance>): [<ID-JIRA>] <descripción en imperativo>
```

💡 **Sugerencia:** Si no estás seguro de cómo estructurar el mensaje, una buena práctica es **copiar el título del ticket de Jira** y adaptarlo para completar el tipo, alcance y descripción.

**Ejemplo:**
```bash
git commit -m "feat(vision): [VM-45] implement open search client for image matching"
```

## 4. Guardar Cambios Temporalmente (`stash`)

Si tienes cambios en tu directorio de trabajo que aún no están listos para un commit y necesitas cambiar de rama o realizar un pull, puedes guardar temporalmente el estado con `stash` incluyendo archivos no rastreados (`-u`):

```bash
git stash -u
```

Para recuperar y aplicar esos cambios guardados en el directorio de trabajo más adelante:

```bash
git stash pop
```

## 5. Corregir el Historial Local (`reset` y `squash`)

Si necesitas corregir algo en tus últimos commits **antes de subirlos al repositorio remoto**:

### Deshacer Commits (`git reset`)
Para deshacer los últimos `X` commits, manteniendo los archivos modificados en el área de trabajo (ideal para reorganizarlos en nuevos commits atómicos):
```bash
git reset HEAD~X
```
*(Cambia `X` por el número de commits que deseas retroceder).*

### Agrupar Commits (`squash` local)
Si hiciste múltiples commits pequeños (por ejemplo, "fix typo" o "wip") en tu rama y deseas unificarlos antes de crear el PR, puedes hacer un rebase interactivo:
```bash
git rebase -i HEAD~X
```
Luego, en el editor de texto que se abra, cambia `pick` por `squash` (o `s`) para fusionar los commits posteriores en el primero.

## 6. Subir la Rama y Crear un Pull Request (PR)

Una vez que los commits están listos en tu entorno local, sube la rama al repositorio remoto (GitHub):

```bash
git push -u origin <nombre-de-la-rama>
```

Luego, en GitHub, crea un **Pull Request (PR)** hacia la rama principal (`main`). Asegúrate de que el título del PR también siga la estructura de Conventional Commits y contenga el ID de Jira.

## 7. Revisión en GitHub

Los miembros del equipo revisarán el código en el PR. Durante este proceso, se pueden realizar comentarios y sugerir cambios. Si necesitas aplicar correcciones, simplemente realiza los cambios necesarios, haz nuevos commits en la misma rama local y ejecuta `git push`. El PR se actualizará automáticamente.

## 8. Integración: Squash & Merge

Una vez aprobado el Pull Request, el método de integración a la rama principal será **Squash & Merge**. 

Esto significa que, sin importar cuántos commits tenga la rama del PR, al momento de realizar el merge todos se condensarán ("squash") en un único commit atómico en `main`. El título de este commit final resultante deberá mantener la estructura requerida (incluyendo el ID de Jira) para mantener el historial de `main` completamente limpio, organizado y directo.
