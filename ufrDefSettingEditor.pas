//**********************************************************************************************************************
//  $Id: ufrDefSettingEditor.pas,v 1.1 2004-04-19 13:25:50 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Copyright 2002-2004 Dmitry Kann, http://phoa.narod.ru
//**********************************************************************************************************************
unit ufrDefSettingEditor;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, phSettings,
  VirtualTrees;

type
  TfrDefSettingEditor = class(TFrame, IPhoaSettingEditor)
    tvMain: TVirtualStringTree;
    procedure tvMainAfterCellPaint(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; CellRect: TRect);
    procedure tvMainChecked(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure EmbedControlNotify(Sender: TObject);
    procedure tvMainFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
    procedure tvMainGetCellIsEmpty(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; var IsEmpty: Boolean);
    procedure tvMainInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure tvMainGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString);
    procedure tvMainPaintText(Sender: TBaseVirtualTree; const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType);
  private
     // Prop storage
    FRootSetting: TPhoaPageSetting;
     // ��������� � tvMain ������ ��������, ����������� � ����� ���� FRootSetting
    procedure LoadTree;
     // ���������� ��������������� ������� ��� �������� ����, ���� �� �����. ���� ��� (� ��� ����� ���
     //   tvMain.FocusedNode=nil), ������� ������� �������
    procedure EmbedControl;
     // ������� ����������� ��������
    procedure EmbeddedControlChange(Sender: TObject);
    procedure EmbeddedControlKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EmbeddedFontButtonClick(Sender: TObject);
     // IPhoaSettingEditor
    function  GetRootSetting: TPhoaPageSetting;
    procedure SetRootSetting(Value: TPhoaPageSetting);
     // Message handlers
    procedure WMEmbedControl(var Msg: TMessage); message WM_EMBEDCONTROL;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

implementation
{$R *.dfm}

   //-------------------------------------------------------------------------------------------------------------------
   // TSettingButton - ������� TButton, ��������������� ������� �������
   //-------------------------------------------------------------------------------------------------------------------

type
  TSettingButton = class(TButton)
  private
    procedure WMGetDlgCode(var Msg: TWMGetDlgCode); message WM_GETDLGCODE;
  end;

  procedure TSettingButton.WMGetDlgCode(var Msg: TWMGetDlgCode);
  begin
    Msg.Result := DLGC_WANTARROWS;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // TfrDefSettingEditor
   //-------------------------------------------------------------------------------------------------------------------

  constructor TfrDefSettingEditor.Create(AOwner: TComponent);
  begin
    inherited Create(AOwner);
    ApplyTreeSettings(tvMain);
     // ������ ���� tvMain ����� ������� ��������� �� TPhoaSetting
    tvMain.NodeDataSize := SizeOf(Pointer);
  end;

  destructor TfrDefSettingEditor.Destroy;
  begin
    FEditorControl.Free;
    inherited Destroy;
  end;

  procedure TfrDefSettingEditor.EmbedControl;
  var
    Setting: TPhoaSetting;
    bBlurred: Boolean;
    CurNode: PVirtualNode;

     // ������ � ����������� � FEditorControl Control ��������� ������ � �������� ��������� �������� ���������
    procedure NewControl(CtlClass: TWinControlClass);

      procedure BindKeyEvent(const sPropName: String; Event: TKeyEvent);
      begin
        SetMethodProp(FEditorControl, sPropName, TMethod(Event));
      end;

      procedure BindNotifyEvent(const sPropName: String; Event: TNotifyEvent);
      begin
        SetMethodProp(FEditorControl, sPropName, TMethod(Event));
      end;

    begin
       // ������ �������, ���� ��� ��� ���, ��� �� ������� ������
      if (FEditorControl=nil) or (FEditorControl.ClassType<>CtlClass) then begin
        FreeAndNil(FEditorControl);
        FEditorControl := CtlClass.Create(Self);
        FEditorControl.Parent := tvMain;
      end;
       // ����������� ������
      FEditorControl.BoundsRect := tvMain.GetDisplayRect(CurNode, 1, False);
       // Tag ������ ��������� �� ��������������� ����
      FEditorControl.Tag := Integer(CurNode);
       // ����������� �������
      BindNotifyEvent('OnEnter',   EmbedControlNotify);
      BindNotifyEvent('OnExit',    EmbedControlNotify);
      BindKeyEvent   ('OnKeyDown', EmbeddedControlKeyDown);
    end;

     // ������ � ���������� TComboBox � �������� ��������� �������� ���������
    procedure NewComboBox;
    var i: Integer;
    begin
      NewControl(TComboBox);
      with TComboBox(FEditorControl) do begin
         // �������� ������ ���������
        Items.Clear;
        for i := 0 to Setting.Variants.Count-1 do Items.AddObject(DecodeSettingText(Setting.Variants[i]), Setting.Variants.Objects[i]);
         // ������ �����
        DropDownCount := 16;
        Style         := csDropDownList;
        ItemIndex     := Setting.VariantIndex;
        OnChange      := EmbeddedControlChange;
      end;
    end;

     // ������ � ���������� TColorBox � �������� ��������� �������� ���������
    procedure NewColorBox;
    begin
      NewControl(TColorBox);
      with TColorBox(FEditorControl) do begin
        DropDownCount := 16;
        Style         := [cbStandardColors, cbExtendedColors, cbSystemColors, cbCustomColor, cbPrettyNames];
        Selected      := Setting.ValueInt;
        OnChange      := EmbeddedControlChange;
      end;
    end;

     // ������ � ���������� TEdit � �������� ��������� �������� ���������
    procedure NewEdit(iMaxLen: Integer);
    begin
      NewControl(TEdit);
      with TEdit(FEditorControl) do begin
        MaxLength := iMaxLen;
        Text      := IntToStr(Setting.ValueInt);
        OnChange  := EmbeddedControlChange;
      end;
    end;

     // ������ � ���������� TSettingButton � �������� ��������� ������
    procedure NewFontButton;
    begin
      NewControl(TSettingButton);
      with TSettingButton(FEditorControl) do begin
        Caption   := GetFirstWord(Setting.ValueStr, '/');
        OnClick   := EmbeddedFontButtonClick;
      end;
    end;

  begin
     // ���������� ���� ������������� ������/���������
    bBlurred := (ActiveControl<>tvMain) and (ActiveControl<>FEditorControl);
     // ��������� ������������� [����]�������� ��������
    CurNode := tvMain.FocusedNode;
    if (FEditorControl=nil) or bBlurred or (CurNode<>PVirtualNode(FEditorControl.Tag)) then begin
      FEmbeddingControl := True;
      try
         // ���� ����� ���������� �������
        if (CurNode=nil) or bBlurred then
          FreeAndNil(FEditorControl)
         // ����� - ������
        else begin
           // �������� ����� �������� �� ������ ����
          Setting := PPhoaSetting(tvMain.GetNodeData(CurNode))^;
           // ������ ��� ���������� �������
          case Setting.Datatype of
            sdtComboIdx,
              sdtComboObj: NewComboBox;
            sdtColor:      NewColorBox;
            sdtInt:        NewEdit(Length(IntToStr(Setting.MaxValue)));
            sdtFont:       NewFontButton;
            else           FreeAndNil(FEditorControl);
          end;
        end;
      finally
        FEmbeddingControl := False;
      end;
    end;
     // ���������� �������
    if (FEditorControl<>nil) and not FEditorControl.Focused then FEditorControl.SetFocus;
  end;

  procedure TfrDefSettingEditor.EmbedControlNotify(Sender: TObject);
  begin
    if not FEmbeddingControl then PostMessage(Handle, WM_EMBEDCONTROL, 0, 0);
  end;

  procedure TfrDefSettingEditor.EmbeddedControlChange(Sender: TObject);
  var
    Node: PVirtualNode;
    Setting: TPhoaSetting;
  begin
    if FEmbeddingControl then Exit;
     // Tag �������� - ��� ������ �� ��� ����
    Node := PVirtualNode(FEditorControl.Tag);
     // �������� ����� �������� �� ������ ����
    Setting := PPhoaSetting(tvMain.GetNodeData(Node))^;
    case Setting.Datatype of
      sdtComboIdx,
        sdtComboObj: Setting.VariantIndex := (FEditorControl as TComboBox).ItemIndex;
      sdtColor:      Setting.ValueInt     := (FEditorControl as TColorBox).Selected;
      sdtInt:        Setting.ValueInt     := StrToIntDef((FEditorControl as TEdit).Text, Setting.ValueInt);
    end;
    Modified := True;
  end;

  procedure TfrDefSettingEditor.EmbeddedControlKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  begin
    if (Shift*[ssShift, ssCtrl, ssAlt]=[]) and (not (Sender is TCustomComboBox) or not TCustomComboBox(Sender).DroppedDown) then
      case Key of
        VK_UP, VK_DOWN: begin
          tvMain.Perform(WM_KEYDOWN, Key, 0);
          tvMain.SetFocus;
          Key := 0;
        end;
      end;
  end;

  procedure TfrDefSettingEditor.EmbeddedFontButtonClick(Sender: TObject);
  var Setting: TPhoaSetting;
  begin
     // Tag �������� - ��� ������ �� ��� ����. �������� ����� �������� �� ������ ����
    Setting := PPhoaSetting(tvMain.GetNodeData(PVirtualNode(FEditorControl.Tag)))^;
    with TFontDialog.Create(Self) do
      try
        FontFromStr(Font, Setting.ValueStr);
        if Execute then begin
          Setting.ValueStr := FontToStr(Font);
          (FEditorControl as TSettingButton).Caption := Font.Name;
          Modified := True;
        end;
      finally
        Free;
      end;
  end;

  function TfrDefSettingEditor.GetRootSetting: TPhoaPageSetting;
  begin
    Result := FRootSetting;
  end;

  procedure TfrDefSettingEditor.LoadTree;
  var i: Integer;
  begin
     // ��������� ������
    with tvMain do begin
      BeginUpdate;
      try
         // ������� ��� ����
        Clear;
         // ������������� ���������� ������� � �������� ��������
        RootNodeCount := PageSetting.ChildCount;
         // �������������� ��� ����
        ReinitChildren(nil, True);
         // �������� ������ ����
        FocusedNode := GetFirst;
        Selected[FocusedNode] := True;
      finally
        EndUpdate;
      end;
      if Self.Visible then SetFocus;
    end;
  end;

  procedure TfrDefSettingEditor.SetRootSetting(Value: TPhoaPageSetting);
  begin
    if FRootSetting<>Value then begin
      FRootSetting := Value;
      ReloadTree;
    end;
  end;

  procedure TfrDefSettingEditor.tvMainAfterCellPaint(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; CellRect: TRect);
  var Setting: TPhoaSetting;
  begin
    if Column=1 then begin
       // �������� �����
      Setting := PPhoaSetting(Sender.GetNodeData(Node))^;
       // ���� ��� "����", ������ ��������� ���������������� �����
      if Setting.Datatype=sdtColor then
        with TargetCanvas do begin
          Pen.Color   := clBlack;
          Brush.Color := Setting.ValueInt;
          Rectangle(CellRect.Left+2, (CellRect.Top+CellRect.Bottom-14) div 2, CellRect.Left+16, (CellRect.Top+CellRect.Bottom+14) div 2);
        end;
    end;
  end;

  procedure TfrDefSettingEditor.tvMainChecked(Sender: TBaseVirtualTree; Node: PVirtualNode);
  var Setting: TPhoaSetting;
  begin
    Setting := PPhoaSetting(Sender.GetNodeData(Node))^;
    case Setting.Datatype of
      sdtBool: begin
        Setting.ValueBool := not Setting.ValueBool;
        Modified := True;
      end;
      sdtParMsk: begin
        with PPhoaSetting(Sender.GetNodeData(Node.Parent))^ do ValueInt := ValueInt xor (Integer(1) shl Node.Index);
        Modified := True;
      end;
      sdtMutex: begin
        PPhoaSetting(Sender.GetNodeData(Node.Parent))^.ValueInt := Node.Index;
        Modified := True;
      end;
      sdtMutexInt: begin
        PPhoaSetting(Sender.GetNodeData(Node.Parent))^.ValueInt := Setting.ValueInt;
        Modified := True;
      end;
    end;
  end;

  procedure TfrDefSettingEditor.tvMainFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
  begin
    PostMessage(Handle, WM_EMBEDCONTROL, 0, 0);
  end;

  procedure TfrDefSettingEditor.tvMainGetCellIsEmpty(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; var IsEmpty: Boolean);
  begin
     // ������ �������� �� ������, ���� ��������� ������������� ����������
    if Column=1 then IsEmpty := not (PPhoaSetting(Sender.GetNodeData(Node))^.Datatype in EditableSettingDatatypes);
  end;

  procedure TfrDefSettingEditor.tvMainGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString);
  var
    s: String;
    Setting: TPhoaSetting;
  begin
    s := '';
    Setting := PPhoaSetting(Sender.GetNodeData(Node))^;
    case Column of
      0: s := DecodeSettingText(Setting.Name);
      1:
        case Setting.Datatype of
          sdtComboIdx,
            sdtComboObj: s := DecodeSettingText(Setting.VariantText);
          sdtInt:        s := IntToStr(Setting.ValueInt);
          sdtFont:       s := GetFirstWord(Setting.ValueStr, '/');
        end;
    end;
    CellText := AnsiToUnicodeCP(s, cMainCodePage);
  end;

  procedure TfrDefSettingEditor.tvMainInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
  var
    ParentItem, Setting: TPhoaSetting;
    bChecked: Boolean;
  begin
     // ���� ������������ ����
    if ParentNode=nil then ParentItem := FCurSetting else ParentItem := PPhoaSetting(Sender.GetNodeData(ParentNode))^;
     // ��������� ����� � Node.Data
    Setting := ParentItem[Node.Index];
    PPhoaSetting(Sender.GetNodeData(Node))^ := Setting;
     // ����������� CheckType � CheckState
    bChecked := False;
    case Setting.Datatype of
       // ������
      sdtBool:  begin
        Node.CheckType := ctCheckBox;
        bChecked := Setting.ValueBool;
      end;
       // ��� � ����� ��������
      sdtParMsk: begin
        Node.CheckType := ctCheckBox;
        bChecked := ParentItem.ValueInt and (Integer(1) shl Node.Index)<>0;
      end;
       // RadioButton, ��� (�������� ��������)=(������ ������)
      sdtMutex: begin
        Node.CheckType := ctRadioButton;
        bChecked := ParentItem.ValueInt=Integer(Node.Index);
      end;
       // RadioButton, ��� (�������� ��������)=(�������� ���������� ������)
      sdtMutexInt: begin
        Node.CheckType := ctRadioButton;
        bChecked := ParentItem.ValueInt=Setting.ValueInt;
      end;
    end;
    Node.CheckState := aCheckStates[bChecked];
     // �������������� �-�� �����
    tvMain.ChildCount[Node] := Setting.ChildCount;
     // ������������� ��� ����
    Include(InitialStates, ivsExpanded);
  end;

  procedure TfrDefSettingEditor.tvMainPaintText(Sender: TBaseVirtualTree; const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType);
  begin
     // �������� ������ ����, ������� �����
    if Sender.ChildCount[Node]>0 then TargetCanvas.Font.Style := [fsBold];
  end;

  procedure TfrDefSettingEditor.WMEmbedControl(var Msg: TMessage);
  begin
    EmbedControl;
  end;

end.
