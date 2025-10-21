:: Copyright Henri Vainio 2025
:: This script builds tesseract ocr for Windows
:: Expects Unzip, Curl, GIT, Cmake and Visual studio 2022 to be installed on build device
:: Instructions can be found on Github repository https://github.com/henrivain/BuildTesseract
:: This script originally was written in 6.4.2023
:: Last verified successfull run was 21.10.2025 
:: Build tool versions might have changed and broken the script after writing

@echo off

setlocal

echo Build Tesseract ocr 
echo for all Android platforms
echo script by Henri Vainio
echo -------------------------------------------------------------
echo Build to Windows architechtures.
echo x86_64 (x86 not supported currently)
echo Expecting batch file folder to contain BuildWindows.bat
echo Expecting path to this folder not to contain spaces.
echo You should have unzip, curl, git, cmake and Visual studio 2022 installed.
echo Next script will create output folder to this folder 
echo and then start loading tools and build.
SET /P ISCORRECTINPUT="Is information correct? (Y/[N]) >"
IF /I "%ISCORRECTINPUT%" NEQ "Y" GOTO END



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

echo ------------------------------
echo Create result folders
echo ------------------------------

:: Script currently only supports x86_64
:: echo \x86
echo \x86_64

:: mkdir x86
mkdir x86_64

:: Script currently only supports x86_64

:: echo ------------------------------
:: echo Build x86
:: echo ------------------------------
:: cd x86
::CALL ..\BuildWindows x86 %VISUAL_STUDIO_ENV% || GOTO FAILED
:: cd ..

echo ------------------------------
echo Build x86_64
echo ------------------------------

cd x86_64

CALL ..\BuildWindows x86_64 %VISUAL_STUDIO_ENV% || GOTO FAILED

cd ..


GOTO END

:FAILED
echo Failed!
echo BuildAllWindows.bat failed.
echo Exit, return 1
EXIT /b 1

:END 
echo Success!
echo Finished BuildAllWindows.bat successfully.
echo Exit, return 0
EXIT /b 0