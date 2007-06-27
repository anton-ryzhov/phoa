//**********************************************************************************************************************
//  $Id: phDlg.pas,v 1.22 2007-06-27 18:29:10 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Copyright DK Software, http://www.dk-soft.org/
//**********************************************************************************************************************
unit phDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, Registry,
  StdCtrls, ExtCtrls, phFrm;

type
  TPhoaDialog = class(TPhoaForm)
    pButtonsBottom: TPanel;
    bCancel: TButton;
    bOK: TButton;
    bHelp: TButton;
    bvBottom: TBevel;
     // ���������� ������� ��� ������������ ������� TNotifyEvent, ���������� ������ �������
    procedure bCancelClick(Sender: TObject);
    procedure bHelpClick(Sender: TObject);
    procedure bOKClick(Sender: TObject);
    procedure DlgDataChange(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
     // Prop storage
    FIgnoreModified: Boolean;
    FIgnoreDataValidity: Boolean;
  protected
    procedure DoCreate; override;
     // ������� ������� ������ �������
    procedure ButtonClick_OK; virtual;
    procedure ButtonClick_Cancel; virtual;
    procedure ButtonClick_Help; virtual;
     // ���������� ��� ��������� ������� �������. � ������� ������ ����������� ������������� � ��� ������
    procedure UpdateState; override;
  public
     // ���������� (�� �����) ����� ���������� �����������, �������� �������������� ��������
    function  ExecuteModal(bIgnoreDataValidity, bIgnoreModified: Boolean): Boolean;
     // Props
     // -- ���� True, ������������� ������ �� �� ������� �� DataValid
    property IgnoreDataValidity: Boolean read FIgnoreDataValidity;
     // -- ���� True, ������������� ������ �� �� ������� �� Modified
    property IgnoreModified: Boolean read FIgnoreModified;
  end;

implementation
{$R *.dfm}
uses DKLang, phChmHlp, phUtils, ConsVars, phObj, phGUIObj;

   //===================================================================================================================
   // TPhoaDialog
   //===================================================================================================================

  procedure TPhoaDialog.bCancelClick(Sender: TObject);
  begin
    ButtonClick_Cancel;
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

  procedure TPhoaDialog.DoCreate;
  begin
    inherited DoCreate;
     // ������ size gripper
    if Sizeable then TSizeGripper.Create(Self).Parent := pButtonsBottom;
  end;

  function TPhoaDialog.ExecuteModal(bIgnoreDataValidity, bIgnoreModified: Boolean): Boolean;
  begin
    FIgnoreDataValidity := bIgnoreDataValidity;
    FIgnoreModified     := bIgnoreModified;
    Result := inherited ExecuteModal;
  end;

  procedure TPhoaDialog.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  begin
     // ������������� ������� Ctrl+Enter � ������������ ��� ��� ������� �� ��
    if (Key=VK_RETURN) and (Shift=[ssCtrl]) and DataValid then begin
      Key := 0;
      ButtonClick_OK;
    end;
  end;

  procedure TPhoaDialog.UpdateState;
  begin
    bOK.Enabled := (IgnoreModified or Modified) and (IgnoreDataValidity or DataValid);
    bCancel.Caption := DKLangConstW(iif(HasUpdates, 'SBtn_Close', 'SBtn_Cancel'));
  end;

end.


