�
 TMAINFORM 00  TPF0	TMainFormMainFormLeft� TopkBorderIconsbiSystemMenubiHelp BorderStylebsSingleCaptionComponent Help InstallerClientHeight� ClientWidth�Color	clBtnFaceFont.CharsetDEFAULT_CHARSET
Font.ColorclWindowTextFont.Height�	Font.NameMS Sans Serif
Font.Style OldCreateOrder	OnCreate
FormCreate	OnDestroyFormDestroyOnShowFormShowPixelsPerInch`
TextHeight TBevelbvlRuleLeft Top� Width�Height(AlignalTopShapebsBottomLine  TLabellblDelphiVerLeftTop� Width!HeightCaptionDel&phi:  TButtonbtnOKLeft� Top� WidthKHeightCaptionInstallDefault	TabOrderOnClick
btnOKClick  TButton	btnCancelLeftTop� WidthKHeightCancel	CaptionCloseTabOrderOnClickbtnCancelClick  TPageControlpgCtrlLeft Top Width�Height� 
ActivePage	tabRemoveAlignalTopTabOrder OnChangepgCtrlChange 	TTabSheet
tabInstallCaption&Install TLabellblDestFolderLeftTop6Width'HeightCaption	&Copy to:FocusControledDestFolder  TLabellblSourceFileLeftTopWidth)HeightCaptionH&elp file:FocusControledSourceFile  TLabellblDescLeftTop^Width8HeightCaption&Description:FocusControledDesc  TButtonbtnBrowseDestLeft`Top0WidthKHeightCaption
Bro&wse...TabOrderOnClickbtnBrowseDestClick  TButtonbtnSourceFileLeft`TopWidthKHeightCaption
&Browse...TabOrderOnClickbtnSourceFileClick  TEditedSourceFileLeftDTop
WidthHeightTabOrder   TEditedDestFolderLeftDTop2WidthHeightTabOrder  TEditedDescLeftDTopZWidthHeightTabOrder   	TTabSheet	tabRemoveCaption&Remove TLabel
lblDelFileLeftTopWidth)HeightCaptionH&elp file:FocusControl
cmbDelFile  TLabel
lblSelFileLeftDTop$WidthHeightAutoSizeCaption
lblSelFile  	TCheckBox
chkDelFileLeftrTopTWidth� HeightCaptionDelete the help &fileTabOrder  	TCheckBoxchkUnRegFileLeft`Top<Width� HeightCaption$Re&move file reference from registryTabOrderOnClickchkUnRegFileClick  	TComboBox
cmbDelFileLeftDTop
WidthHeightStylecsDropDownList
ItemHeightSorted	TabOrder OnChangecmbDelFileChange    TBitBtnbtnHelpLefthTop� WidthKHeightCaption&HelpTabOrderOnClickbtnHelpClick
Glyph.Data
�   �   BM�       v   (   
   
         P                       �  �   �� �   � � ��  ��� ���   �  �   �� �   � � ��  ��� �����   �����   ����   �� ��   �  �   �   �   �����   �����   �����   �����   LayoutblGlyphRight  	TComboBoxcmbDelphiVerLeftHTop� WidthAHeightStylecsDropDownList
ItemHeightTabOrderOnChangecmbDelphiVerChange  TPJBrowseDialog	dlgBrowseTitleChoose Destination FolderRootFolderIDHeadline%Choose a folder on a local fixed diskOptions
boShowHelpboContextHelpboStatusText OnSelChangedlgBrowseSelChangeLeft� Top  TPJMessageDialogdlgInfoIconResourceMAINICONIconKindmiInformationLeft� Top  
TPopupMenumnuHelpLeft� Top 	TMenuItemmiHelpContentsCaption	&ContentsOnClickmiHelpContentsClick  	TMenuItemmiHelpHowItWorksCaption&How CHI WorksOnClickmiHelpHowItWorksClick  	TMenuItemmiHelpSpacer1Caption-  	TMenuItemmiHelpWebsiteCaptionVisit DelphiDabbler &WebsiteOnClickmiHelpWebsiteClick  	TMenuItemmiHelpSpacer2Caption-  	TMenuItemmiHelpAboutCaption	&About...OnClickmiHelpAboutClick   TPJFormDropFilesdrpFileCatcherForegroundOnDrop	OptionsdfoIncFoldersdfoIncFiles OnDropFilesdrpFileCatcherDropFilesLeftgTop  TOpenDialogdlgOpenFileFilter,Help files (*.hlp)|*.hlp|All files (*.*)|*.*OptionsofHideReadOnly
ofShowHelpofPathMustExistofFileMustExistofEnableSizing LeftTop  TPJVersionInfo
verInfoAppLeft� Top  TPJAboutBoxDlgdlgAboutTitle	About CHIVersionInfo
verInfoAppPositionabpOwnerUseOwnerAsParent	Left+Top   