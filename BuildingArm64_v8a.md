# Building [Tesseract ocr](https://github.com/tesseract-ocr) for Android devices using arm64 v8a architecture

25.3.2023

x86_64 Windows 11 as build platform

This tutorial is based on [blog from 2021](https://bucket401.blogspot.com/2021/07/crosscompile-tesseract-for-android-on.html). I have added some more information and changed a little how build targets are chosen.

Currently this can generate Tesseract libraries that can be run on many Android architectures.

## Step 1: Download needed build tools

Using winget in your windows terminal, run commands

```powershell
winget install cmake
winget install Git.Git
```

Next download android build tools

[SDK Platform Tools](https://developer.android.com/studio/releases/platform-tools)

[NDK](https://developer.android.com/ndk/downloads)

Extract both and place extracted folders to empty directory of your choise. This new folder will be your `root folder`.

Now you should have folder structure like

```
> root
    > android-ndk-r25c
    > platform-tools
```

## Step 2: Set environment variables

Any time you close your console window, you need to repeat this step

### Set git location (use your corresponding path)

-   `C:\Program Files\Git\usr\bin` -part should match your git bin location

```powershell
SET PATH=%PATH%;C:\Program Files\Git\usr\bin;
```

### Set build tool paths

replace `[PathToRootFolder]` with your full root folder path
Each command to its own line

```powershell
SET INSTALL_DIR=[PathToRootFolder]\build
SET NDK=[PathToRootFolder]\android-ndk-r25c
SET TOOLCHAIN=%NDK%\toolchains\llvm\prebuilt\windows-x86_64
SET PATH=%PATH%;%TOOLCHAIN%\bin;[PathToRootFolder]\platform-tools;
```

Set targets

```powershell
SET TARGET=aarch64-linux-android
SET API=21
SET ABI=arm64-v8a
SET MINSDKVERSION=16
SET CXX=%TOOLCHAIN%\bin\%TARGET%%API%-clang++
SET CC=%TOOLCHAIN%\bin\%TARGET%%API%-clang
```

## Step 3: Build libpng

Download [libpng from source forge](https://sourceforge.net/projects/libpng/files/) and unzip it to its own `libpng` folder inside `root` folder

move to the new folder using

```powershell
cd libpng
```

### Run cmake command

```powershell
cmake -Bbuild -G"Unix Makefiles" ^
-DHAVE_LD_VERSION_SCRIPT=OFF ^
-DCMAKE_TOOLCHAIN_FILE=%NDK%\build\cmake\android.toolchain.cmake ^
-DANDROID_PLATFORM=android-21 ^
-DCMAKE_MAKE_PROGRAM=%NDK%\prebuilt\windows-x86_64\bin\make.exe ^
-DANDROID_TOOLCHAIN=clang ^
-DANDROID_ABI="arm64-v8a" ^
-DCMAKE_BUILD_TYPE=Release ^
-DCMAKE_PREFIX_PATH=%INSTALL_DIR% ^
-DCMAKE_INSTALL_PREFIX=%INSTALL_DIR%
```

### Install libpng

To install libpng to `INSTALL_DIR`, run inside libpng folder

```powershell
cmake --build build --config Release --target install
```

### Go back to root folder

```powershell
cd ..
```

## Step 4: Build leptonica

### Clone leptonica repository

```powershell
git clone --depth 1 https://github.com/DanBloomberg/leptonica.git
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
-DANDROID_PLATFORM=android-21 ^
-DCMAKE_MAKE_PROGRAM=%NDK%\prebuilt\windows-x86_64\bin\make.exe ^
-DANDROID_TOOLCHAIN=clang ^
-DANDROID_ABI=arm64-v8a ^
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

## Step 5: Build Google cpu_features

This package seems to be missing, so it needs to be build independently

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
-DANDROID_PLATFORM=android-21 ^
-DCMAKE_MAKE_PROGRAM=%NDK%\prebuilt\windows-x86_64\bin\make.exe ^
-DANDROID_TOOLCHAIN=clang ^
-DANDROID_ABI="arm64-v8a" ^
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

## Step 6: Build Tesseract

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
cmake -Bbuild -G"Unix Makefiles" -DBUILD_TRAINING_TOOLS=OFF ^
-DGRAPHICS_DISABLED=ON -DSW_BUILD=OFF -DOPENMP_BUILD=OFF ^
-DBUILD_SHARED_LIBS=ON ^
-DLeptonica_DIR=%INSTALL_DIR%\lib\cmake\leptonica ^
-DCMAKE_TOOLCHAIN_FILE=%NDK%\build\cmake\android.toolchain.cmake ^
-DANDROID_PLATFORM=android-21 ^
-DCMAKE_MAKE_PROGRAM=%NDK%\prebuilt\windows-x86_64\bin\make.exe ^
-DANDROID_TOOLCHAIN=clang -DANDROID_ABI=arm64-v8a ^
-DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=%INSTALL_DIR% ^
-DCMAKE_PREFIX_PATH=%INSTALL_DIR%;%INSTALL_DIR%\lib;%INSTALL_DIR%\include;%INSTALL_DIR%\lib\cmake ^
-DCpuFeaturesNdkCompat_DIR=%INSTALL_DIR%\lib\cmake\CpuFeaturesNdkCompat
```

### Install Tesseract

Install Tesseract to `INSTALL_DIR` using

```powershell
cmake --build build --config Release --target install
```

## Step 7: Check results

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

### Check binary platform

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

Target architecture is `ARM aarch64` meaning `arm64_v8a`
