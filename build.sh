#!/bin/bash

ANDROID_NDK=$ANDROID_NDK
CURRENT_DIR=$(pwd)

if [ -z $ANDROID_NDK ]
then
    read -p "Enter path to Android NDK:" ANDROID_NDK
fi

read -p "Create standalone toolchain (Y/N)? " DECISION
case $DECISION in
    [Yy]* )
        read -p "Enter arch (arm/arm64/x86/x86_64): " TOOLCHAIN_ARCH
        read -p "Enter API level(for example 24): " TOOLCHAIN_API
        cd $ANDROID_NDK/build/tools
        echo "Creating standalone toolchain in ${ANDROID_NDK}/toolchains/${TOOLCHAIN_ARCH}-androideabi-clang-${TOOLCHAIN_API}"
        python make_standalone_toolchain.py --arch $TOOLCHAIN_ARCH --api $TOOLCHAIN_API --stl=libc++ --install-dir $ANDROID_NDK/toolchains/$TOOLCHAIN_ARCH-androideabi-clang-$TOOLCHAIN_API
        echo "Toolchain created"
        STANDALONE_TOOLCHAIN=$ANDROID_NDK/toolchains/$TOOLCHAIN_API-androideabi-clang-$TOOLCHAIN_API
        TOOLCHAIN_PREFIX=$TOOLCHAIN_ARCH-linux-androideabi
        cd $CURRENT_DIR
        ;;
    [Nn]* )
        read -p "Path to existing standalone toolchain: " STANDALONE_TOOLCHAIN
        read -p "Toolchain's prefix triplet for binaries (arm-linux-androideabi if arm-linux-androideabi-clang): " TOOLCHAIN_PREFIX
        ;;
    * )
        echo "Please answer Y/y or N/n";;
esac

if [ -d install ]
then
    export CC=$TOOLCHAIN_PREFIX-clang
    export CXX=$TOOLCHAIN_PREFIX-clang++
    export NDK=$ANDROID_NDK
    export SYSROOT=$STANDALONE_TOOLCHAIN/sysroot
    PATH=$PATH:$STANDALONE_TOOLCHAIN/bin
    export CFLAGS="${CFLAGS} --sysroot=$SYSROOT"
    export CPPFLAGS="${CPPFLAGS} --sysroot=$SYSROOT"
    export CXXFLAGS="${CXXFLAGS} --sysroot=$SYSROOT -std=c++11"
    export LDFLAGS="${LDFLAGS} -L${SYSROOT}/usr/lib -L${STANDALONE_TOOLCHAIN}/lib -lc++_shared"

    cd ./android_build
    make
    make install
else
    mkdir host_build
    mkdir android_build
    mkdir install
    cd ./host_build
    read -p "Host operation system (Linux/MacOSX/Solaris): " HOST_OS
    sh ../source/runConfigureICU.sh $HOST_OS
    make

    export CC=$TOOLCHAIN_PREFIX-clang
    export CXX=$TOOLCHAIN_PREFIX-clang++
    export NDK=$ANDROID_NDK
    export SYSROOT=$STANDALONE_TOOLCHAIN/sysroot
    PATH=$PATH:$STANDALONE_TOOLCHAIN/bin
    export CFLAGS="${CFLAGS} --sysroot=${SYSROOT}"
    export CPPFLAGS="${CPPFLAGS} --sysroot=${SYSROOT}"
    export CXXFLAGS="${CXXFLAGS} --sysroot=${SYSROOT} -std=c++11"
    export LDFLAGS="${LDFLAGS} -L${SYSROOT}/usr/lib -L${STANDALONE_TOOLCHAIN}/lib -lc++_shared"
    export PREFIX=$CURRENT_DIR/install

    cd ../android_build
    sh ../source/configure --host=arm-linux-androideabi --target=arm-linux-androideabi --prefix=$PREFIX --with-cross-build=$CURRENT_DIR/host_build
    make
    make install
fi
