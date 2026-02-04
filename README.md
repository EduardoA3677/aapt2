# AAPT2 Build System

Este repositorio contiene scripts y configuración para clonar y compilar los binarios AAPT (Android Asset Packaging Tool) desde el código fuente de Android.

## Descripción

Este proyecto clona únicamente los archivos y carpetas necesarios de:
- **Repositorio frameworks/base**: https://android.googlesource.com/platform/frameworks/base
- **Repositorio system/libbase**: https://android.googlesource.com/platform/system/libbase
- **Repositorio system/core**: https://android.googlesource.com/platform/system/core
- **Repositorio frameworks/native**: https://android.googlesource.com/platform/frameworks/native
- **Repositorio system/incremental_delivery**: https://android.googlesource.com/platform/system/incremental_delivery
- **Repositorio system/logging**: https://android.googlesource.com/platform/system/logging
- **Tag**: android-16.0.0_r4

Y compila los siguientes binarios:
- `aapt2` - Android Asset Packaging Tool 2
- `aapt2_64` - Versión de 64 bits de AAPT2
- `aapt` - Android Asset Packaging Tool (versión 1)
- `aapt_64` - Versión de 64 bits de AAPT

## Requisitos Previos

### Sistema Operativo
- Linux (Ubuntu/Debian, RedHat/CentOS)
- macOS
- Windows con WSL2

### Dependencias de Compilación
- CMake (>= 3.10)
- Ninja build system
- GCC/G++ (>= 7.0) o Clang
- Protobuf compiler
- Bibliotecas de desarrollo:
  - zlib
  - libpng
  - expat
  - protobuf

## Documentación

- **[INSTALL.md](INSTALL.md)** - Guía de instalación detallada paso a paso
- **[USAGE.md](USAGE.md)** - Ejemplos de uso y casos comunes
- **[.github/workflows/README.md](.github/workflows/README.md)** - Documentación de workflows de CI/CD

## Inicio Rápido

### Opción A: Usar Binarios Pre-compilados (Más Rápido)

Si ya existen releases en el repositorio:

```bash
# Descargar binarios para Linux
wget https://github.com/EduardoA3677/aapt2/releases/latest/download/aapt2-linux-x64.tar.gz
tar -xzf aapt2-linux-x64.tar.gz
sudo install -m 755 aapt2 /usr/local/bin/

# Verificar
aapt2 version
```

### Opción B: Compilar Localmente

## Instalación Rápida

### Opción 1: Script Automatizado (Recomendado)

```bash
# Clonar el repositorio
git clone <repository-url>
cd aapt2

# Ejecutar el script de compilación automática
./clone_and_build.sh
```

Este script realizará:
1. Clonación con sparse checkout del repositorio de Android
2. Verificación de dependencias
3. Configuración del entorno de compilación
4. Compilación de todos los binarios

### Opción 2: Usando Makefile

```bash
# Clonar fuentes
make clone

# Instalar dependencias (requiere sudo)
make deps

# Compilar binarios
make all

# Ver estado
make status

# Instalar binarios (opcional)
sudo make install
```

### Opción 3: Manual

```bash
# 1. Instalar dependencias (Ubuntu/Debian)
sudo apt-get update
sudo apt-get install -y \
    build-essential \
    cmake \
    ninja-build \
    pkg-config \
    protobuf-compiler \
    libprotobuf-dev \
    zlib1g-dev \
    libpng-dev \
    libexpat1-dev

# 2. Ejecutar el script de clonación y compilación
./clone_and_build.sh
```

## Estructura del Proyecto

```
aapt2/
├── README.md                 # Este archivo
├── clone_and_build.sh       # Script principal de compilación
├── build_with_soong.sh      # Script alternativo con Soong
├── Makefile                 # Makefile para automatización
├── frameworks-base/         # Código fuente clonado (creado después de clonar)
│   ├── tools/aapt2/        # Fuentes de AAPT2
│   ├── tools/aapt/         # Fuentes de AAPT
│   └── libs/androidfw/     # Bibliotecas de Android Framework
├── libbase/                 # Código fuente de libbase (creado después de clonar)
│   └── include/android-base/ # Android base library headers
├── system-core/             # Código fuente de system-core (creado después de clonar)
│   └── libutils/include/   # Android utils headers
├── native/                  # Código fuente de frameworks-native (creado después de clonar)
│   └── include/            # Native framework headers
├── incfs/                   # Código fuente de incremental_delivery (creado después de clonar)
│   └── incfs/util/include/ # INCFS utility headers
├── liblog/                  # Código fuente de system-logging (creado después de clonar)
│   └── liblog/include/     # Android logging headers
└── build/                   # Directorio de compilación (creado durante build)
    ├── aapt2               # Binario AAPT2
    ├── aapt2_64            # Binario AAPT2 64-bit
    ├── aapt                # Binario AAPT
    └── aapt_64             # Binario AAPT 64-bit
```

## Uso de los Binarios

Una vez compilados, los binarios se encuentran en el directorio `build/`:

```bash
# Verificar versión de AAPT2
./build/aapt2 version

# Compilar recursos de Android
./build/aapt2 compile -o output.zip input.xml

# Ver ayuda
./build/aapt2 --help
```

## Clonación Sparse

El script `clone_and_build.sh` utiliza sparse checkout de Git para clonar únicamente los archivos necesarios:

**De frameworks/base:**
```
/tools/aapt2/          # Código fuente de AAPT2
/tools/aapt/           # Código fuente de AAPT
/libs/androidfw/       # Framework Android
/include/androidfw/    # Headers
Android.bp             # Archivos de build
Android.mk
```

**De system/libbase:**
```
/include/              # Android base library headers (android-base/*)
```

**De system/core:**
```
/libutils/include/     # Android utils headers
/include/              # System headers
```

**De frameworks/native:**
```
/include/              # Native framework headers
```

**De system/incremental_delivery:**
```
/incfs/util/include/   # INCFS utility headers
```

**De system/logging:**
```
/liblog/include/       # Android logging headers
```

Esto reduce significativamente el tamaño de descarga comparado con clonar todo el repositorio frameworks/base.

## Solución de Problemas

### Error: No se puede resolver el host android.googlesource.com

Si no puedes acceder a android.googlesource.com, verifica:
1. Conexión a Internet
2. Configuración de proxy/firewall
3. Usa un mirror alternativo si está disponible

### Error: Faltan dependencias

Ejecuta la verificación de dependencias:
```bash
./clone_and_build.sh
```

El script identificará las dependencias faltantes y mostrará los comandos de instalación.

### Error de compilación

1. Verifica que todas las dependencias estén instaladas
2. Asegúrate de tener suficiente espacio en disco (>5GB recomendado)
3. Revisa los logs de compilación para errores específicos

### Compilación en macOS

En macOS con Apple Silicon (M1/M2), puede que necesites:
```bash
# Instalar Rosetta 2 si es necesario
softwareupdate --install-rosetta

# Usar Homebrew para dependencias
brew install cmake ninja protobuf zlib libpng expat
```

## Información Técnica

### Sobre AAPT2

AAPT2 (Android Asset Packaging Tool 2) es una herramienta de línea de comandos que:
- Compila recursos de aplicaciones Android
- Genera archivos APK
- Empaqueta recursos en formato binario
- Optimiza recursos para diferentes configuraciones

### Diferencias entre AAPT y AAPT2

- **AAPT**: Herramienta original, más simple
- **AAPT2**: Versión mejorada con:
  - Compilación incremental
  - Mejor rendimiento
  - Soporte para AAB (Android App Bundle)
  - Manejo mejorado de recursos

### Arquitecturas

- **aapt2/aapt**: Arquitectura del sistema (32-bit o 64-bit según el sistema)
- **aapt2_64/aapt_64**: Forzado a 64-bit con flag `-m64`

## Scripts Incluidos

### clone_and_build.sh
Script principal que maneja todo el proceso:
- Clonación con sparse checkout
- Verificación de dependencias
- Generación de CMakeLists.txt
- Compilación de binarios

### build_with_soong.sh
Script alternativo que documenta el proceso con el sistema de build nativo de Android (Soong).
Nota: Requiere un entorno de build completo de Android.

### Makefile
Proporciona targets convenientes:
- `make clone` - Clona fuentes
- `make deps` - Instala dependencias
- `make all` - Compila todo
- `make clean` - Limpia build
- `make install` - Instala binarios
- `make status` - Muestra estado

## Contribuir

Si encuentras problemas o tienes sugerencias:
1. Abre un issue en el repositorio
2. Incluye información del sistema (OS, versión)
3. Adjunta logs de compilación si hay errores

## Licencia

Este proyecto contiene scripts para compilar código del Android Open Source Project (AOSP).
El código de Android está bajo licencia Apache 2.0.

## Referencias

- [Android Source](https://source.android.com/)
- [AAPT2 Documentation](https://developer.android.com/tools/aapt2)
- [Android Build System](https://source.android.com/docs/setup/build)
- [frameworks/base Repository](https://android.googlesource.com/platform/frameworks/base/)

## Notas Adicionales

### Tag android-16.0.0_r4

Este tag corresponde a Android 16.0.0 Release 4. Para usar una versión diferente, modifica la variable `TAG` en los scripts.

### Compilación Completa de Android

Para una compilación completa del sistema Android, se recomienda:
1. Usar el [repo tool](https://source.android.com/docs/setup/download)
2. Inicializar el árbol completo de Android
3. Compilar con `m aapt2`

Este repositorio proporciona una alternativa ligera para compilar solo AAPT2.

## Contacto

Para preguntas específicas sobre la compilación de AAPT2, consulta la documentación oficial de Android o abre un issue en este repositorio.