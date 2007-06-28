//**********************************************************************************************************************
//  $Id: ufrWzPageFileOps_RepairSelLinks.pas,v 1.3 2007-06-28 18:41:59 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Copyright DK Software, http://www.dk-soft.org/
//**********************************************************************************************************************
unit ufrWzPageFileOps_RepairSelLinks;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs,
  phIntf, phMutableIntf, phNativeIntf, phObj, phOps, ConsVars,
  phWizard, StdCtrls, ExtCtrls, Mask, VirtualTrees,
  DKLang, TntStdCtrls, TntExtCtrls;

type
  TfrWzPageFileOps_RepairSelLinks = class(TWizardPage)
    cbDeleteUnmatched: TTntCheckBox;
    dklcMain: TDKLanguageController;
    pBottom: TTntPanel;
    tvMain: TVirtualStringTree;
    procedure tvMainBeforeCellPaint(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; CellRect: TRect);
    procedure tvMainGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer);
    procedure tvMainGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString);
    procedure tvMainInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
  protected
    function  NextPage: Boolean; override;
    procedure BeforeDisplay(ChangeMethod: TPageChangeMethod); override;
    procedure DoCreate; override;
  end;

implementation
{$R *.dfm}
uses phUtils, udFileOpsWizard, Main;

  procedure TfrWzPageFileOps_RepairSelLinks.BeforeDisplay(ChangeMethod: TPageChangeMethod);
  var Wiz: TdFileOpsWizard;
  begin
    inherited BeforeDisplay(ChangeMethod);
    Wiz := TdFileOpsWizard(StorageForm);
     // �������������� �����
    tvMain.Clear;
    tvMain.RootNodeCount      := Wiz.SelectedPics.Count;
    cbDeleteUnmatched.Checked := Wiz.Repair_DeleteUnmatchedPics;
  end;

  procedure TfrWzPageFileOps_RepairSelLinks.DoCreate;
  begin
    inherited DoCreate;
    tvMain.NodeDataSize := SizeOf(Integer);
  end;

  function TfrWzPageFileOps_RepairSelLinks.NextPage: Boolean;
  var Wiz: TdFileOpsWizard;
  begin
    Result := inherited NextPage;
    if Result then begin
       // ��������� �����
      Wiz := TdFileOpsWizard(StorageForm);
      Wiz.Repair_DeleteUnmatchedPics := cbDeleteUnmatched.Checked;
    end;
  end;

  procedure TfrWzPageFileOps_RepairSelLinks.tvMainBeforeCellPaint(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; CellRect: TRect);
  begin
     // ��� ��������� �������� (�����������) ������������� ���� ���� clBtnFace
    if Sender.NodeParent[Node]=nil then
      with TargetCanvas do begin
        Brush.Color := clBtnFace;
        FillRect(CellRect);
      end;
  end;

  procedure TfrWzPageFileOps_RepairSelLinks.tvMainGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer);
  begin
     // � ����������� ��� ���������� ������������ ������ ���� ����������
    if (Column=0) and (Sender.NodeParent[Node]=nil) and (Sender.ChildCount[Node]=0) then ImageIndex := iiNo;
  end;

  procedure TfrWzPageFileOps_RepairSelLinks.tvMainGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString);
//  var
//    ws: WideString;
//    Pic: IPhotoAlbumPic;
//    FL: TFileLink;
  begin
//    CellText := '';
//     // �������� �����������
//    if Sender.NodeParent[Node]=nil then begin
//      Pic := PPhoaPic(Sender.GetNodeData(Node))^;
//      case Column of
//        0: CellText := Pic.Props[ppFileName];
//        1: CellText := Pic.Props[ppFilePath];
//        2: CellText := HumanReadableSize(Pic.FileSize);
//      end;
//     // ��������� ����
//    end else begin
//      FL := PFileLink(Sender.GetNodeData(Node))^;
//      case Column of
//        0: CellText := FL.FileName;
//        1: CellText := FL.FilePath;
//        2: CellText := HumanReadableSize(FL.FileSize);
//        3: CellText := DateTimeToStr(FL.FileTime, AppFormatSettings);
//      end;
//    end;
  end;

  procedure TfrWzPageFileOps_RepairSelLinks.tvMainInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
//  var
//    Wiz: TdFileOpsWizard;
//    i: Integer;
//    Pic: IPhoaPic;
//    FL: TFileLink;
  begin
//    Wiz := TdFileOpsWizard(StorageForm);
//     // *** �������� �����������
//    if ParentNode=nil then begin
//       // Node.Data = ������ �� ����������� �� SelectedPics
//      Pic := Wiz.SelectedPics[Node.Index];
//      PPhoaPic(Sender.GetNodeData(Node))^ := Pic;
//       // ��������� �������� ���� ������, ����������� �� �����������. �� Node.Data = ������ �� ���� �� Repair_FileLinks
//      for i := 0 to Wiz.Repair_FileLinks.Count-1 do begin
//        FL := Wiz.Repair_FileLinks[i];
//        if FL.Pics.IndexOfID(Pic.ID)>=0 then tvMain.AddChild(Node, FL);
//      end;
//       // ������ ����������� CheckBox
//      if Node.ChildCount>0 then begin
//        tvMain.CheckType[Node]  := ctCheckBox;
//        tvMain.CheckState[Node] := csCheckedNormal;
//      end;
//       // ������������� ��� ����
//      Include(InitialStates, ivsExpanded);
//     // *** ��������� ����
//    end else begin
//       // ������������� ��� �����������
//      Sender.CheckType[Node]  := ctRadioButton;
//      //#TODO: ���������� ��������� �����������  Sender.CheckState[Node] := ctRadioButton;
//    end;
  end;

end.

