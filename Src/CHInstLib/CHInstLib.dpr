{
 * CHInstLib.dpr
 *
 * Project file for the CHInstLib installation engine DLL. Exports factory
 * routines that create objects provided by this DLL.
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
 * The Original Code is CHInstLib.dpr.
 * 
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 * 
 * Portions created by the Initial Developer are Copyright (C) 2001-2010er
 * Johnson. All Rights Reserved.
 * 
 * Contributor(s):
 *   NONE
 *
 * ***** END LICENSE BLOCK *****
}


library CHInstLib;

uses
  // Delphi
  UCHInstaller in 'UCHInstaller.pas',
  UOpenHelpCntFile in 'UOpenHelpCntFile.pas',
  IntfCHIInst in '..\Shared\Intf\IntfCHIInst.pas',
  UErrors in '..\Shared\Support\UErrors.pas',
  UFileUtils in '..\Shared\Support\UFileUtils.pas',
  UDelphiInfo in '..\Shared\Support\UDelphiInfo.pas',
  UDelphiVerInfo in '..\Shared\Support\UDelphiVerInfo.pas';

{$RESOURCE CHInstLibVerInfo.res}  // version information

exports
  CreateCHIInstall,
  CreateCHIInfo;

begin
end.

