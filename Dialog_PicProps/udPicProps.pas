//**********************************************************************************************************************
//  $Id: udPicProps.pas,v 1.4 2007-06-30 10:36:21 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Copyright DK Software, http://www.dk-soft.org/
//**********************************************************************************************************************
unit udPicProps;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs,
  TntWindows, TntClasses, GR32_Layers,
  phIntf, phMutableIntf, phNativeIntf, phObj, phOps, phMetadata, phWizard, phFrm,
  phDlg, Menus, TB2Item, TBX, ImgList, DKLang, TB2Dock, TB2Toolbar,
  StdCtrls, TntStdCtrls, ExtCtrls, TntExtCtrls;

type
  TdPicProps = class(TPhoaDialog, IWizardHostForm)
    bPgData: TTBXItem;
    bPgFileProps: TTBXItem;
    bPgGroups: TTBXItem;
    bPgKeywords: TTBXItem;
    bPgMetadata: TTBXItem;
    bPgView: TTBXItem;
    dklcMain: TDKLanguageController;
    dkNav: TTBXDock;
    ilFiles: TImageList;
    pMain: TTntPanel;
    pmNav: TTBXPopupMenu;
    pPages: TTntPanel;
    tbNav: TTBXToolbar;
    procedure PageButtonClick(Sender: TObject);
  private
     // ���������� �������
    FController: TWizardController;
     // ID ��������� �������������� (�������) ��������
    FLastUsedPageID: Integer;
     // ������ ImageIndeices ������ �� ���������� ImageList'�
    FFileImageIndices: Array of Integer;
     // ������ ������ �����������
    FPictureFiles: TTntStringList;
     // ������ �������� ��� ������ ��������������/����������
    FUndoOperations: TPhoaOperations;
     // Prop storage
    FApp: IPhotoAlbumApp;
    FEditedPics: IPhotoAlbumPicList;
     // ���������� ������ ������� �� ������� ��������
    procedure FocusFirstPageControl;
     // IWizardHostForm
    function  WizHost_PageChanging(ChangeMethod: TPageChangeMethod; var iNewPageID: Integer): Boolean;
    procedure WizHost_PageChanged(ChangeMethod: TPageChangeMethod; iPrevPageID: Integer);
    function  WizHost_GetHostControl: TWinControl;
    function  WizHost_GetNextPageID: Integer;
    function  WizHost_GetStorageForm: TPhoaForm;
    function  IWizardHostForm.PageChanging   = WizHost_PageChanging;
    procedure IWizardHostForm.PageChanged    = WizHost_PageChanged;
    procedure IWizardHostForm.StateChanged   = StateChanged;
    function  IWizardHostForm.GetHostControl = WizHost_GetHostControl;
    function  IWizardHostForm.GetNextPageID  = WizHost_GetNextPageID;
    function  IWizardHostForm.GetStorageForm = WizHost_GetStorageForm;
     // Prop handlers
    function  GetFileImageIndex(Index: Integer): Integer;
    function  GetPictureFiles(Index: Integer): WideString;
    procedure SetPictureFiles(Index: Integer; const Value: WideString);
  protected
    function  GetRelativeRegistryKey: AnsiString; override;
    function  GetSizeable: Boolean; override;
    procedure ButtonClick_OK; override;
    procedure DoCreate; override;
    procedure DoDestroy; override;
    procedure DoShow; override;
    procedure ExecuteInitialize; override;
    procedure SettingsLoad(rif: TPhoaRegIniFile); override;
    procedure SettingsSave(rif: TPhoaRegIniFile); override;
  public
     // ���� ����������� �� ����� ����� � ���������� ��� ID, ���� �����, ����� ���������� 0. ����� �������������� �
     //   ������ ����� ��� ������, �������� � �������, �� ����� ���� ����������� �������
    function  FindPicIDByFileName(const wsFileName: WideString): Integer;
     // Props
     // -- ����������
    property App: IPhotoAlbumApp read FApp;
     // -- ������������� �����������
    property EditedPics: IPhotoAlbumPicList read FEditedPics;
     // -- ImageIndices ������ ������������� �����������
    property FileImageIndex[Index: Integer]: Integer read GetFileImageIndex;
     // -- ����� ������ ������������� �����������
    property PictureFiles[Index: Integer]: WideString read GetPictureFiles write SetPictureFiles;
  end;

  function EditPics(AApp: IPhotoAlbumApp; AEditedPics: IPhotoAlbumPicList; AUndoOperations: TPhoaOperations): Boolean;

implementation
{$R *.dfm}
uses
  ShellAPI,
  phUtils, phSettings, ConsVars, Main,
  phPicPropsDlgPage, ufrPicProps_FileProps, ufrPicProps_Metadata, ufrPicProps_View, ufrPicProps_Data,
  ufrPicProps_Keywords, ufrPicProps_Groups;

  function EditPics(AApp: IPhotoAlbumApp; AEditedPics: IPhotoAlbumPicList; AUndoOperations: TPhoaOperations): Boolean;
  begin
    with TdPicProps.Create(Application) do
      try
        FApp            := AApp;
        FEditedPics     := AEditedPics;
        FUndoOperations := AUndoOperations;
        Result := ExecuteModal(False, False);
      finally
        Free;
      end;
  end;

   //===================================================================================================================
   // TfPicProps
   //===================================================================================================================

  procedure TdPicProps.ButtonClick_OK;
  var
    i, idxMainParam: Integer;
    wsOpParam: WideString;
    OpParams: IPhoaOperationParams;
    aMainOpParams: Array of Variant;
  begin
     // ��������� ��������������� ��� ��������
    for i := 0 to FController.Count-1 do
      if not (FController[i] as TPicPropsDialogPage).CanApply then begin
        FController.SetVisiblePageID(FController[i].ID, pcmForced);
        Exit;
      end;
     // ��������� ��������������� ��� ��������, �������� ������ ���������� ������� �������� (PicEdit)
    aMainOpParams := nil;
    idxMainParam  := -1;
    for i := 0 to FController.Count-1 do begin
      wsOpParam := '';
      OpParams := nil;
      TPicPropsDialogPage(FController[i]).Apply(wsOpParam, OpParams);
      if wsOpParam<>'' then begin
        SetLength(aMainOpParams, idxMainParam+3);
        Inc(idxMainParam);
        aMainOpParams[idxMainParam] := wsOpParam;
        Inc(idxMainParam);
        aMainOpParams[idxMainParam] := OpParams;
      end;
    end;
     // ��������� ��������
    FApp.PerformOperation('PicEdit', aMainOpParams);
     // ��������� ������
    inherited ButtonClick_OK;
  end;

  procedure TdPicProps.DoCreate;
  begin
    inherited DoCreate;
     // ������ ������ ������
    FPictureFiles := TTntStringList.Create;
     // ������ ���������� �������
    FController := TWizardController.Create(Self);
    with FController do begin
      KeepHistory := False;
       // ������ ��������
      CreatePage(TfrPicProps_FileProps, IDlgPicPropsPageID_FileProps, IDH_intf_pic_props_fprops,   '');
      CreatePage(TfrPicProps_Metadata,  IDlgPicPropsPageID_Metadata,  IDH_intf_pic_props_metadata, '');
      CreatePage(TfrPicProps_View,      IDlgPicPropsPageID_View,      IDH_intf_pic_props_view,     '');
      CreatePage(TfrPicProps_Data,      IDlgPicPropsPageID_Data,      IDH_intf_pic_props_data,     '');
      CreatePage(TfrPicProps_Keywords,  IDlgPicPropsPageID_Keywords,  IDH_intf_pic_props_keywords, '');
      CreatePage(TfrPicProps_Groups,    IDlgPicPropsPageID_Groups,    IDH_intf_pic_props_groups,   '');
    end;
    pmNav.LinkSubitems := tbNav.Items;
  end;

  procedure TdPicProps.DoDestroy;
  begin
    FController.Free;
    FPictureFiles.Free;
    inherited DoDestroy;
  end;

  procedure TdPicProps.DoShow;
  var iPageID: Integer; 
  begin
    inherited DoShow;
     // ���������� ��������� ��������� ��������
    case TPicPropsDlgDefaultPage(SettingValueInt(ISettingID_Dlgs_PP_DefaultPage)) of
      ppddpFileProps:      iPageID := IDlgPicPropsPageID_FileProps;
      ppddpMetadata:       iPageID := IDlgPicPropsPageID_Metadata;
      ppddpView:           iPageID := IDlgPicPropsPageID_View;
      ppddpData:           iPageID := IDlgPicPropsPageID_Data;
      ppddpKeywords:       iPageID := IDlgPicPropsPageID_Keywords;
      ppddpGroups:         iPageID := IDlgPicPropsPageID_Groups;
      else {ppddpLastUsed} iPageID := FLastUsedPageID;
    end;
     // ���� �� ������� ���������� ���������� ID �������� - ����� ��� ����� �������� "������"
    if (iPageID=0) or (FController.IndexOfID(iPageID)<0) then iPageID := IDlgPicPropsPageID_Data;
     // ���������� ��������� ��������
    FController.SetVisiblePageID(iPageID, pcmForced);
     // ���������� ������ ������� �� ��������
    FocusFirstPageControl;
  end;

  procedure TdPicProps.ExecuteInitialize;
  var
    i: Integer;
    FileInfo: TSHFileInfoW;
  begin
    inherited ExecuteInitialize;
    if FEditedPics.Count>0 then begin
       // �������������� ������ �������� ����������� ������ � -1 ("ImageIndex �� ������") � �������� ������ ������
      SetLength(FFileImageIndices, FEditedPics.Count);
      for i := 0 to FEditedPics.Count-1 do begin
        FFileImageIndices[i] := -1;
        FPictureFiles.Add(FEditedPics[i].FileName);
      end;
       // �������� Handle ���������� ImageList-�
      ilFiles.Handle := Tnt_SHGetFileInfoW(PWideChar(FPictureFiles[0]), 0, FileInfo, SizeOf(FileInfo), SHGFI_SYSICONINDEX or SHGFI_SMALLICON);
    end;
  end;

  function TdPicProps.FindPicIDByFileName(const wsFileName: WideString): Integer;
  var
    i, iPicID: Integer;
    ProjPics: IPhotoAlbumPicList;
  begin
     // ������� ���� ����� ������������� �����������
    for i := 0 to FPictureFiles.Count-1 do
      if ReverseCompare(FPictureFiles[i], wsFileName) then begin
        Result := EditedPics[i].ID;
        Exit;
      end;
     // ���� �� ����� - ���� ����� ���� ����������� �����������
    Result := 0;
    ProjPics := App.ProjectX.PicsX;
    for i := 0 to ProjPics.Count-1 do
       // ����� ����� ����
      if ReverseCompare(ProjPics[i].FileName, wsFileName) then begin
         // ���� ����������� ��������� � ����� �������������, ������, ���� ��� �������� (����� �� ����� �� ��� �����
         //   ������� �� ������������� ������������) � ����������� � ����� ������ ����� �� ����������
        iPicID := ProjPics[i].ID;
        if EditedPics.IndexOfID(iPicID)<0 then Result := iPicID;
        Break;
      end;
  end;

type TWinControlCast = class(TWinControl);

  procedure TdPicProps.FocusFirstPageControl;
  begin
    if Visible and (FController.VisiblePage<>nil) then TWinControlCast(FController.VisiblePage).SelectFirst;
  end;

  function TdPicProps.GetFileImageIndex(Index: Integer): Integer;
  var
    FileInfo: TSHFileInfoW;
    pImgIdx: PInteger;
  begin
     // ���� ImageIndex=-1 - ��� ������, �� ��� �� ����������
    pImgIdx := @FFileImageIndices[Index];
    if pImgIdx^=-1 then begin
      Tnt_SHGetFileInfoW(PWideChar(FPictureFiles[Index]), 0, FileInfo, SizeOf(FileInfo), SHGFI_SYSICONINDEX or SHGFI_SMALLICON);
      pImgIdx^ := FileInfo.iIcon;
    end;
    Result := pImgIdx^;
  end;

  function TdPicProps.GetPictureFiles(Index: Integer): WideString;
  begin
    Result := FPictureFiles[Index];
  end;

  function TdPicProps.GetRelativeRegistryKey: AnsiString;
  begin
    Result := SRegPicProps_Root;
  end;

  function TdPicProps.GetSizeable: Boolean;
  begin
    Result := True;
  end;

  procedure TdPicProps.PageButtonClick(Sender: TObject);
  begin
    FController.SetVisiblePageID(TComponent(Sender).Tag+1, pcmForced);
  end;

  procedure TdPicProps.SetPictureFiles(Index: Integer; const Value: WideString);
  var i: Integer;
  begin
    if FPictureFiles[Index]<>Value then begin
      FPictureFiles[Index] := Value;
       // ���������� ImageIndex
      FFileImageIndices[Index] := -1;
       // ���������� ��� �������� �� ��������� �����
      for i := 0 to FController.Count-1 do TPicPropsDialogPage(FController[i]).FileChanged(Index);
      Modified := True;
    end;
  end;

  procedure TdPicProps.SettingsLoad(rif: TPhoaRegIniFile);
  begin
    inherited SettingsLoad(rif);
    FLastUsedPageID := rif.ReadInteger('', 'LastUsedPageID', 0);
  end;

  procedure TdPicProps.SettingsSave(rif: TPhoaRegIniFile);
  begin
    inherited SettingsSave(rif);
    rif.WriteInteger('', 'LastUsedPageID', FController.VisiblePageID);
  end;

  function TdPicProps.WizHost_GetHostControl: TWinControl;
  begin
    Result := pPages;
  end;

  function TdPicProps.WizHost_GetNextPageID: Integer;
  begin
    Result := 0;
  end;

  function TdPicProps.WizHost_GetStorageForm: TPhoaForm;
  begin
    Result := Self;
  end;

  procedure TdPicProps.WizHost_PageChanged(ChangeMethod: TPageChangeMethod; iPrevPageID: Integer);
  var i, iPageID: Integer;
  begin
     // ����������� "���������" ������ ������ �������
    iPageID := FController.VisiblePageID;
    for i := 0 to tbNav.Items.Count-1 do
      with tbNav.Items[i] do Checked := Tag=iPageID-1;
     // ���������� ������ �������
    FocusFirstPageControl;
  end;

  function TdPicProps.WizHost_PageChanging(ChangeMethod: TPageChangeMethod; var iNewPageID: Integer): Boolean;
  begin
    Result := True;
  end;

end.

