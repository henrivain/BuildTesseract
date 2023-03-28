# Building Tesseract ocr for Android running processor architectures

27.3.2023

Build platform: `Windows 11 64bit`

Build Target: `Android`

Target Architectures: `Arm_v8a (64bit), Arm_v7a (32bit), x86 (32bit), x86_64 (64bit)`

## Step 1: Get required tools

Cmake, Git Android NDK and Android build tools are required on the build process

### Install Cmake

```powershell
winget install cmake
```

### Install Git

```powershell
winget install Git.Git
```

### [Android NDK](https://developer.android.com/ndk/downloads) from Google

Download Windows version from the website and unzip

### [Android SDK Platform Tools](https://developer.android.com/studio/releases/platform-tools) from Google

Download Windows version from the website and unzip

### Install unzip (Optional)

```
winget install -e --id GnuWin32.UnZip
```

## Step 2 Configure build environment

### Create new empty folder

In this example I use name `root`

### Copy tools

Copy `NDK` and `platform tools` folders to newly created folder

### Create build folder

Open your terminal into the `root` folder and create `build` folder with command

```powershell
mkdir build
```

Now you should have folder structure like

```
> root
    > android-ndk-r25c
    > platform-tools
    > build
```

## Step 3: Set enviroment variables

These are enviroment variables that are only preserved during your current terminal session. If you close your terminal for some reson, you need to repeat this step.

### Set build targets

These variables define, what processor architecture you are building for. You can choose from [4 Android platforms](https://developer.android.com/ndk/guides/other_build_systems).

|  Platform   | ABI (Application binary interface) | Target                   | APIs  |
| :---------: | :--------------------------------: | ------------------------ | ----- |
| Arm (64bit) |             arm64-v8a              | aarch64-linux-android    | 21-33 |
| Arm (32bit) |            armeabi-v7a             | armv7a-linux-androideabi |       |
| x86 (64bit) |                x86                 | i686-linux-android       |       |
| x86 (32bit) |               x86-64               | x86_64-linux-android     |       |

Available APIs could have been changed after writing (27.3.2023). You can check them from folder inside NDK: `android-ndk-r25c\toolchains\llvm\prebuilt\windows-x86_64\bin`. Check the clang file names for available APIs.

You can change values to target your platform

```powershell
SET TARGET=aarch64-linux-android
SET API=21
SET ABI=arm64-v8a
SET MINSDKVERSION=16
```

### Set your root folder

Replace `[PATH\TO\ROOT\FOLDER]` with full path to your root folder.
Remember to use backslashes '`\`' instead of forwardslashes '`/`'.

```powershell
SET ROOT=[PATH\TO\ROOT\FOLDER]
```

### Set other variables

You don't probably need to change any of these. `build` folder is going to be your `INSTALL_DIR` and result folder.

```powershell
SET INSTALL_DIR=%ROOT%\build
SET NDK=%ROOT%\android-ndk-r25c
SET TOOLCHAIN=%NDK%\toolchains\llvm\prebuilt\windows-x86_64
SET PATH=%PATH%;%TOOLCHAIN%\bin;%ROOT%\platform-tools;
SET CXX=%TOOLCHAIN%\bin\%TARGET%%API%-clang++
SET CC=%TOOLCHAIN%\bin\%TARGET%%API%-clang
```

## Step 4: Build libpng

Download [libpng from source forge](https://sourceforge.net/projects/libpng/files/) and unzip it to its own `libpng` folder inside `root` folder

### move to the new folder using

```powershell
cd libpng
```

### Run cmake

```powershell
cmake -Bbuild -G"Unix Makefiles" ^
-DHAVE_LD_VERSION_SCRIPT=OFF ^
-DCMAKE_TOOLCHAIN_FILE=%NDK%\build\cmake\android.toolchain.cmake ^
-DANDROID_PLATFORM=android-%API% ^
-DCMAKE_MAKE_PROGRAM=%NDK%\prebuilt\windows-x86_64\bin\make.exe ^
-DANDROID_TOOLCHAIN=clang ^
-DANDROID_ABI=%ABI% ^
-DCMAKE_BUILD_TYPE=Release ^
-DCMAKE_PREFIX_PATH=%INSTALL_DIR% ^
-DCMAKE_INSTALL_PREFIX=%INSTALL_DIR%
```

### Install

This will install libpng to `INSTALL_DIR`. This libpng installation is used during the other build processes.

```powershell
cmake --build build --config Release --target install
```

### Go back to root folder

```powershell
cd ..
```

## Step 5: Build Leptonica

### Clone leptonica repository

```powershell
git clone https://github.com/DanBloomberg/leptonica.git
```

### Go to cloned folder

```powershell
cd leptonica
```

### Run cmake

```powershell
cmake -Bbuild -G"Unix Makefiles" ^
-DBUILD_PROG=OFF ^
-DSW_BUILD=OFF ^
-DBUILD_SHARED_LIBS=ON ^
-DPNG_LIBRARY=%INSTALL_DIR%\lib\libpng.so ^
-DPNG_PNG_INCLUDE_DIR=%INSTALL_DIR%\include ^
-DCMAKE_TOOLCHAIN_FILE=%NDK%\build\cmake\android.toolchain.cmake ^
-DANDROID_PLATFORM=android-%API% ^
-DCMAKE_MAKE_PROGRAM=%NDK%\prebuilt\windows-x86_64\bin\make.exe ^
-DANDROID_TOOLCHAIN=clang ^
-DANDROID_ABI=%ABI% ^
-DCMAKE_BUILD_TYPE=Release ^
-DCMAKE_INSTALL_PREFIX=%INSTALL_DIR% ^
-DCMAKE_PREFIX_PATH=%INSTALL_DIR%;%INSTALL_DIR%\lib;%INSTALL_DIR%\include;%INSTALL_DIR%\lib\cmake
```

### Install leptonica

Install leptonica to `INSTALL_DIR` using

```powershell
cmake --build build --config Release --target install
```

### Go back to root

```powershell
cd ..
```

## Step 6: Build Google cpu_features

This package seems to be missing, so it also needs to be build as a part of Tesseract build process.

### Clone cpu_features repository

```powershell
git clone https://github.com/google/cpu_features.git
```

### Go to cpu_features folder

```powershell
cd cpu_features
```

Run cmake

```powershell
cmake -Bbuild -G"Unix Makefiles" ^
-DCMAKE_TOOLCHAIN_FILE=%NDK%\build\cmake\android.toolchain.cmake ^
-DANDROID_PLATFORM=android-%API% ^
-DCMAKE_MAKE_PROGRAM=%NDK%\prebuilt\windows-x86_64\bin\make.exe ^
-DANDROID_TOOLCHAIN=clang ^
-DANDROID_ABI=%ABI% ^
-DCMAKE_BUILD_TYPE=Release ^
-DCMAKE_PREFIX_PATH=%INSTALL_DIR% ^
-DCMAKE_INSTALL_PREFIX=%INSTALL_DIR%
```

### Install cpu_features

Install cpu_features to `INSTALL_DIR` using

```powershell
cmake --build build --config Release --target install
```

### Go back to root

```powershell
cd ..
```

## Step 7: Build Tesseract

### Clone tesseract ocr repository

```powershell
git clone https://github.com/tesseract-ocr/tesseract.git
```

### Go to tesseract folder

```powershell
cd tesseract
```

### Run cmake

```powershell
cmake -Bbuild -G"Unix Makefiles" ^
-DBUILD_TRAINING_TOOLS=OFF ^
-DGRAPHICS_DISABLED=ON ^
-DSW_BUILD=OFF ^
-DOPENMP_BUILD=OFF ^
-DBUILD_SHARED_LIBS=ON ^
-DLeptonica_DIR=%INSTALL_DIR%\lib\cmake\leptonica ^
-DCMAKE_TOOLCHAIN_FILE=%NDK%\build\cmake\android.toolchain.cmake ^
-DANDROID_PLATFORM=android-%API% ^
-DCMAKE_MAKE_PROGRAM=%NDK%\prebuilt\windows-x86_64\bin\make.exe ^
-DANDROID_TOOLCHAIN=clang ^
-DANDROID_ABI=%ABI% ^
-DCMAKE_BUILD_TYPE=Release ^
-DCMAKE_INSTALL_PREFIX=%INSTALL_DIR% ^
-DCMAKE_PREFIX_PATH=%INSTALL_DIR%;%INSTALL_DIR%\lib;%INSTALL_DIR%\include;%INSTALL_DIR%\lib\cmake ^
-DCpuFeaturesNdkCompat_DIR=%INSTALL_DIR%\lib\cmake\CpuFeaturesNdkCompat
```

### Install Tesseract

Install Tesseract to `INSTALL_DIR` using

```powershell
cmake --build build --config Release --target install
```

## Step 8: Validate results

### You should now have folder structure like

```
> root
    > cpu_features
    > tesseract
    > build
        > include
        > share
        > bin
            > tesseract
        > lib
            > libtesseract.so
            > libpng.so
            > libleptonica.so
    > leptonica
    > libpng
    > android-ndk-r25c
    > platform-tools

```

### Check binary architecture

If you have [WSL](https://www.microsoft.com/store/productId/9P9TQF7MRM4R) installed, you can check file target architecture by running commands

```powershell
cd ..\build\lib
wsl
file libtesseract.so
```

returns

```
libtesseract.so: ELF 64-bit LSB shared object, ARM aarch64, version 1 (SYSV), dynamically linked, BuildID[sha1]=5415d67f42d81288bf60ecfde5851ec44f8fd2c9, with debug_info, not stripped
```

Here you can see, that the file architecture is `ARM aarch64` meaning `arm64_v8a`

Now you can copy the .so files to you project.

Example of build for arm64_v8a can be found in file `BuildingArm64_V8a.md`

<br></br>
by
[Henri Vainio](https://github.com/henrivain) 27.3.2023
