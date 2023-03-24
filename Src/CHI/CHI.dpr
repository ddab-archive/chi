{
 * CHI.dpr
 *
 * Project file for CHI Windows GUI application.
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
 * The Original Code is CHI.dpr.
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


program CHI;

uses
  Forms,
  FmMain in 'FmMain.pas' {MainForm},
  IntfCHIInst in '..\Shared\Intf\IntfCHIInst.pas',
  UHelpInfo in 'UHelpInfo.pas',
  UDelphiInfo in '..\Shared\Support\UDelphiInfo.pas',
  UDelphiVerInfo in '..\Shared\Support\UDelphiVerInfo.pas',
  UFileUtils in '..\Shared\Support\UFileUtils.pas',
  UErrors in '..\Shared\Support\UErrors.pas',
  UCHIFileNames in '..\Shared\Support\UCHIFileNames.pas',
  UGenInfo in 'UGenInfo.pas',
  UCHIInfo in 'UCHIInfo.pas';

{$Resource CHIVerInfo.res}    // version information resource
{$Resource CHIIcon.res}       // resource containing the program's icon
{$Resource CHIResources.res}  // resource containing manifest file


begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

