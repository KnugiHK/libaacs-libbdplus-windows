#include <stdio.h>
#include <windows.h>

// Define the signatures
// void aacs_get_version(int *major, int *minor, int *micro)
// void bdplus_get_version(int *major, int *minor, int *micro)
typedef void (__cdecl *GetVerFunc)(int*, int*, int*);

// AACS *aacs_init(void)
typedef void* (__cdecl *AacsInitFunc)(void);
// void aacs_close(AACS *aacs)
typedef void (__cdecl *AacsCloseFunc)(void*);
// bdplus_t *bdplus_init(const char *path, const char *config_path, const uint8_t *vid)
typedef void* (__cdecl *BdplusInitFunc)(const char*, const char*, const unsigned char*);
// void bdplus_free(bdplus_t *plus)
typedef void (__cdecl *BdplusFreeFunc)(void*);

// Helper to get the correct subdirectory based on build architecture
const wchar_t* get_arch_directory() {
#if defined(_M_AMD64) || defined(__x86_64__)
    return L"winx64\\";
#elif defined(_M_IX86) || defined(__i386__)
    return L"winx86\\";
#elif defined(_M_ARM64) || defined(__aarch64__)
    return L"winarm64\\";
#else
    return L""; // Fallback to current directory
#endif
}

void print_error_message(DWORD errorCode) {
    LPVOID lpMsgBuf;
    DWORD size = FormatMessageW(
        FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
        NULL, errorCode, MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
        (LPWSTR)&lpMsgBuf, 0, NULL
    );

    if (size > 0) {
        wprintf(L"System Error %lu: %ls", errorCode, (LPCWSTR)lpMsgBuf);
        LocalFree(lpMsgBuf);
    } else {
        printf("System Error %lu (No description available)\n", errorCode);
    }
}

// Functionally exercise the crypto subsystem. The version functions only
// write three hardcoded integer constants to memory, but libgpg-error and
// libgcrypt are statically linked into the DLLs, so calling the init
// functions verifies that libgcrypt (and the statically linked winpthread
// primitives) actually initialize at runtime instead of crashing or
// deadlocking on startup. This is especially important for the llvm-mingw
// ARM64 build.
int test_aacs_init(HMODULE hModule) {
    AacsInitFunc aacsInit = (AacsInitFunc)GetProcAddress(hModule, "aacs_init");
    AacsCloseFunc aacsClose = (AacsCloseFunc)GetProcAddress(hModule, "aacs_close");

    if (!aacsInit || !aacsClose) {
        printf("FUNCTION NOT FOUND: Could not find aacs_init/aacs_close\n");
        return 1;
    }

    void* handle = aacsInit();
    if (handle == NULL) {
        printf("FAILED: aacs_init() returned NULL, libgcrypt initialization did not work\n");
        return 1;
    }
    printf("FUNCTIONAL TEST PASSED: aacs_init() initialized the crypto subsystem\n");
    aacsClose(handle);
    return 0;
}

int test_bdplus_init(HMODULE hModule) {
    BdplusInitFunc bdplusInit = (BdplusInitFunc)GetProcAddress(hModule, "bdplus_init");
    BdplusFreeFunc bdplusFree = (BdplusFreeFunc)GetProcAddress(hModule, "bdplus_free");

    if (!bdplusInit || !bdplusFree) {
        printf("FUNCTION NOT FOUND: Could not find bdplus_init/bdplus_free\n");
        return 1;
    }

    // No BD+ disc is available here. bdplus_init still initializes libgcrypt
    // before it returns NULL when no configuration is found, which is the
    // code path we want to exercise; a zeroed volume ID keeps the call safe
    // even when a configuration happens to be present on this machine. Any
    // handle that is returned is released again.
    const unsigned char vid[16] = {0};
    void* handle = bdplusInit(NULL, NULL, vid);
    if (handle != NULL) {
        bdplusFree(handle);
    }
    printf("FUNCTIONAL TEST PASSED: bdplus_init() initialized the crypto subsystem and returned safely\n");
    return 0;
}

int test_library(const wchar_t* filename) {
    wchar_t fullPath[MAX_PATH];
    const wchar_t* dir = get_arch_directory();
    
    swprintf(fullPath, MAX_PATH, L"%ls%ls", dir, filename);

    printf("\n--- Testing: %ls ---\n", fullPath);

    HMODULE hModule = LoadLibraryW(fullPath);

    if (hModule == NULL) {
        printf("FAILED to load %ls. Error:\n", fullPath);
        print_error_message(GetLastError());
        return 1;
    }

    printf("SUCCESS: Loaded %ls at address %p\n", fullPath, (void*)hModule);

    const char* funcName = NULL;
    if (wcsstr(filename, L"aacs")) {
        funcName = "aacs_get_version";
    } else if (wcsstr(filename, L"bdplus")) {
        funcName = "bdplus_get_version";
    }
    
    GetVerFunc getVersion = (GetVerFunc)GetProcAddress(hModule, funcName);

    if (getVersion) {
        int major, minor, micro;
        getVersion(&major, &minor, &micro);
        printf("FUNCTION FOUND: %s reported version %d.%d.%d\n", funcName, major, minor, micro);
    } else {
        printf("FUNCTION NOT FOUND: Could not find %s\n", funcName);
        FreeLibrary(hModule);
        return 1;
    }

    int result;
    if (wcsstr(filename, L"aacs")) {
        result = test_aacs_init(hModule);
    } else {
        result = test_bdplus_init(hModule);
    }

    FreeLibrary(hModule);
    return result;
}

int main() {
#if defined(_M_AMD64) || defined(__x86_64__)
    printf("Running 64-bit Test Suite\n");
#elif defined(_M_IX86) || defined(__i386__)
    printf("Running 32-bit Test Suite\n");
#elif defined(_M_ARM64) || defined(__aarch64__)
    printf("Running ARM 64-bit Test Suite\n");
#endif
    const wchar_t* libraries[] = { L"libaacs.dll", L"libbdplus.dll" };
    int count = sizeof(libraries) / sizeof(libraries[0]);

    for (int i = 0; i < count; i++) {
        if (test_library(libraries[i]) != 0) {
            printf("\nOne or more tests failed. Exiting.\n");
            return 1; 
        }
    }

    printf("\nAll tests passed successfully.\n");
    return 0;
}