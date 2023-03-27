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
echo Do you have unzip, curl, git and cmake installed? Are you inside empty folder?
SET /P ISEMPTY="Y/[N] >"
IF /I "%ISEMPTY%" NEQ "Y" GOTO END

SET /P TARGET="Give build TARGET >"
SET /P API="Give Android API >"
SET /P ABI="Give Android ABI >"

SET /P ISCORRECTINPUT="Is information correct? (Y/[N]) >"
IF /I "%ISCORRECTINPUT%" NEQ "Y" GOTO END


:: DOWNLOAD NDK
if exist android-ndk-r25c\ (
    echo android-ndk-r25c  already exist, no need to download.
) else (
    echo --------------------------
    echo Download android ndk 
    echo --------------------------

    echo This might take a while
    curl -o android-ndk-r25c .zip https://dl.google.com/android/repository/android-ndk-r25c-windows.zip || GOTO FAILED

    unzip android-ndk-r25c .zip || GOTO FAILED
)


:: DOWNLOAD PLATFORM TOOLS
if exist platform-tools\ (
    echo platform-tools already exist, no need to download.
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

:: Configure tool paths
SET MINSDKVERSION=16
SET ROOT=%cd%
SET INSTALL_DIR=%ROOT%\build
SET NDK=%ROOT%\android-ndk-r25c
SET TOOLCHAIN=%NDK%\toolchains\llvm\prebuilt\windows-x86_64
SET PATH=%PATH%;%TOOLCHAIN%\bin;%ROOT%\platform-tools;
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