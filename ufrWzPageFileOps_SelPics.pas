unit ufrWzPageFileOps_SelPics;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, ConsVars,
  Dialogs, phWizard, StdCtrls, VirtualTrees, TB2Item, TBX, Menus,
  DTLangTools, ActnList;

type
  TfrWzPageFileOps_SelPics = class(TWizardPage)
    rbAllPics: TRadioButton;
    rbSelPics: TRadioButton;
    rbSelGroups: TRadioButton;
    tvGroups: TVirtualStringTree;
    lCountInfo: TLabel;
    dtlsMain: TDTLanguageSwitcher;
    alMain: TActionList;
    aCheckAll: TAction;
    aUncheckAll: TAction;
    aInvertChecks: TAction;
    pmGroups: TTBXPopupMenu;
    ipmGroupsCheckAll: TTBXItem;
    ipmGroupsUncheckAll: TTBXItem;
    ipmGroupsInvertChecks: TTBXItem;
    cbSkipValid: TCheckBox;
    cbSkipInvalid: TCheckBox;
    procedure tvGroupsChecked(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure tvGroupsGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer);
    procedure tvGroupsGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString);
    procedure tvGroupsInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure RBSelPicturesClick(Sender: TObject);
    procedure tvGroupsPaintText(Sender: TBaseVirtualTree; const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType);
    procedure aaCheckAll(Sender: TObject);
    procedure aaUncheckAll(Sender: TObject);
    procedure aaInvertChecks(Sender: TObject);
    procedure UpdateCountInfoNotify(Sender: TObject);
  private
     // ���������� ��������� �����
    FSelGroupCount: Integer;
     // ���������� ��������� �����������
    FSelPicCount: Integer;
     // ��������� ������ ������ ��������� �����������
    FSelPicFileTotalSize: Integer;
     // ����������� ����������� [���������] ��������� ������ �����������
    procedure AdjustPicControls;
     // ��������� ���������� � ��������� ������������
    procedure UpdateCountInfo;
     // ������, ������� ��� ����������� ������� � ���� ����� � �������������
    procedure CheckFiles(Mode: TMassCheckMode);
  protected
    procedure InitializePage; override;
    function  GetDataValid: Boolean; override;
    procedure BeforeDisplay(ChangeMethod: TPageChangeMethod); override;
    function  NextPage: Boolean; override;
  end;

implementation
{$R *.dfm}
uses phUtils, udFileOpsWizard, Main, phObj;

  procedure TfrWzPageFileOps_SelPics.aaCheckAll(Sender: TObject);
  begin
    CheckFiles(mcmAll);
  end;

  procedure TfrWzPageFileOps_SelPics.aaInvertChecks(Sender: TObject);
  begin
    CheckFiles(mcmInvert);
  end;

  procedure TfrWzPageFileOps_SelPics.aaUncheckAll(Sender: TObject);
  begin
    CheckFiles(mcmNone);
  end;

  procedure TfrWzPageFileOps_SelPics.AdjustPicControls;
  begin
    EnableWndCtl(tvGroups, rbSelGroups.Checked);
    UpdateCountInfo;
  end;

  procedure TfrWzPageFileOps_SelPics.BeforeDisplay(ChangeMethod: TPageChangeMethod);
  var Wiz: TdFileOpsWizard;
  begin
    inherited BeforeDisplay(ChangeMethod);
    Wiz := TdFileOpsWizard(StorageForm);
    rbSelPics.Enabled  := Wiz.ViewerSelPicCount>0;
    if Wiz.ViewerCurView=nil then
      rbAllPics.Caption := ConstVal('SWzFileOps_AllPicsInPhoa')
    else
      rbAllPics.Caption := ConstVal('SWzFileOps_AllPicsInView', [Wiz.ViewerCurView.Name]);
     // ������������� ��������� ����������� � ����������� �� ������
    rbSelPics.Checked     := Wiz.SelPicMode=fospmSelPics;
    rbAllPics.Checked     := Wiz.SelPicMode=fospmAll;
    rbSelGroups.Checked   := Wiz.SelPicMode=fospmSelGroups;
     // ������ �����
    cbSkipValid.Enabled   := Wiz.FileOpKind in [fokMoveFiles, fokDeleteFiles, fokRepairFileLinks];
    cbSkipValid.Checked   := Wiz.SkipValidPics and (Wiz.FileOpKind in [fokMoveFiles, fokDeleteFiles, fokRepairFileLinks]);
    cbSkipInvalid.Checked := Wiz.SkipInvalidPics;
     // ����������� ��������� ��������
    AdjustPicControls;
  end;

  procedure TfrWzPageFileOps_SelPics.CheckFiles(Mode: TMassCheckMode);
  var
    n: PVirtualNode;
    cs: TCheckState;
  begin
    tvGroups.BeginUpdate;
    try
      n := tvGroups.GetFirst;
      while n<>nil do begin
        if not (vsDisabled in n.States) then begin
          case Mode of
            mcmAll:  cs := csCheckedNormal;
            mcmNone: cs := csUncheckedNormal;
            else     cs := aCheckStates[n.CheckState<>csCheckedNormal];
          end;
          tvGroups.CheckState[n] := cs;
        end;
        n := tvGroups.GetNext(n);
      end;
    finally
      tvGroups.EndUpdate;
    end;
    UpdateCountInfo;
  end;

  function TfrWzPageFileOps_SelPics.GetDataValid: Boolean;
  begin
    Result := FSelPicCount>0;
  end;

  procedure TfrWzPageFileOps_SelPics.InitializePage;
  begin
    inherited InitializePage;
     // ����������� ������ �����
    tvGroups.NodeDataSize := SizeOf(Pointer);
    tvGroups.RootNodeCount := fMain.tvGroups.RootNodeCount;
  end;

  function TfrWzPageFileOps_SelPics.NextPage: Boolean;
  var
    n: PVirtualNode;
    Wiz: TdFileOpsWizard;
  begin
     // ������������� ����� ������ ����������� � ����������� ������ ��������� �����
    Wiz := TdFileOpsWizard(StorageForm);
    Wiz.ClearSelectedGroups;
     // -- ��������� �� ������ �����������
    if rbSelPics.Checked then
      Wiz.SelPicMode := fospmSelPics
     // -- ��� ����������� �����������
    else if rbAllPics.Checked then
      Wiz.SelPicMode := fospmAll
     // -- ����������� �� ��������� �����
    else begin
      Wiz.SelPicMode := fospmSelGroups;
      n := tvGroups.GetFirst;
      while n<>nil do begin
        if n.CheckState=csCheckedNormal then Wiz.AddSelectedGroup(PPhoaGroup(tvGroups.GetNodeData(n))^);
        n := tvGroups.GetNext(n);
      end;
    end;
     // ��������� ������ �����
    if Wiz.FileOpKind in [fokMoveFiles, fokDeleteFiles, fokRepairFileLinks] then Wiz.SkipValidPics := cbSkipValid.Checked;
    Wiz.SkipInvalidPics := cbSkipInvalid.Checked;
    Result := True;
  end;

  procedure TfrWzPageFileOps_SelPics.RBSelPicturesClick(Sender: TObject);
  begin
    AdjustPicControls;
  end;

  procedure TfrWzPageFileOps_SelPics.tvGroupsChecked(Sender: TBaseVirtualTree; Node: PVirtualNode);
  begin
    if not (tsUpdating in Sender.TreeStates) then UpdateCountInfo;
  end;

  procedure TfrWzPageFileOps_SelPics.tvGroupsGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer);
  begin
    fMain.tvGroupsGetImageIndex(Sender, Node, Kind, Column, Ghosted, ImageIndex);
  end;

  procedure TfrWzPageFileOps_SelPics.tvGroupsGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString);
  begin
    fMain.tvGroupsGetText(Sender, Node, Column, TextType, CellText);
  end;

  procedure TfrWzPageFileOps_SelPics.tvGroupsInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
  var Group: TPhoaGroup;
  begin
    fMain.tvGroupsInitNode(Sender, ParentNode, Node, InitialStates);
     // �������� ������, � ������� ������������ ����
    Group := PPhoaGroup(Sender.GetNodeData(Node))^;
     // ��������� ����, ���� � ���� ��� �����������
    if Group.PicIDs.Count=0 then Include(InitialStates, ivsDisabled);
     // ����������� ����� ����
    Node.CheckType := ctCheckBox;
    Node.CheckState := aCheckStates[not (ivsDisabled in InitialStates) and (TdFileOpsWizard(StorageForm).IndexOfSelectedGroup(Group)>=0)];
  end;

  procedure TfrWzPageFileOps_SelPics.tvGroupsPaintText(Sender: TBaseVirtualTree; const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType);
  begin
    fMain.tvGroupsPaintText(Sender, TargetCanvas, Node, Column, TextType);
  end;

  procedure TfrWzPageFileOps_SelPics.UpdateCountInfo;
  var
    n: PVirtualNode;
    FPicIDs: TIntegerList;
    i: Integer;
    Wiz: TdFileOpsWizard;
    bSkipValid, bSkipInvalid: Boolean;

     // ���� validity ����������� Pic ������������� ������, ����������� FSelPicCount �� 1, � FSelPicFileTotalSize -
     //   �� ������ �����
    procedure AddPicInfo(Pic: TPhoaPic);
    begin
       // ���� ����� ��������� ���������� - ��������� ������� �����
      if (not bSkipValid and not bSkipInvalid) or (FileExists(Pic.PicFileName)<>bSkipValid) then begin
        Inc(FSelPicCount);
        Inc(FSelPicFileTotalSize, Pic.PicFileSize);
      end;
    end;

  begin
    StartWait;
    try
      Wiz := TdFileOpsWizard(StorageForm);
      FSelGroupCount       := 0;
      FSelPicCount         := 0;
      FSelPicFileTotalSize := 0;
      bSkipValid   := cbSkipValid.Checked;
      bSkipInvalid := cbSkipInvalid.Checked;
       // ���� ������� ��� "���������� ������������" � "���������� ��������������" - �������� ������
      if not bSkipValid or not bSkipInvalid then begin
         // ��������� �����������
        if rbSelPics.Checked then begin
          FSelGroupCount := 1;
          for i := 0 to Wiz.ViewerSelPicCount-1 do AddPicInfo(Wiz.PhoA.Pics.PicByID(Wiz.ViewerSelPicIDs[i]));
         // ��� ����������� �����������
        end else if rbAllPics.Checked then begin
          FSelGroupCount := Wiz.PhoA.RootGroup.NestedGroupCount+1;
          for i := 0 to Wiz.PhoA.Pics.Count-1 do AddPicInfo(Wiz.PhoA.Pics[i]);
         // ����������� �� ��������� �����
        end else begin
          FPicIDs := TIntegerList.Create(False);
          try
            n := tvGroups.GetFirst;
            while n<>nil do begin
              if n.CheckState=csCheckedNormal then begin
                Inc(FSelGroupCount);
                FPicIDs.AddAll(PPhoaGroup(tvGroups.GetNodeData(n))^.PicIDs);
              end;
              n := tvGroups.GetNext(n);
            end;
            for i := 0 to FPicIDs.Count-1 do AddPicInfo(Wiz.PhoA.Pics.PicByID(FPicIDs[i]));
          finally
            FPicIDs.Free;
          end;
        end;
      end;
      lCountInfo.Caption := ConstVal('SWzFileOps_PicGroupSelectedCount', [FSelPicCount, FSelGroupCount, HumanReadableSize(FSelPicFileTotalSize)]);
      StatusChanged;
    finally
      StopWait;
    end;
  end;

  procedure TfrWzPageFileOps_SelPics.UpdateCountInfoNotify(Sender: TObject);
  begin
    UpdateCountInfo;
  end;

end.
