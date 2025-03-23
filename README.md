# Windows Libraries of libaacs & libbdplus

The libraries available for download here are essential for playing Blu-ray discs with FFmpeg, VLC, and MPC-HC.

* libaacs: https://www.videolan.org/developers/libaacs.html
* libbdplus: https://www.videolan.org/developers/libbdplus.html

## How to use libaacs & libbdplus

For detailed instruction, refer to [this forum post](https://forum.doom9.org/showthread.php?p=1886086) from Doom9.

This repository’s purpose is to offer a transparent building process and clean binaries for consumption (i.e., no need to download the libraries from the Mega.nz link in the forum post).

You can find the libraries on the Release page, which includes both 64-bit and 32-bit Windows versions — choose accordingly. Once downloaded, place the library files (`libaacs.dll` and `libbdplus.dll`) into `C:\Windows\System32` to make them accessible to all applications.

Unlike the libraries hosted on Mega.nz, all required dependencies have been **statically linked**, so no additional third-party DLLs (i.e., `libgpg-error6-0.dll`, and `libgcrypt-20.dll`) are needed.

The build for this project uses GitHub Actions and cross-compilation with mingw64 on Ubuntu, leveraging GNU/gcc. It's safe to use and free from viruses, though you’re encouraged to review the process and repository for full transparency.

## Build Locally

To build libaacs & libbdplus for Windows on WSL 1 or 2 (Debian/Ubuntu), follow these steps:

```bash
sudo apt-get install -y autoconf fig2dev mingw-w64 mingw-w64-tools mingw-w64-i686-dev gcc make m4 pkg-config gettext
git clone https://github.com/KnugiHK/libaacs-libbdplus-windows && cd libaacs-libbdplus-windows
make
```

To build 32-bit or 64-bit only:
```bash
make 32
make 64
```

If the `Makefile` does not work for you, try to use the `build.sh` script instead.

## Credit

This project is inspired by [wget-windows](https://github.com/KnugiHK/wget-windows), originally created by @webfolderio.

Development also referenced the [Cross-compile libaacs for Windows (64bit)](https://gist.github.com/ePirat/0fd2c714dea2748cca98cf2096faa574) gist.
