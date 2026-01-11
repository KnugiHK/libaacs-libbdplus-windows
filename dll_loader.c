#include <stdio.h>
#include <windows.h>

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

int test_library(const wchar_t* filename) {
    wchar_t fullPath[MAX_PATH];
    const wchar_t* dir = get_arch_directory();
    
    swprintf(fullPath, MAX_PATH, L"%ls%ls", dir, filename);

    printf("\n--- Testing: %ls ---\n", fullPath);

    HMODULE hModule = LoadLibraryW(fullPath);

    if (hModule == NULL) {
        DWORD errorCode = GetLastError();
        printf("FAILED to load %ls. Error Code: %lu\n", fullPath, errorCode);

        LPVOID lpMsgBuf;
        FormatMessageW(
            FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
            NULL, errorCode, MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
            (LPWSTR)&lpMsgBuf, 0, NULL
        );

        if (lpMsgBuf) {
            wprintf(L"System Error: %ls", (LPCWSTR)lpMsgBuf);
            LocalFree(lpMsgBuf);
        }
        return 1; // Return failure
    }

    printf("SUCCESS: Loaded %ls at address %p\n", fullPath, hModule);
    FreeLibrary(hModule);
    return 0; // Return success
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
            printf("\nOne or more libraries failed to load. Exiting with error.\n");
            return 1; 
        }
    }

    printf("\nAll tests passed successfully.\n");
    return 0;
}