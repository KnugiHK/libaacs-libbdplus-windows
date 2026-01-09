; Installer properties
Name "libaacs & libbdplus Installer"
OutFile "libaacs-bdplus.exe"
InstallDir "$SYSDIR"
RequestExecutionLevel admin

; Variables
Var BITNESS

; Pages
!include "MUI2.nsh"
!include "LogicLib.nsh" ; Required for {If} statements

!define MUI_PAGE_CUSTOMFUNCTION_LEAVE ComponentsLeave
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

; Languages
!insertmacro MUI_LANGUAGE "English"

; Sections
Section "32-bit DLLs (x86)" SEC_32BIT
  SetOutPath "$SYSDIR"
  File "win86\libaacs.dll"
  File "win86\libbdplus.dll"
SectionEnd

Section "64-bit DLLs (x64)" SEC_64BIT
  SetOutPath "$SYSDIR"
  File "win64\libaacs.dll"
  File "win64\libbdplus.dll"
SectionEnd

Section "ARM 64-bit DLLs" SEC_ARM64
  SetOutPath "$SYSDIR"
  File "winarm64\libaacs.dll"
  File "winarm64\libbdplus.dll"
SectionEnd

; Functions
Function .onInit
  ; Set default to 64-bit
  StrCpy $BITNESS "64"
  
  SectionSetFlags ${SEC_32BIT} 0
  SectionSetFlags ${SEC_64BIT} ${SF_SELECTED}
  SectionSetFlags ${SEC_ARM64} 0
FunctionEnd

Function ComponentsLeave
  ; Get selection states
  SectionGetFlags ${SEC_32BIT} $0
  SectionGetFlags ${SEC_64BIT} $1
  SectionGetFlags ${SEC_ARM64} $2
  
  ; Mask the selection bit
  IntOp $0 $0 & ${SF_SELECTED}
  IntOp $1 $1 & ${SF_SELECTED}
  IntOp $2 $2 & ${SF_SELECTED}
  
  ; Calculate how many sections are selected
  IntOp $3 $0 + $1
  IntOp $3 $3 + $2

  ; Validation: Ensure exactly one is selected
  ${If} $3 == 0
    MessageBox MB_OK|MB_ICONEXCLAMATION "Please select one version to install!"
    Abort
  ${ElseIf} $3 > 1
    MessageBox MB_OK|MB_ICONEXCLAMATION "Please select only one architecture (32-bit, 64-bit, or ARM64)!"
    Abort
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