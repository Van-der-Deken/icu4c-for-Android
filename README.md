# icu4c for Android
icu4c 60.2 with patched build system, so now it can be easily built for Android
## How to build
To build icu4c for Android you need installed autotools and Android NDK

For host systems, that support bash scripts (Mac OS X, Linux, Solaris) you should just run `build.sh`. Build for Android would be installed in `install` directory. For now supported only shared libraries (problem with linking static libraries with NDK's STL). Script tested on WSL.

On other systems, you can follow guides how cross compile icu4c for other system on your environment.