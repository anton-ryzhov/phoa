//**********************************************************************************************************************
//  $Id: ufrWzPageAddFiles_CheckFiles.pas,v 1.9 2004-10-12 12:38:10 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Copyright 2002-2004 DK Software, http://www.dk-soft.org/
//**********************************************************************************************************************
unit ufrWzPageAddFiles_CheckFiles;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs,
  phIntf, phObj, ConsVars,
  phWizard, ImgList, TB2Item, TBX, Menus, ActnList, ExtCtrls, VirtualTrees,
  DKLang;

type
  TfrWzPageAddFiles_CheckFiles = class(TWizardPage)
    tvFiles: TVirtualStringTree;
    alMain: TActionList;
    aFilesCheckAll: TAction;
    aFilesUncheckAll: TAction;
    aFilesInvertChecks: TAction;
    pBottom: TPanel;
    pmFiles: TTBXPopupMenu;
    ilFiles: TImageList;
    ipmFilesInvertChecks: TTBXItem;
    ipmFilesUncheckAll: TTBXItem;
    ipmFilesCheckAll: TTBXItem;
    dklcMain: TDKLanguageController;
    procedure aaFilesCheckAll(Sender: TObject);
    procedure aaFilesInvertChecks(Sender: TObject);
    procedure aaFilesUncheckAll(Sender: TObject);
    procedure tvFilesChecked(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure tvFilesGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer);
    procedure tvFilesGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString);
    procedure tvFilesHeaderClick(Sender: TVTHeader; Column: TColumnIndex; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure tvFilesInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure tvFilesKeyAction(Sender: TBaseVirtualTree; var CharCode: Word; var Shift: TShiftState; var DoDefault: Boolean);
  private
     // ������ ������
    FFiles: TFileList;
     // ���������� ��������� ������
    FCheckedFilesCount: Integer;
     // ���������� ��� ��������� ���������� ���������/���������� ������. ��������� ������ � ����������
    procedure UpdateFileListInfo;
     // ������, ������� ��� ����������� ������� � ���� ������
    procedure CheckFiles(Mode: TMassCheckMode);
     // ����������� ������������� Actions
    procedure EnableActions;
  protected
    function  GetDataValid: Boolean; override;
    procedure InitializePage; override;
    procedure BeforeDisplay(ChangeMethod: TPageChangeMethod); override;
  end;

implementation
{$R *.dfm}
uses phUtils, ufAddFilesWizard, Main, phSettings;

  procedure TfrWzPageAddFiles_CheckFiles.aaFilesCheckAll(Sender: TObject);
  begin
    CheckFiles(mcmAll);
  end;

  procedure TfrWzPageAddFiles_CheckFiles.aaFilesInvertChecks(Sender: TObject);
  begin
    CheckFiles(mcmInvert);
  end;

  procedure TfrWzPageAddFiles_CheckFiles.aaFilesUncheckAll(Sender: TObject);
  begin
    CheckFiles(mcmNone);
  end;

  procedure TfrWzPageAddFiles_CheckFiles.BeforeDisplay(ChangeMethod: TPageChangeMethod);
  begin
    inherited BeforeDisplay(ChangeMethod);
    if ChangeMethod=pcmNextBtn then begin
      tvFiles.RootNodeCount := FFiles.Count;
      tvFiles.ReinitChildren(nil, False);
      ilFiles.Handle := FFiles.SysImageListHandle;
      UpdateFileListInfo;
    end;
  end;

  procedure TfrWzPageAddFiles_CheckFiles.CheckFiles(Mode: TMassCheckMode);
  var
    n: PVirtualNode;
    cs: TCheckState;
  begin
    tvFiles.BeginUpdate;
    try
      n := tvFiles.GetFirst;
      while n<>nil do begin
        case Mode of
          mcmAll:  cs := csCheckedNormal;
          mcmNone: cs := csUncheckedNormal;
          else     cs := aCheckStates[n.CheckState<>csCheckedNormal];
        end;
        tvFiles.CheckState[n] := cs;
        n := tvFiles.GetNext(n);
      end;
    finally
      tvFiles.EndUpdate;
    end;
    UpdateFileListInfo;
  end;

  procedure TfrWzPageAddFiles_CheckFiles.EnableActions;
  var bFilesChecked, bFilesUnchecked: Boolean;
  begin
    bFilesChecked   := FCheckedFilesCount>0;
    bFilesUnchecked := FCheckedFilesCount<FFiles.Count;
     // ����������� Actions
    aFilesCheckAll.Enabled   := bFilesUnchecked;
    aFilesUncheckAll.Enabled := bFilesChecked;
    StatusChanged;
  end;

  function TfrWzPageAddFiles_CheckFiles.GetDataValid: Boolean;
  begin
    Result := FCheckedFilesCount>0;
  end;

  procedure TfrWzPageAddFiles_CheckFiles.InitializePage;
  begin
    inherited InitializePage;
    ApplyTreeSettings(tvFiles);
    FFiles := TfAddFilesWizard(StorageForm).FileList;
  end;

  procedure TfrWzPageAddFiles_CheckFiles.tvFilesChecked(Sender: TBaseVirtualTree; Node: PVirtualNode);
  begin
    if not (tsUpdating in Sender.TreeStates) then UpdateFileListInfo;
  end;

  procedure TfrWzPageAddFiles_CheckFiles.tvFilesGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer);
  begin
    if (Kind=ikNormal) and (Column=0) then ImageIndex := FFiles[Node.Index].iIconIndex;
  end;

  procedure TfrWzPageAddFiles_CheckFiles.tvFilesGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString);
  var
    p: PFileRec;
    s: String;
  begin
    p := FFiles[Node.Index];
    case Column of
      0: s := p.sName;
      1: s := p.sPath;
      2: s := HumanReadableSize(p.iSize);
      3: s := DateTimeToStr(p.dModified);
    end;
    CellText := AnsiToUnicodeCP(s, cMainCodePage);
  end;

  procedure TfrWzPageAddFiles_CheckFiles.tvFilesHeaderClick(Sender: TVTHeader; Column: TColumnIndex; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  var n: PVirtualNode;
  begin
    if (Button<>mbLeft) or (Shift*[ssShift, ssCtrl, ssAlt]<>[]) then Exit;
    tvFiles.BeginUpdate;
    try
      with Sender do begin
         // ����������� ��������� ����������
        if SortColumn=Column then
          SortDirection := TSortDirection(1-Byte(SortDirection))
        else begin
          SortDirection := sdAscending;
          SortColumn := Column;
        end;
         // ��������� ������ ������
        FFiles.Sort(TFileListSortProperty(SortColumn), TPhoaSortDirection(SortDirection));
      end;
       // ������������ ����� � ������
      n := tvFiles.GetFirst;
      while n<>nil do begin
        tvFiles.CheckState[n] := aCheckStates[FFiles[n.Index].bChecked];
        n := tvFiles.GetNext(n);
      end;
    finally
      tvFiles.EndUpdate;
    end;
    tvFiles.Invalidate;
  end;

  procedure TfrWzPageAddFiles_CheckFiles.tvFilesInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
  begin
    Node.CheckType  := ctCheckBox;
    Node.CheckState := csCheckedNormal;
  end;

  procedure TfrWzPageAddFiles_CheckFiles.tvFilesKeyAction(Sender: TBaseVirtualTree; var CharCode: Word; var Shift: TShiftState; var DoDefault: Boolean);
  var n: PVirtualNode;
  begin
     // �� ������� ������� ����������� ����� � ���� ���������� �������
    if (Shift*[ssShift, ssCtrl, ssAlt]=[]) and (CharCode=VK_SPACE) then begin
      DoDefault := False;
      with tvFiles do begin
        BeginUpdate;
        try
          n := GetFirstSelected;
          while n<>nil do begin
            CheckState[n] := aCheckStates[n.CheckState<>csCheckedNormal];
            n := GetNextSelected(n);
          end;
        finally
          EndUpdate;
        end;
      end;
      UpdateFileListInfo;
    end;
  end;

  procedure TfrWzPageAddFiles_CheckFiles.UpdateFileListInfo;
  var
    n: PVirtualNode;
    bChecked: Boolean;
  begin
     // ������� ���������� ���������� ������
    FCheckedFilesCount := 0;
    n := tvFiles.GetFirst;
    while n<>nil do begin
      bChecked := n.CheckState=csCheckedNormal;
      if bChecked then Inc(FCheckedFilesCount);
       // �������� ��������� ����� � FFiles[]
      FFiles[n.Index].bChecked := bChecked;
      n := tvFiles.GetNext(n);
    end;
     // ��������� ����������
    pBottom.Caption := ConstVal('SWzPageAddFiles_CheckFiles_Info', [FFiles.Count, FCheckedFilesCount]);
    EnableActions;
  end;

end.

