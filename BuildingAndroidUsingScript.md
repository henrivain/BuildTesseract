# Using provided build script

You can find build scripts I have written in the repository `Scripts` folder

Build platform: `Windows 11 64bit`

Build Target: `Android`

Target Architectures: `Arm_v8a (64bit), Arm_v7a (32bit), x86 (32bit), x86_64 (64bit)`

## Required tools

You must have Curl, Unzip, Git and Cmake installed

Tool installations

### Git

```powershell
winget install Git.Git
```

### Unzip

```powershell
winget install -e --id GnuWin32.UnZip
```

### Cmake

```powershell
winget install cmake
```

Curl should be installed as a part of Windows 10/11

## Configuration

For Android you have four target architechtures `Arm64_v8a`, `Arm_v7a`, `x86` and `x86_64`

You can see possible configurations (28.3.2023) down below. You can build one row at the time.

|  Platform   | ABI (Application binary interface) | Target                   | APIs  |
| :---------: | :--------------------------------: | ------------------------ | ----- |
| Arm (64bit) |             arm64-v8a              | aarch64-linux-android    | 21-33 |
| Arm (32bit) |            armeabi-v7a             | armv7a-linux-androideabi | 19-33 |
| x86 (64bit) |                x86                 | i686-linux-android       | 19-33 |
| x86 (32bit) |               x86_64               | x86_64-linux-android     | 21-33 |

### Run script

1. I have created new empty folder `arm_v7a` and copied BuildAndroid.bat in it. This folder can have any folder.
2. Then in my terminal I ran the script with `.\BuildAndroid.bat`
3. Script will ask me if I have installed Unzip, Curl, Git and Cmake. If you have, answer `Y` and continue. If you haven't you must install all required tools and rerun.
4. Script will ask for `TARGET`, choose your target architecture and choose equivalent Target, from table above.
5. Next give one of available `API`s for your architecture. Older APIs should work with more devices.
6. Last script will ask for Application binary interface (`ABI`).
7. Finally answer `Y`, if all information is correct.

Here is example of building for arm_v7a with API 21.

```powershell
C:\Users\MyDirectory\arm_v7a>.\BuildAndroid.bat
Build Tesseract ocr
script by Henri Vainio
-------------------------------------------------------------
Do you have unzip, curl, git and cmake installed? Are you inside empty folder?
Y/[N] >Y
Give build TARGET >armv7a-linux-androideabi
Give Android API >21
Give Android ABI >armeabi-v7a
Is information correct? (Y/[N]) >Y
```

## Wait

After configuration script tries to find Android NDK and platform-tools from folder you ran the script from or from the folder where script is located. If it doesn't find them, they will be downloaded automatically. Now you just need to wait and hope, that no errors occur. Downloads might take even a minute to start.

Finally you should get

```powershell
--------------------------
Finished successfully
find input in root/build/bin and root/build/lib
--------------------------
Exit
```

If you see this screen, everything worked prefectly and you should now have built libraries in build/lib and build/bin folders.

Example of my folder structure

```
> arm_v7a
    > build
        > lib
            > libtesseract.so
            > libleptonica.so
            > libpng.so
        > bin
            > tesseract
        > include
        > share
    > libpng.zip
    > tesseract
    > leptonica
    > libpng
```

You might also have additional files like for example android-ndk-r25c.zip if you didn't have it at the start.

Now just copy Tesseract libraries and use them in your projects.

<br></br>
by
[Henri Vainio](https://github.com/henrivain) 27.3.2023
