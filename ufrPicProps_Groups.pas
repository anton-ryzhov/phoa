//**********************************************************************************************************************
//  $Id: ufrPicProps_Groups.pas,v 1.6 2004-09-11 17:52:36 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Copyright 2002-2004 DK Software, http://www.dk-soft.org/
//**********************************************************************************************************************
unit ufrPicProps_Groups;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, phObj, ConsVars,
  phWizard, VirtualTrees, phPicPropsDlgPage;

type
  TfrPicProps_Groups = class(TPicPropsDialogPage)
    tvMain: TVirtualStringTree;
    procedure tvMainInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure tvMainGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString);
    procedure tvMainGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer);
    procedure tvMainPaintText(Sender: TBaseVirtualTree; const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType);
    procedure tvMainChecking(Sender: TBaseVirtualTree; Node: PVirtualNode; var NewState: TCheckState; var Allowed: Boolean);
    procedure tvMainChecked(Sender: TBaseVirtualTree; Node: PVirtualNode);
  private
     // ���������� ���������� ��������� ����������� ����� ����������� ������
    function  GetSelCount(Group: TPhoaGroup): Integer;
  protected
    procedure InitializePage; override;
    procedure BeforeDisplay(ChangeMethod: TPageChangeMethod); override;
    procedure AfterDisplay(ChangeMethod: TPageChangeMethod); override;
  public
    function  CanApply: Boolean; override;
    procedure Apply(FOperations: TPhoaOperations); override;
  end;

implementation
{$R *.dfm}
uses Main, phUtils, phSettings, udMsgBox;

type
   // ������, ��������������� � ������ ����� ������ �����
  PGroupData = ^TGroupData;
  TGroupData = record
    Group: TPhoaGroup;  // ������ �� ������
    iSelCount: Integer; // ���������� ����������� � ������ �� ����� ���������
  end;

  procedure TfrPicProps_Groups.AfterDisplay(ChangeMethod: TPageChangeMethod);
  begin
    inherited AfterDisplay(ChangeMethod);
    StorageForm.ActiveControl := tvMain;
  end;

  procedure TfrPicProps_Groups.Apply(FOperations: TPhoaOperations);
  var
    n: PVirtualNode;
    pgd: PGroupData;
    bChanges, bLinked: Boolean;
    aIDs: TIDArray;
    i, iPicID: Integer;
  begin
     // ���� �������� ������������������, ������ �������� ����������/�������� �����������
    if tvMain.RootNodeCount>0 then begin
       // ������ ���� �� ����� ������ (�� �������)
      n := tvMain.GetFirst;
      while n<>nil do begin
         // ����������, ���� �� ���������
        pgd := tvMain.GetNodeData(n);
        case n.CheckState of
           // -- ���� �������� ���
          csCheckedNormal:   bChanges := pgd.iSelCount<EditedPicCount;
           // -- ���� ��������� ���
          csUncheckedNormal: bChanges := pgd.iSelCount>0;
           // -- �� ��������
          else               bChanges := False;
        end;
         // ���� ���� - ���������� ������ ID �����������
        if bChanges then begin
          aIDs := nil;
          for i := 0 to EditedPicCount-1 do begin
            iPicID := EditedPics[i].ID;
            bLinked := pgd.Group.IsPicLinked(iPicID, False);
            if (n.CheckState=csCheckedNormal) <> bLinked then begin
              SetLength(aIDs, Length(aIDs)+1);
              aIDs[High(aIDs)] := iPicID;
            end;
          end;
           // ��������� (������) ��������
          if n.CheckState=csCheckedNormal then
            TPhoaOp_InternalPicToGroupAdding.Create(FOperations, PhoA, pgd.Group, aIDs)
          else
            TPhoaOp_InternalPicFromGroupRemoving.Create(FOperations, PhoA, pgd.Group, aIDs);
        end;
         // ��������� � ��������� ������
        n := tvMain.GetNext(n);
      end;
    end;
  end;

  procedure TfrPicProps_Groups.BeforeDisplay(ChangeMethod: TPageChangeMethod);
  begin
    inherited BeforeDisplay(ChangeMethod);
    with tvMain do
      if RootNodeCount=0 then begin
        BeginUpdate;
        try
          RootNodeCount := 1;
           // �������������� ��� ����, ����� ���������� ����������
          ReinitChildren(nil, True);
          OffsetXY := Point(0, 0);
        finally
          EndUpdate;
        end;
      end;
  end;

  function TfrPicProps_Groups.CanApply: Boolean;
  var
    i, iUnlinkedCount: Integer;
    bAllInGroups: Boolean;

     // ���������� True, ���� ����������� ���������� � �����-������ ������
    function PicLinked(Pic: TPhoaPic): Boolean;
    var Node: PVirtualNode;
    begin
      Result := False;
       // ���� �� ������
      Node := tvMain.GetFirst;
      while (Node<>nil) and not Result do begin
        case Node.CheckState of
           // ���� ��������� ����� - �� �������, ��� ��� ������� � ���� ������ ����� ��� ����������, ��������� ������
           //   ������������
          csCheckedNormal: begin
            Result := True;
            bAllInGroups := True;
          end;
           // ���� �������� ����� - ��������� ������� � ���� ������ ��������� ����� �����������
          csMixedNormal: Result := PGroupData(tvMain.GetNodeData(Node)).Group.IsPicLinked(Pic.ID, False);
        end;
        Node := tvMain.GetNext(Node);
      end;
    end;

  begin
     // ���� �������� �� ������������������
    if tvMain.RootNodeCount=0 then
      Result := True
     // ����� ���������, ��� ������ ����������� ���������� � �����-���� ������
    else begin
      bAllInGroups := False;
      iUnlinkedCount := 0;
       // ���� �� ��������� ������������
      for i := 0 to EditedPicCount-1 do begin
        if not PicLinked(EditedPics[i]) then Inc(iUnlinkedCount);
        if bAllInGroups then Break;
      end;
       // ��������� ���������� �����������
      Result := iUnlinkedCount=0;
      if not Result then PhoaError('SErrNotAllPicsLinked', [iUnlinkedCount, EditedPicCount]);
    end;
  end;

  function TfrPicProps_Groups.GetSelCount(Group: TPhoaGroup): Integer;
  var i: Integer;
  begin
    Result := 0;
    for i := 0 to EditedPicCount-1 do
      if Group.IsPicLinked(EditedPics[i].ID, False) then Inc(Result);
  end;

  procedure TfrPicProps_Groups.InitializePage;
  begin
    inherited InitializePage;
    ApplyTreeSettings(tvMain);
    tvMain.NodeDataSize := SizeOf(TGroupData);
  end;

  procedure TfrPicProps_Groups.tvMainChecked(Sender: TBaseVirtualTree; Node: PVirtualNode);
  begin
    Modified;
  end;

  procedure TfrPicProps_Groups.tvMainChecking(Sender: TBaseVirtualTree; Node: PVirtualNode; var NewState: TCheckState; var Allowed: Boolean);
  begin
     // ���������� ��� �����: ���� ���������� ���� Grayed - ����� Unchecked ��� Grayed
    if (Node.CheckState=csUncheckedNormal) and (NewState=csCheckedNormal) then
      with PGroupData(Sender.GetNodeData(Node))^ do
        if (iSelCount>0) and (iSelCount<EditedPicCount) then NewState := csMixedNormal;
  end;

  procedure TfrPicProps_Groups.tvMainGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer);
  begin
    if Kind in [ikNormal, ikSelected] then ImageIndex := iif(Sender.NodeParent[Node]=nil, iiPhoA, iiFolder);
    Ghosted := Node.CheckState=csUncheckedNormal;
  end;

  procedure TfrPicProps_Groups.tvMainGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString);
  var
    p: PGroupData;
    s: String;
  begin
    p := Sender.GetNodeData(Node);
    if p<>nil then
      if TextType=ttStatic then begin
        if p.Group.PicIDs.Count>0 then s := Format(iif(p.iSelCount>0, '(%d/%d)', '(%1:d)'), [p.iSelCount, p.Group.PicIDs.Count]);
      end else if Sender.NodeParent[Node]<>nil then s := p.Group.Text
      else s := ConstVal('SPhotoAlbumNode');
    CellText := AnsiToUnicodeCP(s, cMainCodePage);
  end;

  procedure TfrPicProps_Groups.tvMainInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
  var p, pp: PGroupData;
  begin
    p := Sender.GetNodeData(Node);
    if ParentNode=nil then
      p.Group := PhoA.RootGroup
    else begin
      pp := Sender.GetNodeData(ParentNode);
      p.Group := pp.Group.Groups[Node.Index];
    end;
    Sender.ChildCount[Node] := p.Group.Groups.Count;
     // ������� ���������� ��������� ����������� ����� ����������� ������
    p.iSelCount := GetSelCount(p.Group);
     // ����������� CheckBox
    Node.CheckType  := ctCheckBox;
    if      p.iSelCount=0              then Node.CheckState := csUncheckedNormal
    else if p.iSelCount<EditedPicCount then Node.CheckState := csMixedNormal
    else                                    Node.CheckState := csCheckedNormal;

    if p.iSelCount>0 then Sender.FullyVisible[Node] := True;
     // ������������� ��� ����
//    Include(InitialStates, ivsExpanded);
  end;

  procedure TfrPicProps_Groups.tvMainPaintText(Sender: TBaseVirtualTree; const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType);
  begin
    if TextType=ttStatic then TargetCanvas.Font.Color := clGrayText;
  end;

end.
