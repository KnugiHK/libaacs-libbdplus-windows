; Installer properties
!define /date VERSION "%Y%m%d"
Name "libaacs & libbdplus Installer"
OutFile "libaacs-libbdplus-installer.exe"
InstallDir "$PROGRAMFILES\libaacs-libbdplus-windows" ; Recommended: Install uninstaller to a folder
RequestExecutionLevel admin

; Variables
Var BITNESS

; Includes
!include "MUI2.nsh"
!include "LogicLib.nsh" ; Required for {If} statements
!include "x64.nsh" ; Required for architecture detection

; Pages
!insertmacro MUI_PAGE_LICENSE "LICENSE";
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
; Uninstaller Pages
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

; Languages
!insertmacro MUI_LANGUAGE "English"

; ---- Installation Sections ----
Section "32-bit DLLs (x86)" SEC_32BIT
  SetOutPath "$SYSDIR"
  File "win86\libaacs.dll"
  File "win86\libbdplus.dll"
SectionEnd

Section "64-bit DLLs (x64)" SEC_64BIT
  ${DisableX64FSRedirection}
  SetOutPath "$SYSDIR"
  File "win64\libaacs.dll"
  File "win64\libbdplus.dll"
  ${EnableX64FSRedirection}
SectionEnd

Section "ARM 64-bit DLLs" SEC_ARM64
  ${DisableX64FSRedirection}
  SetOutPath "$SYSDIR"
  File "winarm64\libaacs.dll"
  File "winarm64\libbdplus.dll"
  ${EnableX64FSRedirection}
SectionEnd

; ---- Hidden Section: to create uninstaller and registry keys ----
Section "-Post" 
  SetOutPath "$INSTDIR"
  WriteUninstaller "$INSTDIR\Uninstall.exe"

  ; Registry keys for Add/Remove Programs
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\libaacs-libbdplus-windows" "DisplayName" "Windows Libraries of libaacs & libbdplus"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\libaacs-libbdplus-windows" "UninstallString" '"$INSTDIR\Uninstall.exe"'
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\libaacs-libbdplus-windows" "QuietUninstallString" '"$INSTDIR\Uninstall.exe" /S'
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\libaacs-libbdplus-windows" "Publisher" "KnugiHK"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\libaacs-libbdplus-windows" "DisplayVersion" "${VERSION}"
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\libaacs-libbdplus-windows" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\libaacs-libbdplus-windows" "NoRepair" 1
SectionEnd

; ---- Uninstaller Section ----
Section "Uninstall"
  ; Delete DLLs from System32/SysWOW64
  ${If} ${RunningX64}
    ${DisableX64FSRedirection}
    Delete "$SYSDIR\libaacs.dll"
    Delete "$SYSDIR\libbdplus.dll"
    ${EnableX64FSRedirection}
  ${EndIf}
  
  ; Delete 32-bit versions if they were installed on a 64-bit system
  Delete "$SYSDIR\libaacs.dll"
  Delete "$SYSDIR\libbdplus.dll"

  ; Remove uninstaller and folder
  Delete "$INSTDIR\Uninstall.exe"
  RMDir "$INSTDIR"

  ; Remove registry keys
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\libaacs-libbdplus-windows"
SectionEnd

; ---- Functions ----
Function .onInit
  ; Unselect everything
  SectionSetFlags ${SEC_32BIT} 0
  SectionSetFlags ${SEC_64BIT} 0
  SectionSetFlags ${SEC_ARM64} 0

  ; Detect Architecture
  ${If} ${IsNativeARM64}
    StrCpy $BITNESS "ARM64"
    SectionSetFlags ${SEC_ARM64} ${SF_SELECTED}
    ; Disable other sections because only ARM64 can run on this CPU
    IntOp $0 ${SF_SELECTED} | ${SF_RO}
    SectionSetFlags ${SEC_ARM64} $0 
    SectionSetFlags ${SEC_32BIT} ${SF_RO}
    SectionSetFlags ${SEC_64BIT} ${SF_RO}

  ${ElseIf} ${IsNativeAMD64}
    StrCpy $BITNESS "64"
    ; On x64 systems, select 64-bit by default but keep both 32/64 unlocked
    SectionSetFlags ${SEC_64BIT} ${SF_SELECTED}
    SectionSetFlags ${SEC_32BIT} 0
    ; Lock ARM64 because it won't run on this CPU
    SectionSetFlags ${SEC_ARM64} ${SF_RO}
  ${Else}
    StrCpy $BITNESS "32"
    ; On 32-bit only systems, select 32-bit and lock 64-bit options
    SectionSetFlags ${SEC_32BIT} ${SF_SELECTED}
    SectionSetFlags ${SEC_64BIT} ${SF_RO}
    SectionSetFlags ${SEC_ARM64} ${SF_RO}
  ${EndIf}
FunctionEnd

; Descriptions
LangString DESC_SEC_32BIT ${LANG_ENGLISH} "Install 32-bit (x86) version of the DLL files."
LangString DESC_SEC_64BIT ${LANG_ENGLISH} "Install 64-bit (x64) version of the DLL files."
LangString DESC_SEC_ARM64 ${LANG_ENGLISH} "Install 64-bit ARM version of the DLL files."

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_32BIT} $(DESC_SEC_32BIT)
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_64BIT} $(DESC_SEC_64BIT)
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_ARM64} $(DESC_SEC_ARM64)
!insertmacro MUI_FUNCTION_DESCRIPTION_END