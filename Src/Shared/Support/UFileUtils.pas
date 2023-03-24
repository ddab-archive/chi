{
 * UFileUtils.pas
 *
 * File management routines.
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
 * The Original Code is UFileUtils.pas.
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


unit UFileUtils;

interface

uses
  // Delphi
  Windows;

procedure CopyFile(const Source, Dest: string);
  {Copies Source file to Dest, preserving modification date}

function ExtractDriveType(const Path: string): UINT;
  {Returns type of drive that contains the given (full) path}

function IsDirectory(const DirPath: string): Boolean;
  {Return true if given path is a directory, false if it doesn't exist or is
  a file}

function MakeFilePath(const Dir: string): string;
  {Return given directory with a trailing '\'}

function ExecuteFile(OwnerWdw: THandle; const FileName: string): Boolean;
  {Executes given file and returns true if successful and false on error.
  OwnerWdw is used to display any error messages}


implementation

uses
  // Delphi
  Classes, SysUtils, ShellAPI;

procedure CopyFile(const Source, Dest: string);
  {Copies Source file to Dest, preserving modification date}
var
  SourceStream, DestStream: TFileStream;  // source and dest file streams
begin
  DestStream := nil;
  // Open source and dest file streams
  SourceStream := TFileStream.Create(Source, fmOpenRead or fmShareDenyWrite);
  try
    DestStream := TFileStream.Create(Dest, fmCreate or fmShareExclusive);
    // Copy file from source to dest
    DestStream.CopyFrom(SourceStream, SourceStream.Size);
    // Set dest file's modification date to same as source file
    FileSetDate(DestStream.Handle, FileGetDate(SourceStream.Handle));
  finally
    // Close files
    DestStream.Free;
    SourceStream.Free;
  end;
end;

function ExecuteFile(OwnerWdw: THandle; const FileName: string): Boolean;
  {Executes given file and returns true if successful and false on error.
  OwnerWdw is used to display any error messages}
begin
  Result := ShellExecute(OwnerWdw, nil, PChar(Filename),
    nil, nil, SW_SHOW) > 32;
end;

function ExtractDriveType(const Path: string): UINT;
  {Returns type of drive that contains the given (full) path}
var
  Drive: string;  // The drive name
begin
  Drive := SysUtils.ExtractFileDrive(Path) + '\';
  Result := Windows.GetDriveType(PChar(Drive));
end;

function IsDirectory(const DirPath: string): Boolean;
  {Return true if given path is a directory, false if it doesn't exist or is
  a file}
var
  Attr: Integer;  // attributes of the given path
begin
  Attr := FileGetAttr(DirPath);
  Result := (Attr <> -1) and (Attr and faDirectory = faDirectory);
end;

function MakeFilePath(const Dir: string): string;
  {Return given directory with a trailing '\'}
begin
  if (Dir <> '') and (Dir[Length(Dir)] <> '\') then
    Result := Dir + '\'
  else
    Result := Dir;
end;

end.

