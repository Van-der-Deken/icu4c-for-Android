# Build iuc4c for Android
This topic contains some hacks, which allow build all ICU shared libraries from [sources](http://site.icu-project.org/download) for Android. If you need only `libicuuc` and `libicui18n` and accept static libraries, you can try [this solution](https://github.com/couchbaselabs/icu4c-android).

First of all, you need to build icu4c for host. It can simply done by using `runConfigureICU` (all commands executed inside `icu` directory):

    mkdir buildA
    cd buildA
    sh ../sources/runConfigureICU [host os] [additional flags]
    make (or gnumake on Mac)

For example: `sh ../sources/runConfigureICU Linux --enable-static`

After this you should configure build for Android (all commands executed inside `icu` directory):

    export CC=<full name of preferred C compiler executable in toolchain>
    export CXX=<full name of preferred C++ compiler executable in toolchain>
    export NDK=<path to NDK (without last /)>
    export SYSROOT=<path to sysroot directory in toolchain (without last /)>
    PATH=$PATH:<path to bin directory of used toolchain (without last /)>
    export CFLAGS="${CFLAGS} --sysroot=$SYSROOT"
    export CPPFLAGS="${CPPFLAGS} --sysroot=$SYSROOT"
    export CXXFLAGS="${CXXFLAGS} --sysroot=$SYSROOT"
    export LDFLAGS="${LDFLAGS} -L${SYSROOT}/usr/lib -L<path to lib directory of toolchain (without last /)> -lgnustl_shared"
    mkdir buildB
    cd buildB
    sh ../sources/configure --host=<target platform> --target=<target platform> --with-cross-build=<path to icu directory>/icu/buildA

For example: `sh ../sources/configure --host=arm-linux-androideabi --target=arm-linux-androideabi --with-cross-build=/Users/test/icu/buildA`

**NOTE:** This commands can confugure only some versions of icu4c, not all (so customize some commands above or lib's source code to configure particular version)

**NOTE 2:** `-lgnustl_shared` important to avoid undefined references during linking

When configuration ended, open `icudefs.mk` in `buildB` and make following changes:

Before:

    FINAL_SO_TARGET = $(SO_TARGET).$(SO_TARGET_VERSION)
    MIDDLE_SO_TARGET = $(SO_TARGET).$(SO_TARGET_VERSION_MAJOR)

After:

    FINAL_SO_TARGET = $(SO_TARGET)
    MIDDLE_SO_TARGET = $(SO_TARGET)

Before:

    ICULIBS_DT	= -l$(STATIC_PREFIX_WHEN_USED)$(ICUPREFIX)$(DATA_STUBNAME)$(ICULIBSUFFIX)$(SO_TARGET_VERSION_SUFFIX)
    ICULIBS_UC	= -l$(STATIC_PREFIX_WHEN_USED)$(ICUPREFIX)$(COMMON_STUBNAME)$(ICULIBSUFFIX)$(SO_TARGET_VERSION_SUFFIX)
    ICULIBS_I18N	= -l$(STATIC_PREFIX_WHEN_USED)$(ICUPREFIX)$(I18N_STUBNAME)$(ICULIBSUFFIX)$(SO_TARGET_VERSION_SUFFIX)
    ICULIBS_LX	= -l$(STATIC_PREFIX_WHEN_USED)$(ICUPREFIX)$(LAYOUTEX_STUBNAME)$(ICULIBSUFFIX)$(SO_TARGET_VERSION_SUFFIX)
    ICULIBS_IO	= -l$(STATIC_PREFIX_WHEN_USED)$(ICUPREFIX)$(IO_STUBNAME)$(ICULIBSUFFIX)$(SO_TARGET_VERSION_SUFFIX)
    ICULIBS_CTESTFW	= -l$(STATIC_PREFIX_WHEN_USED)$(ICUPREFIX)$(CTESTFW_STUBNAME)$(ICULIBSUFFIX)$(SO_TARGET_VERSION_SUFFIX)
    ICULIBS_TOOLUTIL = -l$(STATIC_PREFIX_WHEN_USED)$(ICUPREFIX)$(TOOLUTIL_STUBNAME)$(ICULIBSUFFIX)$(SO_TARGET_VERSION_SUFFIX)

After:

    ICULIBS_DT	= -l$(STATIC_PREFIX_WHEN_USED)$(ICUPREFIX)$(DATA_STUBNAME)$(ICULIBSUFFIX)
    ICULIBS_UC	= -l$(STATIC_PREFIX_WHEN_USED)$(ICUPREFIX)$(COMMON_STUBNAME)$(ICULIBSUFFIX)
    ICULIBS_I18N	= -l$(STATIC_PREFIX_WHEN_USED)$(ICUPREFIX)$(I18N_STUBNAME)$(ICULIBSUFFIX)
    ICULIBS_LX	= -l$(STATIC_PREFIX_WHEN_USED)$(ICUPREFIX)$(LAYOUTEX_STUBNAME)$(ICULIBSUFFIX)
    ICULIBS_IO	= -l$(STATIC_PREFIX_WHEN_USED)$(ICUPREFIX)$(IO_STUBNAME)$(ICULIBSUFFIX)
    ICULIBS_CTESTFW	= -l$(STATIC_PREFIX_WHEN_USED)$(ICUPREFIX)$(CTESTFW_STUBNAME)$(ICULIBSUFFIX)
    ICULIBS_TOOLUTIL = -l$(STATIC_PREFIX_WHEN_USED)$(ICUPREFIX)$(TOOLUTIL_STUBNAME)$(ICULIBSUFFIX)

This fixes adding version number after `.so` and linking. After this open `Makefile` in `data` and change following:

Before:

    PKGDATA_VERSIONING = -r $(SO_TARGET_VERSION)

After:

    PKGDATA_VERSIONING =

Now execute `gnumake` command. All should be successfuly build, but this changes cause one problem: in `lib` directory you recieve `libicudataso` instead of `libicudata.so`. To fix this (this isn't problem solution, just simple hack to quickly get result) open `icupkg.inc` in `data` and change this:

Before:

    SO=so
    SOBJ=so

After:

    SO=.so
    SOBJ=.so

Execute `gnumake` in `data` directory. You'll recieve absolutly correct `libicudata.so` in `lib`.

This hacks tried with 56.1 and 58.2 versions of icu4c