{
 * UController.pas
 *
 * Defines a class that controls and performs main functions of the command line
 * CHInst program.
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
 * The Original Code is UController.pas.
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


unit UController;


interface


uses
  // Project
  UReporter, UParamParser;

type

  {
  TController:
    Object that controls and performs main functions of program: reads command
    line, performs program actions and reports progress.
  }
  TController = class(TObject)
  private
    fReporter: TReporter;
      {Reporter object used to report progress on console}
    fParamParser: TParamParser;
      {Object used to parse command line and expose values as properties}
    procedure ReportActions;
      {Reports required install / uninstall actions on console}
    procedure DoInstall;
      {Performs actual installation / uninstallation}
  public
    constructor Create;
      {Class constructor: creates owned objects}
    destructor Destroy; override;
      {Class destructor: frees owned objects}
    function Execute: Integer;
      {Performs program actions and returns error code or 0 if no error}
  end;


implementation


uses
  // Delphi
  Windows,
  // Project
  IntfCHIInst, UCHIFileNames, UCHInstError;


function CreateCHIInstall: ICHIInstall; stdcall;
  external CHInstLibName;
  {Factory function imported from DLL that creates instance of installer object}

function CreateCHIInfo: ICHIInfo; stdcall;
  external CHInstLibName;
  {Factory function imported from DLL that creates an instance of a CHI info
  object}


{ TController }

constructor TController.Create;
  {Class constructor: creates owned objects}
begin
  inherited;
  fReporter := TReporter.Create;
  fParamParser := TParamParser.Create;
end;

destructor TController.Destroy;
  {Class destructor: frees owned objects}
begin
  fParamParser.Free;
  fReporter.Free;
  inherited;
end;

procedure TController.DoInstall;
  {Performs actual installation / uninstallation}
var
  Installer: ICHIInstall; // installer object from install DLL
  Info: ICHIInfo;         // information object from install DLL
begin
  // Create info object and find out if we have privileges for installation
  Info := CreateCHIInfo;
  if not Info.UserCanInstallHelp then
    RaiseCHInstError(ecBadPrivileges);
  // Create installer object
  Installer := CreateCHIInstall;
  // Do installation or uninstallation as required
  if fParamParser.Install then
  begin
    // Install
    if not Installer.Install(
      fParamParser.DelphiVer,
      fParamParser.HelpSourceFile,
      fParamParser.HelpDestFile,
      fParamParser.Description
    ) then
      // there was an error: raise install failed exception
      RaiseCHInstError(ecInstallFailed);
  end
  else
  begin
    // Uninstall
    if not Installer.UnInstall(
      fParamParser.DelphiVer,
      fParamParser.HelpSourceFile,
      fParamParser.DeleteFile,
      fParamParser.UnRegister
    ) then
      // there was an error: raise uninstall failed exception
      RaiseCHInstError(ecUnInstallFailed);
  end;
end;

function TController.Execute: Integer;
  {Performs program actions and returns error code or 0 if no error}
const
  // Help macro string
  cHelpMacro = 'KL("Command line application,overview")';
begin
  Result := 0;
  try
    // Parse the command line
    try
      fParamParser.Execute;
    finally
      // Tell reporter whether to be quiet or to display output then sign on
      fReporter.Quiet := fParamParser.Quiet;
    end;
    fReporter.SignOn;
    // Work out what to do
    if fParamParser.ShowHelp = haBrief then
      // user just wants a help screen: do it
      fReporter.DisplayHelp
    else if fParamParser.ShowHelp = haWinHelp then
      // user wants WinHelp topic - display it
      WinHelp(0, CHIHelpFileName, HELP_COMMAND, LongInt(PChar(cHelpMacro))
      )
    else
    begin
      // we're actually installing / uninstalling: report and do it
      ReportActions;
      DoInstall;
    end;
  except
    on E: TCHInstError do
    begin
      // We had an error: record error code and report it
      Result := Ord(E.ErrCode);
      fReporter.DisplayError(E.Msg);
    end;
  end;
  // All done: sign off
  fReporter.SignOff;
  // If WinHelp has been display, close it
  if fParamParser.ShowHelp = haWinHelp then
    WinHelp(0, CHIHelpFileName, HELP_QUIT, 0);
end;

procedure TController.ReportActions;
  {Reports required install / uninstall actions on console}
begin
  if fParamParser.Install then
    // We're installing: report actions
    fReporter.DisplayInstallActions(
      fParamParser.HelpSourceFile,
      fParamParser.HelpDestFile,
      fParamParser.Description,
      fParamParser.DelphiVer
    )
  else
    // We're uninstalling: report actions
    fReporter.DisplayUninstallActions(
      fParamParser.HelpSourceFile,
      fParamParser.DeleteFile,
      fParamParser.UnRegister,
      fParamParser.DelphiVer
    );
end;

end.

