//**********************************************************************************************************************
//  $Id: ufrWzPageFileOps_SelTask.pas,v 1.8 2005-05-15 09:03:08 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Copyright DK Software, http://www.dk-soft.org/
//**********************************************************************************************************************
unit ufrWzPageFileOps_SelTask;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, ConsVars,
  Dialogs, phWizard, StdCtrls, DKLang;

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
    dklcMain: TDKLanguageController;
  private
     // ������ ������������ ����������� ����� ��������
    FKindRadioButtons: Array[TFileOperationKind] of TRadioButton;
  protected
    function  GetDataValid: Boolean; override;
    function  NextPage: Boolean; override;
    procedure BeforeDisplay(ChangeMethod: TPageChangeMethod); override;
    procedure DoCreate; override;
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

  procedure TfrWzPageFileOps_SelTask.DoCreate;
  var fok: TFileOperationKind;
  begin
    inherited DoCreate;
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

