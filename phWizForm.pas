//**********************************************************************************************************************
//  $Id: phWizForm.pas,v 1.15 2005-05-15 09:03:08 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Copyright DK Software, http://www.dk-soft.org/
//**********************************************************************************************************************
unit phWizForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, ConsVars, phObj, phWizard, Registry,
  StdCtrls, ExtCtrls, DKLang, phFrm;

type
  TPhoaWizardForm = class(TPhoaForm, IWizardHostForm)
    bBack: TButton;
    bCancel: TButton;
    bHelp: TButton;
    bNext: TButton;
    bvBottom: TBevel;
    bvTopPanel: TBevel;
    iIcon: TImage;
    lHeading: TLabel;
    pButtons: TPanel;
    pHeader: TPanel;
    pMain: TPanel;
    procedure bBackClick(Sender: TObject);
    procedure bCancelClick(Sender: TObject);
    procedure bHelpClick(Sender: TObject);
    procedure bNextClick(Sender: TObject);
  private
     // ���������� �������
    FController: TWizardController;
     // IWizardHostForm
    function  IWizardHostForm.PageChanging   = PageChanging;
    procedure IWizardHostForm.PageChanged    = PageChanged;
    procedure IWizardHostForm.StateChanged   = StateChanged;
    function  IWizardHostForm.GetHostControl = WizHost_GetHostControl;
    function  IWizardHostForm.GetNextPageID  = GetNextPageID;
    function  IWizardHostForm.GetStorageForm = WizHost_GetStorageForm;
    function  WizHost_GetHostControl: TWinControl;
    function  WizHost_GetStorageForm: TPhoaForm;
     // Prop handlers
    function  GetCurPage: TWizardPage;
    function  GetCurPageID: Integer;
  protected
    function  GetRelativeRegistryKey: String; override; abstract;
    function  GetSizeable: Boolean; override;
    procedure DoCreate; override;
    procedure DoDestroy; override;
    procedure DoShow; override;
    procedure UpdateState; override;
     // �������, ������������ ������������� ��������������� ������
    function  IsBtnBackEnabled:   Boolean; virtual;
    function  IsBtnNextEnabled:   Boolean; virtual;
    function  IsBtnCancelEnabled: Boolean; virtual;
     // ��������� ������� �� ������� ������
    procedure ButtonClick_Back; virtual;
    procedure ButtonClick_Next; virtual;
    procedure ButtonClick_Cancel; virtual;
     // ������ ���������� ID ������ ������������ ��������
    function  GetStartPageID: Integer; virtual; abstract; 
     // ������ ���������� ID ��������� ��������, ��� 0, ���� ��� �����
    function  GetNextPageID: Integer; virtual; abstract;
     // ���������� ����� ������ ��������. ������ ������� True, ����� ��������� �����. � ������� ������ ������ ����������
     //   True
    function  PageChanging(ChangeMethod: TPageChangeMethod; var iNewPageID: Integer): Boolean; virtual;
     // ���������� ����� ����� ��������. � ������� ������ �� ������ ������
    procedure PageChanged(ChangeMethod: TPageChangeMethod; iPrevPageID: Integer); virtual;
  public
     // Props
     // -- ���������� �������
    property Controller: TWizardController read FController;
     // -- ������� ������������ �������� (nil, ���� ���)
    property CurPage: TWizardPage read GetCurPage;
     // -- ID ������� ������������ �������� (0, ���� ���)
    property CurPageID: Integer read GetCurPageID;
  end;

implementation
{$R *.dfm}
uses phUtils, ChmHlp, phSettings, phGUIObj;

   //===================================================================================================================
   // TdFileOpsWizard
   //===================================================================================================================

  procedure TPhoaWizardForm.bBackClick(Sender: TObject);
  begin
    ButtonClick_Back;
  end;

  procedure TPhoaWizardForm.bCancelClick(Sender: TObject);
  begin
    ButtonClick_Cancel;
  end;

  procedure TPhoaWizardForm.bHelpClick(Sender: TObject);
  begin
    HtmlHelpContext(HelpContext);
  end;

  procedure TPhoaWizardForm.bNextClick(Sender: TObject);
  begin
    ButtonClick_Next;
  end;

  procedure TPhoaWizardForm.ButtonClick_Back;
  begin
    FController.SetPrevPageFromHistory;
  end;

  procedure TPhoaWizardForm.ButtonClick_Cancel;
  begin
    ModalResult := mrCancel;
  end;

  procedure TPhoaWizardForm.ButtonClick_Next;
  begin
    FController.SetNextPage;
  end;

  procedure TPhoaWizardForm.DoCreate;
  begin
    inherited DoCreate;
     // ������ size gripper
    TSizeGripper.Create(Self).Parent := pButtons;
     // ��������� ������
    iIcon.Picture.Icon.Handle := LoadIcon(HInstance, 'MAINICON');
     // ������ � ����������� ����������
    FController := TWizardController.Create(Self);
  end;

  procedure TPhoaWizardForm.DoDestroy;
  begin
    FController.Free;
    inherited DoDestroy;
  end;

  procedure TPhoaWizardForm.DoShow;
  begin
    inherited DoShow;
     // ���������� ������ ��������
    FController.SetVisiblePageID(GetStartPageID, pcmForced);
  end;

  function TPhoaWizardForm.GetCurPage: TWizardPage;
  begin
    Result := FController.VisiblePage;
  end;

  function TPhoaWizardForm.GetCurPageID: Integer;
  begin
    Result := FController.VisiblePageID;
  end;

  function TPhoaWizardForm.GetSizeable: Boolean;
  begin
     // ��� ������� �� ��������� sizeable
    Result := True;
  end;

  function TPhoaWizardForm.IsBtnBackEnabled: Boolean;
  begin
    Result := not FController.HistoryEmpty;
  end;

  function TPhoaWizardForm.IsBtnCancelEnabled: Boolean;
  begin
    Result := True;
  end;

  function TPhoaWizardForm.IsBtnNextEnabled: Boolean;
  begin
    Result := (CurPage<>nil) and CurPage.DataValid and (GetNextPageID>0);
  end;

  procedure TPhoaWizardForm.PageChanged(ChangeMethod: TPageChangeMethod; iPrevPageID: Integer);
  begin
    { does nothing }
  end;

  function TPhoaWizardForm.PageChanging(ChangeMethod: TPageChangeMethod; var iNewPageID: Integer): Boolean;
  begin
    Result := True;
  end;

  procedure TPhoaWizardForm.UpdateState;
  begin
    inherited UpdateState;
     // ����������� ������
    bBack.Enabled   := IsBtnBackEnabled;
    bNext.Enabled   := IsBtnNextEnabled;
    bNext.Default   := bNext.Enabled;
    bCancel.Enabled := IsBtnCancelEnabled;
    bCancel.Caption := ConstVal(iif(HasUpdates, 'SBtn_Close', 'SBtn_Cancel'));
    bCancel.Default := not bNext.Default and bCancel.Enabled;
     // ������������� heading
    if CurPage<>nil then lHeading.Caption := CurPage.PageTitle;
  end;

  function TPhoaWizardForm.WizHost_GetHostControl: TWinControl;
  begin
    Result := pMain;
  end;

  function TPhoaWizardForm.WizHost_GetStorageForm: TPhoaForm;
  begin
    Result := Self;
  end;

end.

