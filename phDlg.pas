//**********************************************************************************************************************
//  $Id: phDlg.pas,v 1.14 2004-10-14 08:11:09 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Copyright 2002-2004 DK Software, http://www.dk-soft.org/
//**********************************************************************************************************************
unit phDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, DKLang;

type
  TPhoaDialog = class(TForm)
    pButtonsBottom: TPanel;
    bCancel: TButton;
    bOK: TButton;
    bHelp: TButton;
    bvBottom: TBevel;
     // ���������� ������� ��� ������������ ������� TNotifyEvent, ���������� ������ �������
    procedure DlgDataChange(Sender: TObject);
    procedure bOKClick(Sender: TObject);
    procedure bCancelClick(Sender: TObject);
    procedure bHelpClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    FLockCounter: Integer;
     // Prop storage
    FHasUpdates: Boolean;
    FModified: Boolean;
    FOKIgnoresDataValidity: Boolean;
    FOKIgnoresModified: Boolean;
     // Message handlers
    procedure WMHelp(var Msg: TWMHelp); message WM_HELP;
     // Prop handlers
    procedure SetHasUpdates(Value: Boolean);
    procedure SetModified(Value: Boolean);
    procedure SetOKIgnoresModified(Value: Boolean);
    procedure SetOKIgnoresOKIgnoresDataValidity(Value: Boolean);
  protected
    procedure Loaded; override;
     // �������������/����������� �������
    procedure InitializeDialog; virtual;
    procedure FinalizeDialog; virtual;
     // ������� ������� ������ �������
    procedure ButtonClick_OK; virtual;
    procedure ButtonClick_Cancel; virtual;
    procedure ButtonClick_Help; virtual;
     // ������ ������ ����� ����������� �������. ���������� �������� �� InitializeDialog, ����� ��������� �������� ���
     //   ������������� Large Fonts (���� �������� ��� �������� �������)
    procedure MakeSizeable;
     // Prop handler. � ������� ������ ������ ���������� True
    function  GetDataValid: Boolean; virtual;
  public
     // ���������� ������. ���������� HasUpdates
    function  Execute: Boolean;
     // ���������/������ ���������� ��������� Modified
    procedure BeginUpdate;
    procedure EndUpdate;
     // ����������� ������������� � ��� ������
    procedure UpdateButtons; virtual;
     // Props
     // -- ���� True, ������ � ������� ���������
    property DataValid: Boolean read GetDataValid;
     // -- True, ���� ������ ������� �����-�� ���������
    property HasUpdates: Boolean read FHasUpdates write SetHasUpdates;
     // -- True, ���� � ������� ������������ ������� �����-�� ������
    property Modified: Boolean read FModified write SetModified;
     // -- ���� True, ������������� ������ �� �� ������� �� DataValid
    property OKIgnoresDataValidity: Boolean read FOKIgnoresDataValidity write SetOKIgnoresOKIgnoresDataValidity;
     // -- ���� True, ������������� ������ �� �� ������� �� Modified
    property OKIgnoresModified: Boolean read FOKIgnoresModified write SetOKIgnoresModified;
  end;

implementation
{$R *.dfm}
uses phUtils, ChmHlp, ConsVars, phSettings, phObj, phGUIObj;

   //===================================================================================================================
   // TPhoaDialog
   //===================================================================================================================

  procedure TPhoaDialog.bCancelClick(Sender: TObject);
  begin
    ButtonClick_Cancel;
  end;

  procedure TPhoaDialog.BeginUpdate;
  begin
    Inc(FLockCounter);
  end;

  procedure TPhoaDialog.bHelpClick(Sender: TObject);
  begin
    ButtonClick_Help;
  end;

  procedure TPhoaDialog.bOKClick(Sender: TObject);
  begin
    ButtonClick_OK;
  end;

  procedure TPhoaDialog.ButtonClick_Cancel;
  begin
    ModalResult := mrCancel;
  end;

  procedure TPhoaDialog.ButtonClick_Help;
  begin
    HtmlHelpContext(HelpContext);
  end;

  procedure TPhoaDialog.ButtonClick_OK;
  begin
    HasUpdates := True;
    ModalResult := mrOK;
  end;

  procedure TPhoaDialog.DlgDataChange(Sender: TObject);
  begin
    Modified := True;
  end;

  procedure TPhoaDialog.EndUpdate;
  begin
    if FLockCounter>0 then Dec(FLockCounter);
    if FLockCounter=0 then UpdateButtons;
  end;

  function TPhoaDialog.Execute: Boolean;
  begin
     // �������������� ������
    BeginUpdate;
    try
      InitializeDialog;
    finally
      EndUpdate;
    end;
     // ����� ������
    try
      ShowModal;
    finally
       // ������������ ������
      FinalizeDialog;
    end;
    Result := HasUpdates;
  end;

  procedure TPhoaDialog.FinalizeDialog;
  begin
    { does nothing }
  end;

  procedure TPhoaDialog.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  begin
     // ������������� ������� Ctrl+Enter � ������������ ��� ��� ������� �� ��
    if (Key=VK_RETURN) and (Shift=[ssCtrl]) and DataValid then begin
      Key := 0;
      ButtonClick_OK;
    end;
  end;

  function TPhoaDialog.GetDataValid: Boolean;
  begin
    Result := True;
  end;

  procedure TPhoaDialog.InitializeDialog;
  begin
     // ����������� �����
    FontFromStr(Font, SettingValueStr(ISettingID_Gen_MainFont));
  end;           

  procedure TPhoaDialog.Loaded;
  begin
    inherited Loaded;
    AutoScroll := False;
  end;

  procedure TPhoaDialog.MakeSizeable;
  begin
     // ������ sizeable
    BorderStyle := bsSizeable;
    AutoScroll := False;
     // ������������ ������� ������� � �������� �����������
    Constraints.MinWidth  := Width;
    Constraints.MinHeight := Height;
     // ������ size gripper
    TSizeGripper.Create(Self).Parent := pButtonsBottom;
  end;

  procedure TPhoaDialog.SetHasUpdates(Value: Boolean);
  begin
    FHasUpdates := Value;
    UpdateButtons;
  end;

  procedure TPhoaDialog.SetModified(Value: Boolean);
  begin
    if FLockCounter>0 then Exit;
    FModified := Value;
    UpdateButtons;
  end;

  procedure TPhoaDialog.SetOKIgnoresModified(Value: Boolean);
  begin
    if FOKIgnoresModified<>Value then begin
      FOKIgnoresModified := Value;
      UpdateButtons;
    end;
  end;

  procedure TPhoaDialog.SetOKIgnoresOKIgnoresDataValidity(Value: Boolean);
  begin
    if FOKIgnoresDataValidity<>Value then begin
      FOKIgnoresDataValidity := Value;
      UpdateButtons;
    end;
  end;

  procedure TPhoaDialog.UpdateButtons;
  begin
    if FLockCounter>0 then Exit;
    bOK.Enabled := (OKIgnoresModified or Modified) and (OKIgnoresDataValidity or DataValid);
    bCancel.Caption := ConstVal(iif(HasUpdates, 'SBtn_Close', 'SBtn_Cancel'));
  end;

  procedure TPhoaDialog.WMHelp(var Msg: TWMHelp);
  begin
    HtmlHelpContext(HelpContext);
  end;

end.

