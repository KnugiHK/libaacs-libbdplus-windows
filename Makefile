# Makefile for libaacs and libbdplus
# Author: KnugiHK
# March 03, 2025

# --- Versions ---
GPG_ERROR_VER := 1.58
LIBGCRYPT_VER := 1.12.1
LIBAACS_VER   := 0.11.1
LIBBDPLUS_VER := 0.2.0

# --- URLs ---
URL_GPG_ERROR := https://github.com/gpg/libgpg-error/archive/refs/tags/libgpg-error-$(GPG_ERROR_VER).tar.gz
URL_GCRYPT    := https://github.com/gpg/libgcrypt/archive/refs/tags/libgcrypt-$(LIBGCRYPT_VER).tar.gz
URL_LIBAACS   := https://download.videolan.org/pub/videolan/libaacs/$(LIBAACS_VER)/libaacs-$(LIBAACS_VER).tar.bz2
URL_LIBBDPLUS := https://download.videolan.org/pub/videolan/libbdplus/$(LIBBDPLUS_VER)/libbdplus-$(LIBBDPLUS_VER).tar.bz2
URL_LLVM_MINGW:= https://github.com/mstorsjo/llvm-mingw/releases/download/20251216/llvm-mingw-20251216-ucrt-ubuntu-22.04-x86_64.tar.xz

# --- Configuration ---
SHELL       := /bin/bash
DL_DIR      := build-libaacs-dl
LLVM_MINGW_PATH := $(HOME)/llvm-mingw

# Common Flags
STATIC_FLAGS := -static-libgcc -Wl,-Bstatic -lwinpthread -Wl,-Bdynamic
SHARED_LDFLAGS := -no-undefined -avoid-version

.PHONY: all clean x32 x64 arm64 check-deps directories build-internal

all: x32 x64

# --- Checks & Setup ---

check-deps:
	@which fig2dev > /dev/null || (echo 'Error: fig2dev must be installed' && exit 1)
	@which flex > /dev/null || (echo 'Error: flex must be installed' && exit 1)
	@which wget > /dev/null || (echo 'Error: wget must be installed' && exit 1)
	@mkdir -p $(DL_DIR)

$(LLVM_MINGW_PATH)/bin/aarch64-w64-mingw32-gcc:
	@echo "-> Checking destination safety..."
	@! [ -d "$(LLVM_MINGW_PATH)" ] || [ -f "$@" ] || (echo "Error: $(LLVM_MINGW_PATH) exists but is not an llvm-mingw installation. Stopping to protect your data." && exit 1)
	@echo "-> llvm-mingw not found. Downloading..."
	@mkdir -p $(LLVM_MINGW_PATH)
	wget -qO- $(URL_LLVM_MINGW) | tar -xJ --strip-components=1 -C $(LLVM_MINGW_PATH)

clean:
	rm -rf build-libaacs build-libaacs-x86 build-libaacs-arm64

distclean:
	rm -rf build-libaacs build-libaacs-x86 build-libaacs-arm64 build-libaacs-dl

# --- Architecture Entry Points ---

x32: check-deps
	@echo '=== Building for 32-bit Windows ==='
	@mkdir -p build-libaacs-x86
	@$(MAKE) -C build-libaacs-x86 -f ../Makefile build-internal \
		HOST=i686-w64-mingw32 \
		STRIP=i686-w64-mingw32-strip \
		SRC_DIR=..

x64: check-deps
	@echo '=== Building for 64-bit Windows ==='
	@mkdir -p build-libaacs
	@$(MAKE) -C build-libaacs -f ../Makefile build-internal \
		HOST=x86_64-w64-mingw32 \
		STRIP=x86_64-w64-mingw32-strip \
		SRC_DIR=..
		
arm64: $(LLVM_MINGW_PATH)/bin/aarch64-w64-mingw32-gcc check-deps
	@echo '=== Building for Windows ARM64 (using LLVM/Clang) ==='
	@mkdir -p build-libaacs-arm64
	@$(MAKE) -C build-libaacs-arm64 -f ../Makefile build-internal \
		HOST=aarch64-w64-mingw32 \
		CC="$(LLVM_MINGW_PATH)/bin/aarch64-w64-mingw32-gcc" \
		RC="$(LLVM_MINGW_PATH)/bin/aarch64-w64-mingw32-windres" \
		AR="$(LLVM_MINGW_PATH)/bin/aarch64-w64-mingw32-ar" \
		RANLIB="$(LLVM_MINGW_PATH)/bin/aarch64-w64-mingw32-ranlib" \
		STRIP="$(LLVM_MINGW_PATH)/bin/aarch64-w64-mingw32-strip" \
		SRC_DIR=..

# --- Internal Build Logic (Runs inside build dir) ---

INSTALL_PATH := $(shell pwd)/install

# Targets for final DLLs
build-internal: libaacs libbdplus

# libgpg-error
$(INSTALL_PATH)/lib/libgpg-error.a:
	@echo "-> Building libgpg-error..."
	@mkdir -p $(INSTALL_PATH)
	tar -xf $(SRC_DIR)/$(DL_DIR)/libgpg-error-$(GPG_ERROR_VER).tar.gz
	cd libgpg-error-libgpg-error-$(GPG_ERROR_VER) && \
		./autogen.sh && \
		./configure --host=$(HOST) --disable-shared --prefix="$(INSTALL_PATH)" --enable-static --disable-doc && \
		$(MAKE) && \
		$(MAKE) install

# libgcrypt (Depends on gpg-error)
$(INSTALL_PATH)/lib/libgcrypt.a: $(INSTALL_PATH)/lib/libgpg-error.a
	@echo "-> Building libgcrypt..."
	tar -xf $(SRC_DIR)/$(DL_DIR)/libgcrypt-$(LIBGCRYPT_VER).tar.gz
	cd libgcrypt-libgcrypt-$(LIBGCRYPT_VER) && \
		./autogen.sh && \
		./configure --host=$(HOST) --disable-shared --prefix="$(INSTALL_PATH)" --disable-doc --with-gpg-error-prefix="$(INSTALL_PATH)" && \
		$(MAKE) && \
		$(MAKE) install

# libaacs (Depends on gcrypt)
libaacs: $(INSTALL_PATH)/lib/libgcrypt.a
	@echo "-> Building libaacs..."
	tar xf $(SRC_DIR)/$(DL_DIR)/libaacs-$(LIBAACS_VER).tar.bz2
	cd libaacs-$(LIBAACS_VER) && \
		LIBS="-L$(INSTALL_PATH)/lib -lws2_32" \
		LDFLAGS="$(STATIC_FLAGS)" \
		./configure --host=$(HOST) --prefix="$(INSTALL_PATH)" --with-gpg-error-prefix="$(INSTALL_PATH)" --with-libgcrypt-prefix="$(INSTALL_PATH)" && \
		$(MAKE) libaacs_la_LDFLAGS="$(SHARED_LDFLAGS)" && \
		$(MAKE) install
	$(STRIP) "$(INSTALL_PATH)/bin/libaacs.dll"

# libbdplus (Depends on gcrypt)
libbdplus: $(INSTALL_PATH)/lib/libgcrypt.a
	@echo "-> Building libbdplus..."
	tar xf $(SRC_DIR)/$(DL_DIR)/libbdplus-$(LIBBDPLUS_VER).tar.bz2
	cd libbdplus-$(LIBBDPLUS_VER) && \
		LIBS="-L$(INSTALL_PATH)/lib -lws2_32" \
		LDFLAGS="$(STATIC_FLAGS)" \
		./configure --host=$(HOST) --prefix="$(INSTALL_PATH)" --with-gpg-error-prefix="$(INSTALL_PATH)" --with-libgcrypt-prefix="$(INSTALL_PATH)" && \
		$(MAKE) libbdplus_la_LDFLAGS="$(SHARED_LDFLAGS)" && \
		$(MAKE) install
	$(STRIP) "$(INSTALL_PATH)/bin/libbdplus.dll"

# --- Download Helpers (Run in main dir) ---
# These run if the file doesn't exist in DL_DIR.

$(DL_DIR)/libgpg-error-$(GPG_ERROR_VER).tar.gz:
	wget -nc -P $(DL_DIR) $(URL_GPG_ERROR)

$(DL_DIR)/libgcrypt-$(LIBGCRYPT_VER).tar.gz:
	wget -nc -P $(DL_DIR) $(URL_GCRYPT)

$(DL_DIR)/libaacs-$(LIBAACS_VER).tar.bz2:
	wget -nc -P $(DL_DIR) $(URL_LIBAACS)

$(DL_DIR)/libbdplus-$(LIBBDPLUS_VER).tar.bz2:
	wget -nc -P $(DL_DIR) $(URL_LIBBDPLUS)

# Pre-download all source files
check-deps: $(DL_DIR)/libgpg-error-$(GPG_ERROR_VER).tar.gz \
            $(DL_DIR)/libgcrypt-$(LIBGCRYPT_VER).tar.gz \
            $(DL_DIR)/libaacs-$(LIBAACS_VER).tar.bz2 \
            $(DL_DIR)/libbdplus-$(LIBBDPLUS_VER).tar.bz2