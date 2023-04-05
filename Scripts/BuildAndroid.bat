:: Copyright Henri Vainio 2023
:: This script builds tesseract ocr for Android in Windows 11
:: Unzip, Curl, GIT and Cmake are required to be installed on this build device
:: You can find available TARGET, ABI and API from BuildingAndroidArchitectures.md
:: That file can be found on Github repository https://github.com/henrivain/BuildTesseract
:: This script was written in 27.3.2023
:: Build tool versions might have changed and broken the script after writing

@echo off

setlocal


echo Build Tesseract ocr 
echo script by Henri Vainio
:: SET target variables
echo -------------------------------------------------------------
echo Path to your root folder should not contain any spaces!
echo Do you have unzip, curl, git and cmake installed? Are you inside empty folder?
SET /P ISEMPTY="Y/[N] >"
IF /I "%ISEMPTY%" NEQ "Y" GOTO END

SET /P TARGET="Give build TARGET >"
SET /P API="Give Android API >"
SET /P ABI="Give Android ABI >"

SET /P ISCORRECTINPUT="Is information correct? (Y/[N]) >"
IF /I "%ISCORRECTINPUT%" NEQ "Y" GOTO END


:: CONFIGURE SOME PATHS 
SET ROOT=%cd%
SET INSTALL_DIR=%ROOT%\build
SET BATCH_DIR=%~dp0

echo --------------------------
echo Download Tools 
echo --------------------------


:: VALIDATE NDK
:: FIND OR DOWNLOAD
SET NDK=%ROOT%\android-ndk-r25c
echo batch file at %BATCH_DIR%
echo Check for NDK at %BATCH_DIR%\android-ndk-r25c
echo Check for NDK at %cd%\android-ndk-r25c

if exist "%BATCH_DIR%\android-ndk-r25c\"  (
    :: NDK INSIDE BATCH FILE DIRECTORY, RESET PATH
    SET NDK=%BATCH_DIR%android-ndk-r25c
    echo android-ndk-r25c already exist, no need to download.
) else if exist android-ndk-r25c\ (
    :: FILE WAS FOUND ELSEWHERE, RESET PATH
    echo NDK exist inside root folder, no need to download.
) else (
    echo --------------------------
    echo Download android ndk 
    echo --------------------------

    echo This might take a while
    curl -o android-ndk-r25c.zip https://dl.google.com/android/repository/android-ndk-r25c-windows.zip || GOTO FAILED

    unzip android-ndk-r25c.zip || GOTO FAILED
)

echo Check platform-tools location 

:: VALIDATE PLATFORM-TOOLS
:: FIND OR DOWNLOAD
if exist "%BATCH_DIR%\platform-tools\" (
    :: PLATFORM-TOOLS INSIDE BATCH FILE DIRECTORY, RESET PATH
    SET PLATFORM_TOOLS_PATH=%BATCH_DIR%\platform-tools
    echo platform-tools found inside batch file directory, no need to download.
) else if exist platform-tools\ (
    echo platform-tools exist inside root folder, no need to download.
) else (
    echo --------------------------
    echo Download android platform tools
    echo --------------------------

    curl -o platform-tools.zip https://dl.google.com/android/repository/platform-tools_r34.0.1-windows.zip || GOTO FAILED

    unzip platform-tools.zip || GOTO FAILED
)

echo --------------------------
echo Configure build
echo --------------------------

:: Create build folder
echo "Start build"
echo "Create folder \build"
mkdir build 

echo platform-tools at %PLATFORM_TOOLS_PATH%
echo NDK at %NDK%

:: Configure tool paths
SET MINSDKVERSION=16
SET TOOLCHAIN=%NDK%\toolchains\llvm\prebuilt\windows-x86_64
SET PATH=%PATH%;%TOOLCHAIN%\bin;%PLATFORM_TOOLS_PATH%;
SET CXX=%TOOLCHAIN%\bin\%TARGET%%API%-clang++
SET CC=%TOOLCHAIN%\bin\%TARGET%%API%-clang

echo --------------------------
echo Download and install libpng 
echo --------------------------

:: Download libpng from source forge
echo Download start might take a while!
curl -o libpng.zip https://nav.dl.sourceforge.net/project/libpng/libpng16/1.6.39/lpng1639.zip || GOTO FAILED
unzip libpng.zip || GOTO FAILED
ren lpng1639 libpng || GOTO FAILED
cd libpng || GOTO failed

:: Build libpng
cmake -Bbuild -G"Unix Makefiles" ^
-DHAVE_LD_VERSION_SCRIPT=OFF ^
-DCMAKE_TOOLCHAIN_FILE=%NDK%\build\cmake\android.toolchain.cmake ^
-DANDROID_PLATFORM=android-%API% ^
-DCMAKE_MAKE_PROGRAM=%NDK%\prebuilt\windows-x86_64\bin\make.exe ^
-DANDROID_TOOLCHAIN=clang ^
-DANDROID_ABI=%ABI% ^
-DCMAKE_BUILD_TYPE=Release ^
-DCMAKE_PREFIX_PATH=%INSTALL_DIR% ^
-DCMAKE_INSTALL_PREFIX=%INSTALL_DIR% || GOTO FAILED

:: Install to build folder
cmake --build build --config Release --target install || GOTO FAILED

cd ..

echo --------------------------
echo Download and install libjpeg 
echo --------------------------

:: clone and build libjpeg
git clone https://github.com/libjpeg-turbo/libjpeg-turbo.git libjpeg || GOTO FAILED

cd libjpeg 

cmake -Bbuild -G"Unix Makefiles" ^
-DCMAKE_TOOLCHAIN_FILE=%NDK%\build\cmake\android.toolchain.cmake ^
-DANDROID_PLATFORM=android-%API% ^
-DCMAKE_MAKE_PROGRAM=%NDK%\prebuilt\windows-x86_64\bin\make.exe ^
-DANDROID_TOOLCHAIN=clang ^
-DANDROID_ABI=%ABI% ^
-DCMAKE_BUILD_TYPE=Release ^
-DCMAKE_PREFIX_PATH=%INSTALL_DIR% ^
-DCMAKE_INSTALL_PREFIX=%INSTALL_DIR% || GOTO FAILED

cmake --build build --config Release --target install || GOTO FAILED

cd ..

echo --------------------------
echo Download and install Leptonica 
echo --------------------------

:: Build and install Leptonica
git clone https://github.com/DanBloomberg/leptonica.git || GOTO FAILED

cd leptonica

cmake -Bbuild -G"Unix Makefiles" ^
-DBUILD_PROG=OFF ^
-DSW_BUILD=OFF ^
-DBUILD_SHARED_LIBS=ON ^
-DPNG_LIBRARY=%INSTALL_DIR%\lib\libpng.so ^
-DPNG_PNG_INCLUDE_DIR=%INSTALL_DIR%\include ^
-DJPEG_LIBRARY=%INSTALL_DIR%\lib\libjpeg.so ^
-DJPEG_INCLUDE_DIR=%INSTALL_DIR%\include ^
-DCMAKE_TOOLCHAIN_FILE=%NDK%\build\cmake\android.toolchain.cmake ^
-DANDROID_PLATFORM=android-%API% ^
-DCMAKE_MAKE_PROGRAM=%NDK%\prebuilt\windows-x86_64\bin\make.exe ^
-DANDROID_TOOLCHAIN=clang ^
-DANDROID_ABI=%ABI% ^
-DCMAKE_BUILD_TYPE=Release ^
-DCMAKE_INSTALL_PREFIX=%INSTALL_DIR% ^
-DCMAKE_PREFIX_PATH=%INSTALL_DIR%;%INSTALL_DIR%\lib;%INSTALL_DIR%\include;%INSTALL_DIR%\lib\cmake || GOTO FAILED

cmake --build build --config Release --target install || GOTO FAILED

cd ..

echo --------------------------
echo Download and install Google cpu_features 
echo --------------------------
:: cpu_features was missing from dependencies Android, so build it
git clone https://github.com/google/cpu_features.git || GOTO FAILED

cd cpu_features

cmake -Bbuild -G"Unix Makefiles" ^
-DCMAKE_TOOLCHAIN_FILE=%NDK%\build\cmake\android.toolchain.cmake ^
-DANDROID_PLATFORM=android-%API% ^
-DCMAKE_MAKE_PROGRAM=%NDK%\prebuilt\windows-x86_64\bin\make.exe ^
-DANDROID_TOOLCHAIN=clang ^
-DANDROID_ABI=%ABI% ^
-DCMAKE_BUILD_TYPE=Release ^
-DCMAKE_PREFIX_PATH=%INSTALL_DIR% ^
-DCMAKE_INSTALL_PREFIX=%INSTALL_DIR% || GOTO FAILED

cmake --build build --config Release --target install || GOTO FAILED

cd ..

echo --------------------------
echo Download and install Tesseract ocr 
echo --------------------------

:: Build Tesseract 
git clone https://github.com/tesseract-ocr/tesseract.git || GOTO FAILED

cd tesseract

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
-DCpuFeaturesNdkCompat_DIR=%INSTALL_DIR%\lib\cmake\CpuFeaturesNdkCompat || GOTO FAILED

cmake --build build --config Release --target install || GOTO FAILED

:: Finish
echo --------------------------
echo Finished successfully
echo find input in root/build/bin and root/build/lib 
echo --------------------------


@echo off
GOTO END
:FAILED
echo process failed!

:END 

echo Exit