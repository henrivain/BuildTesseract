:: Copyright Henri Vainio 2023
:: This script builds tesseract ocr for Android in Windows 11
:: Unzip, Curl, GIT and Cmake are required to be installed on this build device
:: Instructions can be found on Github repository https://github.com/henrivain/BuildTesseract
:: This script was written in 5.4.2023
:: Last updated with verified successful run 3.12.2023
:: Build tool versions might have changed and broken the script after writing

@echo off

setlocal

echo Build Tesseract ocr 
echo for all Android platforms
echo script by Henri Vainio
echo -------------------------------------------------------------
echo Build to all Android architechtures.
echo x86, x86_64, arm64-v8a, arm-v7a.
echo Expecting batch file folder to contain BuildAndroid.bat
echo Expecting path to this folder not to contain spaces.
echo You should have unzip, curl, git and cmake installed.
echo Uses Android API 21
echo Next script will create output folder to this folder 
echo and then start loading tools and build.
SET /P ISCORRECTINPUT="Is information correct? (Y/[N]) >"
IF /I "%ISCORRECTINPUT%" NEQ "Y" GOTO END

echo ------------------------------
echo Configure tool versions
echo ------------------------------
SET NDK_VERSION=android-ndk-r26b
SET PLATFORM_TOOLS_VERSION=platform-tools_r34.0.4-windows

echo Uses %NDK_VERSION% and %PLATFORM_TOOLS_VERSION%

echo ------------------------------
echo Create result folders
echo ------------------------------

echo \x86
echo \x86_64
echo \arm64-v8a
echo \arm-v7a

mkdir x86
mkdir x86_64
mkdir arm64-v8a
mkdir arm-v7a

echo ------------------------------
echo Build x86
echo ------------------------------

cd x86

CALL ..\BuildAndroid x86 --NDK_V %NDK_VERSION% --PT_V %PLATFORM_TOOLS_VERSION% || GOTO FAILED

cd ..

echo x86 ready
echo Check if tools can be copied

SET BATCH_DIR=%~dp0

if exist "%BATCH_DIR%\%NDK_VERSION%\" (
    echo NDK exist inside batch file folder, no need to copy.
) else (
    mkdir %NDK_VERSION%
    :: Copy ndk to batch file directory
    xcopy x86\%NDK_VERSION% %NDK_VERSION%\ /h /i /c /k /e /r /y || echo Cannot copy NDK to root folder, it might already exist in it.
)

if exist "%BATCH_DIR%\platform-tools\" (
    echo platform-tools exist inside batch file folder, no need to copy.
) else (
    mkdir platform-tools
    :: Copy platform tools to batch file directory
    xcopy x86\platform-tools platform-tools\ /h /i /c /k /e /r /y || echo Cannot copy platform-tools to root folder, it might already exist in it
)


echo ------------------------------
echo Build x86_64
echo ------------------------------

cd x86_64

CALL ..\BuildAndroid x86_64 --NDK_V %NDK_VERSION% --PT_V %PLATFORM_TOOLS_VERSION% || GOTO FAILED

cd ..


echo ------------------------------
echo Build arm64-v8a
echo ------------------------------

cd arm64-v8a

CALL ..\BuildAndroid arm64-v8a --NDK_V %NDK_VERSION% --PT_V %PLATFORM_TOOLS_VERSION% || GOTO FAILED

cd ..


echo ------------------------------
echo Build arm-v7a
echo ------------------------------

cd arm-v7a

CALL ..\BuildAndroid arm-v7a --NDK_V %NDK_VERSION% --PT_V %PLATFORM_TOOLS_VERSION% || GOTO FAILED

cd ..


echo SUCCESS!
echo Output can be found inside platform folder

GOTO END

:FAILED
echo Failed!
echo Exit build all.
EXIT /b 1

:END
echo Success!
echo Exit build all.
echo Exit, return 0
EXIT /b 0