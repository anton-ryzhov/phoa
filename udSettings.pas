//**********************************************************************************************************************
//  $Id: udSettings.pas,v 1.6 2004-04-19 13:25:50 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Copyright 2002-2004 Dmitry Kann, http://phoa.narod.ru
//**********************************************************************************************************************
unit udSettings;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, GR32, Controls, Forms, Dialogs, ConsVars, phSettings,
  phDlg, VirtualTrees, TB2Dock, TB2Toolbar, TBX, DTLangTools, StdCtrls,
  ExtCtrls;

const
  WM_EMBEDCONTROL = WM_USER+1;

type
  TdSettings = class(TPhoaDialog)
    pMain: TPanel;
    dkNav: TTBXDock;
    tbNav: TTBXToolbar;
    tvMain: TVirtualStringTree;
  private
     // ��������� ����� ��������
    FLocalRootSetting: TPhoaSetting;
     // ����, ���������������� ������� ������� NavBar-������
    FCurSetting: TPhoaPageSetting;
     // ������ ������ ����������, ������� ������� ������� �� ��������
    FDefNavBtnIndex: Integer;
     // ������� ��� �������������� �������� �������� ����
    FEditorControl: TWinControl;
     // ���� ����������� ��������-���������. ������������ ��� �������������� ������� EmbeddedControlChange �� ����� ���
     //   ��������� ���������, � ����� ��� ������������� ������ ������ �������
    FEmbeddingControl: Boolean;
     // ������ �����t� ��������� (������� 0 �� ConsVars.aPhoaSettings[])
    procedure CreateNavBar;
     // ������� ������� NavBar-������
    procedure NavBarButtonClick(Sender: TObject);
     // �������� ��������� PageSetting � �������� ������� �������������
    procedure SelectCurSetting(PageSetting: TPhoaPageSetting);
     // ���������� ������ ������ ��������� �������� (���� ���������, �� � �������������� ��������)
    function  DecodeSettingText(const sText: String): String;
  protected
    procedure InitializeDialog; override;
    procedure FinalizeDialog; override;
    procedure ButtonClick_OK; override;
  end;

   // ���������� ������ ��������. iBtnIndex - ������ ������ ����������, ������� ������� ������� �� ��������
  function EditSettings(iBtnIndex: Integer): Boolean;

implementation
{$R *.dfm}
uses phUtils, Main, TypInfo;

  function EditSettings(iBtnIndex: Integer): Boolean;
  begin
    with TdSettings.Create(Application) do
      try
        FDefNavBtnIndex := iBtnIndex;
        Result := Execute;
      finally
        Free;
      end;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // TdSettings
   //-------------------------------------------------------------------------------------------------------------------

  procedure TdSettings.ButtonClick_OK;
  begin
     // �������� ��������� ��������� � ����������
    RootSetting.Assign(FLocalRootSetting);
    inherited ButtonClick_OK;
  end;

  procedure TdSettings.CreateNavBar;
  var
    i: Integer;
    tbi: TTBXCustomItem;
    PPS: TPhoaPageSetting;
  begin
    for i := 0 to FLocalRootSetting.ChildCount-1 do begin
      PPS := FLocalRootSetting.Children[i] as TPhoaPageSetting;
      tbi := TTBXItem.Create(Self);
      tbi.Caption     := DecodeSettingText(PPS.Name);
      tbi.HelpContext := PPS.HelpContext;
      tbi.ImageIndex  := PPS.ImageIndex;
      tbi.Tag         := Integer(PPS);
      tbi.OnClick     := NavBarButtonClick;
      if i<9 then tbi.ShortCut := 16433+i; // Ctrl+1..9 keys
      tbNav.Items.Add(tbi);
    end;
  end;

  function TdSettings.DecodeSettingText(const sText: String): String;
  begin
    Result := sText;
    if Result<>'' then
      case Result[1] of
         // ���� ������������ ���������� �� '@' - ��� ��������� �� TdSettings.dtlsMain
        '@': Result := dtlsMain.Consts[Copy(Result, 2, MaxInt)];
         // ���� ������������ ���������� �� '#' - ��� ��������� �� fMain.dtlsMain
        '#': Result := ConstVal(Copy(Result, 2, MaxInt));
      end;
  end;

  procedure TdSettings.FinalizeDialog;
  begin
    FLocalRootSetting.Free;
    inherited FinalizeDialog;
  end;

  procedure TdSettings.InitializeDialog;
  begin
    inherited InitializeDialog;
     // �������� ���������
    FLocalRootSetting := TPhoaSetting.Create(nil, sdtStatic, 0, '');
    FLocalRootSetting.Assign(RootSetting);
     // ������ ������ ���������
    CreateNavBar;
     // �������� ��������� ������
    LoadSettingTree(FLocalRootSetting[FDefNavBtnIndex] as TPhoaPageSetting);
  end;

  procedure TdSettings.NavBarButtonClick(Sender: TObject);
  begin
    SelectCurSetting(TPhoaPageSetting(TComponent(Sender).Tag));
  end;

  procedure TdSettings.SelectCurSetting(PageSetting: TPhoaPageSetting);
  begin
    FCurSetting := PageSetting;
     // �������� �����. ������
    for i := 0 to tbNav.Items.Count-1 do
      with tbNav.Items[i] do Checked := Tag=Integer(PageSetting);
     // ����������� HelpContext
    HelpContext := PageSetting.HelpContext;
     // ��������� ��������
    //!!!
  end;

end.
