You build output for each platform is in <platform>/build/lib

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