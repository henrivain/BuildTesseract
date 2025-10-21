# Build Tesseract

Instructions to build tesseract from source.

_This is a part of my journey in learning how to use native libraries with .NET MAUI._

This repository contains information about how to build [Tesseract ocr](https://github.com/tesseract-ocr/tesseract) for different platforms from source. I needed Tesseract for my C# project, but wasn't able to find any good package for ocr that would run on Android. I haven't build C/C++ projects from source before, so I had some difficulties. When I finally found working instructions I gathered them here with some of my own thinking and fixing problems, like missing dependency. I also wrote a little script that can automatically build for Android. I hope this helps someone! I am still beginner with these build tools, so if there are any mistakes let me know!

## Instuctions

| Platform          | File                                                                                                                                                         |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Android arm64_v8a | [BuildingAndroidArchitectures.md](https://github.com/henrivain/BuildTesseract/blob/55de161a8152dde7aab03d24e1943175630725d8/BuildingAndroidArchitectures.md) |
| Android arm_v7a   | [BuildingAndroidArchitectures.md](https://github.com/henrivain/BuildTesseract/blob/55de161a8152dde7aab03d24e1943175630725d8/BuildingAndroidArchitectures.md) |
| Android x86_64    | [BuildingAndroidArchitectures.md](https://github.com/henrivain/BuildTesseract/blob/55de161a8152dde7aab03d24e1943175630725d8/BuildingAndroidArchitectures.md) |
| Android x86       | [BuildingAndroidArchitectures.md](https://github.com/henrivain/BuildTesseract/blob/55de161a8152dde7aab03d24e1943175630725d8/BuildingAndroidArchitectures.md) |
| Windows x86_64    | [BuildingForWindowsx86_64.md](https://github.com/henrivain/BuildTesseract/blob/55de161a8152dde7aab03d24e1943175630725d8/BuildingForWindowsx86_64.md)         |

## Available build scripts

| Architecture           | Instructions                                                                                                                                             | Script           |
| ---------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------- |
| Android arm64_v8a      | [BuildingAndroidUsingScript.md](https://github.com/henrivain/BuildTesseract/blob/6630fe58a572ccb3c400ccb0daa5e317b6f20f8f/BuildingAndroidUsingScript.md) | BuildAndroid.bat |
| Android arm_v7a        | [BuildingAndroidUsingScript.md](https://github.com/henrivain/BuildTesseract/blob/6630fe58a572ccb3c400ccb0daa5e317b6f20f8f/BuildingAndroidUsingScript.md) | BuildAndroid.bat |
| Android Android x86_64 | [BuildingAndroidUsingScript.md](https://github.com/henrivain/BuildTesseract/blob/6630fe58a572ccb3c400ccb0daa5e317b6f20f8f/BuildingAndroidUsingScript.md) | BuildAndroid.bat |
| Android x86            | [BuildingAndroidUsingScript.md](https://github.com/henrivain/BuildTesseract/blob/6630fe58a572ccb3c400ccb0daa5e317b6f20f8f/BuildingAndroidUsingScript.md) | BuildAndroid.bat |

## Available precompiled binaries

All can be found inside `Binaries` folder
All are build using newest available (No release) code from repositories. Newest Tesseract release at the time of writing is 5.5.1 (21.10.2025).

> Android Arm64_v8a  
> Android Arm_v7a  
> Android x86_64  
> Android x86  
> Windows x86_64
