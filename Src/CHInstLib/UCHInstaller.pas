{
 * UCHInstaller.pas
 *
 * Contains classes that perform installation / removal of component help.
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
 * The Original Code is UCHInstaller.pas.
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


unit UCHInstaller;


interface


uses
  // Project
  IntfCHIInst;


{ Exported factory functions }

function CreateCHIInstall: ICHIInstall; stdcall;
  {EXPORTED FUNCTION:
  Creates an instance of the installer object}

function CreateCHIInfo: ICHIInfo; stdcall;
  {EXPORTED FUNCTION:
  Creates an instance of the CHI info object}


implementation


uses
  // Delphi
  Windows, SysUtils, Classes, Registry,
  // Project
  UOpenHelpCntFile, UFileUtils, UDelphiInfo, UErrors;

resourcestring
  // Error messages
  sCntFileOpenErr = 'Can''t open contents file "%s".';
  sNoSourceFileGivenErr = 'A source file must be specified.';
  sSourceFileMissingErr = 'Source file "%s" does not exist.';


type

  {
  TCHIErrorHandler:
    Base class for classes that provide ErrorMessage method as part of their
    interface implementation.
  }
  TCHIErrorHandler = class(TInterfacedObject)
  private
    fErrorMessage: string;
      {Stores last error message: '' if no error}
  protected
    procedure SetErrorMessage(const E: Exception);
      {Sets last error message to that of given exception}
    procedure ClearErrorMessage;
      {Sets last error message to ''}
  protected
    function ErrorMessage: WideString; stdcall;
      {Returns last error message: this method is exposed by interfaces
      implemented by descended classes}
  end;


  {
  TCHIInstall:
    Class that installs and uninstalls help files into Delphi's OpenHelp system.
  }
  TCHIInstall = class(TCHIErrorHandler, ICHIInstall)
  protected
    { ICHIInstall }
    function Install(const DelphiVer: Integer; const ASourceFileName,
      ADestFileName, ADescription: WideString): WordBool; stdcall;
      {Installs the given help file (and any associated contents file) using the
      given description into the given version of Delphi's OpenHelp system. If
      ADestFileName is not '' and is different to ASourceFileName, the source
      file is copied as the destination file before installing from the new
      position. Returns True if all proceeds properly and False if the
      installation fails}
    function UnInstall(const DelphiVer: Integer;
      const AHelpFileName: WideString;
      const DeleteFile, UnRegister: LongBool): WordBool; stdcall;
      {Uninstalls the given help file (and any associated contents file) from
      the given version of Delphi's OpenHelp system. If DeleteFile is true the
      help file is deleted. If UnRegister is true the help file's registration
      with Windows is removed from the registry. Returns True if the
      installation succeeds and False otherwise}
    {function ErrorMessage: WideString; stdcall;}
      {Implemented in ancestor class}
  end;

  {
  TCHIInfo:
    Class that proides information about help files installed by CHI2.
  }
  TCHIInfo = class(TCHIErrorHandler, ICHIInfo)
  protected
    { ICHIInfo }
    function InstalledHelpFiles(const DelphiVer: Integer;
      out Files: WideString): WordBool; stdcall;
      {Sets Files to names of all help files installed by CHI for given version
      of Delphi. File names are separated by CR LF in string. Returns True on
      success or False on error. If function fails then ErrorMessage provides
      a description of the error}
    function FullHelpFilePath(FileName: WideString): WideString; stdcall;
      {Given the name of a help file installed by CHI, returns the full file
      path per the registry. If file is not installed in Windows, '' is
      returned}
    function UserCanInstallHelp: WordBool; stdcall;
      {Returns true if current user has privileges to install help files (which
      requires write access to HKLM in registry) and false if not}
    {function ErrorMessage: WideString; stdcall;}
      {Implemented in ancestor class}
  end;

{ Exported Factory functions }

function CreateCHIInstall: ICHIInstall; stdcall;
  {Creates an instance of ICHIInstall}
begin
  Result := TCHIInstall.Create;
end;

function CreateCHIInfo: ICHIInfo; stdcall;
  {Creates an instance of the CHI info object}
begin
  Result := TCHIInfo.Create;
end;

{ Helper routines }

const
  // Reg key where details of installed help files recorded in HKLM
  cWindowsHelpKey = 'Software\Microsoft\Windows\Help';
  // Extensions used for Delphi help files
  cCntFileExt     = '.cnt';   // contents file
  cIndexFileExt   = '.ohi';   // index file
  cLinkFileExt    = '.ohl';   // link file
  cGIDFileExt     = '.gid';   // hidden help "state" file
  cFTGFileExt     = '.ftg';   // help find file
  cHelpFileExt    = '.hlp';   // help file
  cALSFileExt     = '.als';   // a-link keyword file


function CHICfgFileName(DelphiVersion: Integer): string;
  {Gets name of config file for given version of Delphi}
const
  cCfgFileName = 'CHId%d.cfg'; // template for name of CHI's config file
begin
  Result := Format(cCfgFileName, [DelphiVersion]);
end;

function CHICfgFilePath(const DelphiVersion: Integer): string;
  {Returns full path to CHI's config file on the given version of Delphi}
begin
  Result := MakeFilePath(DelphiHelpDir(DelphiVersion))
    + CHICfgFileName(DelphiVersion);
end;

procedure RegHelpFileWithWindows(const FileName: string);
  {Registers the given help file with Windows by making appropriate entry in
  registry key HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\Help}
var
  Reg: TRegistry; // registry object
begin
  // Open registry key where help files are registered with Windows
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    Reg.OpenKey(cWindowsHelpKey, True);
    // Record info about help file in registry:
    //   Value Name = help file name, Value = directory containing help file
    Reg.WriteString(ExtractFileName(FileName), ExtractFileDir(FileName));
  finally
    Reg.Free;
  end;
end;

procedure UnRegHelpFileWithWindows(const FileName: string);
  {Un-registers the given help file with Windows by removing details from
  registry key HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\Help}
var
  Reg: TRegistry; // registry object
begin
  // Open registry key where help files are registered with Windows
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey(cWindowsHelpKey, False) then
      // Delete the help file's entry: Value name is help file name
      Reg.DeleteValue(ExtractFileName(FileName));
  finally
    Reg.Free;
  end;
end;

function RegisteredHelpFilePath(const FileName: string): string;
  {Returns path to given help file if the file has been registered with Windows.
  If help file is not registered with Windows then '' is returned. Provided
  help file name should not include a path}
var
  Reg: TRegistry; // registry object
begin
  // Open registry key where Windows registers help files
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKeyReadOnly(cWindowsHelpKey)
      and Reg.ValueExists(ExtractFileName(FileName)) then
      // Read path for file name (file name is name of value: path is value)
      Result := MakeFilePath(Reg.ReadString(ExtractFileName(FileName)))
        + FileName
    else
      Result := '';
  finally
    Reg.Free;
  end;
end;

function ExpandMacros(const DelphiVer: Integer; const Text: string): string;
  {Expands recognised macros in given text and returns the text containing the
  macro expansion}
const
  // Macro names
  cHelpMacro = '$(HELP)';
  cRootMacro = '$(ROOT)';

  // ---------------------------------------------------------------------------
  function MacroReplacement(const Macro: string): string;
    {Replace the given macro by its string representation and return it}
  begin
    if AnsiCompareText(Macro, cRootMacro) = 0 then
      Result := DelphiRootDir(DelphiVer)
    else if AnsiCompareText(Macro, cHelpMacro) = 0 then
      Result := DelphiHelpDir(DelphiVer)
    else
      Result := '';
  end;

  function ReplaceMacro(const Macro: string; Text: string): string;
    {Replace all occurences of given macro within the given string and returns
    result}
  begin
    Result := StringReplace(Text, Macro, MacroReplacement(Macro),
      [rfReplaceAll, rfIgnoreCase]);
  end;
  // ---------------------------------------------------------------------------

begin
  {Replace all occurences of supported macros by macro's current value}
  Result := ReplaceMacro(cRootMacro, Text);
  Result := ReplaceMacro(cHelpMacro, Result);
end;

function CanWriteHelpFileInfo: Boolean;
  {Tests whether we can write to windows help sub key of HKEY_LOCAL_MACHINE in
  registry. We need to be able to do this to record details of an installed help
  file}
var
  Reg: TRegistry;   // registry object
begin
  // Try to open required sub key in registry and record result
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    Result := Reg.OpenKey(cWindowsHelpKey, True);
  finally
    Reg.Free;
  end;
end;

procedure DeleteSupportFiles(DelphiVer: Integer);
  {Deletes the housekeeping files (.gid and .ftg) created by WinHelp when Delphi
  help files are displayed: these files cause new files to be ignored and
  invalid references to removed files to remain. Deletion causes the files to be
  regenerated and for changes made by CHI to have immediate effect}

  // ---------------------------------------------------------------------------
  procedure FindFiles(Path, FileSpec: string; const Files: TStrings);
    {Searches folder with given path for files matching given spec (wildcard)
    and adds found files to given string list}
  var
    SR: TSearchRec; // record used by file find routines
    Res: Integer;   // result of a file find call
  begin
    // Normalise the path
    Path := UFileUtils.MakeFilePath(Path);
    // Search for matching files, adding to string list
    Res := SysUtils.FindFirst(Path + FileSpec, faAnyFile, SR);
    try
      while Res = 0 do
      begin
        if (SR.Attr and faDirectory = 0) and (SR.Attr and faVolumeID = 0) then
          // ignore directories and volume ids
          Files.Add(Path + SR.Name);
        Res := SysUtils.FindNext(SR);
      end;
    finally
      SysUtils.FindClose(SR);
    end;
  end;
  // ---------------------------------------------------------------------------

var
  Files: TStringList; // list of files to be deleted
  Idx: Integer;       // loops thru file list
begin
  // Get list of files to delete
  Files := TStringList.Create;
  try
    FindFiles(MakeFilePath(DelphiHelpDir(DelphiVer)), '*' + cGIDFileExt, Files);
    FindFiles(MakeFilePath(DelphiHelpDir(DelphiVer)), '*' + cFTGFileExt, Files);
    // Delete all files in list
    for Idx := 0 to Pred(Files.Count) do
      SysUtils.DeleteFile(Files[Idx]);
  finally
    Files.Free;
  end;
end;

procedure MergeStringLists(const Src1, Src2, Dest: TStringList);
  {Merges two sorted source string lists into destination list, maintaining sort
  order}
var
  Idx1, Idx2: Integer;  // indexes into each of source lists
  Cmp: Integer;         // result of comparing entries in source lists
begin
  // Clear and estimate capacity of destination output list
  Dest.Clear;
  Dest.Capacity := Src1.Count + Src2.Count;
  // Loop thru all items in source list until end of one list reach
  Idx1 := 0;
  Idx2 := 0;
  while (Idx1 < Src1.Count) and (Idx2 < Src2.Count) do
  begin
    // Compare next two items in lists
    Cmp := AnsiCompareStr(Src1[Idx1], Src2[Idx2]);
    if Cmp < 0 then
    begin
      // Src1 < Src2: store & inc Src1
      Dest.Add(Src1[Idx1]);
      Inc(Idx1);
    end
    else if Cmp = 0 then
    begin
      // Src1 = Src2: store Src1 and inc both
      Dest.Add(Src1[Idx1]);
      Inc(Idx1);
      Inc(Idx2);
    end
    else // Cmp > 0
    begin
      // Src1 > Src2: store & inc Src2
      Dest.Add(Src2[Idx2]);
      Inc(Idx2);
    end;
  end;
  // Copy over last items from non-empty list: one of these loop will run
  while Idx1 < Src1.Count do
  begin
    Dest.Add(Src1[Idx1]);
    Inc(Idx1);
  end;
  while Idx2 < Src2.Count do
  begin
    Dest.Add(Src2[Idx2]);
    Inc(Idx2);
  end;
end;

procedure LoadALSFile(const ALSFileName: string; const ALSStrings: TStringList);
  {Loads an ALS file into a string list, ensuring list is all in lower case and
  sorted}
var
  FS: TFileStream;        // file stream that loads ALS file into string stream
  SSRaw: TStringStream;   // stores content of file when loaded
  SSLower: TStringStream; // stores content of file in lower case
begin
  SSRaw := nil;
  SSLower := nil;
  // Open stream onto file
  FS := TFileStream.Create(ALSFileName, fmOpenRead or fmShareDenyNone);
  try
    // Load file content into string stream
    SSRaw := TStringStream.Create('');
    SSRaw.CopyFrom(FS, 0);
    // Convert content as lower case
    SSLower := TStringStream.Create(AnsiLowerCase(SSRaw.DataString));
    // Finally copy stream into string list and sort
    ALSStrings.LoadFromStream(SSLower);
    ALSStrings.Sort;
  finally
    SSLower.Free;
    SSRaw.Free;
    FS.Free;
  end;
end;

procedure MergeALSFiles(const DelphiVer: Integer; const SourceFile: string);
  {Merges new ALS file into master Delphi ALS file, backing up original Delphi
  file}
var
  Master: TStringList;    // contains master Delphi ALS file content
  Source: TStringList;    // content of ALS file to be merged into master
  Dest: TStringList;      // contains merged content
  DelphiALSFile: string;  // full path of master Delphi ALS file
begin
  Source := nil;
  Dest := nil;
  // Create required string list
  Master := TStringList.Create;
  try
    Source := TStringList.Create;
    Dest := TStringList.Create;
    // Get name of Delphi master ALS file
    DelphiALSFile := DelphiAlsFilePath(DelphiVer);
    // Load master and new ALS to string lists
    LoadALSFile(DelphiALSFile, Master);
    LoadALSFile(SourceFile, Source);
    // Merge the ALS content
    MergeStringLists(Master, Source, Dest);
    // Save the merged content to master Delphi ALS file, safely
    Dest.SaveToFile(DelphiALSFile + '.tmp');
    DeleteFile(DelphiALSFile + '.bak');
    RenameFile(DelphiALSFile, DelphiALSFile + '.bak');  // backup of orig file
    DeleteFile(DelphiALSFile);
    RenameFile(DelphiALSFile + '.tmp', DelphiALSFile);  // new merged ALS file
  finally
    Dest.Free;
    Source.Free;
    Master.Free;
  end;
end;

{ TCHIErrorHandler }

procedure TCHIErrorHandler.ClearErrorMessage;
  {Sets last error message to ''}
begin
  fErrorMessage := '';
end;

function TCHIErrorHandler.ErrorMessage: WideString;
  {Returns last error message: this method is exposed by interfaces implemented
  by descended classes}
begin
  Result := fErrorMessage;
end;

procedure TCHIErrorHandler.SetErrorMessage(const E: Exception);
  {Sets last error message to that of given exception}
begin
  fErrorMessage := E.Message;
end;

{ TCHIInstall }

function TCHIInstall.Install(const DelphiVer: Integer;
  const ASourceFileName, ADestFileName, ADescription: WideString): WordBool;
  {Installs the given help file (and any associated contents and ALS files)
  using the given description into the given version of Delphi's OpenHelp
  system. If ADestFileName is not '' and is different to ASourceFileName, the
  source file is copied as the destination file before installing from the new
  position. Returns True if all proceeds properly and False if the installation
  fails}
var
  SourceFileName: string;     // name of source file after replacing macros
  DestFileName: string;       // name of dest file after replacing macros
  SourceCntFileName: string;  // path to any source contents file
  SourceAlsFileName: string;  // path to any a-link keyword file
  HelpFileName: string;       // path to help file to be registerd
  CntFileName: string;        // path to any contents file being registered
  CHICfgFile: TCHICfgFile;    // object used to update CHI's config file
  CntFile: TOpenHelpCntFile;  // object to access openhelp .cnt format files
begin

  // Assume OK result
  Result := True;
  ClearErrorMessage;

  try
    // Check source file valid
    SourceFileName := ExpandMacros(DelphiVer, ASourceFileName);
    if SourceFileName = '' then
      Error(sNoSourceFileGivenErr);
    if not FileExists(SourceFileName) then
      Error(sSourceFileMissingErr, [SourceFileName]);

    // Check if we're also handling contents files
    SourceCntFileName := ChangeFileExt(SourceFileName, cCntFileExt);
    if not FileExists(SourceCntFileName) then
      SourceCntFileName := '';

    // Check if we're handling a a-link keyword file (Delphi 6 & 7 only)
    SourceAlsFileName := '';
    if DelphiVer in [6, 7] then
    begin
      SourceAlsFileName := ChangeFileExt(SourceFileName, cALSFileExt);
      if not FileExists(SourceAlsFileName) then
        SourceAlsFileName := '';
    end
    else
      SourceAlsFileName := '';

    // Copy file and store name of help file we're to register
    DestFileName := ExpandMacros(DelphiVer, ADestFileName);
    if (DestFileName <> '')
      and (AnsiCompareText(SourceFilename, DestFileName) <> 0) then
    begin
      // we have a destination file name and its different to source: so copy
      CopyFile(SourceFileName, DestFileName);
      if SourceCntFileName <> '' then
      begin
        // we also have a .cnt file: copy that
        CntFileName := ChangeFileExt(DestFileName, cCntFileExt);
        CopyFile(SourceCntFileName, CntFileName);
      end
      else
        CntFileName := '';
      // dest file is the one we register
      HelpFileName := DestFileName;
    end
    else
    begin
      // No dest file (or same as source): source file is one we register
      HelpFileName := SourceFileName;
      CntFileName := SourceCntFileName;
    end;

    // Ensure Index and Link files are referenced in contents file
    CntFile := TOpenHelpCntFile.Create(
      DelphiHelpFileSpec(DelphiVer, cCntFileExt)
    );
    try
      CntFile.IncludeFile(DelphiHelpFileName(DelphiVer, cIndexFileExt), True);
      CntFile.IncludeFile(DelphiHelpFileName(DelphiVer, cLinkFileExt), True);
    finally
      CntFile.Free;
    end;

    // Reference our help file from Link file
    CntFile := TOpenHelpCntFile.Create(
      DelphiHelpFileSpec(DelphiVer, cLinkFileExt)
    );
    try
      CntFile.LinkFile(ExtractFileName(HelpFileName), True);
    finally
      CntFile.Free;
    end;

    // Reference our help file from Index file
    CntFile := TOpenHelpCntFile.Create(
      DelphiHelpFileSpec(DelphiVer, cIndexFileExt)
    );
    try
      CntFile.IndexFile(ExtractFileName(HelpFileName), ADescription, True);
    finally
      CntFile.Free;
    end;

    // Register help file in CHI's config file
    CHICfgFile := TCHICfgFile.Create(CHICfgFilePath(DelphiVer));
    try
      CHICfgFile.InstalledFile(ExtractFileName(HelpFileName), True);
    finally
      CHICfgFile.Free;
    end;

    // Install ALS files under Delphi 6 and 7
    if (DelphiVer in [6, 7]) and (SourceAlsFileName <> '') then
      MergeALSFiles(DelphiVer, SourceAlsFileName);

    // Ensure files recorded in registry
    // our help and any contents file
    RegHelpFileWithWindows(HelpFileName);
    if CntFilename <> '' then
      RegHelpFileWithWindows(CntFileName);
    // delphi's help, contents, link and index files
    RegHelpFileWithWindows(DelphiHelpFileSpec(DelphiVer, cHelpFileExt));
    RegHelpFileWithWindows(DelphiHelpFileSpec(DelphiVer, cCntFileExt));
    RegHelpFileWithWindows(DelphiHelpFileSpec(DelphiVer, cIndexFileExt));
    RegHelpFileWithWindows(DelphiHelpFileSpec(DelphiVer, cLinkFileExt));

    // Delete any old househeeping files
    DeleteSupportFiles(DelphiVer);

  except
    // There was an error
    on E: Exception do
    begin
      Result := False;
      SetErrorMessage(E);
    end;
  end;

end;

function TCHIInstall.UnInstall(const DelphiVer: Integer;
  const AHelpFileName: WideString; const DeleteFile,
  UnRegister: LongBool): WordBool;
  {Uninstalls the given help file (and any associated contents file) from the
  given version of Delphi's OpenHelp system. If DeleteFile is true the help file
  is deleted. If UnRegister is true the help file's registration with Windows is
  removed from the registry. Returns True if the installation succeeds and
  False otherwise}
var
  CntFileName: string;        // path to any contents file being registered
  CHICfgFile: TCHICfgFile;    // object used to update CHI's config file
  HelpFileName: string;       // expanded name of help file
  CntFile: TOpenHelpCntFile;  // object to access openhelp .cnt format files
begin

  // Assume all is OK
  Result := True;
  ClearErrorMessage;

  try
    // Record name of help file to process: after expanding macros
    HelpFileName := ExpandMacros(DelphiVer, AHelpFileName);

    // Check if we're also handling contents files
    CntFileName := ChangeFileExt(HelpFileName, cCntFileExt);
    if not FileExists(CntFileName) then
      CntFileName := '';

    // Optionally remove help file (and cnt file) from registry
    if UnRegister then
    begin
      UnRegHelpFileWithWindows(HelpFileName);
      if CntFileName <> '' then
        UnRegHelpFileWithWindows(CntFileName);
    end;

    // Remove installation reference from CHI's config file
    CHICfgFile := TCHICfgFile.Create(CHICfgFilePath(DelphiVer));
    try
      CHICfgFile.InstalledFile(ExtractFileName(HelpFileName), False);
    finally
      CHICfgFile.Free;
    end;

    // Delete reference our help file from Link file
    CntFile := TOpenHelpCntFile.Create(
      DelphiHelpFileSpec(DelphiVer, cLinkFileExt)
    );
    try
      CntFile.LinkFile(ExtractFileName(HelpFileName), False);
    finally
      CntFile.Free;
    end;

    // Delete reference our help file from Index file
    CntFile := TOpenHelpCntFile.Create(
      DelphiHelpFileSpec(DelphiVer, cIndexFileExt)
    );
    try
      CntFile.IndexFile(ExtractFileName(HelpFileName), '', False);
    finally
      CntFile.Free;
    end;

    // Delete any old housekeeping files
    DeleteSupportFiles(DelphiVer);

    // Optionally delete the help file (and any contents file)
    if DeleteFile then
    begin
      SysUtils.DeleteFile(HelpFileName);
      if CntFileName <> '' then
        SysUtils.DeleteFile(CntFileName);
    end;

  except
    // There was an error
    on E: Exception do
    begin
      Result := False;
      SetErrorMessage(E);
    end;
  end;

end;

{ TCHIInfo }

function TCHIInfo.FullHelpFilePath(FileName: WideString): WideString;
  {Given the name of a help file installed by CHI, returns the full file path
  per the registry. If file is not installed in Windows, '' is returned}
begin
  Result := RegisteredHelpFilePath(FileName);
end;

function TCHIInfo.InstalledHelpFiles(const DelphiVer: Integer;
  out Files: WideString): WordBool;
  {Sets Files to names of all help files installed by CHI for given version of
  Delphi. File names are separated by CR LF in string. Returns True on success
  or False on error. If function fails then ErrorMessage provides a description
  of the error}
var
  CHICfgFile: TCHICfgFile;  // object used to access CHI's config file
  FileList: TStringList;    // list of installed help files
begin
  // Assume success
  Result := True;
  ClearErrorMessage;

  try
    // Open CHI config file for required Delphi version
    FileList := nil;
    CHICfgFile := TCHICfgFile.Create(CHICfgFilePath(DelphiVer));
    try
      // Get list of installed files
      FileList := TStringList.Create;
      CHICfgFile.ListInstalledFiles(FileList);
      // Return list as CR LF delimted string
      Files := FileList.Text;
    finally
      FileList.Free;
      CHICfgFile.Free;
    end;

  except
    // We have an error: record error message and fail
    on E: Exception do
    begin
      Result := False;
      SetErrorMessage(E);
      Files := '';
    end;
  end;
end;

function TCHIInfo.UserCanInstallHelp: WordBool;
  {Returns true if current user has privileges to install help files (which
  requires write access to HKLM in registry) and false if not}
begin
  Result := CanWriteHelpFileInfo;
end;

end.

