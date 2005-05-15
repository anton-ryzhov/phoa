//**********************************************************************************************************************
//  $Id: ufrWzPageAddFiles_SelFiles.pas,v 1.24 2005-05-15 09:03:08 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Copyright DK Software, http://www.dk-soft.org/
//**********************************************************************************************************************
unit ufrWzPageAddFiles_SelFiles;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, VirtualShellUtilities, GraphicEx, GR32,
  phIntf, phMutableIntf, phNativeIntf, phObj, phOps, ConsVars,
  phWizard, VirtualTrees, VirtualExplorerTree, StdCtrls,
  ExtCtrls, Mask, ToolEdit, DKLang, TB2Dock, TB2ToolWindow, TBX, GR32_Image,
  TBXDkPanels, RXSpin;

type
  TfrWzPageAddFiles_SelFiles = class(TWizardPage, IPhoaWizardPage_PreviewInfo)
    bAdvanced: TButton;
    cbFileMasks: TComboBox;
    cbFileSizeFromUnit: TComboBox;
    cbFileSizeToUnit: TComboBox;
    cbPresence: TComboBox;
    cbRecurseFolders: TCheckBox;
    cbShowPreview: TCheckBox;
    dklcMain: TDKLanguageController;
    eFileDateFrom: TDateEdit;
    eFileDateTo: TDateEdit;
    eFileSizeFrom: TRxSpinEdit;
    eFileSizeTo: TRxSpinEdit;
    eFileTimeFrom: TMaskEdit;
    eFileTimeTo: TMaskEdit;
    gbFilter: TGroupBox;
    lFileDateFrom: TLabel;
    lFileDateTo: TLabel;
    lFileMasks: TLabel;
    lFileSizeFrom: TLabel;
    lFileSizeTo: TLabel;
    lPresence: TLabel;
    pMain: TPanel;
    tvMain: TVirtualExplorerTree;
    procedure bAdvancedClick(Sender: TObject);
    procedure cbShowPreviewClick(Sender: TObject);
    procedure tvMainChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure tvMainEnumFolder(Sender: TCustomVirtualExplorerTree; Namespace: TNamespace; var AllowAsChild: Boolean);
  private
     // ����������� ������ � ������ ����������� �����
    procedure AdjustAdvancedCtls(bShowAdvanced: Boolean);
     // IPhoaWizardPage_PreviewInfo
    procedure PreviewVisibilityChanged(bVisible: Boolean);
    function  GetCurrentFileName: String;
  protected
    function  GetDataValid: Boolean; override;
    function  NextPage: Boolean; override;
    procedure BeforeDisplay(ChangeMethod: TPageChangeMethod); override;
    procedure DoCreate; override;
  end;

implementation
{$R *.dfm}
uses
  phUtils, ufAddFilesWizard, phSettings, udMsgBox, phGraphics;

  procedure TfrWzPageAddFiles_SelFiles.AdjustAdvancedCtls(bShowAdvanced: Boolean);
  begin
    gbFilter.Visible := bShowAdvanced;
    bAdvanced.Tag := iif(bShowAdvanced, 1, 0);
    bAdvanced.Caption := ConstVal(iif(bShowAdvanced, 'SBtn_ExpandOn', 'SBtn_ExpandOff'));
  end;

  procedure TfrWzPageAddFiles_SelFiles.bAdvancedClick(Sender: TObject);
  begin
    AdjustAdvancedCtls(bAdvanced.Tag=0);
  end;

  procedure TfrWzPageAddFiles_SelFiles.BeforeDisplay(ChangeMethod: TPageChangeMethod);
  var Wiz: TfAddFilesWizard;
  begin
    inherited BeforeDisplay(ChangeMethod);
    Wiz := TfAddFilesWizard(StorageForm);
    if ChangeMethod<>pcmBackBtn then begin
       // ����������� �������
       // -- ������� �����/�����
      if SettingValueBool(ISettingID_Dlgs_APW_ShowHidden) then
        tvMain.FileObjects := [foFolders, foNonFolders, foHidden]
      else
        tvMain.FileObjects := [foFolders, foNonFolders];
       // -- ������������
      tvMain.Active := True;
       // -- ���������� ���������
      tvMain.BrowseTo(Wiz.DefaultPath, False, True, False, True);
      cbRecurseFolders.Checked := Wiz.RecurseFolders;
       // ����������� ������
      cbPresence.ItemIndex := Byte(Wiz.Filter_Presence);
      RegLoadHistory(SRegAddFiles_MaskMRU, cbFileMasks, False);
      cbFileMasks.Text := Wiz.Filter_Masks;
      if Wiz.Filter_DateFrom>0  then eFileDateFrom.Date := Wiz.Filter_DateFrom;
      if Wiz.Filter_DateTo>0    then eFileDateTo.Date   := Wiz.Filter_DateTo;
      if Wiz.Filter_TimeFrom>=0 then eFileTimeFrom.Text := ChangeTimeSeparator(FormatDateTime('hh:nn', Wiz.Filter_TimeFrom, AppFormatSettings), True);
      if Wiz.Filter_TimeTo>=0   then eFileTimeTo.Text   := ChangeTimeSeparator(FormatDateTime('hh:nn', Wiz.Filter_TimeTo,   AppFormatSettings), True);
      eFileSizeFrom.AsInteger      := Wiz.Filter_SizeFrom;
      cbFileSizeFromUnit.ItemIndex := Byte(Wiz.Filter_SizeFromUnit);
      eFileSizeTo.AsInteger        := Wiz.Filter_SizeTo;
      cbFileSizeToUnit.ItemIndex   := Byte(Wiz.Filter_SizeToUnit);
       // ����������� ����������� �����
      AdjustAdvancedCtls(Wiz.ShowAdvancedOptions);
    end;
     // ����������� ����� ���������
    cbShowPreview.Checked := Wiz.ShowPreview;
  end;

  procedure TfrWzPageAddFiles_SelFiles.cbShowPreviewClick(Sender: TObject);
  begin
    TfAddFilesWizard(StorageForm).ShowPreview := cbShowPreview.Checked;
  end;

  procedure TfrWzPageAddFiles_SelFiles.DoCreate;
  var fsu: TFileSizeUnit;
  begin
    inherited DoCreate;
     // ��������� �����-����� ������ ������� �����
    for fsu := Low(fsu) to High(fsu) do cbFileSizeFromUnit.Items.Add(FileSizeUnitName(fsu));
    cbFileSizeToUnit.Items.Assign(cbFileSizeFromUnit.Items);
  end;

  function TfrWzPageAddFiles_SelFiles.GetCurrentFileName: String;
  var
    Namespace: TNamespace;
    Node: PVirtualNode;
  begin
    Result := '';
    Node := tvMain.FocusedNode;
    if (Node<>nil) and tvMain.ValidateNamespace(Node, Namespace) and Namespace.FileSystem and not Namespace.Folder then
      Result := Namespace.NameParseAddress
  end;

  function TfrWzPageAddFiles_SelFiles.GetDataValid: Boolean;
  var
    Namespace: TNamespace;
    Node: PVirtualNode;
  begin
    Result := False;
     // ���������, ��� ���� ��������� � �� ���������� �������� ��������� �������� �������
    Node := tvMain.GetFirstSelected;
    if Node<>nil then begin
      repeat
        if not tvMain.ValidateNamespace(Node, Namespace) or not Namespace.FileSystem then Exit;
        Node := tvMain.GetNextSelected(Node);
      until Node=nil;
      Result := True;
    end;
  end;

  function TfrWzPageAddFiles_SelFiles.NextPage: Boolean;
  var
    Wiz: TfAddFilesWizard;
    Namespace: TNamespace;
    Node: PVirtualNode;
  begin
    Result := True;
    Wiz := TfAddFilesWizard(StorageForm);
     // ��������� ��������
    Wiz.Filter_Presence     := TAddFilePresenceFilter(cbPresence.ItemIndex);
    Wiz.Filter_Masks        := cbFileMasks.Text;
    Wiz.Filter_DateFrom     := StrToDateDef(eFileDateFrom.Text, -1, AppFormatSettings);
    Wiz.Filter_DateTo       := StrToDateDef(eFileDateTo.Text,   -1, AppFormatSettings);
    Wiz.Filter_TimeFrom     := StrToTimeDef(ChangeTimeSeparator(eFileTimeFrom.Text, False), -1, AppFormatSettings);
    Wiz.Filter_TimeTo       := StrToTimeDef(ChangeTimeSeparator(eFileTimeTo.Text,   False), -1, AppFormatSettings);
    Wiz.Filter_SizeFrom     := eFileSizeFrom.AsInteger;
    Wiz.Filter_SizeFromUnit := TFileSizeUnit(cbFileSizeFromUnit.ItemIndex);
    Wiz.Filter_SizeTo       := eFileSizeTo.AsInteger;
    Wiz.Filter_SizeToUnit   := TFileSizeUnit(cbFileSizeToUnit.ItemIndex);
    Wiz.RecurseFolders      := cbRecurseFolders.Checked;
    Wiz.DefaultPath         := tvMain.SelectedPath;
    Wiz.ShowAdvancedOptions := bAdvanced.Tag<>0;
    Wiz.ShowPreview         := cbShowPreview.Checked;
     // ���������� � ������ ������ ��������� ������/�����
    Wiz.AddList.Clear;
    Node := tvMain.GetFirstSelected;
    while Assigned(Node) do begin
      if tvMain.ValidateNamespace(Node, Namespace) and Namespace.FileSystem then Wiz.AddList.Add(Namespace.NameParseAddress);
      Node := tvMain.GetNextSelected(Node);
    end;
     // ���������� ���������
    RegSaveHistory(SRegAddFiles_MaskMRU, cbFileMasks, True);
  end;

  procedure TfrWzPageAddFiles_SelFiles.PreviewVisibilityChanged(bVisible: Boolean);
  begin
    cbShowPreview.Checked := bVisible;
  end;

  procedure TfrWzPageAddFiles_SelFiles.tvMainChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
  begin
    StateChanged;
    TfAddFilesWizard(StorageForm).UpdatePreview;
  end;

  procedure TfrWzPageAddFiles_SelFiles.tvMainEnumFolder(Sender: TCustomVirtualExplorerTree; Namespace: TNamespace; var AllowAsChild: Boolean);
  begin
    if Namespace.Folder then
       // ��� Win2k+ ��������� .ZIP-����������� (����� Win2k �������� Browsable �� ������������)
      AllowAsChild := not CheckWin32Version(5, 0) or not Namespace.Browsable
    else
      AllowAsChild := FileFormatList.GraphicFromExtension(Namespace.FileName)<>nil;
  end;

end.

