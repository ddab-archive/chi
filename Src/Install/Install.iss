; Install.iss
;
; Install file generation script for use with Inno Setup (with ISPP).
;
; $Rev: 76 $
; $Date: 2010-05-10 17:26:05 +0100 (Mon, 10 May 2010) $
;
; ***** BEGIN LICENSE BLOCK *****
;
; Version: MPL 1.1
;
; The contents of this file are subject to the Mozilla Public License Version
; 1.1 (the "License"); you may not use this file except in compliance with the
; License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
;
; Software distributed under the License is distributed on an "AS IS" basis,
; WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
; the specific language governing rights and limitations under the License.
;
; The Original Code is Install.iss
;
; The Initial Developer of the Original Code is Peter Johnson
; (http://www.delphidabbler.com/).
;
; Portions created by the Initial Developer are Copyright (C) 2010 Peter
; Johnson. All Rights Reserved.
;
; Contributors:
;    NONE
;
; ***** END LICENSE BLOCK *****

; The following defines use these macros that are predefined by ISPP:
;   SourcePath - path where this script is located
;   GetStringFileInfo - gets requested version info string from an executable
;   GetFileProductVersion - gets product version info string from an executable

; Deletes "Release " from beginning of S
#define DeleteToVerStart(str S) \
  /* assumes S begins with "Release " followed by version as x.x.x */ \
  Local[0] = Copy(S, Len("Release ") + 1, 99), \
  Local[0]
  
#define AppPublisher "DelphiDabbler"

#define ReadMeFile "ReadMe.txt"

#define OutDir SourcePath + "..\..\Exe"

#define SrcDocsPath SourcePath + "..\..\Docs\"

#define SrcExePath SourcePath + "..\..\Exe\"

#define ExeProg SrcExePath + "CHI.exe"

#define AppVersion DeleteToVerStart(GetFileProductVersion(ExeProg))

#define Copyright GetStringFileInfo(ExeProg, LEGAL_COPYRIGHT)

#define Company "DelphiDabbler.com"

#define WebAddress "www.delphidabbler.com"

#define WebURL "http://" + WebAddress + "/"

; Creates name of setup file from app name, version and any special build string
#define CreateSetupName(str fn) \
  Local[0] = GetStringFileInfo(fn, "SpecialBuild"), \
  Local[1] = (Local[0] == "") ? "" : "-" + Local[0], \
  "CHI-Setup-" + AppVersion + Local[1]

#define SetupName CreateSetupName(ExeProg)

[Setup]
AppID={{3D281ECB-A9C7-4C3A-B244-F2566DAD890A}
AppName=Component Help Installer
AppVersion={#AppVersion}
AppVerName={#AppPublisher} Component Help Installer {#AppVersion}
AppPublisher={#AppPublisher}
AppPublisherURL={#WebURL}
AppReadMeFile={app}\{#ReadMeFile}
AppCopyright={#Copyright} ({#WebAddress})
AppComments=
AppContact=
DefaultDirName={pf}\{#AppPublisher}\CHI
DefaultGroupName={#AppPublisher} CHI
AllowNoIcons=true
LicenseFile={#SrcDocsPath}License.rtf
Compression=lzma/ultra
SolidCompression=true
InternalCompressLevel=ultra
OutputDir={#OutDir}
OutputBaseFilename={#SetupName}
VersionInfoVersion={#AppVersion}
VersionInfoCompany={#Company}
VersionInfoDescription=Installer for Component Help Installer
VersionInfoTextVersion=Release {#AppVersion}
VersionInfoCopyright={#Copyright}
MinVersion=0,4.0.1381sp6
TimeStampsInUTC=true
ShowLanguageDialog=yes
UninstallFilesDir={app}\Uninstall
UninstallDisplayIcon={app}\CHI.exe
PrivilegesRequired=admin

[Files]
Source: {#SrcExePath}CHI.exe; DestDir: {app}
Source: {#SrcExePath}CHInst.exe; DestDir: {app}
Source: {#SrcExePath}CHInstLib.dll; DestDir: {app}
Source: {#SrcExePath}CHI.cnt; DestDir: {app}; Flags: ignoreversion
Source: {#SrcExePath}CHI.hlp; DestDir: {app}; Flags: ignoreversion
Source: {#SrcDocsPath}License.rtf; DestDir: {app}; Flags: ignoreversion
Source: {#SrcDocsPath}{#ReadMeFile}; DestDir: {app}; Flags: ignoreversion

[Icons]
Name: {group}\Component Help Installer; Filename: {app}\CHI.exe
Name: {group}\{cm:UninstallProgram,{#AppPublisher} CHI}; Filename: {uninstallexe}

[Run]
Filename: {app}\{#ReadMeFile}; Description: View the ReadMe file; Flags: nowait postinstall skipifsilent shellexec
Filename: {app}\CHI.exe; Description: {cm:LaunchProgram,Component Help Installer}; Flags: nowait postinstall skipifsilent runascurrentuser

[Messages]
BeveledLabel={#Company}

