#!/bin/bash

# Wanted versions
[ -z "$BINUTILS" ] && BINUTILS=2.23.51.0.8
[ -z "$GCC" ] && GCC=lp:gcc-linaro
[ -z "$GMP" ] && GMP=5.0.5
[ -z "$MPFR" ] && MPFR=3.1.1
[ -z "$MPC" ] && MPC=1.0
[ -z "$MAKE" ] && MAKE=3.82
[ -z "$NCURSES" ] && NCURSES=5.9
[ -z "$VIM" ] && VIM=7.3
[ -z "$ANDROID" ] && ANDROID=4.1.2

# Everything below is needed only for rpm support
[ -z "$WITH_RPM" ] && WITH_RPM=false
[ -z "$DB" ] && DB=5.3.15
[ -z "$BEECRYPT" ] && BEECRYPT=4.2.1
[ -z "$POPT" ] && POPT=1.16
[ -z "$PCRE" ] && PCRE=8.31

# Installation location
[ -z "$DEST" ] && DEST=/tmp/android-native-toolchain

# Parallel build flag passed to make
[ -z "$SMP" ] && SMP="-j`getconf _NPROCESSORS_ONLN`"

# Whether or not we're building inside an Android source tree
[ "$INTREE" != "true" ] && INTREE=false

# Set to true to keep Bionic. (This shouldn't be copied to the device
# because it's already there -- but it can be useful to do a sysroot-like
# install.)
KEEP_BIONIC=false

export TARGET_CFLAGS="$CFLAGS -Os -march=armv7-a"
export TARGET_CXXFLAGS="$CXXFLAGS -Os -march=armv7-a"

# Don't edit anything below unless you know exactly what you're doing.
set -e

export LC_ALL=C

DIR="$(readlink -f $(dirname $0))"
cd "$DIR"
if ! [ -d tc-wrapper ]; then
	# Workaround for
	#	1. toolchain not being properly sysrooted
	#	2. gcc not making a difference between CPPFLAGS for build and host machine
	mkdir tc-wrapper
	gcc -std=gnu99 -o tc-wrapper/arm-linux-androideabi-gcc tc-wrapper.c -DCCVERSION=\"4.7.3\" -DTCROOT=\"/tmp/arm-linux-androideabi\" -DDESTDIR=\"$DEST\"
	for i in cpp g++ c++; do
		ln -s arm-linux-androideabi-gcc tc-wrapper/arm-linux-androideabi-$i
	done
fi
SRC="$DIR/src"
[ -d src ] || mkdir src
cd src
if ! [ -d binutils ]; then
	git clone git://android.git.linaro.org/toolchain/binutils-current.git binutils
	cd binutils
	git checkout -b linaro-$BINUTILS origin/linaro-$BINUTILS
	cd ..
fi
if ! [ -d gmp ]; then
	git clone git://android.git.linaro.org/toolchain/gmp.git
	cd gmp
	git checkout -b linaro-master origin/linaro-master
	cd ..
fi
if ! [ -d mpfr ]; then
	git clone git://android.git.linaro.org/toolchain/mpfr.git
	cd mpfr
	git checkout -b linaro-master origin/linaro-master
	cd ..
fi
if ! [ -d mpc ]; then
	git clone git://android.git.linaro.org/toolchain/mpc.git
	cd mpc
	git checkout -b linaro-master origin/linaro-master
	cd ..
fi
if ! [ -d gcc ]; then
	bzr branch $GCC gcc
	patch -p0 <"$DIR/gcc-4.7-android-workarounds.patch"
	patch -p0 <"$DIR/gcc-4.7-no-unneeded-multilib.patch"
	patch -p0 <"$DIR/gcc-4.7-stlport.patch"
fi
if ! [ -d make-$MAKE ]; then
	wget ftp://ftp.gnu.org/gnu/make/make-$MAKE.tar.bz2
	tar xf make-$MAKE.tar.bz2
	cd make-$MAKE
	patch -p1 <"$DIR/make-3.82-android-default-shell.patch"
	cd ..
fi
if ! [ -d ncurses-$NCURSES ]; then
	wget ftp://invisible-island.net/ncurses/ncurses-$NCURSES.tar.gz
	tar xf ncurses-$NCURSES.tar.gz
	cd ncurses-$NCURSES
	patch -p1 <"$DIR/ncurses-5.9-android.patch"
	cd ..
fi
if $INTREE; then
	BIONIC=../bionic
	STLPORT=../external/stlport
	ZLIB=../external/zlib
else
	BIONIC=src/android/bionic
	STLPORT=src/android/external/stlport
	ZLIB=src/android/external/zlib
	if ! [ -d android ]; then
		mkdir -p android
		cd android
		git clone git://android.git.linaro.org/platform/bionic.git
		cd bionic
		git checkout -b linaro_android_$ANDROID origin/linaro_android_$ANDROID
		cd ..
		git clone git://android.git.linaro.org/platform/build.git
		cd build
		git checkout -b linaro_android_$ANDROID origin/linaro_android_$ANDROID
		cd ..
		mkdir -p device/linaro
		cd device/linaro
		git clone git://android.git.linaro.org/device/linaro/common.git
		cd common
		git checkout -b linaro-ics origin/linaro-ics
		cd ..
		git clone git://android.git.linaro.org/device/linaro/pandaboard.git
		cd pandaboard
		git checkout -b linaro-jb origin/linaro-jb
		cd ..
		cd ../..
		mkdir frameworks
		cd frameworks
		git clone git://android.git.linaro.org/platform/frameworks/native.git
		cd native
		git checkout -b linaro_android_$ANDROID origin/linaro_android_$ANDROID
		cd ..
		cd ..
		mkdir -p hardware/ti
		cd hardware/ti
		git clone git://android.git.linaro.org/platform/hardware/ti/omap4xxx
		cd omap4xxx
		git checkout -b linaro_android_$ANDROID origin/linaro_android_$ANDROID
		cd ..
		cd ../..
		mkdir system
		cd system
		git clone git://android.git.linaro.org/platform/system/core.git
		cd core
		git checkout -b linaro_android_$ANDROID origin/linaro_android_$ANDROID
		cd ..
		cd ..
		mkdir external
		cd external
		git clone git://android.git.linaro.org/platform/external/stlport.git
		cd stlport
		git checkout -b linaro_android_$ANDROID origin/linaro_android_$ANDROID
		cd ..
		cd ..
		ln -sf build/core/root.mk Makefile
		cd ..
	fi
fi
if $WITH_RPM; then
	if ! [ -d db-$DB ]; then
		wget http://download.oracle.com/berkeley-db/db-$DB.tar.gz
		tar xf db-$DB.tar.gz
	fi
	if ! [ -d popt-$POPT ]; then
		wget http://rpm5.org/files/popt/popt-$POPT.tar.gz
		tar xf popt-$POPT.tar.gz
		# popt's config.sub doesn't know about androideabi
		cp -f /usr/share/automake-1.12/config.sub popt-$POPT/
	fi
	if ! [ -d beecrypt-$BEECRYPT ]; then
		wget http://downloads.sourceforge.net/project/beecrypt/beecrypt/$BEECRYPT/beecrypt-$BEECRYPT.tar.gz
		tar xf beecrypt-$BEECRYPT.tar.gz
		cd beecrypt-$BEECRYPT
		patch -p1 <"$DIR/beecrypt-4.2.1-compile.patch"
		patch -p1 <"$DIR/beecrypt-4.2.1-inline.patch"
		aclocal
		libtoolize --force
		automake -a
		autoconf
		# beecrypt's config.sub doesn't know about androideabi
		cp -f /usr/share/automake-1.13/config.sub . || cp -f /usr/share/automake-1.12/config.sub .
		cd ..
	fi
	if ! [ -d pcre-$PCRE ]; then
		wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-$PCRE.tar.bz2
		tar xf pcre-$PCRE.tar.bz2
	fi
	if ! [ -d rpm-5.4.10 ]; then
		svn co svn+ssh://svn.mandriva.com/svn/packages/cooker/rpm/current/SOURCES
		tar xf SOURCES/rpm-5.4.10.tar.gz
		cd rpm-5.4.10
		patch -p1 <"$DIR/rpm-5.4.10-android.patch"
		cd ..
	fi
	if ! $INTREE && ! [ -d android/external/zlib ]; then
		cd android/external
		git clone git://android.git.linaro.org/platform/external/zlib.git
		cd zlib
		git checkout -b $ANDROID android-${ANDROID}_r1
		sed -i -e 's,LOCAL_NDK,# LOCAL_NDK,;s,LOCAL_SDK,# LOCAL_SDK,' Android.mk
		cd ../../..
	fi
fi
VIMD=`echo $VIM |sed -e 's,\.,,'` # Directory name is actually vim73 for vim-7.3 etc.
if ! [ -d vim$VIMD ]; then
	wget ftp://ftp.vim.org/pub/vim/unix/vim-$VIM.tar.bz2
	tar xf vim-$VIM.tar.bz2
	cd vim$VIMD
	patch -p1 <"$DIR/vim-7.3-crosscompile.patch"
	cd ..
fi
cd ..

$INTREE || rm -rf "$DEST"
# FIXME this is a pretty awful hack to make sure gcc can find
# its headers even though it has been taught Android doesn't
# have system headers (no proper sysroot)
# At some point, we should build a properly sysrooted compiler
# even if AOSP doesn't.
#
# We can't just cp -a bionic/libc/include \
# 	bionic/libc/arch-arm-include ... \
#	"$TC"/lib/gcc/arm-linux-androideabi/*/include
# because some files in kernel/arch-arm are supposed to overwrite
# files from libc/include
mkdir -p "$DEST"/system/include
for i in libc/include libc/arch-arm/include libc/kernel/common libc/kernel/arch-arm libm/include; do
	cp -a $BIONIC/$i/* "$DEST"/system/include
done
mkdir -p "$DEST/system/include/libstdc++"
cp -a $BIONIC/libstdc++/include "$DEST"/system/include/libstdc++/
# We'll need stlport headers too, as we're disabling libstdc++ when
# building gcc
cp -a $STLPORT/stlport "$DEST"/system/include/
# Make them match the include directory structure we're building
sed -i -e 's,\.\./include/header,../header,g;s,usr/include,system/include,g' "$DEST"/system/include/stlport/stl/config/_android.h
# And don't insist on -DANDROID when gcc already defines __ANDROID__ for us
sed -i -e 's,defined (ANDROID),defined (ANDROID) || defined (__ANDROID__),g' "$DEST"/system/include/stlport/stl/config/_system.h

rm -rf build
mkdir build
cd build

# First of all, build a cross-toolchain for the current host (properly sysrooted)
export PATH="$DIR/tc-wrapper:/tmp/arm-linux-androideabi/bin:$PATH"
mkdir -p binutils-host
cd binutils-host
$SRC/binutils/configure \
	--prefix=/tmp/arm-linux-androideabi \
	--target=arm-linux-androideabi \
	--enable-gold=default \
	--enable-shared \
	--disable-static \
	--disable-nls \
	--with-sysroot=$DEST
make $SMP
make install
cd ..

mkdir -p gcc-host-bootstrap
cd gcc-host-bootstrap
$SRC/gcc/configure \
	--prefix=/tmp/arm-linux-androideabi \
	--target=arm-linux-androideabi \
	--enable-languages=c,c++ \
	--with-gnu-as \
	--with-gnu-ar \
	--with-gnu-ld \
	--disable-shared \
	--disable-libssp \
	--disable-libmudflap \
	--disable-libstdc__-v3 \
	--disable-libitm \
	--disable-nls \
	--disable-libquadmath \
	--disable-sjlj-exceptions \
	--disable-libgomp \
	--with-sysroot=$DEST \
	--with-native-system-header-dir=/system/include
make $SMP
make install
cd ..

if $INTREE; then
	mkdir -p $DEST/system/lib
	cp $CRT/crt*.o $DEST/system/lib
else
	mkdir -p bionic
	cd bionic
	ONE_SHOT_MAKEFILE=build/libs/host/Android.mk make -C ../../src/android all_modules TARGET_TOOLS_PREFIX=/tmp/arm-linux-androideabi/bin/arm-linux-androideabi- TARGET_PRODUCT=pandaboard
	ONE_SHOT_MAKEFILE=build/tools/acp/Android.mk make -C ../../src/android all_modules TARGET_TOOLS_PREFIX=/tmp/arm-linux-androideabi/bin/arm-linux-androideabi- TARGET_PRODUCT=pandaboard
	ONE_SHOT_MAKEFILE=bionic/Android.mk make -C ../../src/android all_modules out/target/product/pandaboard/obj/lib/crtbegin_dynamic.o TARGET_TOOLS_PREFIX=/tmp/arm-linux-androideabi/bin/arm-linux-androideabi- TARGET_PRODUCT=pandaboard
	ONE_SHOT_MAKEFILE=external/stlport/Android.mk make -C ../../src/android all_modules TARGET_TOOLS_PREFIX=/tmp/arm-linux-androideabi/bin/arm-linux-androideabi- TARGET_PRODUCT=pandaboard
	mkdir -p "$DEST/system/lib"
	if $WITH_RPM; then
		ONE_SHOT_MAKEFILE=external/zlib/Android.mk make -C ../../src/android all_modules TARGET_TOOLS_PREFIX=/tmp/arm-linux-androideabi/bin/arm-linux-androideabi- TARGET_PRODUCT=pandaboard
		cp -L ../../src/android/external/zlib/*.h $DEST/system/include/
	fi
	cp ../../src/android/out/target/product/pandaboard/obj/lib/* $DEST/system/lib/
	cd ..
fi
if ! [ -d $DEST/system/lib/libpthread.a ]; then
	# Android's pthread bits are built into bionic libc -- but lots of traditional
	# Linux configure scripts just hardcode that there's a -lpthread...
	# Let's accomodate them
	touch dummy.c
	arm-linux-androideabi-gcc -O2 -o dummy.o -c dummy.c
	arm-linux-androideabi-ar cru $DEST/system/lib/libpthread.a dummy.o
	rm -f dummy.[co]
fi

export CFLAGS="$TARGET_CFLAGS"
export CXXFLAGS="$TARGET_CXXFLAGS"

echo "Relevant variables:"
echo "==================="
echo "export PATH=\"$PATH\""
echo "export CFLAGS=\"$CFLAGS\""
echo "export CXXFLAGS=\"$CXXFLAGS\""

mkdir -p binutils
cd binutils
# FIXME gold is disabled for now because it can't be built
# against stlport.
# Need to fix this, then --enable-gold=default
$SRC/binutils/configure \
	--prefix=/system \
	--target=arm-linux-androideabi \
	--host=arm-linux-androideabi \
	--enable-shared \
	--disable-static \
	--enable-gold=default \
	--disable-nls
make $SMP
make install DESTDIR=$DEST
rm -f $DEST/system/lib/*.la # libtool sucks, *.la files are harmful
cd ..

rm -rf gmp
mkdir -p gmp
cd gmp
$SRC/gmp/gmp-$GMP/configure \
	--prefix=/system \
	--disable-nls \
	--disable-static \
	--target=arm-linux-androideabi \
	--host=arm-linux-androideabi
make $SMP
make install DESTDIR=$DEST
rm -f $DEST/system/lib/*.la # libtool sucks, *.la files are harmful
cd ..

rm -rf mpfr
mkdir -p mpfr
cd mpfr
$SRC/mpfr/mpfr-$MPFR/configure \
	--prefix=/system \
	--disable-static \
	--target=arm-linux-androideabi \
	--host=arm-linux-androideabi \
	--with-sysroot=$DEST \
	--with-gmp-include=$DEST/system/include \
	--with-gmp-lib=$DEST/system/lib
make $SMP
make install DESTDIR=$DEST
rm -f $DEST/system/lib/*.la # libtool sucks, *.la files are harmful
cd ..

rm -rf mpc
mkdir -p mpc
cd mpc
pushd $SRC/mpc/mpc-$MPC
# Got to rebuild the auto* bits - the auto* versions
# they were built with are too old to recognize
# "androideabi"
libtoolize --force
cp -f /usr/share/libtool/config/config.* .
aclocal -I m4
automake -a
autoconf
popd
# libtool rather sucks
rm -f $DEST/system/lib/*.la
$SRC/mpc/mpc-$MPC/configure \
	--prefix=/system \
	--disable-static \
	--target=arm-linux-androideabi \
	--host=arm-linux-androideabi
make $SMP
make install DESTDIR=$DEST
rm -f $DEST/system/lib/*.la # libtool sucks, *.la files are harmful
cd ..

# TODO build CLooG and friends for graphite

export CXXFLAGS="-O2 -frtti"
rm -rf gcc
mkdir -p gcc
cd gcc
$SRC/gcc/configure \
	--prefix=/system \
	--target=arm-linux-androideabi \
	--host=arm-linux-androideabi \
	--enable-languages=c,c++ \
	--with-gnu-as \
	--with-gnu-ar \
	--with-gnu-ld \
	--disable-shared \
	--disable-libssp \
	--disable-libmudflap \
	--disable-libstdc__-v3 \
	--disable-libitm \
	--disable-nls \
	--disable-libquadmath \
	--disable-sjlj-exceptions
make $SMP
make install DESTDIR=$DEST
cd ..

# Remove superfluous bits
rm -rf \
	"$DEST"/system/lib/gcc/arm-linux-androideabi/*/include-fixed \
	"$DEST"/system/share/gcc-*

# Merge gcc headers into the /system/include directory so stlport
# can make (invalid) assumptions about their locations
for i in "$DEST"/system/lib/gcc/arm-linux-androideabi/*/include/*.h; do
	[ -e "$DEST"/system/include/"`basename $i`" ] || mv $i "$DEST"/system/include/
done

# For compatibility with make defaults
ln -s gcc "$DEST"/system/bin/cc

# Libtool sucks
rm -f "$DEST"/system/lib/*.la

rm -rf make
mkdir -p make
cd make
$SRC/make-$MAKE/configure \
	--prefix=/system \
	--target=arm-linux-androideabi \
	--host=arm-linux-androideabi
make $SMP
make install DESTDIR=$DEST
cd ..

rm -rf ncurses
mkdir ncurses
cd ncurses
$SRC/ncurses-$NCURSES/configure \
	--prefix=/system \
	--target=arm-linux-androideabi \
	--host=arm-linux-androideabi \
	--enable-hard-tabs \
	--enable-const \
	--without-cxx-binding \
	--without-ada \
	--without-manpages \
	--with-shared
make $SMP
make install DESTDIR=$DEST

# Get rid of components we don't need, we just need what we need to run vim
rm -rf \
	"$DEST"/system/lib/libform* \
	"$DEST"/system/lib/libmenu* \
	"$DEST"/system/lib/libpanel* \
	"$DEST"/system/lib/libncurses*.a \
	"$DEST"/system/bin/*captoinfo \
	"$DEST"/system/bin/*clear \
	"$DEST"/system/bin/*infocmp \
	"$DEST"/system/bin/*infotocap \
	"$DEST"/system/bin/*reset \
	"$DEST"/system/bin/*tabs \
	"$DEST"/system/bin/*tic \
	"$DEST"/system/bin/*toe \
	"$DEST"/system/bin/*tput \
	"$DEST"/system/bin/*tset

# Get rid of most terminfo files... We just want:
# screen -- used by Android Terminal Emulator and just generally useful
# linux, xterm and variants -- useful when ssh-ing in
# vt100 -- that's what we get from "adb shell"
rm -rf	"$DEST"/system/share/terminfo/[0-9]* \
	"$DEST"/system/share/terminfo/[a-k]* \
	"$DEST"/system/share/terminfo/l/l[a-h]* \
	"$DEST"/system/share/terminfo/l/li[a-m]* \
	"$DEST"/system/share/terminfo/l/li[o-z]* \
	"$DEST"/system/share/terminfo/l/l[j-z]* \
	"$DEST"/system/share/terminfo/[m-r]* \
	"$DEST"/system/share/terminfo/s/s[0-9]* \
	"$DEST"/system/share/terminfo/s/s[a-b]* \
	"$DEST"/system/share/terminfo/s/sc[0-9]* \
	"$DEST"/system/share/terminfo/s/sc[a-q]* \
	"$DEST"/system/share/terminfo/s/screwpoint \
	"$DEST"/system/share/terminfo/s/scrhp \
	"$DEST"/system/share/terminfo/s/s[d-z]* \
	"$DEST"/system/share/terminfo/[t-u]* \
	"$DEST"/system/share/terminfo/v/v[0-9]* \
	"$DEST"/system/share/terminfo/v/v[a-s]* \
	"$DEST"/system/share/terminfo/v/vt100-am \
	"$DEST"/system/share/terminfo/v/vt102* \
	"$DEST"/system/share/terminfo/v/vt1[1-9]* \
	"$DEST"/system/share/terminfo/v/vt[2-9]* \
	"$DEST"/system/share/terminfo/v/vt[a-z]* \
	"$DEST"/system/share/terminfo/v/vt-* \
	"$DEST"/system/share/terminfo/v/v[u-z]* \
	"$DEST"/system/share/terminfo/w* \
	"$DEST"/system/share/terminfo/x/x[0-9]* \
	"$DEST"/system/share/terminfo/x/x[a-s]* \
	"$DEST"/system/share/terminfo/x/xtalk* \
	"$DEST"/system/share/terminfo/x/x[u-z]* \
	"$DEST"/system/share/terminfo/[y-z]* \
	"$DEST"/system/share/terminfo/[A-Z]*
cd ..

rm -rf vim
# vim doesn't currently support out-of-source builds
cp -a $SRC/vim$VIMD vim
cd vim
vim_cv_toupper_broken=no vim_cv_terminfo=yes vim_cv_tgent=zero \
vim_cv_stat_ignores_slash=no vim_cv_tty_group=system vim_cv_tty_mode=0666 vim_cv_getcwd_broken=no \
vim_cv_memmove_handles_overlap=yes \
	./configure \
		--prefix=/system \
		--target=arm-linux-androideabi \
		--host=arm-linux-androideabi
make $SMP STRIP=/tmp/arm-linux-androideabi/bin/arm-linux-androideabi-strip
make install DESTDIR=$DEST STRIP=/tmp/arm-linux-androideabi/bin/arm-linux-androideabi-strip
ln -s vim "$DEST"/system/bin/vi
cd ..

# save space (from vim)
rm -rf \
	"$DEST"/system/share/vim/vim$VIMD/doc \
	"$DEST"/system/share/vim/vim$VIMD/tutor \
	"$DEST"/system/share/vim/vim$VIMD/print \
	"$DEST"/system/bin/vimtutor \
	"$DEST"/system/bin/vimdiff \
	"$DEST"/system/bin/view \
	"$DEST"/system/bin/rview \
	"$DEST"/system/bin/rvim

pushd "$DEST"/system/share/vim/vim$VIMD/syntax
for i in *; do
	[ "$i" = "config.vim" ] || \
	[ "$i" = "conf.vim" ] || \
	[ "$i" = "cpp.vim" ] || \
	[ "$i" = "c.vim" ] || \
	[ "$i" = "doxygen.vim" ] || \
	[ "$i" = "html.vim" ] || \
	[ "$i" = "javascript.vim" ] || \
	[ "$i" = "java.vim" ] || \
	[ "$i" = "manual.vim" ] || \
	[ "$i" = "sh.vim" ] || \
	[ "$i" = "syncolor.vim" ] || \
	[ "$i" = "synload.vim" ] || \
	[ "$i" = "syntax.vim" ] || \
	[ "$i" = "vim.vim" ] || \
		rm -f "$i"
done
popd

# Set some nice defaults
mv "$DEST"/system/share/vim/vim$VIMD/vimrc_example.vim "$DEST"/system/share/vim/vimrc

if $WITH_RPM; then
	mkdir db
	cd db
	../../src/db-$DB/dist/configure --prefix=/system --host=arm-linux-androideabi --target=arm-linux-androideabi --enable-shared --enable-posixmutexes --with-mutex=ARM/gcc-assembly
	make $SMP
	make install DESTDIR=$DEST
	cd ..

	mkdir beecrypt
	cd beecrypt
	../../src/beecrypt-$BEECRYPT/configure --prefix=/system --host=arm-linux-androideabi --target=arm-linux-androideabi --without-cplusplus --without-java --without-python --with-gnu-ld
	make install DESTDIR=$DEST
	cd ..

	mkdir popt
	cd popt
	../../src/popt-$POPT/configure --prefix=/system --host=arm-linux-androideabi --target=arm-linux-androideabi
	make $SMP
	make install DESTDIR=$DEST
	cd ..

	mkdir pcre
	cd pcre
	../../src/pcre-$PCRE/configure --prefix=/system --host=arm-linux-androideabi --target=arm-linux-androideabi
	make $SMP
	make install DESTDIR=$DEST
	cd ..

	mkdir rpm
	cd rpm
	# --without-pthreads isn't nice... But rpm uses pthread_cancel
	ac_cv_va_copy=C99 ../../src/rpm-5.4.10/configure --prefix=/system --host=arm-linux-androideabi --target=arm-linux-androideabi --disable-nls --enable-posixmutexes --without-python --without-perl --without-mozjs185 --with-glob --without-selinux --without-augeas --without-pthreads
	# rpm defaults to bison -y -- but bison 2.7 generates a duplicate
	# definition of yylval on getdate.y
	make $SMP YACC="byacc"
	make install DESTDIR=$DEST
	cd ..
fi

# Save space (from stuff accumulated by all projects)
rm -rf \
	"$DEST"/system/share/doc \
	"$DEST"/system/share/info \
	"$DEST"/system/share/man

if ! $KEEP_BIONIC && ! $INTREE; then
	# Get rid of Bionic and stlport -- they're already included in Android
	rm -rf \
		"$DEST"/system/lib/libc.so \
		"$DEST"/system/lib/libstdc++.so \
		"$DEST"/system/lib/libstlport.so \
		"$DEST"/system/lib/libm.so \
		"$DEST"/system/lib/libthread_db.so \
		"$DEST"/system/lib/libc_malloc*.so \
		"$DEST"/system/lib/libdl.so
fi

if ! $INTREE; then
	# strip everything so we can fit into the limited
	# /system space on GNexus
	# set +e because the strip command will fail, given it will also get
	# to "strip" non-binaries.
	set +e
	find "$DEST" |xargs /tmp/arm-linux-androideabi/bin/arm-linux-androideabi-strip --strip-unneeded
fi
echo
echo Toolchain build successful.
echo The native toolchain can be found in $DEST.
