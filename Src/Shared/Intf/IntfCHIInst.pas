{
 * IntfCHInst.pas
 *
 * Declares interfaces to objects provided by CHI's installation engine DLL.
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
 * The Original Code is IntfCHIInst.pas.
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


unit IntfCHIInst;


interface


type

  {
  ICHIInstall:
    Interface to object that installs and uninstalls help files into Delphi's
    OpenHelp system.
  }
  ICHIInstall = interface
    ['{370596BB-0D30-4A27-B581-72914DE94754}']
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
    function ErrorMessage: WideString; stdcall;
      {Returns last error message or '' if last method returned successfully}
  end;


  {
  ICHIInfo:
    Interface to object that provides information about help files installed by
    CHI2.
  }
  ICHIInfo = interface
    ['{B451A346-745F-4C83-933B-AD4F4941054D}']
    function InstalledHelpFiles(const DelphiVer: Integer;
      out Files: WideString): WordBool; stdcall;
      {Sets Files to names of all help files installed by CHI for given version
      of Delphi. File names are separated by CR LF in string. Returns True on
      success or False on error. If function fails then ErrorMessage provides a
      description of the error}
    function FullHelpFilePath(FileName: WideString): WideString; stdcall;
      {Given the name of a help file installed by CHI, returns the full file
      path per the registry. If file is not installed in Windows, '' is
      returned}
    function UserCanInstallHelp: WordBool; stdcall;
      {Returns true if current user has privileges to install help files (which
      requires write access to HKEY_LOCAL_MACHINE in registry) and false if not}
    function ErrorMessage: WideString; stdcall;
      {Returns last error message or '' if last method returned successfully}
  end;


implementation


end.

