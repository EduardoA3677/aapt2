# GitHub Actions Workflows

Este directorio contiene los workflows de GitHub Actions para automatizar la compilación y distribución de AAPT2.

## Workflows Disponibles

### 1. Build and Release (`build-and-release.yml`)

**Propósito**: Compila AAPT2 para múltiples plataformas y crea releases automáticos.

**Triggers**:
- Push de tags con formato `v*` (ej: `v1.0.0`, `v2.1.3`)
- Ejecución manual (workflow_dispatch)

**Plataformas**:
- Linux (Ubuntu latest)
- macOS (latest)

**Proceso**:
1. **Preparación del entorno**
   - Libera espacio en disco usando `jlumbroso/free-disk-space`
   - Instala dependencias de compilación
   - Verifica herramientas instaladas

2. **Clonación de código fuente**
   - Clona `platform/frameworks/base` desde android.googlesource.com
   - Usa sparse checkout para clonar solo archivos necesarios
   - Tag: `android-16.0.0_r4`

3. **Compilación**
   - Genera CMakeLists.txt
   - Compila con CMake y Make
   - Genera binarios: aapt2, aapt2_64, aapt, aapt_64

4. **Empaquetado**
   - Reduce tamaño con strip
   - Empaqueta en tar.gz por plataforma
   - Sube como artefactos

5. **Release**
   - Descarga artefactos de todas las plataformas
   - Crea release en GitHub
   - Sube binarios al release
   - Genera notas de release automáticas

**Uso Manual**:
```bash
# Desde la UI de GitHub:
# Actions → Build and Release → Run workflow
# Especificar tag (ej: v1.0.0)
```

**Uso Automático**:
```bash
# Crear y push de tag
git tag v1.0.0
git push origin v1.0.0
```

**Artefactos Generados**:
- `aapt2-linux-x64.tar.gz` - Binarios para Linux
- `aapt2-macos-x64.tar.gz` - Binarios para macOS

### 2. Test Build (`test-build.yml`)

**Propósito**: Valida que los scripts y configuración funcionen correctamente.

**Triggers**:
- Pull requests a main/master/develop
- Push a main/master/develop

**Proceso**:
1. Verifica que los scripts sean ejecutables
2. Prueba el Makefile
3. Valida instalación de dependencias
4. Prueba configuración de sparse checkout

**No compila binarios** - Solo valida la configuración.

## Uso de los Workflows

### Crear un Release

#### Opción 1: Con tag (Recomendado)

```bash
# 1. Asegúrate de estar en la rama correcta
git checkout main

# 2. Crea un tag versionado
git tag -a v1.0.0 -m "Release version 1.0.0"

# 3. Push del tag
git push origin v1.0.0

# 4. El workflow se ejecutará automáticamente
# Monitorea el progreso en Actions → Build and Release
```

#### Opción 2: Manual desde GitHub UI

1. Ve a **Actions** en el repositorio
2. Selecciona **Build and Release**
3. Click en **Run workflow**
4. Especifica el tag (ej: `v1.0.0`)
5. Click **Run workflow**

### Verificar Builds en PR

Los PRs ejecutan automáticamente el workflow `test-build.yml`:

1. Crea un PR
2. Ve a la pestaña **Checks**
3. Revisa el resultado de **Test Build**

## Configuración de Dependencias

### Linux (Ubuntu)

El workflow instala automáticamente:
- build-essential
- cmake
- ninja-build
- pkg-config
- protobuf-compiler
- libprotobuf-dev
- zlib1g-dev
- libpng-dev
- libexpat1-dev

### macOS

El workflow instala vía Homebrew:
- cmake
- ninja
- pkg-config
- protobuf
- libpng
- expat

## Limpieza de Espacio

El workflow usa `jlumbroso/free-disk-space` para:
- Limpiar tool cache
- Remover Android SDK (no necesario)
- Remover .NET runtime
- Remover Haskell
- Remover paquetes grandes
- Remover imágenes Docker
- Limpiar swap

Esto libera ~30-40 GB de espacio en el runner.

## Estructura de Jobs

### build-linux
1. Checkout código
2. Limpiar espacio
3. Instalar dependencias
4. Clonar Android source
5. Compilar
6. Empaquetar
7. Subir artefactos
8. Limpiar

### build-macos
1. Checkout código
2. Instalar dependencias (Homebrew)
3. Clonar Android source
4. Compilar
5. Empaquetar
6. Subir artefactos
7. Limpiar

### create-release
1. Descargar todos los artefactos
2. Generar notas de release
3. Crear release en GitHub
4. Subir binarios
5. Limpiar

## Personalización

### Cambiar la versión de Android

Edita ambos workflows y cambia:
```yaml
git fetch --depth 1 origin tag android-16.0.0_r4
```

Por la versión deseada, ej:
```yaml
git fetch --depth 1 origin tag android-16.0.0_r5
```

### Agregar más plataformas

Para agregar Windows:

```yaml
build-windows:
  runs-on: windows-latest
  steps:
    - uses: actions/checkout@v4
    - name: Install dependencies
      run: |
        choco install cmake ninja protobuf
    # ... resto de pasos
```

### Modificar paths de sparse checkout

Edita la sección:
```yaml
cat > .git/info/sparse-checkout << 'EOF'
/tools/aapt2/
/tools/aapt/
# Agregar más paths aquí
EOF
```

## Troubleshooting

### Error: Cannot access android.googlesource.com

**Causa**: GitHub runners no pueden acceder al dominio.

**Solución**:
1. Usar un mirror
2. Pre-empaquetar el código fuente
3. Usar submodules de Git

### Error: Out of disk space

**Causa**: Compilación requiere mucho espacio.

**Solución**: El workflow ya usa `free-disk-space`. Si persiste:
```yaml
- name: Free even more space
  run: |
    sudo rm -rf /usr/share/dotnet
    sudo rm -rf /opt/ghc
    sudo rm -rf /usr/local/share/boost
```

### Error: Build fails

**Causa**: Dependencias faltantes o errores de compilación.

**Solución**:
1. Revisa los logs del workflow
2. Prueba localmente: `./clone_and_build.sh`
3. Verifica CMakeLists.txt

### Error: Release creation fails

**Causa**: Permisos o artefactos faltantes.

**Solución**:
1. Verifica que el token GITHUB_TOKEN tenga permisos
2. Settings → Actions → General → Workflow permissions → Read and write

## Mejores Prácticas

### Versionado

Usar Semantic Versioning:
- `v1.0.0` - Release mayor
- `v1.1.0` - Nuevas características
- `v1.1.1` - Bug fixes

### Testing

Antes de crear un release:
1. Crear PR con cambios
2. Esperar que pase `test-build.yml`
3. Merge a main
4. Crear tag para release

### Release Notes

Las notas se generan automáticamente pero puedes personalizarlas:
1. Edita el step `Generate release notes`
2. Modifica el template en `release_notes.md`

### Artifacts Retention

Los artefactos se guardan 7 días. Para cambiar:
```yaml
retention-days: 30  # Guardar 30 días
```

## Monitoreo

### Ver progreso

1. GitHub → Actions
2. Selecciona el workflow en ejecución
3. Click en el job para ver logs en tiempo real

### Descargar artefactos

1. GitHub → Actions
2. Selecciona workflow completado
3. Scroll hasta **Artifacts**
4. Download ZIP

### Notificaciones

GitHub envía notificaciones por:
- Email (configurable en Settings)
- Notificaciones web
- GitHub Mobile

## Seguridad

### Secrets

El workflow usa:
- `GITHUB_TOKEN` - Provisto automáticamente por GitHub
- No se requieren secrets adicionales

### Permisos

Requeridos:
- `contents: write` - Para crear releases
- `actions: read` - Para leer artefactos

### Code Scanning

Considera agregar:
```yaml
- name: Run CodeQL
  uses: github/codeql-action/analyze@v2
```

## Referencias

- [GitHub Actions Documentation](https://docs.github.com/actions)
- [Workflow Syntax](https://docs.github.com/actions/reference/workflow-syntax-for-github-actions)
- [Free Disk Space Action](https://github.com/jlumbroso/free-disk-space)
- [Upload Artifact](https://github.com/actions/upload-artifact)
- [Download Artifact](https://github.com/actions/download-artifact)
- [Create Release](https://github.com/softprops/action-gh-release)

## Preguntas Frecuentes

**P: ¿Cuánto tiempo toma la compilación?**
R: ~20-30 minutos por plataforma (Linux, macOS)

**P: ¿Puedo compilar solo para una plataforma?**
R: Sí, edita `needs: [build-linux, build-macos]` en el job `create-release`

**P: ¿Cómo descargo un release?**
R: GitHub → Releases → Selecciona versión → Download Assets

**P: ¿Puedo ejecutar el workflow localmente?**
R: Sí, usa [act](https://github.com/nektos/act) o ejecuta `./clone_and_build.sh`

**P: ¿Qué pasa si falla la compilación?**
R: El workflow se detiene, no se crea el release. Revisa los logs y corrige.
