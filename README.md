# Windows Libraries of libaacs & libbdplus

This repository provides pre-built libraries for **libaacs** and **libbdplus**, essential components for playing Blu-ray discs with popular software like FFmpeg, VLC, and MPC-HC.

* **libaacs**: https://www.videolan.org/developers/libaacs.html
* **libbdplus**: https://www.videolan.org/developers/libbdplus.html

This repository provides an automated build process and ready-to-use binaries as a transparent alternative to manual uploads shared online. To supplement existing community resources, we use GitHub Actions and cross-compilation with mingw64 on Ubuntu to offer a verifiable path from source to executable. This 'clean-room' compilation ensures a consistent, auditable result, and we encourage users to review the build scripts for full transparency.

> [!TIP]
> Binaries for Windows on ARM(64) are now available!

## How to Use libaacs & libbdplus

### Using Installer

Simply download, run, select your architecture, and install, you'll be up and running in seconds.

### Manual

Once downloaded, you'll find x86, x64 and arm64 Windows versions of the libraries. Follow these steps to get started:

1. **Download the libraries** from the [Releases](https://github.com/KnugiHK/libaacs-libbdplus-windows/releases) page.
2. **Extract the appropriate architecture**: `winx64` for x64, `winx86` for x86 and `winarm64` for ARM64.
3. **Move the DLL files** (`libaacs.dll` and `libbdplus.dll`) to `C:\Windows\System32`. If you are installing x86 binaries on a 64-bit Windows system, place them in `C:\Windows\SysWOW64` instead. This will make them accessible to all applications.

Unlike the libraries provided in external sources (like Mega.nz), these libraries have **all dependencies statically linked**, so you won't need any additional DLLs (like `libgpg-error6-0.dll` or `libgcrypt-20.dll`).

For detailed instruction, refer to [this forum post](https://forum.doom9.org/showthread.php?p=1886086) from Doom9.

## Building libaacs & libbdplus Locally

To build libaacs & libbdplus for Windows on WSL 1 or 2 (Debian/Ubuntu), follow these steps:

```bash
sudo apt-get install -y autoconf fig2dev mingw-w64 mingw-w64-tools mingw-w64-i686-dev gcc make m4 pkg-config gettext lbzip2 flex bison
git clone https://github.com/KnugiHK/libaacs-libbdplus-windows && cd libaacs-libbdplus-windows
make # This will build both x86 and x64. See below for arm64
```

To build each architecture individually:
```bash
make x32
make x64
make arm64
```
If the `Makefile` does not work for you, try to use the `build.sh` script instead.

## Building the Installer

The installer is built using NSIS. To build the installer, place the DLLs to the `winx86`, `winx64`  and `winarm64` directories accordingly and run the following command:

```bash
makensis installer.nsi
```

## Testing

This repository includes a testing utility, `dll_loader.c`. To use it, compile the source using `x86_64-w64-mingw32-gcc` (for 64-bit) or `i686-w64-mingw32-gcc` (for 32-bit). Once built, run the executable on Windows, ensuring the library files are organized in the following directory structure:

```bash
.
├── dll_loader_arm64.exe
├── dll_loader_x64.exe
├── dll_loader_x86.exe
├── winx64
│   ├── aacs_info.exe
│   ├── libaacs.dll
│   └── libbdplus.dll
├── winx86
│   ├── aacs_info.exe
│   ├── libaacs.dll
│   └── libbdplus.dll
└── winarm64
    ├── aacs_info.exe
    ├── libaacs.dll
    └── libbdplus.dll
```

## Verifying Build Integrity

To ensure that the binaries provided in the releases were built directly from this source code via GitHub Actions and have not been tampered with, GitHub Artifact Attestations is used. You can verify the authenticity of any `.exe` or `.dll` file using the GitHub CLI.

### Using PowerShell (Windows)

```powershell
gci "*.exe", "./winx64/*", "./winx86/*", "./winarm64/*" | % { gh attestation verify $_.FullName -R KnugiHK/libaacs-libbdplus-windows }
```

### Using Bash (Linux/WSL/macOS)

```bash
for file in *.exe ./winx64/* ./winx86/* ./winarm64/*; do; gh attestation verify "$file" -R KnugiHK/libaacs-libbdplus-windows ; done
```

## Credit

This project is inspired by [wget-windows](https://github.com/KnugiHK/wget-windows), originally created by @webfolderio.

Development also referenced the [Cross-compile libaacs for Windows (64bit)](https://gist.github.com/ePirat/0fd2c714dea2748cca98cf2096faa574) gist.
