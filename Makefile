# Makefile for libaacs and libbdplus
# Author: KnugiHK
# March 03, 2025

.PHONY: all clean 32 64 check-deps

# Default is to build both architectures
all: 32 64

check-deps:
	@which fig2dev > /dev/null || (echo 'Error: fig2dev must be installed' && exit 1)

# 32-bit Windows build
32: check-deps
	@echo 'Building for 32bit Windows'
	@mkdir -p build-libaacs-x86
	@cd build-libaacs-x86 && $(MAKE) -f ../Makefile build-internal \
		LIBAACS_GCC=i686-w64-mingw32-gcc \
		LIBAACS_MINGW_HOST=i686-w64-mingw32 \
		LIBAACS_ARCH=i686 \
		MINGW_STRIP_TOOL=i686-w64-mingw32-strip

# 64-bit Windows build
64: check-deps
	@echo 'Building for 64bit Windows'
	@mkdir -p build-libaacs
	@cd build-libaacs && $(MAKE) -f ../Makefile build-internal \
		LIBAACS_GCC=x86_64-w64-mingw32-gcc \
		LIBAACS_MINGW_HOST=x86_64-w64-mingw32 \
		LIBAACS_ARCH=x86-64 \
		MINGW_STRIP_TOOL=x86_64-w64-mingw32-strip

build-internal:
	@mkdir -p install
	@export INSTALL_PATH="$$(pwd)/install" && \
	export CORE=$$(nproc) && \
	$(MAKE) -f ../Makefile gpg-error gcrypt libaacs libbdplus \
		INSTALL_PATH="$$(pwd)/install" \
		LIBAACS_GCC=$(LIBAACS_GCC) \
		LIBAACS_MINGW_HOST=$(LIBAACS_MINGW_HOST) \
		LIBAACS_ARCH=$(LIBAACS_ARCH) \
		MINGW_STRIP_TOOL=$(MINGW_STRIP_TOOL) \
		CORE=$$(nproc)

clean:
	rm -rf build-libaacs build-libaacs-x86

gpg-error:
	@echo "Building libgpg-error..."
	@if [ ! -f "$(INSTALL_PATH)/lib/libgpg-error.a" ]; then \
		wget -nc https://github.com/gpg/libgpg-error/archive/refs/tags/libgpg-error-1.51.tar.gz && \
		tar -xf libgpg-error-1.51.tar.gz && \
		cd libgpg-error-libgpg-error-1.51 && \
		./autogen.sh && \
		./configure \
			--host=$(LIBAACS_MINGW_HOST) \
			--disable-shared \
			--prefix="$(INSTALL_PATH)" \
			--enable-static \
			--disable-doc && \
		make -j $(CORE) && \
		make install || exit 1; \
	fi

gcrypt: gpg-error
	@echo "Building libgcrypt..."
	@if [ ! -f "$(INSTALL_PATH)/lib/libgcrypt.a" ]; then \
		wget -nc https://github.com/gpg/libgcrypt/archive/refs/tags/libgcrypt-1.11.0.tar.gz && \
		tar -xf libgcrypt-1.11.0.tar.gz && \
		cd libgcrypt-libgcrypt-1.11.0 && \
		./autogen.sh && \
		./configure \
			--host=$(LIBAACS_MINGW_HOST) \
			--disable-shared \
			--prefix="$(INSTALL_PATH)" \
			--disable-doc \
			--with-gpg-error-prefix="$(INSTALL_PATH)" && \
		make -j $(CORE) && \
		make install || exit 1; \
	fi

libaacs: gcrypt
	@echo "Building libaacs..."
	@wget -nc https://download.videolan.org/pub/videolan/libaacs/0.11.1/libaacs-0.11.1.tar.bz2 && \
	tar xf libaacs-0.11.1.tar.bz2 && \
	cd libaacs-0.11.1 && \
	LIBS="-L$(INSTALL_PATH)/lib -lws2_32" \
	./configure \
		--host=$(LIBAACS_MINGW_HOST) \
		--prefix="$(INSTALL_PATH)" \
		--with-gpg-error-prefix="$(INSTALL_PATH)" \
		--with-libgcrypt-prefix="$(INSTALL_PATH)" && \
	make -j $(CORE) && \
	make install && \
	$(MINGW_STRIP_TOOL) "$(INSTALL_PATH)/bin/libaacs-0.dll" || exit 1

libbdplus: gcrypt
	@echo "Building libbdplus..."
	@wget -nc https://download.videolan.org/pub/videolan/libbdplus/0.2.0/libbdplus-0.2.0.tar.bz2 && \
	tar xf libbdplus-0.2.0.tar.bz2 && \
	cd libbdplus-0.2.0 && \
	LIBS="-L$(INSTALL_PATH)/lib -lws2_32" \
	./configure \
		--host=$(LIBAACS_MINGW_HOST) \
		--prefix="$(INSTALL_PATH)" \
		--with-gpg-error-prefix="$(INSTALL_PATH)" \
		--with-libgcrypt-prefix="$(INSTALL_PATH)" && \
	make -j $(CORE) && \
	make install && \
	$(MINGW_STRIP_TOOL) "$(INSTALL_PATH)/bin/libbdplus-0.dll" || exit 1