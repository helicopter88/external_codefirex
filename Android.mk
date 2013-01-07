# Wrapper Makefile for building the native toolchain as part of an OS build
# This (obviously) lacks proper dependency tracking. If you need to rebuild,
# rm -f $(PRODUCT_OUT)/system/bin/gcc.

native-toolchain: $(PRODUCT_OUT)/system/bin/gcc

$(PRODUCT_OUT)/system/bin/gcc: $(TARGET_CRTBEGIN_DYNAMIC_O) $(TARGET_CRTEND_O) $(TARGET_OUT_SHARED_LIBRARIES)/libm.so $(TARGET_OUT_SHARED_LIBRARIES)/libc.so $(TARGET_OUT_SHARED_LIBRARIES)/libdl.so $(TARGET_OUT_SHARED_LIBRARIES)/libstlport.so
	./build.sh DEST=$(PRODUCT_OUT) HOST_OUT=$(HOST_OUT) TARGET_TOOLS_PREFIX=$(TARGET_TOOLS_PREFIX) INTREE=true

droidcore: native-toolchain

systemtarball: native-toolchain

.PHONY: native-toolchain
