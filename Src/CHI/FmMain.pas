{
 * FmMain.pas
 *
 * Form for main window of CHI GUI application.
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
 * The Original Code is FmBase.pas.
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


unit FmMain;


interface


uses
  // Delphi
  Windows, SysUtils, StdCtrls, ComCtrls, Controls, Classes, Buttons, Forms,
  Menus, Messages, Dialogs, ExtCtrls,
  // DelphiDabbler library classes and components
  PJMessageDialog, PJShellFolders, PJDropFiles, PJVersionInfo, PJAbout,
  // Project
  IntfCHIInst;


type

  {
  TMainForm:
    Main window for CHI GUI application.
  }
  TMainForm = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    dlgBrowse: TPJBrowseDialog;
    pgCtrl: TPageControl;
    tabInstall: TTabSheet;
    lblDestFolder: TLabel;
    lblSourceFile: TLabel;
    lblDesc: TLabel;
    btnBrowseDest: TButton;
    btnSourceFile: TButton;
    tabRemove: TTabSheet;
    lblDelFile: TLabel;
    edSourceFile: TEdit;
    edDestFolder: TEdit;
    edDesc: TEdit;
    chkDelFile: TCheckBox;
    chkUnRegFile: TCheckBox;
    cmbDelFile: TComboBox;
    dlgInfo: TPJMessageDialog;
    mnuHelp: TPopupMenu;
    miHelpContents: TMenuItem;
    miHelpHowItWorks: TMenuItem;
    btnHelp: TBitBtn;
    drpFileCatcher: TPJFormDropFiles;
    miHelpSpacer1: TMenuItem;
    miHelpWebsite: TMenuItem;
    miHelpAbout: TMenuItem;
    miHelpSpacer2: TMenuItem;
    dlgOpenFile: TOpenDialog;
    lblSelFile: TLabel;
    bvlRule: TBevel;
    lblDelphiVer: TLabel;
    cmbDelphiVer: TComboBox;
    verInfoApp: TPJVersionInfo;
    dlgAbout: TPJAboutBoxDlg;
    procedure btnBrowseDestClick(Sender: TObject);
    procedure dlgBrowseSelChange(Sender: TObject; FolderName,
      DisplayName: String; var StatusText: String; var OKEnabled: Boolean);
    procedure btnSourceFileClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure pgCtrlChange(Sender: TObject);
    procedure chkUnRegFileClick(Sender: TObject);
    procedure miHelpContentsClick(Sender: TObject);
    procedure miHelpHowItWorksClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure drpFileCatcherDropFiles(Sender: TObject);
    procedure miHelpWebsiteClick(Sender: TObject);
    procedure miHelpAboutClick(Sender: TObject);
    procedure cmbDelFileChange(Sender: TObject);
    procedure cmbDelphiVerChange(Sender: TObject);
  private // properties
    fIsFatalError: Boolean;
  private
    fCHInstDLL: THandle;
      {Handle of installation DLL}
    fCreateCHIInstall: function : ICHIInstall; stdcall;
      {Reference to function exported from installation DLL that creates
      installer object}
    fCreateCHIInfo: function : ICHIInfo; stdcall;
      {Reference to function exported from installation DLL that creates CHI
      info object}
    procedure LoadInstallDLL;
      {Loads the DLL that is used to do the actual installation / uninstallation
      of help files. Gets reference to DLLs entry point}
    procedure FreeInstallDLL;
      {Unload the DLL that does actual installation / unistallation of help
      files}
    function GetFileFromUser(var FileName: string): Boolean;
      {Displays standard Windows open dialog box with given file name as
      default. If user OKs FileName is set to the name of the file entered and
      True is returned. If user cancels then FileName is unchanged and False is
      returned}
    procedure DoInstallation;
      {Installs a help file according to information entered on Install tab}
    procedure DoRemoval;
      {Uninstalls a help file according to information entered on Remove tab}
    procedure InfoBox(Msg: string);
      {Display an information dialog box with given message text}
    function ConfirmBox(Msg: string): Boolean;
      {Display a confirmation dialog box and return true if user clicks yes and
      false if user clicks no}
    procedure FatalError(Msg: string);
      {Display error message in dialog and close the window}
    procedure GetInstalledHelpFiles(DelphiVer: Integer;
      const Files: TStrings);
      {Returns a list of files installed by CHI for given version of Delphi in
      Files}
    function CanInstallHelpFiles: Boolean;
      {Returns true if user has priviliges to permit installation of help files
      and returns false if not}
    procedure RefreshHelpFilePath;
      {Updates label on Remove tab to display information about the registered
      path of the help file currently selected in the combo box. If the file is
      not registered a message to that effect is displayed}
    procedure ExceptionHandler(Sender: TObject; E: Exception);
      {Handles all exceptions by displaying error in an error box}
  protected
    procedure ErrorBox(Msg: string; Caption: string = '');
      {Display an error dialog box with given message text and given caption, if
      provided}
    procedure RefreshDelFilesCombo;
      {Refreshes list of file displayed in file deletion combobox to be those
      installed by current version of Delphi}
    function GetDelphiVersion: Integer;
      {Returns the version of Delphi selected in the combo box}
    property IsFatalError: Boolean read fIsFatalError;
      {Flag true if a fatal error encountered when starting up}
  end;

var
  MainForm: TMainForm;


implementation


uses
  // Delphi
  CommDlg,
  // Project
  UHelpInfo, UDelphiInfo, UCHIFileNames, UFileUtils, UErrors, UGenInfo,
  UCHIInfo, UDelphiVerInfo;


{$R *.DFM}

resourcestring
  // Error messages
  sDestDriveErr = 'Destination folder must be on a local fixed disk.';
  sNoBrowserErr = 'Can''t activate a web browser.';
  sNoEMailErr = 'Can''t activate email program.';
  sNoDelphiErr = 'Sorry: Component Help Installer can''t find a supported '
    + 'version of Delphi and is closing down.';
  sCantGetFileListErr = 'Error encountered getting list of help files '
    + 'installed for Delphi %d by CHI: %s.';
  sNotAFolderErr = 'Can''t copy file to "%s" since it is not a valid folder.';
  sPrilivegeErr = 'You do not have sufficient user privileges to install help '
    + 'files.'#13#13
    + 'This is because registry keys under HKEY_LOCAL_MACHINE need to be '
    + 'modified as part of the installation process.'#13#13
    + 'You should run the program as administrator.';
  sCantLoadInstDLL = 'Can''t load required library %s. You may need to '
    + 'reinstall CHI.';
  sCantImportRoutine = 'Can''t import a required function from library "%s". '
    + 'You may need to reinstall CHI.';
  sFatalErrorTitle = 'CHI2 - Fatal Error';
  sDelphiNotSelectedErr = 'No Delphi version selected';
  sExceptDlgTitle = 'Component Help Installer';
  // Status messages in browse dialog
  sFixedDiskNeeded = 'A fixed disk must be selected.';
  sFileSysFolderNeeded = 'A file system folder must be selected.';
  // EMail items
  sCommentEmail = '%s?Subject=User comments about CHI %s&'
    + 'Body=CHI Generated Information:'#13#10
    + 'Running as %s'#13#10
    + 'Using Delphi %d'#13#10
    + 'OS is %s'#13#10#13#10
    + '**** Please begin your comments on the following line ****'#13#10;
  // Prompts
  sChooseHelpFile = 'Choose Help File';
  sConfirmRemove = 'Are you sure you want to remove "%s"?';
  // Tab headings
  sInstallTab = 'Install';
  sRemoveTab = 'Remove';
  // Success messages
  sInstalledOK = '"%s" installed.';
  sRemovedOK = '"%s" removed.';


{ Helper function }

procedure GetDelphiVersions(List: TStrings);
  {Returns versions installed versions of Delphi that support OpenHelp. Versions
  are separated by EOL characters}
var
  DelphiVersions: TDelphiVersions;  // set of valid installed Delphi versions
  Idx: Byte;                        // loops thru all possible Delphi versions
begin
  if Assigned(List) then
  begin
    List.Clear;
    // Get set of available versions
    DelphiVersions := AvailableDelphiVersions;
    // Copy available versions into string list
    for Idx := FirstSupportedDelphiVersion to LastSupportedDelphiVersion do
      if Idx in DelphiVersions then
        List.Add(IntToStr(Idx));
  end;
end;

{ TBaseForm }

procedure TMainForm.btnBrowseDestClick(Sender: TObject);
  {Display browse for folder dialog box and store any entered folder in "Copy
  to" edit box on Install tab}
begin
  dlgBrowse.FolderName := edDestFolder.Text;
  if dlgBrowse.Execute then
    edDestFolder.Text := dlgBrowse.FolderName;
end;

procedure TMainForm.btnCancelClick(Sender: TObject);
  {Cancel ("Close") button clicked: close application}
begin
  Close;
end;

procedure TMainForm.btnHelpClick(Sender: TObject);
  {Display help menu}
var
  Pt: TPoint; // position where menu is to pop-up when button clicked
begin
  Pt := ClientToScreen(Point(btnHelp.Left, btnHelp.Top + btnHelp.Height));
  mnuHelp.Popup(Pt.X, Pt.Y);
end;

procedure TMainForm.btnOKClick(Sender: TObject);
  {Either Install or Remove button clicked, depending on tab page: perform
  installation or removal as appropriate}
var
  SelIdx: Integer;  // the index of the selected item in the delete files combo
  SelFile: string;  // name of file that has been installed
begin
  if pgCtrl.ActivePage = tabInstall then
  begin
    // Perform the installation
    DoInstallation;
    // Select the newly added file in the delete file combo box
    SelFile := ExtractFileName(edSourceFile.Text);
    GetInstalledHelpFiles(GetDelphiVersion, cmbDelFile.Items);
    cmbDelFile.ItemIndex := cmbDelFile.Items.IndexOf(SelFile);
  end
  else {pgCtrl.ActivePage = tabRemove}
  begin
    // Record the index of the selected file in delete files combo
    SelIdx := cmbDelFile.ItemIndex;
    // Check we have selected file and user OK's
    if (SelIdx > -1)
      and ConfirmBox(
        Format(sConfirmRemove, [cmbDelFile.Items[cmbDelFile.ItemIndex]])
      ) then
    begin
      // Perform the removal
      DoRemoval;
      // Refresh list of registered files & update selected item in delete combo
      RefreshDelFilesCombo;
    end;
  end;
end;

procedure TMainForm.btnSourceFileClick(Sender: TObject);
  {Display standard file open dialog box and store any entered file name in
  "Help file" edit box on Install tab}
var
  FName: string;  // the file name
begin
  FName := edSourceFile.Text;
  if GetFileFromUser(FName) then
    edSourceFile.Text := FName;
end;

function TMainForm.CanInstallHelpFiles: Boolean;
  {Returns true if user has priviliges to permit installation of help files and
  returns false if not}
var
  Info: ICHIInfo;       // CHI information object tells if can install
begin
  Info := fCreateCHIInfo;
  Assert(Assigned(Info));
  Result := Info.UserCanInstallHelp;
end;

procedure TMainForm.chkUnRegFileClick(Sender: TObject);
  {State of un-register check box on Remove tab has changed: update state and
  value of delete file check box accordingly. File can be deleted only if
  un-register check box is checked}
begin
  chkDelFile.Enabled := chkUnRegFile.Checked;
  if not chkUnRegFile.Checked then
    chkDelFile.Checked := False;
end;

procedure TMainForm.cmbDelFileChange(Sender: TObject);
  {Updates display of help file path to reflect currently selected help file
  when selected file is changed in combo box}
begin
  RefreshHelpFilePath;
end;

procedure TMainForm.cmbDelphiVerChange(Sender: TObject);
  {When user selects a different Delphi version the list of files which can be
  deleted needs to be updated}
begin
  RefreshDelFilesCombo;
end;

function TMainForm.ConfirmBox(Msg: string): Boolean;
  {Display a confirmation dialog box and return true if user clicks yes and
  false if user clicks no}
begin
  // Use the message dialog component
  dlgInfo.IconKind := miQuery;
  dlgInfo.ButtonGroup := bgYesNo;
  dlgInfo.Text := Msg;
  // Return true if users clicks yes
  Result := dlgInfo.Execute = IDYES;
end;

procedure TMainForm.dlgBrowseSelChange(Sender: TObject; FolderName,
  DisplayName: String; var StatusText: String; var OKEnabled: Boolean);
  {Handler for Browse for Folder dialog box's selection change event: if a
  virtual folder is selected display message saying that real folder is required
  and disallow true folders that are not on a fixed drive}
var
  DriveInfo: UINT;  // type of drive selected
begin
  if FolderName <> '' then
  begin
    // A true, file system folder has been selected:
    // check if this is a fixed drive and disallow selection if not
    DriveInfo := ExtractDriveType(FolderName);
    if DriveInfo <> DRIVE_FIXED then
    begin
      OKEnabled := False;
      StatusText := sFixedDiskNeeded
    end
    else
      OKEnabled := True;
  end
  else
  begin
    // A virtual folder has been selected: display message in dlg box
    StatusText := sFileSysFolderNeeded;
    OKEnabled := False;
  end;
end;

procedure TMainForm.DoInstallation;
  {Installs a help file according to information entered on Install tab}
var
  Installer: ICHIInstall; // installer object
  SourceFile: string;     // source help file
  DestFile: string;       // optional destination for help file
  Description: string;    // description of help file
begin
  // Create an installer object (from dll)
  Installer := fCreateCHIInstall;
  // Store information about file to be installed
  // source file
  SourceFile := edSourceFile.Text;
  // destination file, if any
  if edDestFolder.Text <> '' then
  begin
    // a destination folder is provided, check its validity
    if ExtractDriveType(edDestFolder.Text) <> DRIVE_FIXED then
      // destination must be on a fixed drive
      Error(sDestDriveErr);
    if not IsDirectory(edDestFolder.Text) then
      // destination must be a folder, not file
      Error(sNotAFolderErr, [edDestFolder.Text]);
    // add file name of source help file from source to destination path
    DestFile := MakeFilePath(edDestFolder.Text)
      + ExtractFileName(SourceFile);
  end;
  // description
  Description := edDesc.Text;
  // Do installation and report result
  if not Installer.Install(GetDelphiVersion, SourceFile, DestFile,
    Description) then
    Error(Installer.ErrorMessage);
  InfoBox(Format(sInstalledOK, [ExtractFileName(SourceFile)]));
end;

procedure TMainForm.DoRemoval;
  {Uninstalls a help file according to information entered on Remove tab}
var
  Installer: ICHIInstall; // installer object
  Info: ICHIInfo;         // CHI information object
  HelpFile: string;       // name of help file
  DeleteFile: Boolean;    // flag true if help file to be deleted
  UnRegister: Boolean;    // flag true if help file to be unregistered
begin
  // Create an installer and info objects (from dll)
  Installer := fCreateCHIInstall;
  Info := fCreateCHIInfo;
  // Record information from Remove tab
  HelpFile := Info.FullHelpFilePath(cmbDelFile.Text); // get full file path
  if HelpFile = '' then
    HelpFile := cmbDelFile.Text;
  DeleteFile := chkDelFile.Checked;
  UnRegister := chkUnRegFile.Checked;
  // Perform tbe uninstallation and report result
  if not Installer.UnInstall(GetDelphiVersion, HelpFile, DeleteFile,
    UnRegister) then
    Error(Installer.ErrorMessage);
  InfoBox(Format(sRemovedOK, [ExtractFileName(HelpFile)]));
end;

procedure TMainForm.drpFileCatcherDropFiles(Sender: TObject);
  {When a file is dropped, copy its name into Source file edit box on install
  page. This should not happen if install page not visible}
begin
  edSourceFile.Text := drpFileCatcher.FileName;
end;

procedure TMainForm.ErrorBox(Msg: string; Caption: string);
  {Display an error dialog box with given message text and given caption, if
  provided}
var
  Dlg: TForm; // error dialog
begin
  // Create error dialog, updating caption if required
  Dlg := Dialogs.CreateMessageDialog(Msg, mtError, [mbOK]);
  try
    if Caption <> '' then
      Dlg.Caption := Caption;
    Dlg.ShowModal;
  finally
    Dlg.Free;
  end;
end;

procedure TMainForm.ExceptionHandler(Sender: TObject; E: Exception);
  {Handles all exceptions by displaying error in an error box}
begin
  dlgInfo.Title := sExceptDlgTitle;
  ErrorBox(E.Message);
end;

procedure TMainForm.FatalError(Msg: string);
  {Display error message in dialog and then close the window}
begin
  // Fatal errors do not close the window immediately, therefore this method can
  // be called more than once: we only report the first message.
  if not IsFatalError then
  begin
    fIsFatalError := True;
    ErrorBox(Msg, sFatalErrorTitle);
    PostMessage(Self.Handle, WM_CLOSE, 0, 0);
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
  {Initialise components and set required default values}
const
  cNoHelp = 9999; // unused help context used to force system "No help" popup
begin

  // Check there's a suitable version of Delphi installed
  if AvailableDelphiVersions = [] then
    FatalError(sNoDelphiErr);

  // Dynamically load the installation DLL
  LoadInstallDLL;

  // Load icon from resources
  Icon.Handle := LoadIcon(HInstance, AppIconResName);
  Application.Icon.Handle := LoadIcon(HInstance, AppIconResName);

  // Set help file and contexts
  // record help file
  try
    HelpFile := CHIHelpFilePath;
  except on E: Exception do
    FatalError(E.Message);
  end;
  // for controls with no help context: produces systems default "No help" item
  HelpContext := cNoHelp;
  // for dialog components
  dlgBrowse.HelpContext := IDH_DLG_CHOOSEDESTFOLDER;
  dlgOpenFile.HelpContext := IDH_DLG_CHOOSEHELP;
  // for pop-up (what's this) help
  // .. controls that are common to all pages
  btnCancel.HelpContext := IDH_POPUP_CLOSEBTN;
  btnHelp.HelpContext := IDH_POPUP_HELPBTN;
  pgCtrl.HelpContext := IDH_POPUP_TABS;
  // .. install page components
  edSourceFile.HelpContext := IDH_POPUP_HELPFILEEDIT;
  btnSourceFile.HelpContext := IDH_POPUP_HELPFILEEDIT;
  edDestFolder.HelpContext := IDH_POPUP_HELPFILEDESTEDIT;
  btnBrowseDest.HelpContext := IDH_POPUP_HELPFILEDESTEDIT;
  edDesc.HelpContext := IDH_POPUP_DESCEDIT;
  // .. remove page components
  cmbDelFile.HelpContext := IDH_POPUP_HELPFILECOMBO;
  chkUnRegFile.HelpContext := IDH_POPUP_UNREGCHK;
  chkDelFile.HelpContext := IDH_POPUP_DELETEFILECHK;

  // Set required page in tab control and update controls accordingly
  pgCtrl.ActivePage := tabInstall;
  pgCtrlChange(Self);

  // Test if this user can install help files
  if not IsFatalError and not CanInstallHelpFiles then
    FatalError(sPrilivegeErr);

  // Set up application's exception handler
  Application.OnException := ExceptionHandler;
  // Set help context for Delphi version drop-down
  cmbDelphiVer.HelpContext := IDH_POPUP_VERSIONCOMBO;
  // Fill combo box with current versions of Delphi & select most recent
  GetDelphiVersions(cmbDelphiVer.Items);
  if cmbDelphiVer.Items.Count > 0 then
    cmbDelphiVer.ItemIndex := cmbDelphiVer.Items.Count - 1;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
  {Free installation DLL and close Windows help}
begin
  FreeInstallDLL;
  Application.HelpCommand(HELP_QUIT, 0);
end;

procedure TMainForm.FormShow(Sender: TObject);
  {Tests Delphi version against supported versions and throws error, closing
  application, if the Delphi version is not supported}
begin
  if not IsFatalError then
  begin
    // Set default values for controls
    // update check boxes
    chkUnRegFileClick(Self);
    // fill file delete combo with help files installed by CHI and select first
    RefreshDelFilesCombo;
  end;
end;

procedure TMainForm.FreeInstallDLL;
  {Unload the DLL that does actual installation / unistallation of help files}
begin
  if fCHInstDLL <> 0 then
  begin
    FreeLibrary(fCHInstDLL);
    fCHInstDLL := 0;
  end;
end;

function TMainForm.GetDelphiVersion: Integer;
  {Returns the version of Delphi selected in the combo box}
begin
  // Check something is selected
  if cmbDelphiVer.ItemIndex = -1 then
    Error(sDelphiNotSelectedErr);
  // Convert selected version number to integer
  Result := StrToInt(cmbDelphiVer.Text);
end;

function TMainForm.GetFileFromUser(var FileName: string): Boolean;
  {Displays standard Windows open dialog box with given file name as default.
  If user OKs FileName is set to the name of the file entered and True is
  returned. If user cancels then FileName is unchanged and False is returned}
begin
  dlgOpenFile.FileName := FileName;
  Result := dlgOpenFile.Execute;
  if Result then
    FileName := dlgOpenFile.FileName;
end;

procedure TMainForm.GetInstalledHelpFiles(DelphiVer: Integer;
  const Files: TStrings);
  {Returns a list of files installed by CHI for given version of Delphi in
  Files}
var
  Info: ICHIInfo;       // CHI information object that returns list of files
  FileStr: WideString;  // string containing list of file delimited by CR LF
begin
  if Assigned(Files) then
  begin
    // Clear list: in case of problem fetching file list this is what we want
    Files.Clear;
    // Use an information object to get list of installed files
    Info := fCreateCHIInfo;
    if not Info.InstalledHelpFiles(DelphiVer, FileStr) then
      Error(sCantGetFileListErr, [DelphiVer, Info.ErrorMessage]);
    // Store CR LF delimited list of files in string list
    Files.Text := FileStr;
  end;
end;

procedure TMainForm.InfoBox(Msg: string);
  {Display an information dialog box with given message text}
begin
  // Use the message dialog component
  dlgInfo.IconKind := miInformation;
  dlgInfo.ButtonGroup := bgOK;
  dlgInfo.Text := Msg;
  dlgInfo.Execute;
end;

procedure TMainForm.LoadInstallDLL;
  {Loads the DLL that is used to do the actual installation / uninstallation of
  help files. Gets reference to DLLs entry point}
begin
  // Load the PJCHI dll
  try
    fCHInstDLL := LoadLibrary(PChar(CHInstLibFilePath));
  except
    on E: Exception do
    begin
      // exception raised trying to load DLL: bail out
      FatalError(E.Message);
      fCHInstDLL := 0;
      Exit;
    end;
  end;
  if fCHInstDLL <> 0 then
  begin
    // DLL loaded OK
    // get reference to required functions
    fCreateCHIInstall := GetProcAddress(fCHInstDLL, 'CreateCHIInstall');
    fCreateCHIInfo := GetProcAddress(fCHInstDLL, 'CreateCHIInfo');
    // report error if can't get them
    if (@fCreateCHIInstall = nil) or (@fCreateCHIInfo = nil) then
      FatalError(Format(sCantImportRoutine, [CHInstLibFilePath]));
  end
  else
    // DLL load failed: report error
    FatalError(Format(sCantLoadInstDLL, [CHInstLibFilePath]));
end;

procedure TMainForm.miHelpAboutClick(Sender: TObject);
  {Display about box}
begin
  dlgAbout.Execute;
end;

procedure TMainForm.miHelpContentsClick(Sender: TObject);
  {Display help overview}
begin
  Application.HelpCommand(HELP_FINDER, 0);
end;

procedure TMainForm.miHelpHowItWorksClick(Sender: TObject);
  {Display "How it works" help topic}
begin
  Application.HelpContext(IDH_HOWITWORKS);
end;

procedure TMainForm.miHelpWebsiteClick(Sender: TObject);
  {Go to DelphiDabbler website}
begin
  if not ExecuteFile(Self.Handle, AuthorWebURL) then
    Error(sNoBrowserErr);
end;

procedure TMainForm.pgCtrlChange(Sender: TObject);
  {Tab page has changed: update controls accordingly}
begin
  if pgCtrl.ActivePage = tabInstall then
  begin
    btnOK.Caption := sInstallTab;
    btnOK.HelpContext := IDH_POPUP_INSTALLBTN;
    drpFileCatcher.Enabled := True;
  end
  else
  begin
    btnOK.Caption := sRemoveTab;
    btnOK.HelpContext := IDH_POPUP_REMOVEBTN;
    drpFileCatcher.Enabled := False;
  end;
end;

procedure TMainForm.RefreshDelFilesCombo;
  {Refreshes list of file displayed in file deletion combobox to be those
  installed by current version of Delphi}
begin
  GetInstalledHelpFiles(GetDelphiVersion, cmbDelFile.Items);
  if cmbDelFile.Items.Count > 0 then
    cmbDelFile.ItemIndex := 0
  else
    cmbDelFile.ItemIndex :=-1;
  RefreshHelpFilePath;
end;

procedure TMainForm.RefreshHelpFilePath;
  {Updates label on Remove tab to display information about the registered path
  of the help file currently selected in the combo box. If the file is not
  registered a message to that effect is displayed}

  // ---------------------------------------------------------------------------
  procedure DisplayPathInLabel(const Path: string);
    {Displays given path in lblSelFile label, with path truncated using
    embedded (path) ellipsis if path is too long to display in label:
    Code based on Delphi Pool tip (http://www.lmc-mediaagentur.de/dpool) by Kurt
    Barthelmess}
  var
    LblCliR: TRect;   // client rectangle of label
    ModPath: string;  // modified path to be displayed
  begin
    // Get copy of Path because we're going to change it
    ModPath := Path;
    // Get the label's client rectangle
    LblCliR := lblSelFile.ClientRect;
    // Make sure label's canvas has correct font
    lblSelFile.Canvas.Font := lblSelFile.Font;
    // Get windows to modify string as required:
    // adds path ellipsis if overflowed and doesn't process & as prefix char
    DrawText(
      lblSelFile.Canvas.Handle,
      PChar(ModPath),
      Length(ModPath),
      LblCliR,
      DT_PATH_ELLIPSIS or DT_MODIFYSTRING or DT_NOPREFIX
    );
    // Now display the processed text
    lblSelFile.Caption := ModPath;
  end;
  // ---------------------------------------------------------------------------

var
  Info: ICHIInfo;         // CHI information object
  HelpFileDir: string;    // path to help file
begin
  if cmbDelFile.ItemIndex > -1 then
  begin
    // Create an info objects (from dll) and get full path to help file from it
    Info := fCreateCHIInfo;
    HelpFileDir := ExtractFileDir(Info.FullHelpFilePath(cmbDelFile.Text));
    if HelpFileDir <> '' then
      DisplayPathInLabel(HelpFileDir)
    else
      lblSelFile.Caption := 'Not registered with Windows help';
  end
  else
    lblSelFile.Caption := '';
end;

end.

