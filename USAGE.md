# Guía de Uso - AAPT2 Build System

## Uso Local (Manual)

### Compilación Completa

La forma más sencilla de compilar AAPT2 localmente:

```bash
# 1. Clonar este repositorio
git clone https://github.com/EduardoA3677/aapt2.git
cd aapt2

# 2. Ejecutar el script automatizado
./clone_and_build.sh
```

El script hará todo automáticamente:
- Clonar el código fuente de Android (solo archivos necesarios)
- Verificar dependencias
- Compilar los binarios
- Generar: aapt2, aapt2_64, aapt, aapt_64

### Usando Makefile

Para un control más granular:

```bash
# Ver ayuda
make help

# Instalar dependencias
make deps

# Clonar fuentes
make clone

# Compilar
make all

# Ver estado
make status

# Instalar en el sistema
sudo make install

# Limpiar
make clean
```

### Verificar Binarios

Después de compilar:

```bash
# Ejecutar verificación automática
./verify_build.sh

# O manualmente
cd build
./aapt2 version
./aapt version
```

## Uso con GitHub Actions

### Crear un Release Automático

#### Método 1: Tag con Git (Recomendado)

```bash
# 1. Asegúrate de estar en main/master
git checkout main
git pull

# 2. Crea un tag versionado
git tag v1.0.0 -m "Release 1.0.0 - AAPT2 binaries"

# 3. Push el tag
git push origin v1.0.0

# 4. GitHub Actions compilará y creará el release automáticamente
```

Puedes monitorear el progreso en:
- https://github.com/EduardoA3677/aapt2/actions

#### Método 2: Manual desde GitHub UI

1. Ve a: https://github.com/EduardoA3677/aapt2/actions
2. Selecciona **"Build and Release AAPT2"**
3. Click **"Run workflow"** (botón a la derecha)
4. Selecciona la rama (main)
5. Ingresa el tag (ej: `v1.0.0`)
6. Click **"Run workflow"**

El workflow se ejecutará y:
- Compilará para Linux
- Compilará para macOS
- Creará un release en GitHub
- Subirá los binarios comprimidos

### Descargar Binarios Pre-compilados

Una vez que el release esté creado:

```bash
# Ver releases disponibles
https://github.com/EduardoA3677/aapt2/releases

# Descargar para Linux
wget https://github.com/EduardoA3677/aapt2/releases/download/v1.0.0/aapt2-linux-x64.tar.gz

# Descargar para macOS
wget https://github.com/EduardoA3677/aapt2/releases/download/v1.0.0/aapt2-macos-x64.tar.gz

# Extraer
tar -xzf aapt2-linux-x64.tar.gz

# Usar
./aapt2 version
```

## Ejemplos de Uso de AAPT2

### Compilar Recursos

```bash
# Compilar un archivo XML
aapt2 compile -o compiled/ res/values/strings.xml

# Compilar todos los recursos
aapt2 compile --dir res -o compiled.zip

# Con opciones
aapt2 compile \
    --dir res \
    -o compiled.zip \
    -v  # verbose
```

### Crear APK

```bash
# Link de recursos compilados
aapt2 link \
    -o output.apk \
    -I android.jar \
    --manifest AndroidManifest.xml \
    compiled/*.flat

# Con múltiples opciones
aapt2 link \
    --proto-format \
    -o app.apk \
    -I android.jar \
    --manifest AndroidManifest.xml \
    --java gen/ \
    --proguard proguard.txt \
    compiled.zip
```

### Dump/Inspeccionar

```bash
# Ver contenidos de APK
aapt2 dump badging app.apk

# Ver recursos
aapt2 dump resources app.apk

# Ver configuración
aapt2 dump configurations app.apk

# Ver strings
aapt2 dump strings app.apk

# Ver XML
aapt2 dump xmltree app.apk AndroidManifest.xml
```

### Optimizar

```bash
# Optimizar APK
aapt2 optimize -o app-optimized.apk app.apk

# Con opciones específicas
aapt2 optimize \
    -o app-optimized.apk \
    --collapse-resource-names \
    app.apk
```

### Convertir de AAPT a AAPT2

```bash
# Convertir APK construido con AAPT v1
aapt2 convert -o converted.apk old-app.apk
```

## Casos de Uso Comunes

### 1. Compilar App Android Simple

```bash
# Estructura de directorios
my-app/
├── AndroidManifest.xml
└── res/
    ├── values/
    │   └── strings.xml
    └── drawable/
        └── icon.png

# Compilar recursos
cd my-app
aapt2 compile --dir res -o compiled.zip

# Crear APK
aapt2 link \
    -o my-app.apk \
    -I $ANDROID_HOME/platforms/android-33/android.jar \
    --manifest AndroidManifest.xml \
    compiled.zip

# Firmar (requiere apksigner)
apksigner sign --ks my-key.keystore my-app.apk
```

### 2. Extraer Recursos de APK Existente

```bash
# Ver información básica
aapt2 dump badging existing-app.apk

# Extraer strings
aapt2 dump strings existing-app.apk > strings.txt

# Ver permisos
aapt2 dump permissions existing-app.apk

# Ver manifest
aapt2 dump xmltree existing-app.apk AndroidManifest.xml
```

### 3. Compilación Incremental

```bash
# Compilar solo archivos modificados
aapt2 compile res/values/strings.xml -o compiled/

# Link incremental
aapt2 link \
    -o app.apk \
    -I android.jar \
    --manifest AndroidManifest.xml \
    compiled/*.flat
```

### 4. Multi-configuración

```bash
# Compilar para múltiples densidades
aapt2 compile \
    res/drawable-mdpi/icon.png \
    res/drawable-hdpi/icon.png \
    res/drawable-xhdpi/icon.png \
    -o compiled/

# Link con configuraciones específicas
aapt2 link \
    -o app.apk \
    -c en,es,fr \
    --preferred-density xhdpi \
    -I android.jar \
    --manifest AndroidManifest.xml \
    compiled/*.flat
```

## Integración con Sistemas de Build

### Gradle (Android Studio)

En `build.gradle`:

```groovy
android {
    // Especificar versión de AAPT2
    aaptOptions {
        useAAPT2 = true
    }
}
```

### CMake

```cmake
# Usar AAPT2 en CMake
find_program(AAPT2 aapt2)

add_custom_command(
    OUTPUT compiled.zip
    COMMAND ${AAPT2} compile --dir ${CMAKE_SOURCE_DIR}/res -o compiled.zip
    DEPENDS ${CMAKE_SOURCE_DIR}/res
)
```

### Makefile

```makefile
AAPT2 := aapt2
RES_DIR := res
BUILD_DIR := build

$(BUILD_DIR)/app.apk: compiled.zip
	$(AAPT2) link \
		-o $@ \
		-I android.jar \
		--manifest AndroidManifest.xml \
		compiled.zip

compiled.zip: $(wildcard $(RES_DIR)/*)
	$(AAPT2) compile --dir $(RES_DIR) -o $@
```

### CI/CD (GitHub Actions)

```yaml
- name: Setup AAPT2
  run: |
    wget https://github.com/EduardoA3677/aapt2/releases/latest/download/aapt2-linux-x64.tar.gz
    tar -xzf aapt2-linux-x64.tar.gz
    sudo mv aapt2 /usr/local/bin/
    aapt2 version

- name: Build resources
  run: |
    aapt2 compile --dir app/res -o compiled.zip
    aapt2 link -o app.apk -I android.jar --manifest app/AndroidManifest.xml compiled.zip
```

## Opciones Avanzadas

### Variables de Entorno

```bash
# Especificar nivel de API
export AAPT2_TARGET_SDK_VERSION=33

# Debug output
export AAPT2_DEBUG=1
```

### Flags Útiles

```bash
# Verbose (más información)
aapt2 compile --dir res -o out.zip -v

# Warnings como errores
aapt2 link ... --warn-manifest-validation

# No comprimir ciertos archivos
aapt2 link ... -0 .mp3 -0 .ogg

# Especificar versión mínima/target
aapt2 link ... --min-sdk-version 21 --target-sdk-version 33
```

## Solución de Problemas

### Error: "aapt2: command not found"

```bash
# Verificar instalación
which aapt2

# Agregar al PATH
export PATH=$PATH:/ruta/a/aapt2

# O copiar a bin del sistema
sudo cp aapt2 /usr/local/bin/
```

### Error: Recursos no encontrados

```bash
# Verificar estructura de directorios
tree res/

# Asegurarse de compilar todos los recursos
aapt2 compile --dir res -o compiled.zip -v
```

### Error: "android.jar not found"

```bash
# Especificar ruta correcta
export ANDROID_HOME=/path/to/android/sdk
aapt2 link -I $ANDROID_HOME/platforms/android-33/android.jar ...
```

## Tips y Mejores Prácticas

1. **Usar aapt2_64 en sistemas de 64 bits** para mejor rendimiento
2. **Compilar incrementalmente** para builds más rápidos
3. **Usar --proto-format** para APKs más pequeños
4. **Activar warnings** con `-v` durante desarrollo
5. **Optimizar APKs** con `aapt2 optimize` antes de release
6. **Usar sparse checkout** al clonar para ahorrar espacio
7. **Cachear recursos compilados** en CI/CD

## Referencias

- [Documentación oficial AAPT2](https://developer.android.com/tools/aapt2)
- [Android Build System](https://developer.android.com/build)
- [Repositorio de este proyecto](https://github.com/EduardoA3677/aapt2)
- [Issues y soporte](https://github.com/EduardoA3677/aapt2/issues)

## Contribuir

¿Encontraste un problema o tienes una sugerencia?

1. Abre un issue: https://github.com/EduardoA3677/aapt2/issues
2. Envía un PR con mejoras
3. Comparte tus casos de uso

## Licencia

Los binarios de AAPT2 están bajo la licencia Apache 2.0 del Android Open Source Project.
Los scripts de este repositorio están bajo licencia MIT.
