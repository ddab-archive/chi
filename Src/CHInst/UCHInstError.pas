{
 * UCHInstError.pas
 *
 * Implements a "light-weight" exception class and routine to raise it for use
 * in CHInst.exe command line program. This class is used to avoid the overhead
 * of the SysUtils unit that would be required to use the Exception class.
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
 * The Original Code is UCHInstError.pas.
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


unit UCHInstError;


interface


type

  {
  TCHInstErrorCode:
    Error codes supported by TCHInstError class.
  }
  TCHInstErrorCode = (ecOK, ecInstallFailed, ecUnInstallFailed,
    ecSourceExpected, ecDestExpected, ecDescExpected, ecBadDelphiVer,
    ecNoParams, ecBadSwitch, ecBadPrivileges);

  {
  TCHInstError:
    Lightweight exception class: avoids overhead of SysUtils and supports an
    error code in addition to error message. This class is not linked into
    Delphi's internal exception handling, it is just raised by code in this
    program.
  }
  TCHInstError = class(TObject)
  private // properties
    fErrCode: TCHInstErrorCode;
    function GetMsg: string;
  public
    constructor Create(ErrCode: TCHInstErrorCode);
      {Class constructor: records error code}
    property Msg: string read GetMsg;
      {Returns error message relating to error code}
    property ErrCode: TCHInstErrorCode read fErrCode;
      {Returns exception's error code}
  end;


procedure RaiseCHInstError(const Code: TCHInstErrorCode);
  {Raises TCHInstError exception with given code}


implementation


const
  {Error messages for codes supported by TError}
  cErrMessages: array[TCHInstErrorCode] of string =
  (
    'OK',
    'Installation failed',
    'Uninstallation failed',
    'Source help file expected',
    'Destination help file expected',
    'Description expected',
    'Unsupported Delphi version or badly formed V switch',
    'No parameters provided',
    'Invalid or unrecognised switch',
    'User does not have required privileges to install/uninstall help files'
  );

procedure RaiseCHInstError(const Code: TCHInstErrorCode);
  {Raises TCHInstError exception with given code}
begin
  raise TCHInstError.Create(Code);
end;


{ TCHInstError }

constructor TCHInstError.Create(ErrCode: TCHInstErrorCode);
  {Class constructor: records error code}
begin
  inherited Create;
  fErrCode := ErrCode;
end;

function TCHInstError.GetMsg: string;
  {Read access method for Msg property}
begin
   Result := cErrMessages[fErrCode]
end;

end.

