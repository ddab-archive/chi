{
 * UDelphiInfo.pas
 *
 * Provides information about available Delphi versions.
 *
 * $Rev: 42 $
 * $Date: 2010-04-09 17:25:16 +0100 (Fri, 09 Apr 2010) $
 *
 * ***** BEGIN LICENSE BLOCK *****
 *
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with the
 * License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 * 
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 * 
 * The Original Code is UDelphiInfo.pas.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2001-2010 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s):
 *   NONE
 *
 * ***** END LICENSE BLOCK *****
}


unit UDelphiInfo;


interface


uses
  // Project
  UDelphiVerInfo;


function DelphiHelpFileName(DelphiVersion: Integer; Ext: string): string;
  {Returns name of a Delphi help file with given extension for given version of
  Delphi}

function DelphiHelpFileSpec(DelphiVersion: Integer; Ext: string): string;
  {Returns full path to a Delphi help file with given extension for given
  version of Delphi}

function DelphiAlsFileName(DelphiVersion: Integer): string;
  {Returns name of an a-link keyword file for given version of Delphi}

function DelphiAlsFilePath(DelphiVersion: Integer): string;
  {Returns full path to an a-link keyword file for given version of Delphi}

function DelphiHelpDir(const DelphiVer: Integer): string;
  {Returns path to Help directory for a given version of Delphi}

function DelphiRootDir(DelphiVersion: Integer): string;
  {Returns path of the root directory of an installation of the given version of
  Delphi}

function AvailableDelphiVersions: TDelphiVersions;
  {Returns set of version numbers of installed versions of Delphi that are
  supported by CHI}


implementation


uses
  // Delphi
  Windows, SysUtils, Registry, Classes,
  // Project
  UFileUtils, UErrors;

const
  // Delphi registry keys
  cDelphiRootKey = 'Software\Borland\Delphi';
    {Key under which all installed versions of Delphi are listed in HKLM and
    HKCU}
  cDelphiExpertsSubKey = '\Experts';
    {Sub key under Delphi's root key in HKCU under which DLL-based experts are
    registered}
  cDelphiRootDirValue = 'RootDir';
    {Name of value under DelphiVerRootKey where installation directory is stored
    for each version of Delphi}

resourcestring
  // Error messages
  sDelphiRegErr = 'Can''t access registry info for Delphi %d';
  sDelphiRootDirErr = 'Can''t find root directory of Delphi %d';


function DelphiVerRootKey(DelphiVersion: Integer): string; forward;
  {Returns root registry key under HKEY_LOCAL_MACHINE for given version of
  Delphi}
function InstalledDelphiVersions: TDelphiVersions; forward;
  {Returns set of version numbers for all installed versions of Delphi}
function SupportedDelphiVersions: TDelphiVersions; forward;
  {Returns set of version nunbers of Delphi versions supported by CHI}


function AvailableDelphiVersions: TDelphiVersions;
  {Returns set of version numbers of installed versions of Delphi that are
  supported by CHI}
begin
  Result := InstalledDelphiVersions * SupportedDelphiVersions;
end;

function DelphiHelpFileName(DelphiVersion: Integer; Ext: string): string;
  {Returns name of a Delphi help file with given extension for given version of
  Delphi}
const
  // File names used for help.* files in each supported Delphi version
  // do not localise
  cFileStub: array[FirstSupportedDelphiVersion..LastSupportedDelphiVersion]
    of string = (
      'Delphi3', 'Delphi4', 'Delphi5', 'Delphi6', 'D7'
    );
begin
  Assert(
    DelphiVersion in [FirstSupportedDelphiVersion..LastSupportedDelphiVersion]
  );
  // Ensure extension begins with '.'
  if (Ext <> '') and (Ext[1] <> '.') then
    Ext := '.' + Ext;
  // Return file name
  Result := cFileStub[DelphiVersion] + Ext;
end;

function DelphiHelpFileSpec(DelphiVersion: Integer; Ext: string): string;
  {Returns full path to a Delphi help file with given extension for given
  version of Delphi}
begin
  Result := MakeFilePath(DelphiHelpDir(DelphiVersion))
    + DelphiHelpFileName(DelphiVersion, Ext);
end;

function DelphiAlsFileName(DelphiVersion: Integer): string;
  {Returns name of an a-link keyword file for given version of Delphi}
begin
  Result := DelphiHelpFileName(DelphiVersion, 'als');
end;

function DelphiAlsFilePath(DelphiVersion: Integer): string;
  {Returns full path to an a-link keyword file for given version of Delphi}
begin
  Result := MakeFilePath(DelphiHelpDir(DelphiVersion))
    + DelphiAlsFileName(DelphiVersion);
end;

function DelphiHelpDir(const DelphiVer: Integer): string;
  {Returns path to Help directory for a given version of Delphi}
begin
  Result := DelphiRootDir(DelphiVer) + '\Help';
end;

function DelphiRootDir(DelphiVersion: Integer): string;
  {Returns path of the root directory of an installation of the given version of
  Delphi}
var
  Reg: TRegistry;   // registry object
  KeyName: string;  // name of reg key where Delphi root is stored
begin
  // Calculate root key name for given Delphi version
  KeyName := DelphiVerRootKey(DelphiVersion);
  // Open registry key
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if not Reg.OpenKeyReadOnly(KeyName) then
      Error(sDelphiRegErr, [DelphiVersion]);
    // Read root directory from registry
    Result := Reg.ReadString(cDelphiRootDirValue);
    if Result = '' then
      Error(sDelphiRootDirErr, [DelphiVersion]);
  finally
    Reg.Free;
  end;
end;

function DelphiVerRootKey(DelphiVersion: Integer): string;
  {Returns root registry key under HKEY_LOCAL_MACHINE for given version of
  Delphi}
const
  cDelphiVerRootKey = cDelphiRootKey + '\%d.0';  // Template for root key
begin
  Result := Format(cDelphiVerRootKey, [DelphiVersion]);
end;

function InstalledDelphiVersions: TDelphiVersions;
  {Returns set of version numbers for all installed versions of Delphi}
var
  Reg: TRegistry;         // registry object
  KeyNames: TStringList;  // names of sub keys of Delphi reg kay - ver numbers
  Idx: Integer;           // loops through version reg keys

  // ---------------------------------------------------------------------------
  function DelphiVerStrToByte(const VerStr: string): Byte;
    {Converts the given version number to a major version number}
  begin
    // We need to ensure version string contains decimal separator for locale
    // before converting to a number using StrToFloat
    Result := Trunc(
      StrToFloat(
        StringReplace(VerStr, '.', DecimalSeparator, [])
      )
    );
  end;
  // ---------------------------------------------------------------------------

begin
  // Initialise
  Result := [];
  KeyNames := nil;
  // Open Delphi registry key in HKEY_LOCAL_MACHINE
  Reg := TRegistry.Create;
  try
    // Open the root key for all Delphi installations
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if not Reg.OpenKeyReadOnly(cDelphiRootKey) then
      Exit;
    // Get sub keys of Delphi reg key - these are version numbers
    KeyNames := TStringList.Create;
    Reg.GetKeyNames(KeyNames);
    // Convert the version strings to byte values and add to result set
    for Idx := 0 to Pred(KeyNames.Count) do
      Result := Result + [DelphiVerStrToByte(KeyNames[Idx])];
  finally
    KeyNames.Free;
    Reg.Free;
  end;
end;

function SupportedDelphiVersions: TDelphiVersions;
  {Returns set of version nunbers of Delphi versions supported by CHI}
begin
  Result := [FirstSupportedDelphiVersion..LastSupportedDelphiVersion]
end;

end.

