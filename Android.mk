ifneq ($(BUILD_TINY_ANDROID),true)
# Wrapper Makefile for building the native toolchain as part of an OS build
# This (obviously) lacks proper dependency tracking. If you need to rebuild,
# rm -f $(PRODUCT_OUT)/system/bin/gcc.

GCC_FILE_NAME = $(PRODUCT_OUT)/system/bin/gcc

native-toolchain: $(GCC_FILE_NAME)

$(GCC_FILE_NAME): $(TARGET_CRTBEGIN_DYNAMIC_O) $(TARGET_CRTEND_O) $(TARGET_OUT_SHARED_LIBRARIES)/libm.so $(TARGET_OUT_SHARED_LIBRARIES)/libc.so $(TARGET_OUT_SHARED_LIBRARIES)/libdl.so $(TARGET_OUT_SHARED_LIBRARIES)/libstlport.so
	DEST=$(realpath $(TOP))/$(PRODUCT_OUT) CRT=$(realpath $(shell dirname $(TOP)/$(TARGET_CRTBEGIN_DYNAMIC_O))) HOST_OUT=$(HOST_OUT) INTREE=true $(CURDIR)/native-toolchain/build.sh

systemimage: $(GCC_FILE_NAME)

systemtarball: $(GCC_FILE_NAME)

$(BUILT_SYSTEMIMAGE): $(GCC_FILE_NAME)

$(INSTALLED_SYSTEMIMAGE): $(GCC_FILE_NAME)

FULL_SYSTEMIMAGE_DEPS += $(GCC_FILE_NAME)

.PHONY: native-toolchain
endif
