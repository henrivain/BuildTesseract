You build output for each platform is in <platform>/build/lib


## On Android

Build produces dynamic libraries: 

```
libturbojpeg.so
libtiffxx.so
libtiff.so
libtesseract.so
libpng16.so
libpng.so
libopenjp2.so
libleptonica.so
libjpeg.so
```

As you can read with command (run also for dependency libraries, just use other library instead of libtesseract.so)

```ps 
"%NDK%\toolchains\llvm\prebuilt\windows-x86_64\bin\llvm-readelf.exe" -d <platform>\build\lib\libtesseract.so | findstr NEEDED
```

You only need to include

```
libtesseract.so
libleptonica.so
libjpeg.so
libpng16.so
libtiff.so
```

## On Windows 

Build produces following dlls

```
jpeg62.dll
leptonica-1.86.1.dll
libpng16.dll
tesseract55.dll
tiff.dll
turbojpeg.dll
z.dll
zlib1.dll
```

You can see dependent dlls with `dumpbin` command from visual studio

```
SET VISUAL_STUDIO_ENV="C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\"

call %VISUAL_STUDIO_ENV%vcvars64.bat

dumpbin /dependents tesseract55.dll
```

With dumbin we can see, that we only need

```
tesseract55.dll
leptonica-1.86.1.dll
jpeg62.dll
libpng16.dll
tiff.dll
z.dll
```