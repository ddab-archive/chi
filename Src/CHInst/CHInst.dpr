{
 * CHInst.dpr
 *
 * Project file for the CHInst command line.
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
 * The Original Code is CHInst.dpr.
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


program CHInst;


{$APPTYPE CONSOLE}


uses
  // Project
  UController in 'UController.pas',
  UReporter in 'UReporter.pas',
  UParamParser in 'UParamParser.pas',
  UCHInstError in 'UCHInstError.pas',
  IntfCHIInst in '..\Shared\Intf\IntfCHIInst.pas',
  UCHIFileNames in '..\Shared\Support\UCHIFileNames.pas';


{$Resource CHInstVerInfo.res}     // version info resource
{$Resource CHInstResources.res}   // resource containing manifest file


var
  ErrorCode: Integer = 0;   // error code returned from program
  Controller: TController;  // object that does all the program's work


begin
  // Get the controller to read command line and perform installation
  Controller := TController.Create;
  ErrorCode := Controller.Execute;
  Controller.Free;
  // Program returns error code returned by controller
  Halt(ErrorCode);
end.

