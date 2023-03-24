{
 * UErrors.pas
 *
 * Unit providing procedures used to raise exceptions.
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
 * The Original Code is UErrors.pas.
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


unit UErrors;

interface

procedure Error(const Msg: string); overload;
  {Raises an exception with the given message}

procedure Error(const Msg: string; const Args: array of const); overload;
  {Raises an exception with the message given by combining Msg with the
  arguments Args}

implementation

uses
  // Delphi
  SysUtils;

procedure Error(const Msg: string);
  {Raises an exception with the given message}
begin
  raise Exception.Create(Msg);
end;

procedure Error(const Msg: string; const Args: array of const);
  {Raises an exception with the message given by combining Msg with the
  arguments Args}
begin
  Error(Format(Msg, Args));
end;

end.

