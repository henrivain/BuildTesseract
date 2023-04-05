:: Copyright Henri Vainio 2023
:: This script builds tesseract ocr for Android in Windows 11
:: Unzip, Curl, GIT and Cmake are required to be installed on this build device
:: Instruction on Github repository https://github.com/henrivain/BuildTesseract
:: This script was written in 5.4.2023
:: Build tool versions might have changed and broken the script after writing

@echo off

setlocal

echo Build Tesseract ocr 
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


mkdir x86
mkdir x86_64
mkdir arm64-v8a
mkdir arm-v7a

echo ------------------------------
echo Build x86
echo ------------------------------

cd x86

..\BuildAndroid x86 || GOTO FAILED

cd ..


SET BATCH_DIR=%~dp0

if exist "%BATCH_DIR%\android-ndk-r25c\"(
    echo NDK exist inside batch file folder, no need to copy.
) else (
    mkdir android-ndk-r25c
    copy x86\android-ndk-r25c android-ndk-r25c\  || echo Cannot copy NDK to root folder, it might already exist in it.
)

if exist "%BATCH_DIR%\platform-tools\" (
    echo platform-tools exist inside batch file folder, no need to copy.
) else (
    mkdir platform-tools
    copy x86\platform-tools platform-tools\ || echo Cannot copy platform-tools to root folder, it might already exist in it
)





echo ------------------------------
echo Build x86_64
echo ------------------------------

cd x86_64

..\BuildAndroid x86_64 || GOTO FAILED

cd ..


echo ------------------------------
echo Build arm64-v8a
echo ------------------------------

cd arm64-v8a

..\BuildAndroid arm64-v8a || GOTO FAILED

cd ..


echo ------------------------------
echo Build arm-v7a
echo ------------------------------

cd arm-v7a

..\BuildAndroid arm-v7a || GOTO FAILED

cd ..


echo SUCCESS!
echo Output can be found inside platform folder

GOTO END

:FAILED
echo failed

:END
echo Exit build all.