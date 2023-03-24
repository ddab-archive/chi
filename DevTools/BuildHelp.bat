@echo off

rem ----------------------------------------------------------------------------
rem Batch file used to build help file for the CHI project.
rem
rem Requires the HCRTF help supplied with Delphi.
rem
rem The DELPHIROOT environment variable must be set to the root Delphi install
rem directory.
rem
rem $Rev: 41 $
rem $Date: 2010-04-09 15:59:55 +0100 (Fri, 09 Apr 2010) $
rem ----------------------------------------------------------------------------

setlocal

set HC="%DELPHIROOT%\Help\Tools\HCRTF.exe"

cd ..

%HC% -x Src\CHI\Help\CHI.hpj
copy Src\CHI\Help\CHI.cnt Exe\CHI.cnt

endlocal
