#!/bin/bash

# Installation location
# Note: we're only building arm-linux-androideabi currently
#
# TODO: support more triplets

# Build for the host
[ -z $ANDROID_BUILD_TOP/prebuilts/clang/linux-x86/x86/i686-linux-android ] && mkdir -p $ANDROID_BUILD_TOP/prebuilts/clang/linux-x86/x86/i686-linux-android
DEST=$ANDROID_BUILD_TOP/prebuilts/clang/linux-x86/x86/i686-linux-android

# Parallel build flag passed to make
[ -z "$SMP" ] && SMP="-j`getconf _NPROCESSORS_ONLN`"

# Set locales to avoid python warnings
# or errors depending on configuration
export LC_ALL=C

# Set our local paths
DIR="$ANDROID_BUILD_TOP/external/codefirex"
SRC="$DIR/llvm"

cd $SRC
git pull
cd tools/clang
git pull origin master
cd ../../projects/compiler-rt
git pull

mkdir -p $OUT/toolchain_build
cd $OUT/toolchain_build

# Configure the build for arm-linux-androideabi
# with all additional arguments.
# Also set --with-tune for TARGET_CPU_VARIANT
$SRC/configure \
        -prefix="$DEST" \
        -target i686-linux-android \
	CC="ccache gcc" \
        CXX="ccache g++" \
	--enable-targets="x86_64, cpp" \
        --enable-optimized \
        --disable-assertions

# Make and install the toolchain to the proper path
make $SMP && make install

#We need to copy the necessary makefiles for the
# Android build system now.
cp $DIR/Makefiles/clang/*.mk $DEST/
cp $DIR/Makefiles/clang/lib/Android.mk $DEST/lib/Android.mk

echo ""
echo "=========================================================="
echo "Toolchain build successful."
echo "The clang toolchain can be found in $DEST."
echo "Now building Android with cfX-Toolchain."
echo "=========================================================="
echo ""

# Go back to android build top to continue the build
cd $ANDROID_BUILD_TOP

