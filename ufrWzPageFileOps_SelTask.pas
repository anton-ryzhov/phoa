//**********************************************************************************************************************
//  $Id: ufrWzPageFileOps_SelTask.pas,v 1.2 2004-04-15 12:54:10 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Copyright 2002-2004 Dmitry Kann, http://phoa.narod.ru
//**********************************************************************************************************************
unit ufrWzPageFileOps_SelTask;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, ConsVars,
  Dialogs, phWizard, StdCtrls, DTLangTools;

type
  TfrWzPageFileOps_SelTask = class(TWizardPage)
    lCopyFiles: TLabel;
    rbCopyFiles: TRadioButton;
    lMoveFiles: TLabel;
    rbMoveFiles: TRadioButton;
    lDeleteFiles: TLabel;
    rbDeleteFiles: TRadioButton;
    lRepairFileLinks: TLabel;
    rbRepairFileLinks: TRadioButton;
    lNBUndoable: TLabel;
    lRebuildThumbs: TLabel;
    rbRebuildThumbs: TRadioButton;
    dtlsMain: TDTLanguageSwitcher;
  private
     // ������ ������������ ����������� ����� ��������
    FKindRadioButtons: Array[TFileOperationKind] of TRadioButton;
  protected
    function  GetDataValid: Boolean; override;
    procedure InitializePage; override;
    procedure BeforeDisplay(ChangeMethod: TPageChangeMethod); override;
    function  NextPage: Boolean; override;
  end;

implementation
{$R *.dfm}
uses phUtils, udFileOpsWizard;

  procedure TfrWzPageFileOps_SelTask.BeforeDisplay(ChangeMethod: TPageChangeMethod);
  var fok: TFileOperationKind;
  begin
    inherited BeforeDisplay(ChangeMethod);
     // ����������� ����������� �����������
    for fok := Low(fok) to High(fok) do FKindRadioButtons[fok].Checked := TdFileOpsWizard(StorageForm).FileOpKind=fok;
  end;

  function TfrWzPageFileOps_SelTask.GetDataValid: Boolean;
  var fok: TFileOperationKind;
  begin
    Result := False;
     // ����� ���� ������, ���� ������� �������� ������������
    for fok := Low(fok) to High(fok) do
      if FKindRadioButtons[fok].Checked then begin
        Result := True;
        Break;
      end;
  end;

  procedure TfrWzPageFileOps_SelTask.InitializePage;
  var fok: TFileOperationKind;
  begin
    inherited InitializePage;
     // �������������� ������ �����������
    FKindRadioButtons[fokCopyFiles]       := rbCopyFiles;
    FKindRadioButtons[fokMoveFiles]       := rbMoveFiles;
    FKindRadioButtons[fokDeleteFiles]     := rbDeleteFiles;
    FKindRadioButtons[fokRebuildThumbs]   := rbRebuildThumbs;
    FKindRadioButtons[fokRepairFileLinks] := rbRepairFileLinks;
     // �������� ����������� ������
    for fok := Low(fok) to High(fok) do
      with FKindRadioButtons[fok].Font do Style := Style+[fsBold];
     // �������� lNBUndoable ������
    with lNBUndoable.Font do Style := Style+[fsBold];
  end;

  function TfrWzPageFileOps_SelTask.NextPage: Boolean;
  var fok: TFileOperationKind;
  begin
    Result := True;
     // ��������� ����������� �����������
    for fok := Low(fok) to High(fok) do
      if FKindRadioButtons[fok].Checked then begin
        TdFileOpsWizard(StorageForm).FileOpKind := fok;
        Break;
      end;
  end;

end.
