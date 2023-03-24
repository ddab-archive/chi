@echo off

rem ----------------------------------------------------------------------------
rem Batch file used to build all binary resources files for the CHI project.
rem
rem Requires the BRCC32 resource compiler supplied with Delphi and the
rem DelphiDabbler VIEd version information editor available from
rem http://www.delphidabbler.com/software/vied
rem
rem The DELPHIROOT environment variable must be set to the root Delphi install
rem directory. The VIEDROOT environment variable must be set to the install 
rem directory of VIEd, unless VIEd is on the path.
rem
rem $Rev: 69 $
rem $Date: 2010-05-10 16:31:15 +0100 (Mon, 10 May 2010) $
rem ----------------------------------------------------------------------------

setlocal

set RC="%DELPHIROOT%\Bin\BRCC32.exe"

set VIED=VIEd.exe
if not "%VIEDROOT%" == "" set VIED="%VIEDROOT%\%VIED%"

cd ..

%RC% Src\CHI\CHIResources.rc -foBin\CHI\CHIResources.res

%RC% Src\CHInst\CHInstResources.rc -foBin\CHInst\CHInstResources.res

%RC% Src\Shared\Graphics\CHIIcon.rc -foBin\Shared\CHIIcon.res

%VIED% -makerc Src\CHI\CHIVerInfo.vi
%RC% Src\CHI\CHIVerInfo.rc -foBin\CHI\CHIVerInfo.res
del Src\CHI\CHIVerInfo.rc

%VIED% -makerc Src\CHInst\CHInstVerInfo.vi
%RC% Src\CHInst\CHInstVerInfo.rc -foBin\CHInst\CHInstVerInfo.res
del Src\CHInst\CHInstVerInfo.rc

%VIED% -makerc Src\CHInstLib\CHInstLibVerInfo.vi
%RC% Src\CHInstLib\CHInstLibVerInfo.rc -foBin\CHInstLib\CHInstLibVerInfo.res
del Src\CHInstLib\CHInstLibVerInfo.rc

endlocal
