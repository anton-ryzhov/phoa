unit ufrWzPageFileOps_DelOptions;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, ConsVars,
  Dialogs, phWizard, StdCtrls, ExtCtrls, Mask, DTLangTools;

type
  TfrWzPageFileOps_DelOptions = class(TWizardPage)
    cbDeleteToRecycleBin: TCheckBox;
    dtlsMain: TDTLanguageSwitcher;
  protected
    procedure BeforeDisplay(ChangeMethod: TPageChangeMethod); override;
    function  NextPage: Boolean; override;
  end;

implementation
{$R *.dfm}
uses phUtils, udFileOpsWizard;

  procedure TfrWzPageFileOps_DelOptions.BeforeDisplay(ChangeMethod: TPageChangeMethod);
  begin
    inherited BeforeDisplay(ChangeMethod);
     // ����������� �����
    cbDeleteToRecycleBin.Checked := TdFileOpsWizard(StorageForm).DelFile_DeleteToRecycleBin;
  end;

  function TfrWzPageFileOps_DelOptions.NextPage: Boolean;
  begin
    Result := inherited NextPage;
    if Result then begin
       // ��������� �����
      TdFileOpsWizard(StorageForm).DelFile_DeleteToRecycleBin := cbDeleteToRecycleBin.Checked;
    end;
  end;

end.
