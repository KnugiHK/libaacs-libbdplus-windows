# Windows Libraries of libaacs & libbdplus

This repository provides pre-built libraries for **libaacs** and **libbdplus**, essential components for playing Blu-ray discs with popular software like FFmpeg, VLC, and MPC-HC.

* **libaacs**: https://www.videolan.org/developers/libaacs.html
* **libbdplus**: https://www.videolan.org/developers/libbdplus.html

This repository is designed to provide a transparent build process and clean, ready-to-use binaries, no need to rely on the Mega.nz link shared on the Internet. The build process uses GitHub Actions and cross-compilation with mingw64 on Ubuntu, utilizing GNU/gcc. The binaries are safe to use and virus-free, but we encourage you to review the build process and repository for full transparency.

## How to use libaacs & libbdplus

Once downloaded, you’ll find both 64-bit and 32-bit Windows versions of the libraries. Follow these steps to get started:

1. **Download the libraries** from the [Releases](https://github.com/KnugiHK/libaacs-libbdplus-windows/releases) page.
2. **Place the DLL files** (`libaacs.dll` and `libbdplus.dll`) into `C:\Windows\System32`. This will make them accessible to all your applications.

Unlike the libraries provided in external sources (like Mega.nz), these libraries have **all dependencies statically linked**, so you won't need any additional DLLs (like `libgpg-error6-0.dll` or `libgcrypt-20.dll`).

For detailed instruction, refer to [this forum post](https://forum.doom9.org/showthread.php?p=1886086) from Doom9.

## Building libaacs & libbdplus Locally

To build libaacs & libbdplus for Windows on WSL 1 or 2 (Debian/Ubuntu), follow these steps:

```bash
sudo apt-get install -y autoconf fig2dev mingw-w64 mingw-w64-tools mingw-w64-i686-dev gcc make m4 pkg-config gettext lbzip2 flex bison
git clone https://github.com/KnugiHK/libaacs-libbdplus-windows && cd libaacs-libbdplus-windows
make
```

To build 32-bit or 64-bit only:
```bash
make 32
make 64
```

If the `Makefile` does not work for you, try to use the `build.sh` script instead.

## Building the Installer

The installer is built using NSIS. To build the installer, place the DLLs to the `win86` and `win64` directories accordingly and run the following command:

```bash
makensis installer.nsi
```

## Credit

This project is inspired by [wget-windows](https://github.com/KnugiHK/wget-windows), originally created by @webfolderio.

Development also referenced the [Cross-compile libaacs for Windows (64bit)](https://gist.github.com/ePirat/0fd2c714dea2748cca98cf2096faa574) gist.
