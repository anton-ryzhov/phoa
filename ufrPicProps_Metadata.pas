//**********************************************************************************************************************
//  $Id: ufrPicProps_Metadata.pas,v 1.10 2004-09-11 17:52:36 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Copyright 2002-2004 DK Software, http://www.dk-soft.org/
//**********************************************************************************************************************
unit ufrPicProps_Metadata;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, phWizard, VirtualTrees, phPicPropsDlgPage, TBXDkPanels, TB2Dock,
  TBX, Menus, TB2Item, DKLang;

type
  TfrPicProps_Metadata = class(TPicPropsDialogPage)
    tvMain: TVirtualStringTree;
    dkBottom: TTBXDock;
    dpDesc: TTBXDockablePanel;
    lDesc: TTBXLabel;
    pmMain: TTBXPopupMenu;
    ipmShowDescPanel: TTBXVisibilityToggleItem;
    dklcMain: TDKLanguageController;
    procedure tvMainGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString);
    procedure tvMainInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure tvMainFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure tvMainPaintText(Sender: TBaseVirtualTree; const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType);
    procedure tvMainGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer);
    procedure tvMainBeforeCellPaint(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; CellRect: TRect);
    procedure tvMainShortenString(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; const S: WideString; TextSpace: Integer; RightToLeft: Boolean; var Result: WideString; var Done: Boolean);
    procedure tvMainChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
  private
     // ������������� �������� ��������� ISettingID_Dlgs_PP_ExpMetadata
    FExpandAll: Boolean;
     // ��������� ��������
    procedure UpdateDesc;
  protected
    procedure InitializePage; override;
    function  GetRegistrySection: String; override;
    procedure BeforeDisplay(ChangeMethod: TPageChangeMethod); override;
    procedure AfterDisplay(ChangeMethod: TPageChangeMethod); override;
  end;

implementation
{$R *.dfm}
uses ConsVars, phUtils, phObj, phMetadata, udSettings, phSettings, Main;

type
  PPExifTag = ^PExifTag;

  procedure TfrPicProps_Metadata.AfterDisplay(ChangeMethod: TPageChangeMethod);
  begin
    inherited AfterDisplay(ChangeMethod);
    StorageForm.ActiveControl := tvMain;
  end;

  procedure TfrPicProps_Metadata.BeforeDisplay(ChangeMethod: TPageChangeMethod);
  begin
    inherited BeforeDisplay(ChangeMethod);
    if tvMain.RootNodeCount=0 then tvMain.RootNodeCount := EditedPicCount;
  end;

  function TfrPicProps_Metadata.GetRegistrySection: String;
  begin
    Result := SRegWizPage_PicProp_Metadata;
  end;

  procedure TfrPicProps_Metadata.InitializePage;
  begin
    inherited InitializePage;
     // ����������� tvMain
    ApplyTreeSettings(tvMain);
    tvMain.NodeDataSize := SizeOf(Pointer);
    tvMain.Images := FileImages;
     // �������� ���������
    FExpandAll := SettingValueBool(ISettingID_Dlgs_PP_ExpMetadata);
     // ��������� ��������
    UpdateDesc;
  end;

  procedure TfrPicProps_Metadata.tvMainBeforeCellPaint(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; CellRect: TRect);
  begin
     // ��� ��������� �������� (�����) ������������� ���� ���� clBtnFace
    if Sender.NodeParent[Node]=nil then
      with TargetCanvas do begin
        Brush.Color := clBtnFace;
        FillRect(CellRect);
      end;
  end;

  procedure TfrPicProps_Metadata.tvMainChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
  begin
     // ���������� ��������
    UpdateDesc;
  end;

  procedure TfrPicProps_Metadata.tvMainFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
  begin
     // ������� ������ ������ ���������� ��� �������� ���������
    if Sender.NodeParent[Node]=nil then PImageMetadata(Sender.GetNodeData(Node))^.Free;
  end;

  procedure TfrPicProps_Metadata.tvMainGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer);
  begin
    if (Kind in [ikNormal, ikSelected]) and (Sender.NodeParent[Node]=nil) and (Column=0) then ImageIndex := FileImageIndex[Node.Index];
  end;

  procedure TfrPicProps_Metadata.tvMainGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString);
  var
    nParent: PVirtualNode;
    s: String;
  begin
    nParent := Sender.NodeParent[Node];
     // ��� ����� ������ (��������)
    if nParent=nil then begin
      case Column of
         // ��� �����
        0: s := EditedPics[Node.Index].PicFileName;
         // ���� ������ - ������� ����
        2: begin
          case PImageMetadata(Sender.GetNodeData(Node))^.StatusCode of
            IMS_OK:                s := '';
            IMS_CannotOpenFile:    s := 'IMS_CannotOpenFile';
            IMS_ReadFailure:       s := 'IMS_ReadFailure';
            IMS_NotAJPEGFile:      s := 'IMS_NotAJPEGFile';
            IMS_NoMetadata:        s := 'IMS_NoMetadata';
            IMS_InvalidEXIFHeader: s := 'IMS_InvalidEXIFHeader';
            IMS_InvalidTIFFHeader: s := 'IMS_InvalidTIFFHeader';
            else                   s := 'IMS_InternalError';
          end;
          if s<>'' then s := ConstVal(s);
        end;
      end;
     // ��� ��������� ����� ���������� (�������� ����� �� ��������� � ������)
    end else
      case Column of
         // ��� ����
        0: s := Format('%.4x', [PPExifTag(Sender.GetNodeData(Node))^.iTag]);
         // ��� ����
        1: s := PPExifTag(Sender.GetNodeData(Node))^.sName;
         // ����������� �������� ����
        2: s := Copy(PImageMetadata(Sender.GetNodeData(nParent))^.EXIFData[Node.Index], 1, 200);
      end;
    CellText := AnsiToUnicodeCP(s, cMainCodePage);
  end;

  procedure TfrPicProps_Metadata.tvMainInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
  var
    pim: PImageMetadata;
    ppt: PPExifTag;
  begin
     // ���� (�������� �������)
    if ParentNode=nil then begin
      pim := Sender.GetNodeData(Node);
       // ������ ������ ������ ���������� �� ������ ����. ��� �������� ������ ������ ����� �����������
      pim^ := TImageMetadata.Create(EditedPics[Node.Index].PicFileName);
       // ���� �� ��������� ������ ��� ����������
      if pim^.StatusCode=IMS_OK then begin
        Sender.ChildCount[Node] := pim^.EXIFData.Count;
         // ���������� ����, ���� ����
        if FExpandAll then Include(InitialStates, ivsExpanded);
      end;
     // ���/������ ���� (��������� ����)
    end else begin
      ppt := Sender.GetNodeData(Node);
      pim := Sender.GetNodeData(ParentNode);
       // ���� � ���������� ���
      ppt^ := FindEXIFTag(Integer(pim^.EXIFData.Objects[Node.Index]));
    end;
  end;

  procedure TfrPicProps_Metadata.tvMainPaintText(Sender: TBaseVirtualTree; const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType);
  begin
    if Sender.NodeParent[Node]=nil then
      case Column of
         // �������� ���������� ����� ������
        0: TargetCanvas.Font.Style := [fsBold];
         // � ������ ������ �������� �������
        2: if PImageMetadata(Sender.GetNodeData(Node))^.StatusCode<>IMS_OK then TargetCanvas.Font.Color := $0000c0;
      end;
  end;

  procedure TfrPicProps_Metadata.tvMainShortenString(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; const S: WideString; TextSpace: Integer; RightToLeft: Boolean; var Result: WideString; var Done: Boolean);
  begin
    Result := AnsiToUnicodeCP(ShortenFileName(TargetCanvas, TextSpace-10, UnicodeToAnsiCP(S, cMainCodePage)), cMainCodePage);
    Done := True;
  end;

  procedure TfrPicProps_Metadata.UpdateDesc;
  var
    n: PVirtualNode;
    s: String;
  begin
    n := tvMain.FocusedNode;
    if tvMain.NodeParent[n]=nil then
      s := ConstVal('SMsg_NoMetatagSelected')
    else begin
      s := PPExifTag(tvMain.GetNodeData(n))^^.sDesc;
      if s='' then s := ConstVal('SNone');
    end;
    lDesc.Caption := s;
  end;

end.

