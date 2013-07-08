#!/bin/bash

# Installation location
# Note: we're only building arm-linux-androideabi currently
#
# TODO: support more triplets

# Build for the target
[ -z $ANDROID_BUILD_TOP/prebuilts/clang/linux-x86/arm ] && mkdir -p $ANDROID_BUILD_TOP/prebuilts/clang/linux-x86/arm
DEST=$ANDROID_BUILD_TOP/prebuilts/clang/linux-x86/arm/arm-linux-androideabi

# Parallel build flag passed to make
[ -z "$SMP" ] && SMP="-j`getconf _NPROCESSORS_ONLN`"

cpu_variant="$TARGET_CPU_VARIANT"

# Set locales to avoid python warnings
# or errors depending on configuration
export LC_ALL=C

# Set our local paths
DIR="$ANDROID_BUILD_TOP/external/codefirex"
SRC="$DIR/llvm"

# Keep things updated
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
if [ "$cpu_variant" = "$krait" ]; then
    $SRC/configure \
            -prefix="$DEST" \
            -target=arm-linux-androideabi \
            CC="ccache gcc" \
            CXX="ccache g++" \
            --with-tune=cortex-a9 \
            --enable-targets="arm, cpp" \
            --enable-optimized \
            --disable-assertions
else
    $SRC/configure \
            -prefix="$DEST" \
            -target=arm-linux-androideabi \
            CC="ccache gcc" \
            CXX="cacche g++" \
	    --with-tune="$TARGET_CPU_VARIANT" \
            --enable-targets="arm, cpp" \
            --enable-optimized \
            --disable-assertions 
fi

# Make and install the toolchain to the proper path
# Install only if compile suceeds
make $SMP && make install

echo ""
echo "=========================================================="
echo "Target toolchain build successful."
echo "The clang toolchain can be found in $DEST."
echo "Now building Android with cfX-Toolchain."
echo "=========================================================="
echo ""

# Go back to android build top to continue the build
cd $ANDROID_BUILD_TOP

exit 0
