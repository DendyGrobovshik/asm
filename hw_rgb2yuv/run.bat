:: Windows GUIDE
:: note: Run this in x64 Native Tools Command Prompt for VS 2022
:: note: use your paths
:: 0. Install nasm (https://www.nasm.us/pub/nasm/releasebuilds/?C=M;O=D)
:: 1. Install Visual Studio 2022
:: 2. Download libjpeg (https://www.ijg.org/files/ e.g. jpegsr9e.zip)
:: 3. unpack, run `nmake /f makefile.vs setup-v17` (check install.txt for more)
:: 4. open jpeg.sln in Visual Studio 2022, change target to x64, build (nevermind runnning .lib issue)
:: 5. run.bat in terminal


x64@echo off

nasm -f win64 rgb_yuv.asm -o asm.obj

cl rgb_yuv.c -I"C:\Users\Denis\Downloads\jpegsr9e2\jpeg-9e" /link /LIBPATH:"C:\Users\Denis\Downloads\jpegsr9e2\jpeg-9e\Release\x64" jpeg.lib asm.obj /LTCG /NODEFAULTLIB:libcmt.lib

rgb_yuv.exe


:: Create VS code new terminal profile
:: note: use your paths
:: 1. Create term.bat with line below:
::      %comspec% /k "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
:: 2. Insert lines below to setting.json:
::      "window.zoomLevel": 1,
::      "terminal.integrated.profiles.windows": {
::          "x64": {
::              "path": "C:\\Users\\Denis\\term64.bat",
::              "args": []
::          }
::      },
::      "terminal.integrated.defaultProfile.windows": "x64"