//**********************************************************************************************************************
//  $Id: ufrPicProps_Groups.pas,v 1.17 2004-12-31 13:38:58 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Copyright DK Software, http://www.dk-soft.org/
//**********************************************************************************************************************
unit ufrPicProps_Groups;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs,
  phIntf, phMutableIntf, phNativeIntf, phObj, phOps, ConsVars,
  phWizard, VirtualTrees, phPicPropsDlgPage;

type
  TfrPicProps_Groups = class(TPicPropsDialogPage)
    tvMain: TVirtualStringTree;
    procedure tvMainChecked(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure tvMainChecking(Sender: TBaseVirtualTree; Node: PVirtualNode; var NewState: TCheckState; var Allowed: Boolean);
    procedure tvMainFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure tvMainGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer);
    procedure tvMainGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString);
    procedure tvMainInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure tvMainPaintText(Sender: TBaseVirtualTree; const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType);
  private
     // ���������� ���������� ��������� ����������� ����� ����������� ������
    function  GetSelCount(Group: IPhotoAlbumPicGroup): Integer;
  protected
    procedure InitializePage; override;
    procedure BeforeDisplay(ChangeMethod: TPageChangeMethod); override;
  public
    function  CanApply: Boolean; override;
    procedure Apply(var sOpParamName: String; var OpParams: IPhoaOperationParams); override;
  end;

implementation
{$R *.dfm}
uses Main, phUtils, phSettings, udMsgBox;

type
   // ������, ��������������� � ������ ����� ������ �����
  PGroupData = ^TGroupData;
  TGroupData = record
    Group: IPhotoAlbumPicGroup; // ������ �� ������
    iSelCount: Integer;         // ���������� ����������� � ������ �� ����� ���������
  end;

  procedure TfrPicProps_Groups.Apply(var sOpParamName: String; var OpParams: IPhoaOperationParams);
  var
    n: PVirtualNode;
    pgd: PGroupData;
    AddToGroups, RemoveFromGroups: IPhotoAlbumPicGroupList;
  begin
     // ���� �������� ������������������
    if tvMain.RootNodeCount>0 then begin
      AddToGroups      := NewPhotoAlbumPicGroupList(nil);
      RemoveFromGroups := NewPhotoAlbumPicGroupList(nil);
       // ������ ���� �� ����� ������ (�� �������), �������� ������ �����, � ������� ���� �������� (AddToGroups) � ��
       //   ������� ���� ������� (RemoveFromGroups) ����������� 
      n := tvMain.GetFirst;
      while n<>nil do begin
         // ����������, ���� �� ���������
        pgd := tvMain.GetNodeData(n);
        case n.CheckState of
           // -- ���� �������� ���
          csCheckedNormal:   if pgd.iSelCount<EditedPics.Count then AddToGroups.Add(pgd.Group);
           // -- ���� ��������� ���
          csUncheckedNormal: if pgd.iSelCount>0 then RemoveFromGroups.Add(pgd.Group);
        end;
         // ��������� � ��������� ������
        n := tvMain.GetNext(n);
      end;
       // ���� ���� ��������� � �������������� �������, ���������� ��������� ��������������� �����������
      if (AddToGroups.Count>0) or (RemoveFromGroups.Count>0) then begin
        sOpParamName := 'EditGroupOpParams';
        OpParams     := NewPhoaOperationParams(['Pics', EditedPics, 'AddToGroups', AddToGroups, 'RemoveFromGroups', RemoveFromGroups]);
      end;
    end;
  end;

  procedure TfrPicProps_Groups.BeforeDisplay(ChangeMethod: TPageChangeMethod);
  begin
    inherited BeforeDisplay(ChangeMethod);
    if tvMain.RootNodeCount=0 then begin
      tvMain.BeginUpdate;
      try
        tvMain.RootNodeCount := 1;
         // �������������� ��� ����, ����� ���������� ����������
        tvMain.ReinitChildren(nil, True);
        ActivateFirstVTNode(tvMain);
      finally
        tvMain.EndUpdate;
      end;
    end;
  end;

  function TfrPicProps_Groups.CanApply: Boolean;
  var
    i, iUnlinkedCount: Integer;
    bAllInGroups: Boolean;

     // ���������� True, ���� ����������� ���������� � �����-������ ������
    function PicLinked(iPicID: Integer): Boolean;
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
          csMixedNormal: Result := PGroupData(tvMain.GetNodeData(Node)).Group.IsPicLinked(iPicID, False);
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
      for i := 0 to EditedPics.Count-1 do begin
        if not PicLinked(EditedPics[i].ID) then Inc(iUnlinkedCount);
        if bAllInGroups then Break;
      end;
       // ��������� ���������� �����������
      Result := iUnlinkedCount=0;
      if not Result then PhoaError('SErrNotAllPicsLinked', [iUnlinkedCount, EditedPics.Count]);
    end;
  end;

  function TfrPicProps_Groups.GetSelCount(Group: IPhotoAlbumPicGroup): Integer;
  var i: Integer;
  begin
    Result := 0;
    for i := 0 to EditedPics.Count-1 do
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
        if (iSelCount>0) and (iSelCount<EditedPics.Count) then NewState := csMixedNormal;
  end;

  procedure TfrPicProps_Groups.tvMainFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
  begin
    Finalize(PGroupData(Sender.GetNodeData(Node))^);
  end;

  procedure TfrPicProps_Groups.tvMainGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer);
  begin
    if Kind in [ikNormal, ikSelected] then ImageIndex := iif(Sender.NodeParent[Node]=nil, iiPhoA, iif(Kind=ikSelected, iiFolderOpen, iiFolder));
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
        if p.Group.Pics.Count>0 then s := Format(iif(p.iSelCount>0, '(%d/%d)', '(%1:d)'), [p.iSelCount, p.Group.Pics.Count]);
      end else if Sender.NodeParent[Node]<>nil then s := p.Group.Text
      else s := ConstVal('SPhotoAlbumNode');
    CellText := AnsiToUnicodeCP(s, cMainCodePage);
  end;

  procedure TfrPicProps_Groups.tvMainInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
  var p, pp: PGroupData;
  begin
    p := Sender.GetNodeData(Node);
    if ParentNode=nil then
      p.Group := App.Project.RootGroupX
    else begin
      pp := Sender.GetNodeData(ParentNode);
      p.Group := pp.Group.GroupsX[Node.Index];
    end;
    Sender.ChildCount[Node] := p.Group.Groups.Count;
     // ������� ���������� ��������� ����������� ����� ����������� ������
    p.iSelCount := GetSelCount(p.Group);
     // ����������� CheckBox
    Node.CheckType  := ctCheckBox;
    if      p.iSelCount=0                then Node.CheckState := csUncheckedNormal
    else if p.iSelCount<EditedPics.Count then Node.CheckState := csMixedNormal
    else                                      Node.CheckState := csCheckedNormal;
    if p.iSelCount>0 then Sender.FullyVisible[Node] := True;
  end;

  procedure TfrPicProps_Groups.tvMainPaintText(Sender: TBaseVirtualTree; const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType);
  begin
    if TextType=ttStatic then TargetCanvas.Font.Color := clGrayText;
  end;

end.
