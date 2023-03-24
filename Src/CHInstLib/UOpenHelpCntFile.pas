{
 * UOpenHelpCntFile.pas
 *
 * Unit that provides classes that read and write OpenHelp .cnt format files.
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
 * The Original Code is UOpenHelpCntFile.pas.
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


unit UOpenHelpCntFile;


interface


uses
  // Delphi
  Classes;

type

  {
  THelpCntFile:
    Class that encapsulates contents and basic actions of a help contents file.
  }
  THelpCntFile = class(TObject)
  private // properties
    fFileName: string;
    fLines: TStringList;
  protected
    procedure Load;
      {Load the help contents file from disk. The file must exist}
    procedure Save;
      {Saves the help contents file in memory to disk}
    function CheckFileExists: Boolean; virtual;
      {Returns true if help contents file exists and false if it doesn't}
    function IsTokenLine(const Token, Line: string): Boolean;
      {Returns true if the given line begins with the given token and false
      otherwise}
    function IsFileToken(const Token, FileName, Line: string;
      const Separator: Char): Boolean;
      {Tests whether the given line both begins with given token and references
      the given file. Separator is the character which delimits the filename in
      the line. Returns true if this is the case and false if not}
    function MakeIncludeStatement(const FileName: string): string;
      {Returns an Include statement for the given file}
    function MakeIndexStatement(const FileName, Description: string): string;
      {Returns an Index statement for the given description and file}
    function MakeLinkStatement(const FileName: string): string;
      {Returns a Link statement for the given file}
    function MakeCommentStatement(const Comment: string): string;
      {Returns a Comment statement using the given comment}
  public
    constructor Create(const FileName: string);
      {Class constructor: creates owned objects and loads contents of file if
      file exists}
    destructor Destroy; override;
      {Class destructor: saves contents of file and frees owned objects}
    property Lines: TStringList read fLines;
      {The lines of the help contents file}
    property FileName: string read fFileName;
      {The filename of the help contents file}
  end;


  {
  TOpenHelpCntFile:
    Class that manipulates an openhelp compatible help contents format file.
  }
  TOpenHelpCntFile = class(THelpCntFile)
  protected
    function FindFileToken(const Token, FileName: string;
      const Separator: Char): Integer;
      {Finds index of first line in file that begins with given token and
      reference given file. Separator is the character that delimits the file
      name in the line. Returns index of found line or -1 if no such line
      exists}
    function FindIndexFile(const FileName: string): Integer;
      {Returns index of first Index statement in file that references FileName.
      Returns -1 if no statement line exists}
    function FindLinkFile(const FileName: string): Integer;
      {Returns index of first Link statement in file that references FileName.
      Returns -1 if no such statement exists}
  public
    procedure IndexFile(const FileName, Description: string;
      const Insert: Boolean); virtual;
      {If Insert is true then ensure that the given file is indexed with the
      given description. If Insert is false then delete any Index that refers to
      FileName, regardless of Description}
    procedure LinkFile(const FileName: string;
      const Insert: Boolean); virtual;
      {If Insert is true then ensure that the given file is linked. If Insert is
      false then delete any Link statement that refers to given file}
    procedure IncludeFile(const FileName: string;
      const Insert: Boolean); virtual;
      {If Insert is true then ensure that a Include statement exists for the
      given file. The include statement should be appended to any existing block
      of include statements. If Insert is false then delete any existing Include
      statement for the file}
  end;


  {
  TCHICfgFile:
    Class that encapsulates the CHI open-help config file. This class is an open
    help compatible help contents file which has comments at its start that
    identify it. It uses a CHI specific statement type.
  }
  TCHICfgFile = class(TOpenHelpCntFile)
  protected
    function CheckFileExists: Boolean; override;
      {Return true if file already exists. If file doesn't exist then add
      required header comments to lines held in memory}
    function MakeInstallStatement(const FileName: string): string;
      {Returns an CHI specific Installed statement for the given file}
  public
    procedure InstalledFile(const FileName: string;
      const Insert: Boolean); virtual;
      {If Insert is true then ensure that the given file is listed as installed.
      If Insert is false then delete any Installed statement that refers to
      given file}
    procedure ListInstalledFiles(const List: TStrings);
      {Fill given TStrings object with list of help files installed by CHI and
      therefore referenced in the CHI config file}
  end;


implementation


uses
  // Delphi
  SysUtils;

const
  // Tokens that introduce various kinds of statements in CNT type files
  cIncludeToken = ':Include';
  cIndexToken   = ':Index';
  cLinkToken    = ':Link';
  // Special custom token that names installed file in CHI config file
  cInstallToken = ':Installed';


{ THelpCntFile }

function THelpCntFile.CheckFileExists: Boolean;
  {Returns true if help contents file exists and false if it doesn't}
begin
  Result := FileExists(fFileName);
end;

constructor THelpCntFile.Create(const FileName: string);
  {Class constructor: creates owned objects and loads contents of file if file
  exists}
begin
  inherited Create;
  fFileName := FileName;        // record file name
  fLines := TStringList.Create; // create object to store file's lines
  if CheckFileExists then       // load file into lines if file exists
    Load;
end;

destructor THelpCntFile.Destroy;
  {Class destructor: saves contents of file and frees owned objects}
begin
  Save;
  fLines.Free;
  inherited;
end;

function THelpCntFile.IsFileToken(const Token, FileName, Line: string;
  const Separator: Char): Boolean;
  {Tests whether the given line both begins with given token and references the
  given file. Separator is the character which delimits the filename in the
  line. Returns true if this is the case and false if not}
var
  SepPos: Integer;  // position of separator in line
  EndStr: string;   // the end of the line after the separator
begin
  // Check if required token begins line
  if IsTokenLine(Token, Line) then
  begin
    // End of line after separator should be file name
    SepPos := AnsiPos(Separator, Line);
    EndStr := Trim(Copy(Line, SepPos + 1, Length(Line)));
    Result := CompareText(EndStr, FileName) = 0;
  end
  else
    // Required token does not begin line
    Result := False;
end;

function THelpCntFile.IsTokenLine(const Token, Line: string): Boolean;
  {Returns true if the given line begins with the given token and false
  otherwise}
begin
  Result := AnsiPos(UpperCase(Token), UpperCase(TrimLeft(Line))) = 1;
end;

procedure THelpCntFile.Load;
  {Load the help contents file from disk. The file must exist}
begin
  fLines.LoadFromFile(fFileName);
end;

function THelpCntFile.MakeCommentStatement(const Comment: string): string;
  {Returns a Comment statement using the given comment}
begin
  Result := Format('; %s', [Comment]);
end;

function THelpCntFile.MakeIncludeStatement(const FileName: string): string;
  {Returns an Include statement for the given file}
begin
  Result := Format('%s %s', [cIncludeToken, FileName]);
end;

function THelpCntFile.MakeIndexStatement(const FileName,
  Description: string): string;
  {Returns an Index statement for the given description and file}
begin
  Result := Format('%s %s=%s', [cIndexToken, Description, FileName]);
end;

function THelpCntFile.MakeLinkStatement(const FileName: string): string;
  {Returns a Link statement for the given file}
begin
  Result := Format('%s %s', [cLinkToken, FileName]);
end;

procedure THelpCntFile.Save;
  {Saves the help contents file in memory to disk}
begin
  fLines.SaveToFile(fFileName);
end;


{ TOpenHelpCntFile }

function TOpenHelpCntFile.FindFileToken(const Token, FileName: string;
  const Separator: Char): Integer;
  {Finds index of first line in file that begins with given token and reference
  given file. Separator is the character that delimits the file name in the
  line. Returns index of found line or -1 if no such line exists}
var
  Idx: Integer; // loops thru lines in file
begin
  Result := -1;
  for Idx := 0 to Pred(fLines.Count) do
  begin
    if IsFileToken(Token, FileName, fLines[Idx], Separator) then
    begin
      Result := Idx;
      Break;
    end;
  end;
end;

function TOpenHelpCntFile.FindIndexFile(const FileName: string): Integer;
  {Returns index of first Index statement in file that references FileName.
  Returns -1 if no statement line exists}
begin
  Result := FindFileToken(cIndexToken, FileName, '=');
end;

function TOpenHelpCntFile.FindLinkFile(const FileName: string): Integer;
  {Returns index of first Link statement in file that references FileName.
  Returns -1 if no such statement exists}
begin
  Result := FindFileToken(cLinkToken, FileName, ' ');
end;

procedure TOpenHelpCntFile.IncludeFile(const FileName: string;
  const Insert: Boolean);
  {If Insert is true then ensure that a Include statement exists for the given
  file. The include statement should be appended to any existing block of
  include statements. If Insert is false then delete any existing Include
  statement for the file}
var
  Idx: Integer;   // index of line where Include statement is inserted/deleted
  Found: Boolean; // whether Include statement is found in file
begin
  // Find start of :Include section
  Idx := 0;
  while (Idx < fLines.Count)
    and not IsTokenLine(cIncludeToken, fLines[Idx]) do
    Inc(Idx);
  // Find end of :Include section or required line if present
  Found := False;
  while not Found
    and (Idx < fLines.Count)
    and IsTokenLine(cIncludeToken, fLines[Idx]) do
  begin
    if IsFileToken(cIncludeToken, FileName, fLines[Idx], ' ') then
      Found := True
    else
      Inc(Idx);
  end;
  // Do insertion or deletion
  if Insert then
  begin
    // insert include statement if it's not in file
    if not Found then
      Lines.Insert(Idx, MakeIncludeStatement(FileName));
  end
  else
  begin
    // delete any existing include from file
    if Found then
      Lines.Delete(Idx);
  end;
end;

procedure TOpenHelpCntFile.IndexFile(const FileName, Description: string;
  const Insert: Boolean);
  {If Insert is true then ensure that the given file is indexed with the given
  description. If Insert is false then delete any Index that refers to FileName,
  regardless of Description}
var
  Idx: Integer; // index of statement in file
begin
  // Find first index statement in file referencing file name
  Idx := FindIndexFile(FileName);
  if Insert then
  begin
    // Insert a statement
    if Idx = -1 then
      // statement doesn't exist: add it
      fLines.Add(MakeIndexStatement(FileName, Description))
    else
      // statement exists: update it with new description
      fLines[Idx] := MakeIndexStatement(FileName, Description);
  end
  else
  begin
    // Delete any existing statement
    if Idx > -1 then
      fLines.Delete(Idx);
  end;
end;

procedure TOpenHelpCntFile.LinkFile(const FileName: string;
  const Insert: Boolean);
  {If Insert is true then ensure that the given file is linked. If Insert is
  false then delete any Link statement that refers to given file}
var
  Idx: Integer; // index of statement line in file
begin
  // Get index of first Index statement in file that references line
  Idx := FindLinkFile(FileName);
  if Insert then
  begin
    // Insert a Link statement if one doesn't yet exist
    if Idx = -1 then
      fLines.Add(MakeLinkStatement(FileName));
  end
  else
  begin
    // Delete any existing Link statement
    if Idx > -1 then
      fLines.Delete(Idx);
  end;
end;


{ TCHICfgFile }

function TCHICfgFile.CheckFileExists: Boolean;
  {Return true if file already exists. If file doesn't exist then add required
  header comments to lines held in memory}
begin
  Result := inherited CheckFileExists;
  if not Result then
  with Lines do
  begin
    Add(MakeCommentStatement('--------------------------------------------'));
    Add(MakeCommentStatement('DelphiDabbler Component Help Installer (CHI)'));
    Add(MakeCommentStatement('Open Help Configuration File'));
    Add(MakeCommentStatement('This file is maintained by CHI - do not edit'));
    Add(MakeCommentStatement('--------------------------------------------'));
  end;
end;

procedure TCHICfgFile.InstalledFile(const FileName: string;
  const Insert: Boolean);
  {If Insert is true then ensure that the given file is listed as installed. If
  Insert is false then delete any Installed statement that refers to given file}
var
  Idx: Integer; // index of statement in file
begin
  // Find first index statement in file referencing file name
  Idx := FindFileToken(cInstallToken, FileName, ' ');
  if Insert then
  begin
    // Insert a statement
    if Idx = -1 then
      // statement doesn't exist: add it
      fLines.Add(MakeInstallStatement(FileName));
  end
  else
  begin
    // Delete any existing statement
    if Idx > -1 then
      fLines.Delete(Idx);
  end;
end;

procedure TCHICfgFile.ListInstalledFiles(const List: TStrings);
  {Fill given TStrings object with list of help files installed by CHI and
  therefore referenced in the CHI config file}
var
  LineIdx: Integer;   // iterates thru lines in file
  Line: string;       // a line in file
  FileName: string;   // file name incorporated in a line in file
begin
  if Assigned(List) then
  begin
    List.Clear;
    // Scan thru all lines in file, searching for :Link statement lines (file is
    // referenced in two statements: choice of :Link statements is arbitrary)
    for LineIdx := 0 to Pred(Lines.Count) do
    begin
      Line := Lines[LineIdx];
      if IsTokenLine(cInstallToken, Line) then
      begin
        // Extract file name from line - file name comes after space ...
        FileName := Trim(Copy(Line, AnsiPos(' ', Line) + 1, Length(Line)));
        // ... which we add to list if not already present
        if List.IndexOf(FileName) = -1 then
          List.Add(FileName);
      end;
    end;
  end;
end;

function TCHICfgFile.MakeInstallStatement(const FileName: string): string;
  {Returns an CHI specific Installed statement for the given file}
begin
  Result := Format('%s %s', [cInstallToken, FileName]);
end;

end.

