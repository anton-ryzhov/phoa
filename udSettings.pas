//**********************************************************************************************************************
//  $Id: udSettings.pas,v 1.16 2004-09-11 17:52:36 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Copyright 2002-2004 DK Software, http://www.dk-soft.org/
//**********************************************************************************************************************
unit udSettings;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, GR32, Controls, Forms, Dialogs, ConsVars, phSettings,
  phDlg, TB2Dock, TB2Toolbar, TBX, StdCtrls, ExtCtrls,
  Placemnt, Menus, DKLang;

type
  TdSettings = class(TPhoaDialog)
    dklcMain: TDKLanguageController;
    pMain: TPanel;
    dkNav: TTBXDock;
    tbNav: TTBXToolbar;
    fpMain: TFormPlacement;
    pEditor: TPanel;
    procedure FormShow(Sender: TObject);
  private
     // ��������� ����� ��������
    FLocalRootSetting: TPhoaSetting;
     // ID ��������-���������, ������� ������� ������� �� ��������
    FDefPageSettingID: Integer;
     // Prop storage
    FCurPageSetting: TPhoaPageSetting;
     // ������� �������� ��������
    FEditor: TWinControl;
     // ������ �����t� ��������� (������� 0 �� ConsVars.aPhoaSettings[])
    procedure CreateNavBar;
     // ������� ������� NavBar-������
    procedure NavBarButtonClick(Sender: TObject);
     // ������� ��������� ������ ��������
    procedure SettingChange(Sender: TObject);
     // Prop handlers
    procedure SetCurPageSetting(Value: TPhoaPageSetting);
  protected
    procedure InitializeDialog; override;
    procedure FinalizeDialog; override;
    procedure ButtonClick_OK; override;
  public
     // Props
     // -- ������� ��������� ��������-��������� (������ �� NavBar)
    property CurPageSetting: TPhoaPageSetting read FCurPageSetting write SetCurPageSetting;
  end;

   // ���������� ������ ��������. DefPageSetting - ��������-��������� ����������, ������� ������� ������� �� ��������
  function EditSettings(DefPageSettingID: Integer): Boolean;

implementation
{$R *.dfm}
uses phUtils, Main, TypInfo;

  function EditSettings(DefPageSettingID: Integer): Boolean;
  begin
    with TdSettings.Create(Application) do
      try
        FDefPageSettingID := DefPageSettingID;
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
      if PPS.Visible then begin
        tbi := TTBXItem.Create(Self);
        tbi.Caption     := ConstValEx(PPS.Name);
        tbi.HelpContext := PPS.HelpContext;
        tbi.ImageIndex  := PPS.ImageIndex;
        tbi.Tag         := Integer(PPS);
        tbi.OnClick     := NavBarButtonClick;
        if i<9 then tbi.ShortCut := 16433+i; // Ctrl+1..9 keys
        tbNav.Items.Add(tbi);
      end;
    end;
  end;

  procedure TdSettings.FinalizeDialog;
  begin
    FLocalRootSetting.Free;
    inherited FinalizeDialog;
  end;

  procedure TdSettings.FormShow(Sender: TObject);
  begin
    ActiveControl := FEditor;
  end;

  procedure TdSettings.InitializeDialog;
  begin
    inherited InitializeDialog;
    MakeSizeable;
     // ����������� fpMain
    fpMain.IniFileName := SRegRoot;
    fpMain.IniSection  := SRegSettings_Root;
     // �������� ���������
    FLocalRootSetting := TPhoaSetting.Create(nil, 0, '');
    FLocalRootSetting.Assign(RootSetting);
     // ������ ������ ���������
    CreateNavBar;
     // �������� ��������� ������
    CurPageSetting := FLocalRootSetting.Settings[FDefPageSettingID] as TPhoaPageSetting;
  end;

  procedure TdSettings.NavBarButtonClick(Sender: TObject);
  begin
    CurPageSetting := TPhoaPageSetting(TComponent(Sender).Tag);
  end;

  procedure TdSettings.SetCurPageSetting(Value: TPhoaPageSetting);
  var
    i: Integer;
    PrevEditor: TWinControl;
  begin
    FCurPageSetting := Value;
     // �������� �����. ������
    for i := 0 to tbNav.Items.Count-1 do
      with tbNav.Items[i] do Checked := Tag=Integer(FCurPageSetting);
     // ����������� HelpContext
    HelpContext := FCurPageSetting.HelpContext;
     // ��������� ��������, ���� ����� ��������
    if (FEditor=nil) or (FEditor.ClassType<>FCurPageSetting.EditorClass) then begin
       // ���������� ������� ��������
      PrevEditor := FEditor;
      try
         // ������ �����
        FEditor := FCurPageSetting.EditorClass.Create(Self);
        (FEditor as IPhoaSettingEditor).InitAndEmbed(pEditor, SettingChange);
      finally
         // ������� ������ �������� ����� �������� ������, ����� �� ����������
        FreeAndNil(PrevEditor);
      end;
    end;
     // �������������� ��������
    (FEditor as IPhoaSettingEditor).RootSetting := FCurPageSetting;
     // ������������� �����
    if Visible then ActiveControl := FEditor;
  end;

  procedure TdSettings.SettingChange(Sender: TObject);
  begin
    Modified := FLocalRootSetting.Modified;
  end;

end.

