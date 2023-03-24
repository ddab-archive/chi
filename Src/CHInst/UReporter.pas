{
 * UReporter.pas
 *
 * Defines object used to display information about program on console, and to
 * detect user input.
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
 * The Original Code is UReporter.pas.
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


unit UReporter;


interface


type

  {
  TReporter:
    Object used to display information about program on console, and to detect
    user input. Output can be toggled on and off by using Quiet property.
  }
  TReporter = class(TObject)
  private
    fQuiet: Boolean;
      {Flag true if quiet (i.e. no) output}
    fSignedOn: Boolean;
      {Flag true if SignOn method has been called}
    procedure Say(const Line: string);
      {Outputs given line of text on console. No action is taken if Quiet
      property is false}
  public
    procedure SignOn;
      {Outputs sign-on message on console: sign-on message is only displayed
      once regardless of how many times this method is called}
    procedure SignOff;
      {Outputs prompt on console and waits for user to press return. This is not
      done if Quiet property is false}
    procedure DisplayUsage;
      {Display text on console informing user of program's usage, providing
      Quiet property is false}
    procedure DisplayHelp;
      {Displays detailed help on using the program on the console - providing
      Quiet property is false}
    procedure DisplayError(const Msg: string);
      {Displays the given error message on console, ensuring that program has
      signed on first. Also displays program usage. No action taken if Quiet
      property is false}
    procedure DisplayInstallActions(const HelpSourceFile, HelpDestFile,
      Description: string; const DelphiVer: Integer);
      {Displays the actions the program is about to perform on installation:
      info displayed depends on parameters. Nothing is displayed if Quiet
      property is false}
    procedure DisplayUninstallActions(const HelpSourceFile: string;
      const DeleteFile, UnRegister: Boolean; const DelphiVer: Integer);
      {Displays the actions the program is about to perform on uninstallation:
      info displayed depends on parameters. Nothing is displayed if Quiet
      property is false}
    property Quiet: Boolean read fQuiet write fQuiet default False;
      {When this property is true the reporter displays messages on the console
      and reads user input from it. When Quiet is false the reporter ignores
      all display and input requests}
  end;


implementation


{ TReporter }

procedure TReporter.DisplayError(const Msg: string);
  {Displays the given error message on console, ensuring that program has signed
  on first. Also displays program usage. No action taken if Quiet property is
  false}
begin
  // Sign on (if required) and display error message
  SignOn;
  Say('Error: ' + Msg);
  Say('');
  // Display usage and info about getting detailed help
  DisplayUsage;
  Say('Use CHInst -? to display help.');
  Say('');
end;

procedure TReporter.DisplayHelp;
  {Displays detailed help on using the program on the console - providing Quiet
  property is false}
begin
  DisplayUsage;
  Say('-c  copy help file to location specified by next parameter');
  Say('-d  description of help file specified by next parameter');
  Say('-h  help: displays the Windows help file at the Command Line application'
    + ' topic');
  Say('-i  install: expects install file name as next parameter');
  Say('-q  quiet mode: no screen output');
  Say('-r  remove help file from registry when uninstalling');
  Say('-u  uninstall: expects uninstall file name as next parameter');
  Say('-vX Delphi version: X=3..7 (default: -v4)');
  Say('-x  delete help file when uninstalling');
  Say('-?  help: displays this usage information - following parameters are '
    + 'ignored');
  Say('');
  Say('Switches are not case sensitive and can be preceded by '
    + '''/'' or ''-''.');
  Say('Those switches following help file name can occur in any order.');
  Say('$(ROOT) or $(HELP) in file paths are replaced by Delphi''s root and '
    + 'help paths.');
  Say('');
end;

procedure TReporter.DisplayInstallActions(const HelpSourceFile,
  HelpDestFile, Description: string; const DelphiVer: Integer);
  {Displays the actions the program is about to perform on installation: info
  displayed depends on parameters. Nothing is displayed if Quiet property is
  false}
begin
  if HelpDestFile = '' then
    // We have no destination file, so we install source file
    Say('Installing ' + HelpSourceFile)
  else
  begin
    // We have a destination file so we copy source and install destination file
    Say('Copying ' + HelpSourceFile + ' to ' + HelpDestFile);
    Say('Installing ' + HelpDestFile);
  end;
  // We report Delphi version number
  Say('Into Delphi version ' + Chr(DelphiVer + Ord('0')));
  // Report any provided description or say we have no description
  if Description <> '' then
    Say('Help file description is "' + Description + '"')
  else
    Say('Help file has no description');
  Say('');
end;

procedure TReporter.DisplayUninstallActions(const HelpSourceFile: string;
  const DeleteFile, UnRegister: Boolean; const DelphiVer: Integer);
  {Displays the actions the program is about to perform on uninstallation: info
  displayed depends on parameters. Nothing is displayed if Quiet property is
  false}
begin
  // Say which file we're uninstalling, and from which version of Delphi
  Say('Uninstalling ' + HelpSourceFile);
  Say('From Delphi version ' + Chr(DelphiVer + Ord('0')));
  Say('Help file:');
  // Note if we are deleting file
  if DeleteFile then
    Say('  will be deleted')
  else
    Say('  will not be deleted');
  // Note if file is to be un-registered with Windows
  if UnRegister then
    Say('  will be unregistered with Windows')
  else
    Say('  will not be unregistered with Windows');
  Say('');
end;

procedure TReporter.DisplayUsage;
  {Display text on console informing user of program's usage, providing Quiet
  property is false}
begin
  Say('Usage is:');
  Say('  CHInst [-i] help_file [-vX] '
    + '[-c copy_help_file] [-d description] [-q]');
  Say('  CHInst -u help_file [-vX] [-r] [-x] [-q]');
  Say('  CHInst -h | -?');
  Say('');
end;

procedure TReporter.Say(const Line: string);
  {Outputs given line of text on console. No action is taken if Quiet property
  is false}
begin
  if not fQuiet then
    WriteLn(Line);
end;

procedure TReporter.SignOff;
  {Outputs prompt on console and waits for user to press return. This is not
  done if Quiet property is false}
begin
  if not Quiet then
  begin
    Write('Press Enter to end');
    ReadLn;
  end;
end;

procedure TReporter.SignOn;
  {Outputs sign-on message on console: sign-on message is only displayed once
  regardless of how many times this method is called}
begin
  // Check if we have done this before
  if not fSignedOn then
  begin
    Say('DelphiDabbler: Component Help Installer');
    Say('Command Line Version');
    Say('Copyright (c) 2001-2003 P.D.Johnson, Wales, UK');
    Say('----------------------------------------------');
    // Record that we've now output the message
    fSignedOn := True;
  end;
end;

end.

