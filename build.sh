#
# libaacs-libbdplus build script for Windows environment
# Author: KnugiHK
# January 28, 2025
#
while getopts "r x" opt ; do
  case $opt in r) r_set=true;; x) x86_set=true;; esac;
done
if [ "$x86_set" ] ; then
  echo 'Building for 32bit Windows'
  [ "$r_set" ] && rm -rf build-libaacs-x86
  mkdir build-libaacs-x86
  cd build-libaacs-x86 || exit
  export LIBAACS_GCC=i686-w64-mingw32-gcc
  export LIBAACS_MINGW_HOST=i686-w64-mingw32
  export LIBAACS_ARCH=i686
  export MINGW_STRIP_TOOL=i686-w64-mingw32-strip
else
  echo 'Building for 64bit Windows'
  [ "$r_set" ] && rm -rf build-libaacs
  mkdir build-libaacs
  cd build-libaacs || exit
  export LIBAACS_GCC=x86_64-w64-mingw32-gcc
  export LIBAACS_MINGW_HOST=x86_64-w64-mingw32
  export LIBAACS_ARCH=x86-64
  export MINGW_STRIP_TOOL=x86_64-w64-mingw32-strip
fi
mkdir install
which fig2dev &> /dev/null || (echo 'fig2dev must be installed' && exit)
export INSTALL_PATH=$PWD/install
export CORE=$(nproc)
while [[ "$(cat /proc/sys/fs/binfmt_misc/status)" == "enabled" ]]
do
  echo "The build script requires a password to work."
  sudo bash -c "echo 0 > /proc/sys/fs/binfmt_misc/status"
done
# -----------------------------------------------------------------------------
# build gpg-error
# -----------------------------------------------------------------------------
if [ ! -f "$INSTALL_PATH"/lib/libgpg-error.a ]; then
  wget -nc https://github.com/gpg/libgpg-error/archive/refs/tags/libgpg-error-1.58.tar.gz
  tar -xf libgpg-error-1.58.tar.gz
  cd libgpg-error-libgpg-error-1.58 || exit
  ./autogen.sh
  ./configure \
  --host=$LIBAACS_MINGW_HOST \
  --disable-shared \
  --prefix="$INSTALL_PATH" \
  --enable-static \
  --disable-doc
  (($? != 0)) && { printf '%s\n' "[gpg-error] configure failed"; exit 1; }
  make -j $CORE
  (($? != 0)) && { printf '%s\n' "[gpg-error] make failed"; exit 1; }
  make install
  (($? != 0)) && { printf '%s\n' "[gpg-error] make install"; exit 1; }
  cd ..
fi
# -----------------------------------------------------------------------------
# build gcrypt
# -----------------------------------------------------------------------------
if [ ! -f "$INSTALL_PATH"/lib/libgcrypt.a ]; then
  wget -nc https://github.com/gpg/libgcrypt/archive/refs/tags/libgcrypt-1.11.2.tar.gz
  tar -xf libgcrypt-1.11.2.tar.gz
  cd libgcrypt-libgcrypt-1.11.2 || exit
  ./autogen.sh
  ./configure \
   --host=$LIBAACS_MINGW_HOST \
   --disable-shared \
   --prefix="$INSTALL_PATH" \
   --disable-doc \
   --with-gpg-error-prefix="$INSTALL_PATH"
  (($? != 0)) && { printf '%s\n' "[gcrypt] configure failed"; exit 1; }
  make -j $CORE
  (($? != 0)) && { printf '%s\n' "[gcrypt] make failed"; exit 1; }
  make install
  (($? != 0)) && { printf '%s\n' "[gcrypt] make install"; exit 1; }
  cd ..
fi
# -----------------------------------------------------------------------------
# build libaacs
# -----------------------------------------------------------------------------
wget -nc https://download.videolan.org/pub/videolan/libaacs/0.11.1/libaacs-0.11.1.tar.bz2
tar xf libaacs-0.11.1.tar.bz2
cd libaacs-0.11.1 || exit
LIBS="-L$INSTALL_PATH/lib -lws2_32" \
LDFLAGS="-static-libgcc -static-libstdc++ -Wl,-Bstatic -lwinpthread -Wl,-Bdynamic" \
./configure \
  --host=$LIBAACS_MINGW_HOST \
  --prefix="$INSTALL_PATH" \
  --with-gpg-error-prefix="$INSTALL_PATH" \
  --with-libgcrypt-prefix="$INSTALL_PATH"
(($? != 0)) && { printf '%s\n' "[libaacs] configure failed"; exit 1; }
make -j $CORE
(($? != 0)) && { printf '%s\n' "[libaacs] make failed"; exit 1; }
make install
(($? != 0)) && { printf '%s\n' "[libaacs] make install"; exit 1; }
$MINGW_STRIP_TOOL "$INSTALL_PATH/bin/libaacs-0.dll"
# -----------------------------------------------------------------------------
# build libbdplus
# -----------------------------------------------------------------------------
wget -nc https://download.videolan.org/pub/videolan/libbdplus/0.2.0/libbdplus-0.2.0.tar.bz2
tar xf libbdplus-0.2.0.tar.bz2
cd libbdplus-0.2.0 || exit
LIBS="-L$INSTALL_PATH/lib -lws2_32" \
LDFLAGS="-static-libgcc -static-libstdc++ -Wl,-Bstatic -lwinpthread -Wl,-Bdynamic" \
./configure \
  --host=$LIBAACS_MINGW_HOST \
  --prefix="$INSTALL_PATH" \
  --with-gpg-error-prefix="$INSTALL_PATH" \
  --with-libgcrypt-prefix="$INSTALL_PATH"
(($? != 0)) && { printf '%s\n' "[libbdplus] configure failed"; exit 1; }
make -j $CORE
(($? != 0)) && { printf '%s\n' "[libbdplus] make failed"; exit 1; }
make install
(($? != 0)) && { printf '%s\n' "[libbdplus] make install"; exit 1; }
$MINGW_STRIP_TOOL "$INSTALL_PATH/bin/libbdplus-0.dll"
exit 0
