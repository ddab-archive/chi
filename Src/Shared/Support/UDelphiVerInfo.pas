{
 * UDelphiVerInfo.pas
 *
 * Provides information about the versions of Delphi supported by the Component
 * Help Installer.
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
 * The Original Code is UDelphiVerInfo.pas.
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


unit UDelphiVerInfo;


interface


const
  // Constants giving information about supported Delphi versions
  LastReleasedDelphiVersion = 7;
    {Number of most recently released version of Delphi known about by CHI}
  FirstSupportedDelphiVersion = 3;
    {Earliest version of Delphi supported by CHI}
  LastSupportedDelphiVersion = LastReleasedDelphiVersion;
    {Latest version of Delphi supported by CHI}

type
  {
  TDelphiVersion:
     Range of Delphi version numbers
  }
  TDelphiVersion = 1..LastReleasedDelphiVersion;

  {
  TDelphiVersions:
    Set of Delphi version numbers
  }
  TDelphiVersions = set of TDelphiVersion;


implementation


end.

