:: Copyright Henri Vainio 2023
:: This script builds tesseract ocr for Windows
:: Expects Unzip, Curl, GIT, Cmake and Visual studio to be installed on build device
:: Instructions can be found on Github repository https://github.com/henrivain/BuildTesseract
:: This script was written in 6.4.2023
:: Build tool versions might have changed and broken the script after writing


@echo off

setlocal

echo Build Tesseract ocr 
echo for Windows
echo script by Henri Vainio
echo -------------------------------------------------------------

:: Check command line args
if "%~1"=="" GOTO CONFIGURE
if "%~1"=="x86" GOTO X86
if "%~1"=="x86_64" GOTO x86_64


:: Start build for x86
:: NOT SUPPORTED
:X86
:: SET TARGET_ARCHITECHTURE=vcvars32.bat x86
:: GOTO NO_CONFIGURE
echo Windows architecture x86 is not supported by the script
GOTO FAILED

:: Start build for x86_64
:X86_64
SET TARGET_ARCHITECHTURE=vcvars64.bat x64
GOTO NO_CONFIGURE

:: Ask for input
:CONFIGURE
echo Do you have unzip, curl, git and cmake installed?
SET /P ISEMPTY="Y/[N] >"
IF /I "%ISEMPTY%" NEQ "Y" GOTO END

echo Available architechtures: (x86 SCRIPT NOT SUPPORTED) or x64 (x86_64)  
SET /P TARGET_ARCHITECHTURE="Choose architecture >"
IF "%TARGET_ARCHITECHTURE%"=="x86" GOTO X86
IF "%TARGET_ARCHITECHTURE%"=="x64" GOTO X86_64

GOTO NO_CONFIGURE


:NO_CONFIGURE

echo --------------------------
echo Configure build
echo --------------------------

echo Start build
echo Create folder \build
mkdir build


echo Locate visual studio environment
SET VISUAL_STUDIO_ENV="C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\"

IF exist %VISUAL_STUDIO_ENV% (
    echo Visual studio environment found.
) ELSE IF NOT "%~2"=="" (
    IF EXIST "%~2" (
        echo Visual studio environment found from command line args.
        SET %VISUAL_STUDIO_ENV%=%~2
    ) 
) ELSE (
    echo Could not locate visual studio automatically.
    :ASK_ENVIRONMENT
    echo Could not locate visual studio environment.
    echo Please provide full path to your 'Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\' folder.
    echo Script default 'C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\' was not found.
    echo If your path has any spaces, please add quotation marks around. 
    echo Path should end in directory separator '\' or '/'
    SET /P VISUAL_STUDIO_ENV="Yor full path >"
    IF NOT EXIST %VISUAL_STUDIO_ENV% (
        echo Path does not exist!
        GOTO ASK_ENVIRONMENT
    )
)

echo Visual studio vcvarsXX.bat in '%VISUAL_STUDIO_ENV%%TARGET_ARCHITECHTURE%'.

:: SET ENVIRONMENT VARIABLES
echo Set environment variables
SET ROOT=%cd%
SET INSTALL_DIR=%ROOT%\build
SET BATCH_DIR=%~dp0
SET PATH=%PATH%;%INSTALL_DIR%/bin


echo make tessdata directory
mkdir "%INSTALL_DIR%\share\tesseract\tessdata"

echo Initialize environment
call %VISUAL_STUDIO_ENV%%TARGET_ARCHITECHTURE%

echo Set more variables
SET INCLUDE=%INCLUDE%;%INSTALL_DIR%\include
SET LIBPATH=%LIBPATH%;%INSTALL_DIR%\lib
SET TESSDATA_PREFIX=%INSTALL_DIR%\share\tesseract\tessdata


echo --------------------------
echo Download tessdata
echo --------------------------

git clone https://github.com/tesseract-ocr/tessconfigs "%TESSDATA_PREFIX%" || GOTO FAILED

curl -L https://github.com/tesseract-ocr/tessdata/raw/master/eng.traineddata ^
    --output "%TESSDATA_PREFIX%\eng.traineddata" || GOTO FAILED

curl -L https://github.com/tesseract-ocr/tessdata/raw/master/osd.traineddata ^
    --output "%TESSDATA_PREFIX%\osd.traineddata" || GOTO FAILED

echo --------------------------
echo Build zlib
echo --------------------------

git clone https://github.com/madler/zlib.git zlib || GOTO FAILED
cd zlib || GOTO FAILED

:: CONFIGURE ZLIB
echo configure zlib
cmake -Bbuild -DCMAKE_BUILD_TYPE=Release ^
-DCMAKE_PREFIX_PATH=%INSTALL_DIR% ^
-DCMAKE_INSTALL_PREFIX=%INSTALL_DIR% || GOTO FAILED

:: BUILD AND INSTALL ZLIB TO INSTALL_DIR
echo build and install zlib
cmake --build build --config Release --target install || GOTO FAILED

cd ..

echo --------------------------
echo Download and install libpng 
echo --------------------------

:: DOWNLOAD LIBPNG FROM SOURCE FORGE
echo Download start might take a while!
curl -o libpng.zip https://nav.dl.sourceforge.net/project/libpng/libpng16/1.6.39/lpng1639.zip || GOTO FAILED
unzip libpng.zip || GOTO FAILED
ren lpng1639 libpng || GOTO FAILED
cd libpng || GOTO FAILED

:: CONFIGURE LIBPNG
echo configure libpng
cmake -Bbuild -DCMAKE_BUILD_TYPE=Release ^
-DCMAKE_PREFIX_PATH=%INSTALL_DIR% -DCMAKE_INSTALL_PREFIX=%INSTALL_DIR% || GOTO FAILED

:: BUILD AND INSTALL LIBPNG TO INSTALL_DIR
echo build and install libpng
cmake --build build --config Release --target install || GOTO FAILED

cd ..

echo --------------------------
echo Download and install libjpeg 
echo --------------------------

:: CLONE LIBJPEG
git clone https://github.com/libjpeg-turbo/libjpeg-turbo.git libjpeg || GOTO FAILED

cd libjpeg

:: CONFIGURE LIBJPEG
echo configure libjpeg
cmake -Bbuild -DCMAKE_BUILD_TYPE=Release ^
-DCMAKE_PREFIX_PATH=%INSTALL_DIR% -DCMAKE_INSTALL_PREFIX=%INSTALL_DIR% || GOTO FAILED


:: BUILD AND INSTALL LIBJPEG TO INSTALL_DIR
echo build and install libjpeg
cmake --build build --config Release --target install || GOTO FAILED

cd ..

echo --------------------------
echo Download and install leptonica
echo --------------------------

:: CLONE LEPTONICA
git clone https://github.com/DanBloomberg/leptonica.git leptonica
cd leptonica

:: CONFIGURE LEPTONICA
echo configure leptonica
cmake -Bbuild -DCMAKE_BUILD_TYPE=Release ^
-DCMAKE_INSTALL_PREFIX=%INSTALL_DIR% -DCMAKE_PREFIX_PATH=%INSTALL_DIR% ^
-DBUILD_PROG=OFF -DSW_BUILD=OFF -DBUILD_SHARED_LIBS=ON || GOTO FAILED

:: BUILD AND INSTALL LEPTONICA TO INSTALL_DIR
echo build and install leptonica
cmake --build build --config Release --target install || GOTO FAILED

cd ..

echo --------------------------
echo Download and install tesseract
echo --------------------------

:: CLONE TESSERACT
git clone https://github.com/tesseract-ocr/tesseract tesseract
cd tesseract

:: CONFIGURE LEPTONICA
echo configure tesseract
cmake -Bbuild -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=%INSTALL_DIR% ^
-DCMAKE_PREFIX_PATH=%INSTALL_DIR% ^
-DLeptonica_DIR=%INSTALL_DIR%\lib\cmake  ^
-DBUILD_TRAINING_TOOLS=OFF ^
-DSW_BUILD=OFF ^
-DOPENMP_BUILD=OFF -DBUILD_SHARED_LIBS=ON || GOTO FAILED

:: BUILD AND INSTALL LEPTONICA TO INSTALL_DIR
echo build and install tesseract
cmake --build build --config Release --target install || GOTO FAILED

cd ..

echo --------------------------
echo Finished successfully
echo You should now find in root/build/bin and root/build/lib 
echo --------------------------
GOTO END

:FAILED
echo Failed!
echo BuildWindows.bat failed!
echo Exit, return 1
EXIT /b 1

:END
echo Success!
echo Finished BuildWindows.bat
echo Exit, return 0
EXIT /b 0