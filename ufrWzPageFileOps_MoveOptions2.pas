unit ufrWzPageFileOps_MoveOptions2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ConsVars,
  phWizard, DTLangTools, StdCtrls;

type
  TfrWzPageFileOps_MoveOptions2 = class(TWizardPage)
    lNoOriginalFileMode: TLabel;
    cbNoOriginalFileMode: TComboBox;
    cbDeleteOriginal: TCheckBox;
    cbDeleteToRecycleBin: TCheckBox;
    dtlsMain: TDTLanguageSwitcher;
    cbUseCDOptions: TCheckBox;
    lOverwriteMode: TLabel;
    cbOverwriteMode: TComboBox;
    procedure AdjustOptionsNotify(Sender: TObject);
  private
     // ����������� [���������] �������� �����
    procedure AdjustOptionControls;
  protected
    procedure BeforeDisplay(ChangeMethod: TPageChangeMethod); override;
    function  NextPage: Boolean; override;
  end;

implementation
{$R *.dfm}
uses phUtils, udFileOpsWizard;

  procedure TfrWzPageFileOps_MoveOptions2.AdjustOptionControls;
  begin
    cbDeleteToRecycleBin.Enabled := cbDeleteOriginal.Enabled and cbDeleteOriginal.Checked;
  end;

  procedure TfrWzPageFileOps_MoveOptions2.AdjustOptionsNotify(Sender: TObject);
  begin
    AdjustOptionControls;
    StatusChanged;
  end;

  procedure TfrWzPageFileOps_MoveOptions2.BeforeDisplay(ChangeMethod: TPageChangeMethod);
  var
    Wiz: TdFileOpsWizard;
    bMoveOp: Boolean;
  begin
    inherited BeforeDisplay(ChangeMethod);
    Wiz := TdFileOpsWizard(StorageForm);
     // ����������� �����
    cbNoOriginalFileMode.ItemIndex := Byte(Wiz.MoveFile_NoOriginalMode);
    cbDeleteOriginal.Checked       := Wiz.MoveFile_DeleteOriginal;
    cbDeleteToRecycleBin.Checked   := Wiz.MoveFile_DeleteToRecycleBin;
    cbOverwriteMode.ItemIndex      := Byte(Wiz.MoveFile_OverwriteMode);
    cbUseCDOptions.Checked         := Wiz.MoveFile_UseCDOptions;
     // �������� "��� ������, ���� ��� ��������� �����" � "������� �������� �����" �������� ������ ��� �������� �����������
    bMoveOp := Wiz.FileOpKind=fokMoveFiles;
    lNoOriginalFileMode.Enabled := bMoveOp;
    EnableWndCtl(cbNoOriginalFileMode, bMoveOp);
    cbDeleteOriginal.Enabled := bMoveOp;
    AdjustOptionControls;
  end;

  function TfrWzPageFileOps_MoveOptions2.NextPage: Boolean;
  var Wiz: TdFileOpsWizard;
  begin
    Result := inherited NextPage;
    if Result then begin
      Wiz := TdFileOpsWizard(StorageForm);
       // ��������� �����
      Wiz.MoveFile_OverwriteMode := TFileOpMoveFileOverwriteMode(cbOverwriteMode.ItemIndex);
      Wiz.MoveFile_UseCDOptions := cbUseCDOptions.Checked;
       // ���� ��� �������� - "����������� �����", ��������� ����������� ��� �� �����
      if Wiz.FileOpKind=fokMoveFiles then begin
        Wiz.MoveFile_NoOriginalMode     := TFileOpMoveFileNoOriginalMode(cbNoOriginalFileMode.ItemIndex);
        Wiz.MoveFile_DeleteOriginal     := cbDeleteOriginal.Checked;
        Wiz.MoveFile_DeleteToRecycleBin := cbDeleteToRecycleBin.Checked;
      end;
    end;
  end;

end.
