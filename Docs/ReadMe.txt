================================================================================
DelphiDabbler Component Help Installer v3 - ReadMe

$Rev: 59 $
$Date: 2010-05-09 21:09:01 +0100 (Sun, 09 May 2010) $
================================================================================


About Component Help Installer
==============================

DelphiDabbler Component Help Installer (CHI) is an application that assists with
installing OpenHelp compatible files into the IDE of Delphi versions 3 to 7.

Component Help Installer comes in two flavours:

+  CHI.exe - the GUI version of the program.
+  CHInst.exe - a command version of the program.

Both versions require a DLL named CHInstLib.dll (supplied) to be accessible in
same folder as the executable program.

The programs are documented in the supplied help file. The help file can be
accessed from the "Help" button of the GUI program or by running

   CHInst -h

from the command line.

Because CHI works by writing information the HKLM hive in the registry it must
be run with administrator privileges. On Windows NT, 2000 and XP it will detect
if it has sufficient privileges and will halt with an error if not. On Windows
Vista and later CHI requests elevation to ensure it has the required privileges.

To use CHI with Windows Vista and later you need to ensure that WinHelp is
installed, because it is not installed by default. See the MSDN article at
<URL:http://support.microsoft.com/kb/917607>.


Installation
============

IMPORTANT NOTES:

1) CHI requires Windows NT4 SP6 or later. It cannot be installed on Windows 95,
   98 or Me.

2) You will need administrator privileges to run the setup program. If you are
   using a non-admin user account on Windows NT, 2000 or XP you should run setup
   as administrator. By default Windows Vista and later will require an admin
   password if running as a standard user and setup will attempt to elevate the
   process. If UAC prompts are disabled you must run setup as administrator.

CHI's installation program is named chi-setup-3.x.x.exe, where x.x is the
program's minor version number. The install program may be distributed in a zip
file. If this is the case then extract the install program before running it.

Close any running instance of CHI. If you are running version 1 or 2 you MUST
first uninstall the existing version. Now double-click the install program to
run it, accept any elevation request (Vista and later) and follow the on-screen
instructions.

If you intend to use the command line application it may be worth adding the
program installation folder to your system path so that Windows can find CHInst.

The installer makes the following changes to your system:

+  The program's executable files and documentation are installed into the
   chosen install folder (\Progam Files\DelphiDabbler\CHI by default).

+  Files required by the uninstaller are stored in the main installation's
   Uninstall sub-folder.

+  The program's uninstall information is registered with the Add / Remove
   Programs control panel applet.

+  A program group may be created in the start menu (optional).

The registry is not modified other than to record install information in the
usual way.


Uninstallation
==============

CHI can be uninstalled via "Add/Remove Programs" or "Programs and Features" from
the Windows Control Panel or by choosing the uninstall option from the program's
start menu group.

Administrator privileges will be required to uninstall. Windows Vista and later
with UAC prompts enabled will prompt for an admin password if necessary.

Uninstalling CHI will not remove any help files previously installed into the
Delphi IDE.


Known Installation and Upgrading Issues
=======================================

Users of v1 of CHI will loose the ability to uninstall any help files installed
with that version of the program.


License & Disclaimer
====================

The executable program's End User License Agreement is displayed by the install
program and must be accepted in order to proceed with installation. A copy of
the license is installed with the program - see License.rtf.

CHI is supplied on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
express or implied. See License.rtf for details.


Source Code
===========

The source code of the latest version of CHI can be downloaded from
<URL:http://www.delphidabbler.com/software/chi/download>. It is available either
as the complete source of CHI v3 or as a Subversion repository dump containing
all changes from v2.2.1 to v3.


Development Frozen
==================

Development of CHI has been frozen and future releases from DelphiDabbler are
unlikely. You are welcome to take over this project providing the open source
nature of the code is maintained under the terms of the applicable licenses.

If you do take over the project, please let DelphiDabbler know via
<URL:http://www.delphidabbler.com/contact>.


Bugs
====

Because development of CHI has been frozen by DelphiDabbler, it is not the
intention to release any updates to the program, so, while you are welcome to
report bugs, there is no guarantee they will be fixed. The source code is
available (see above) to enable you to fix it yourself.
