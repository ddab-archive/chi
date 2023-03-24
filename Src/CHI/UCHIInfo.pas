{
 * UCHIInfo.pas
 *
 * Provides information about CHI's help file and install path.
 * applications.
 *
 * $Rev: 56 $
 * $Date: 2010-04-10 03:36:27 +0100 (Sat, 10 Apr 2010) $
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
 * The Original Code is UCHIInfo.pas.
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


unit UCHIInfo;


interface


function CHIHelpFilePath: string;
  {Full file path to CHI's help file}

function CHInstLibFilePath: string;
  {Full file path to the CHInst DLL}


implementation


uses
  // Delphi
  SysUtils, Windows, Registry,
  // Project
  UCHIFileNames, UErrors, UFileUtils;


function AppPath: string;
  {Path to executable program}
begin
  Result := ExtractFilePath(ParamStr(0));
end;

function CHIHelpFilePath: string;
  {Full file path to CHI's help file}
begin
  Result := AppPath + CHIHelpFileName;
end;

function CHInstLibFilePath: string;
  {Full file path to the CHInst DLL}
begin
  Result := AppPath + CHInstLibName;
end;

end.

