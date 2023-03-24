{
 * UParamParser.pas
 *
 * Implements a class that parses the CHInst program command line and sets
 * properties according to the commands provided. Detects and reports errors.
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
 * The Original Code is UParamParser.pas.
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


unit UParamParser;

interface

type

  {
  THelpAction:
    Enumeration giving details of an help action required.
  }
  THelpAction = (
    haNone,     // don't display help
    haBrief,    // display help on screen
    haWinHelp   // display CHI's Windows help file
  );

  {
  TParamParser:
    Class that parses the CHInst program command line and sets properties
    according to the commands provided. Detects and reports errors.
  }
  TParamParser = class(TObject)
  private // properties
    fDeleteFile: Boolean;
    fDelphiVer: Integer;
    fDescription: string;
    fHelpDestFile: string;
    fHelpSourceFile: string;
    fInstall: Boolean;
    fQuiet: Boolean;
    fShowHelp: THelpAction;
    fUnRegister: Boolean;
  private
    function IsSwitch(const Param: string): Boolean;
      {Returns true if given parameter is a switch, false if not}
    function SwitchChar(const Param: string): Char;
      {If given parameter is a switch, returns the character that identifies it,
      otherwise returns #0}
    function DelphiVerFromSwitch(const VerSwitch: string): Integer;
      {Assuming given switch is V switch, extracts the version number from the
      switch (it is 3rd character). Raises error if version is not valid for
      CHI}
  public
    procedure Execute;
      {Parses the command line and sets the properties}
    property DeleteFile: Boolean read fDeleteFile;
      {True if file being uninstalled is to be deleted: valid only when Install
      is false}
    property DelphiVer: Integer read fDelphiVer;
      {The version of Delphi the install or uninstall operation is being
      performed on}
    property Description: string read fDescription;
      {Description of help file being installed: valid only when Install is
      true}
    property HelpDestFile: string read fHelpDestFile;
      {Destination file name for help file being installed: valid only when
      Install is true. If '' then source file is installed without copying}
    property HelpSourceFile: string read fHelpSourceFile;
      {Name of source help file being installed: valid only when Install is
      true}
    property Install: Boolean read fInstall;
      {Flag true if we are installing a help file and false if uninstalling}
    property Quiet: Boolean read fQuiet;
      {Flag true if installation is to be silent: ie no console output}
    property ShowHelp: THelpAction read fShowHelp;
      {Flag true if user has requested a help screen: no installation or
      uninstallation takes place in this case}
    property UnRegister: Boolean read fUnRegister;
      {Flag true if help file being uninstalled is to be unregistered with
      Windows: valid only when Install is false}
  end;

implementation

uses
  // Project
  UCHInstError, UDelphiVerInfo;

{ TParamParser }

function TParamParser.DelphiVerFromSwitch(
  const VerSwitch: string): Integer;
  {Assuming given switch is V switch, extracts the version number from the
  switch (it is 3rd character). Raises error if version is not valid for CHI}
begin
  Result := 0;  // keeps compiler happy!
  if Length(VerSwitch) = 3 then
  begin
    Result := Ord(VerSwitch[3]) - Ord('0');
    if (Result < FirstSupportedDelphiVersion)
      or (Result > LastSupportedDelphiVersion) then
      // Delphi version not valid
      RaiseCHInstError(ecBadDelphiVer);
  end
  else
    // Switch is not valid
    RaiseCHInstError(ecBadDelphiVer);
end;

procedure TParamParser.Execute;
  {Parses the command line and sets the properties}
var
  ParamIdx: Integer;  // the index of the parameter being parsed
begin
  // Start at 1st true parameter (0 index is program name}
  ParamIdx := 1;
  // Check if any params
  if ParamStr(ParamIdx) = '' then
    RaiseCHInstError(ecNoParams);
  // Default delphi version is 4
  fDelphiVer := 4;
  // Check if 1st param is a switch or not
  if IsSwitch(ParamStr(ParamIdx)) then
  begin
    // We have switch 1st: Get whether install, uninstall or display help screen
    fShowHelp := haNone;
    case SwitchChar(ParamStr(ParamIdx)) of
      'I':                    // we're installing
        fInstall := True;
      'U':                    // we're uninstalling
        fInstall := False;
      '?':                    // we need to display help screen
      begin
        fShowHelp := haBrief;
        Exit;                 // for help screen we ignore rest of commands
      end;
      'H':                    // we need to display WinHelp
      begin
        fShowHelp := haWinHelp;
        Exit;                 // for help screen we ignore rest of commands
      end;
      else
        RaiseCHInstError(ecBadSwitch);
    end;
    Inc(ParamIdx);            // move to next switch
  end
  else
    // 1st param is not a switch: this means installing
    fInstall := True;

  // Next (ie 1st or 2nd param) must be source file name, and not a switch
  fHelpSourceFile := ParamStr(ParamIdx);
  if (HelpSourceFile = '') or IsSwitch(HelpSourceFile) then
    RaiseCHInstError(ecSourceExpected);
  Inc(ParamIdx);

  // Deal with remaining switches
  while ParamStr(ParamIdx) <> '' do
  begin
    case SwitchChar(ParamStr(ParamIdx)) of
      'D':
      begin
        // Description
        // check we're installing: error if not
        if not Install then RaiseCHInstError(ecBadSwitch);
        Inc(ParamIdx);
        // description is next param: check it exists and isn't switch
        fDescription := ParamStr(ParamIdx);
        if (Description = '') or IsSwitch(Description) then
          RaiseCHInstError(ecDescExpected);
      end;
      'C':
      begin
        // Destination file name
        // check we're installing: error if not
        if not Install then RaiseCHInstError(ecBadSwitch);
        Inc(ParamIdx);
        // file name is next param: check it exists and isn't switch
        fHelpDestFile := ParamStr(ParamIdx);
        if (HelpDestFile = '') or IsSwitch(HelpDestFile) then
          RaiseCHInstError(ecDestExpected);
      end;
      'V':
        // Delphi version number: parse it out of switch
        fDelphiVer := DelphiVerFromSwitch(ParamStr(ParamIdx));
      'Q':
        // Want silent output
        fQuiet := True;
      'R':
      begin
        // Unregister file: must be uninstalling
        if Install then RaiseCHInstError(ecBadSwitch);
        fUnRegister := True;
      end;
      'X':
      begin
        // Delete file: must be uninstalling
        if Install then RaiseCHInstError(ecBadSwitch);
        fDeleteFile := True;
      end;
      else
        // Unknown switch: error
        RaiseCHInstError(ecBadSwitch);
    end;
    // Move to next param
    Inc(ParamIdx);
  end;
end;

function TParamParser.IsSwitch(const Param: string): Boolean;
  {Returns true if given parameter is a switch, false if not}
begin
  Result := (Length(Param) >= 2) and (Param[1] in ['/', '-']);
end;

function TParamParser.SwitchChar(const Param: string): Char;
  {If given parameter is a switch, returns the character that identifies it,
  otherwise returns #0}
begin
  if IsSwitch(Param) then
    Result := UpCase(Param[2])
  else
    Result := #0;
end;

end.

