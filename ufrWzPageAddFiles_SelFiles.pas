//**********************************************************************************************************************
//  $Id: ufrWzPageAddFiles_SelFiles.pas,v 1.7 2004-08-29 19:15:28 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Copyright 2002-2004 Dmitry Kann, http://phoa.narod.ru
//**********************************************************************************************************************
unit ufrWzPageAddFiles_SelFiles;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, VirtualShellUtilities, GraphicEx,
  phWizard, DTLangTools, VirtualTrees, VirtualExplorerTree, StdCtrls,
  ExtCtrls, Mask, ToolEdit;

type
  TfrWzPageAddFiles_SelFiles = class(TWizardPage)
    gbFilter: TGroupBox;
    lFileDateFrom: TLabel;
    lFileMasks: TLabel;
    lPresence: TLabel;
    lFileDateTo: TLabel;
    cbFileMasks: TComboBox;
    eFileDateFrom: TDateEdit;
    cbPresence: TComboBox;
    eFileDateTo: TDateEdit;
    eFileTimeFrom: TMaskEdit;
    eFileTimeTo: TMaskEdit;
    pMain: TPanel;
    cbRecurseFolders: TCheckBox;
    bAdvanced: TButton;
    tvMain: TVirtualExplorerTree;
    dtlsMain: TDTLanguageSwitcher;
    dklcMain: TDKLanguageController;
    procedure tvMainEnumFolder(Sender: TCustomVirtualExplorerTree; Namespace: TNamespace; var AllowAsChild: Boolean);
    procedure bAdvancedClick(Sender: TObject);
    procedure tvMainChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
  private
     // ����������� ������ � ������ ����������� �����
    procedure AdjustAdvancedCtls(bShowAdvanced: Boolean);
  protected
    function  GetDataValid: Boolean; override;
    procedure BeforeDisplay(ChangeMethod: TPageChangeMethod); override;
    function  NextPage: Boolean; override;
  end;

implementation
{$R *.dfm}
uses phUtils, phObj, ufAddFilesWizard, ConsVars, phSettings, udMsgBox;

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
    if ChangeMethod<>pcmBackBtn then begin
      Wiz := TfAddFilesWizard(StorageForm);
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
      if Wiz.Filter_TimeFrom>=0 then eFileTimeFrom.Text := FormatDateTime('hh:nn', Wiz.Filter_TimeFrom);
      if Wiz.Filter_TimeTo>=0   then eFileTimeTo.Text   := FormatDateTime('hh:nn', Wiz.Filter_TimeTo);
       // ����������� ����������� �����
      AdjustAdvancedCtls(Wiz.ShowAdvancedOptions);
    end;
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
    Namespace: TNamespace;
    Node: PVirtualNode;
    Files: TFileList;
    PhoA: TPhotoAlbum;
    Masks: TPhoaMasks;
    Wiz: TfAddFilesWizard;

     // ��������� ���� � ������ �� ��� SearchRec, �������� ��� ������������ �������
    procedure AddFile(const sPath: String; SRec: TSearchRec); overload;
    var
      d: TDateTime;
      bMatches: Boolean;
    begin
       // ���������, ��� ���������� ��������� ����
      if FileFormatList.GraphicFromExtension(ExtractFileExt(SRec.Name))=nil then Exit;
      d := FileDateToDateTime(SRec.Time);
       // ���� ������ ��������
      if bAdvanced.Tag=0 then
        bMatches := True
      else begin
         // ��������� ���� ��������� �����
        bMatches :=
          ((Wiz.Filter_DateFrom<0) or (Int(d) >=Wiz.Filter_DateFrom)) and
          ((Wiz.Filter_DateTo<0)   or (Int(d) <=Wiz.Filter_DateTo))   and
          ((Wiz.Filter_TimeFrom<0) or (Frac(d)>=Wiz.Filter_TimeFrom)) and
          ((Wiz.Filter_TimeTo<0)   or (Frac(d)<=Wiz.Filter_TimeTo));
         // ��������� ������������ �����
        if bMatches then bMatches := Masks.Matches(SRec.Name);
         // ��������� ����������� � �����������
        if bMatches and (Wiz.Filter_Presence<>afpfDontCare) then
          bMatches := (PhoA.Pics.PicByFileName(sPath+SRec.Name)<>nil) = (Wiz.Filter_Presence=afpfExistingOnly);
      end;
       // ���� ��� �������� �������������
      if bMatches then Files.Add(SRec.Name, sPath, SRec.Size, -2, d);
    end;

     // ��������� ���� �� ��� �����
    procedure AddFile(const sFilename: String); overload;
    var
      sr: TSearchRec;
      iRes: Integer;
    begin
      iRes := FindFirst(sFilename, faAnyFile, sr);
      try
        if (iRes=0) and (sr.Attr and faDirectory=0) then AddFile(ExtractFilePath(sFileName), sr);
      finally
        FindClose(sr);
      end;
    end;

    procedure AddFolder(const sPath: String; bRecurse: Boolean);
    var
      sr: TSearchRec;
      iRes: Integer;
    begin
      iRes := FindFirst(sPath+'*.*', faAnyFile, sr);
      try
        while iRes=0 do begin
          if sr.Name[1]<>'.' then
             // ���� ������� - ���������� ���������
            if sr.Attr and faDirectory<>0 then begin
              if bRecurse then AddFolder(sPath+sr.Name+'\', True);
             // ���� ���� - ��������� � ������
            end else
              AddFile(sPath, sr);
          iRes := FindNext(sr);
        end;
      finally
        FindClose(sr);
      end;
    end;

  begin
    Wiz := TfAddFilesWizard(StorageForm);
     // �������� �������
    Files := Wiz.FileList;
    PhoA  := Wiz.PhoA;
     // ������� ������������ ������ ������
    Files.Clear;
     // �������������� ��������
    Wiz.Filter_Presence := TAddFilePresenceFilter(cbPresence.ItemIndex);
    Wiz.Filter_Masks    := cbFileMasks.Text;
    Wiz.Filter_DateFrom := StrToDateDef(eFileDateFrom.Text, -1);
    Wiz.Filter_DateTo   := StrToDateDef(eFileDateTo.Text,   -1);
    Wiz.Filter_TimeFrom := StrToTimeDef(eFileTimeFrom.Text, -1);
    Wiz.Filter_TimeTo   := StrToTimeDef(eFileTimeTo.Text,   -1);
    if bAdvanced.Tag=0 then Masks := nil else Masks := TPhoaMasks.Create(Wiz.Filter_Masks);
    try
       // ������������ ������ ��������� ������/�����
      Node := tvMain.GetFirstSelected;
      while Assigned(Node) do begin
        if tvMain.ValidateNamespace(Node, Namespace) then
          if Namespace.FileSystem then
            if Namespace.Folder then
              AddFolder(IncludeTrailingPathDelimiter(Namespace.NameParseAddress), cbRecurseFolders.Checked)
            else
              AddFile(Namespace.NameParseAddress);
        Node := tvMain.GetNextSelected(Node);
      end;
    finally
      Masks.Free;
    end;
     // ���� � ������ ���� �����
    Result := Files.Count>0;
    if Result then begin
       // ���������� ���������
      Wiz.RecurseFolders      := cbRecurseFolders.Checked;
      Wiz.DefaultPath         := tvMain.SelectedPath;
      Wiz.ShowAdvancedOptions := bAdvanced.Tag<>0;
      RegSaveHistory(SRegAddFiles_MaskMRU, cbFileMasks, True);
    end else
      PhoaInfo(False, 'SNoFilesSelected');
  end;

  procedure TfrWzPageAddFiles_SelFiles.tvMainChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
  begin
    StatusChanged;
  end;

  procedure TfrWzPageAddFiles_SelFiles.tvMainEnumFolder(Sender: TCustomVirtualExplorerTree; Namespace: TNamespace; var AllowAsChild: Boolean);
  begin
    AllowAsChild := Namespace.Folder or (FileFormatList.GraphicFromExtension(ExtractFileExt(Namespace.FileName))<>nil);
  end;

end.
