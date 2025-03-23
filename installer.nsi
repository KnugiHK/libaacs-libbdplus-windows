; Installer properties
Name "libaacs & libbdplus Installer"
OutFile "libaacs-bdplus.exe"
InstallDir "$SYSDIR"
RequestExecutionLevel admin

; Variables
Var BITNESS

; Pages
!include "MUI2.nsh"
!define MUI_PAGE_CUSTOMFUNCTION_PRE ComponentsPre
!define MUI_PAGE_CUSTOMFUNCTION_LEAVE ComponentsLeave
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

; Languages
!insertmacro MUI_LANGUAGE "English"

; Sections
Section "32-bit DLLs" SEC_32BIT
  SetOutPath "$SYSDIR"
  File "win86\libaacs.dll"
  File "win86\libbdplus.dll"
SectionEnd

Section "64-bit DLLs" SEC_64BIT
  SetOutPath "$SYSDIR"
  File "win64\libaacs.dll"
  File "win64\libbdplus.dll"
SectionEnd

; Functions
Function .onInit
  ; Set default to 32-bit
  StrCpy $BITNESS "32"
  
  ; Select 32-bit section by default
  SectionSetFlags ${SEC_32BIT} ${SF_SELECTED}
  SectionSetFlags ${SEC_64BIT} 0
FunctionEnd

Function ComponentsPre
  ; Make sections mutually exclusive
  SectionGetFlags ${SEC_32BIT} $0
  SectionGetFlags ${SEC_64BIT} $1
  
  ${If} $0 & ${SF_SELECTED}
    SectionSetFlags ${SEC_64BIT} 0
  ${ElseIf} $1 & ${SF_SELECTED}
    SectionSetFlags ${SEC_32BIT} 0
  ${EndIf}
FunctionEnd

Function ComponentsLeave
  ; Check section selection states
  SectionGetFlags ${SEC_32BIT} $0
  SectionGetFlags ${SEC_64BIT} $1
  
  IntOp $0 $0 & ${SF_SELECTED}
  IntOp $1 $1 & ${SF_SELECTED}
  
  ; Check if both are selected
  ${If} $0 != 0
  ${AndIf} $1 != 0
    MessageBox MB_OK|MB_ICONEXCLAMATION "Please select only one version (32-bit or 64-bit), not both!"
    Abort ; Returns to the components page
  ${EndIf}
  
  ; Check if neither is selected
  ${If} $0 == 0
  ${AndIf} $1 == 0
    MessageBox MB_OK|MB_ICONEXCLAMATION "Please select either 32-bit or 64-bit version!"
    Abort ; Returns to the components page
  ${EndIf}
FunctionEnd

; Descriptions
LangString DESC_SEC_32BIT ${LANG_ENGLISH} "Install 32-bit version of the DLL files"
LangString DESC_SEC_64BIT ${LANG_ENGLISH} "Install 64-bit version of the DLL files"

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_32BIT} $(DESC_SEC_32BIT)
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_64BIT} $(DESC_SEC_64BIT)
!insertmacro MUI_FUNCTION_DESCRIPTION_END