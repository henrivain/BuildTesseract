# Building [Tesseract ocr](https://github.com/tesseract-ocr) for 64 bit Windows devices

26.3.2023

Build platform is 64bit Windows 11 with visual studio 2022 Community edition

This tutorial is based on [tutorial from 2021](https://bucket401.blogspot.com/2021/03/building-tesserocr-on-ms-windows-64bit.html). I have added some more information about steps. I am new to using C/C++ and know very little about compiling them targetting other platforms, but this seems to work.

## Step 1: Install build tools

### Install Cmake and Git if you haven't already

Using winget in your windows terminal, run commands

```powershell
winget install cmake
winget install Git.Git
```

### Download [Curl](https://curl.se/windows/) if you dont have it installed

### Install Visual Studio 2022

You also need [Visual Studio 2022](https://visualstudio.microsoft.com/vs/) installed. Community version is free for most of the people.

Select C/C++ tools when asked during the installation

## Step 2: Configure build environment

These enviroment variables will be deleted after you close your console window, so you need to set them again, if you close your console. Note that, you must add quotation marks around "" any path, that has spaces. (Example: "C:\root\my folder\myFiles")

### Create folder with name of your choice

This folder is going to be your `root` folder for the build. Use command, where `root` is your folder name

```powershell
mkdir root && cd root
```

### Set path enviroment variables

Every command in its own line

```powershell
SET INSTALL_DIR=[path/to/root]/build
SET PATH=%PATH%;%INSTALL_DIR%/bin
```

### Create tessdata folder for later

```powershell
mkdir "%INSTALL_DIR%\share\tesseract\tessdata"
```

### Initialize Visual Studio environment

My Visual Studio is located in the following path, but it might vary. Remember to check, where yours is located.

```powershell
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat" x64
```

### Set more enviroment variables

```powershell
SET INCLUDE=%INCLUDE%;%INSTALL_DIR%\include
SET LIBPATH=%LIBPATH%;%INSTALL_DIR%\lib
SET TESSDATA_PREFIX=%INSTALL_DIR%\share\tesseract\tessdata
```

## Download tessdata files

I am using tessdata from tessdata repository, but you can also use data from tessdata_best or tessdata_fast. Download tess files using

```powershell
git clone https://github.com/tesseract-ocr/tessconfigs "%TESSDATA_PREFIX%"
curl -L https://github.com/tesseract-ocr/tessdata/raw/master/eng.traineddata ^
    --output "%TESSDATA_PREFIX%\eng.traineddata"
curl -L https://github.com/tesseract-ocr/tessdata/raw/master/osd.traineddata ^
    --output "%TESSDATA_PREFIX%\osd.traineddata"
```

## Install Zlib

[Link to download current zip](https://zlib.net/zlib1213.zip)

# Download Zlib

Unzip the [Zlib](https://zlib.net/) folder to your root folder with name `zlib`.

### Go inside zlib folder

```powershell
cd zlib
```

### Build

```powershell
cmake -Bbuild -DCMAKE_BUILD_TYPE=Release ^
-DCMAKE_PREFIX_PATH=%INSTALL_DIR% ^
-DCMAKE_INSTALL_PREFIX=%INSTALL_DIR%
```

### Then install to build folder using

```powershell
cmake --build build --config Release --target install
```

### Go back to `root`

```powershell
cd ..
```

# Download Libpng

### Download [zip from source forge](https://sourceforge.net/projects/libpng/files/libpng16/1.6.39/lpng1639.zip/download) and unzip it to `root` folder with name `libpng`

### Go inside folder

```powershell
cd libpng
```

### Build

```powershell
cmake -Bbuild -DCMAKE_BUILD_TYPE=Release ^
-DCMAKE_PREFIX_PATH=%INSTALL_DIR% -DCMAKE_INSTALL_PREFIX=%INSTALL_DIR%
```

### Install to INSTALL_DIR

```powershell
cmake --build build --config Release --target install
```

### Go back to root

```powershell
cd ..
```

# Download Leptonica

### Clone repository

```powershell
git clone https://github.com/DanBloomberg/leptonica.git
```

### Go inside folder

```powershell
cd leptonica
```

### Build

```powershell
cmake -Bbuild -DCMAKE_BUILD_TYPE=Release ^
-DCMAKE_INSTALL_PREFIX=%INSTALL_DIR% -DCMAKE_PREFIX_PATH=%INSTALL_DIR% ^
-DBUILD_PROG=OFF -DSW_BUILD=OFF -DBUILD_SHARED_LIBS=ON
```

### Install to INSTALL_DIR

```powershell
cmake --build build  --config Release --target install
```

### Go back to root

```powershell
cd ..
```

# Download Tesseract

### Clone repository

```powershell
git clone https://github.com/tesseract-ocr/tesseract
```

### GO inside the folder

```powershell
cd tesseract
```

### Build

```powershell
cmake -Bbuild -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=%INSTALL_DIR% ^
-DCMAKE_PREFIX_PATH=%INSTALL_DIR% ^
-DLeptonica_DIR=%INSTALL_DIR%\lib\cmake  ^
-DBUILD_TRAINING_TOOLS=OFF ^
-DSW_BUILD=OFF ^
-DOPENMP_BUILD=OFF -DBUILD_SHARED_LIBS=ON
```

### Install

```powershell
cmake --build build --config Release --target install
```

### Go back to root

```powershell
cd ..
```

# Finish

### Now you should find your result libraries in the following folders

```
> root
    > build
        > bin
            > tesseract.exe
            > tesseract53.dll
            > leptonica-1.84.0.dll
            > libpng16.dll
            > zlib.dll
        > lib
            > tesseract53.lib
```
