unit udMsgBox;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ConsVars,
  phDlg, StdCtrls, ExtCtrls, DTLangTools;

type
  TdMsgBox = class(TForm)
    dtlsMain: TDTLanguageSwitcher;
    iIcon: TImage;
    lMessage: TLabel;
    cbDontShowAgain: TCheckBox;
  private
     // ��� ���������
    FKind: TMessageBoxKind;
     // ����� ���������
    FMessage: String;
     // ������, ������� ������ ������������ � �������
    FButtons: TMessageBoxButtons;
     // ���� True, �� ������������� ���������� checkbox '������ �� ���������� ������ ���������'
    FDiscardable: Boolean;
     // ������ ������ � ������ ���� ������ � �������, ���������������� � AdjustButtons()
    FButtonWidths: Integer;
     // ����� ������ - ��������� ����������
    FResults: TMessageBoxResults;
     // ������������� �������
    procedure InitializeDlg;
     // ����������� ��������� ����
    procedure AdjustCaption;
     // ����������� ������
    procedure AdjustIcon;
     // ����������� ����� ���������
    procedure AdjustMessage;
     // ����������� ������ � ������������� "������ �� ����������..."
    procedure AdjustButtons;
     // ����������� ������/��������� ����
    procedure AdjustBounds;
     // ����� ����, ��������������� ���� �������
    procedure AdjustSound;
     // ��������� ������ � ���������� ���������
    function Execute: TMessageBoxResults;
     // ������� ����� �� ������
    procedure BtnClick(Sender: TObject); 
     // ������� ����� �� ������ Help
    procedure BtnHelpClick(Sender: TObject);
  end;

   // ���������� [�����] ����������� ������-���������.
   //   AKind           - ��� ���������. ������ �� ���������, ������ � �������� ������
   //   sMessage        - ����� ���������
   //   AButtons        - ������, ������� ������ ������������ � �������
   //   bMsgIsConstName - ���� True, �� sMessage ���������� ��� ��� ���������, � � �������� ������������� ������ ������
   //   bDiscardable    - ���� True, �� ������������� ���������� checkbox '������ �� ���������� ������ ���������'
   //   ���������� �����, ��������� �� ����� �� ������ �, �����������, mbrDontShow (���� ������� ������������� "������
   //     �� ����������..." � bDiscardable=True)
  function PhoaMsgBox(AKind: TMessageBoxKind; const sMessage: String; bMsgIsConstName, bDiscardable: Boolean; AButtons: TMessageBoxButtons): TMessageBoxResults; overload;
   // �� �� �����, �� ������������� ��������� ������ ���������� ��� ��������������
  function PhoaMsgBox(AKind: TMessageBoxKind; const sMessage: String; const aParams: Array of const; bMsgIsConstName, bDiscardable: Boolean; AButtons: TMessageBoxButtons): TMessageBoxResults; overload;
   // ���������� ������ ����������, ���� iSettingID<=0 ��� �������� ��������� iSettingID=True, ����� ������ ��
   //   ������������. ��� iSettingID>0 � ������� ������������ ����� ������������� "������ �� ����������...". ����
   //   ������������ ������� ��� � ����� ��, �� � �������� ��������� ��������� False
   //   ���� bWarning=True, �� ������������ � ������ mbkWarning, ����� - mbkInfo
  procedure PhoaInfo(bWarning: Boolean; const sConstName: String; iSettingID: Integer = 0); overload;
  procedure PhoaInfo(bWarning: Boolean; const sConstName: String; const aParams: Array of const; iSettingID: Integer = 0); overload;
   // ���������� ������ �������������, ���� iSettingID<=0 ��� �������� ��������� iSettingID=True, ����� ������ ��
   //   ������������, � ������ ���������� True. ��� iSettingID>0 � ������� ������������ ����� ������������� "������ ��
   //   ����������...". ���� ������������ ������� ��� � ����� ��, �� � �������� ��������� ��������� False
   //   ���� bWarning=True, �� ������������ � ������ mbkConfirmWarning, ����� - mbkConfirm
  function  PhoaConfirm(bWarning: Boolean; const sConstName: String; iSettingID: Integer = 0): Boolean; overload;
  function  PhoaConfirm(bWarning: Boolean; const sConstName: String; const aParams: Array of const; iSettingID: Integer = 0): Boolean; overload;
   // ���������� ������ ������
  procedure PhoaError(const sConstName: String); overload;
  procedure PhoaError(const sConstName: String; const aParams: Array of const); overload;

const
   // ����������� ������� ����� ������� ������ � ������� ����
  IMsgBox_ScreenWidthGap       = 100;
   // ����������� ������� ����� ������� ������ � ������� ����
  IMsgBox_ScreenHeightGap      = 100;
   // ����������� ������ ���������� ����� �������
  IMsgBox_MinClientWidth       = 300;
   // ���������� �� ������� ���� ������� (������ ���������) �� ������� ���� ����
  IMsgBox_LabelRightMargin     = 20;
   // ����� ������ �������� "������ �� ����������..."
  IMsgBox_CBDontShowLeftMargin = 12;
   // ������ �������� "������ �� ����������..."
  IMsgBox_CBDontShowWidth      = 280;
   // ������ ������ �������
  IMsgBox_ButtonWidth          = 79;
   // ������ ������ �������
  IMsgBox_ButtonHeight         = 23;
   // ���������� �� �������� ���� ������ �� ���������
  IMsgBox_ButtonTopMargin      = 20;
   // ���������� �� ������� ���� ������ �� ���� ����
  IMsgBox_ButtonBottomMargin   = 8;
   // ���������� �� ������� ���� ����� ������ ������ �� ������� ���� ����
  IMsgBox_ButtonRightMargin    = 12;
   // ����������� ���������� �� ������ ���� ����� ����� ������ �� ������ ���� ����
  IMsgBox_ButtonLeftMargin     = 12;
   // ���������� ����� �������� �� �����������
  IMsgBox_ButtonGap            = 8;

implementation
{$R *.dfm}
uses phUtils, phSettings, ChmHlp;

  function PhoaMsgBox(AKind: TMessageBoxKind; const sMessage: String; bMsgIsConstName, bDiscardable: Boolean; AButtons: TMessageBoxButtons): TMessageBoxResults;
  begin
    with TdMsgBox.Create(Application) do
      try
        FKind        := AKind;
        FButtons     := AButtons;
        FDiscardable := bDiscardable;
        if bMsgIsConstName then FMessage := ConstVal(sMessage) else FMessage := sMessage;
        Result := Execute;
      finally
        Free;
      end;
  end;

  function PhoaMsgBox(AKind: TMessageBoxKind; const sMessage: String; const aParams: Array of const; bMsgIsConstName, bDiscardable: Boolean; AButtons: TMessageBoxButtons): TMessageBoxResults;
  begin
    if bMsgIsConstName then
      Result := PhoaMsgBox(AKind, ConstVal(sMessage, aParams), False, bDiscardable, AButtons)
    else
      Result := PhoaMsgBox(AKind, Format(sMessage, aParams), False, bDiscardable, AButtons);
  end;

  procedure PhoaInfo(bWarning: Boolean; const sConstName: String; iSettingID: Integer = 0);
  const aKinds: Array[Boolean] of TMessageBoxKind = (mbkInfo, mbkWarning);
  var mbr: TMessageBoxResults;
  begin
    if (iSettingID<=0) or SettingValueBool(iSettingID) then begin
      mbr := PhoaMsgBox(aKinds[bWarning], sConstName, True, iSettingID>0, [mbbOK]);
      if (iSettingID>0) and (mbrDontShow in mbr) then SetSettingValueBool(iSettingID, False);
    end;
  end;

  procedure PhoaInfo(bWarning: Boolean; const sConstName: String; const aParams: Array of const; iSettingID: Integer = 0);
  const aKinds: Array[Boolean] of TMessageBoxKind = (mbkInfo, mbkWarning);
  var mbr: TMessageBoxResults;
  begin
    if (iSettingID<=0) or SettingValueBool(iSettingID) then begin
      mbr := PhoaMsgBox(aKinds[bWarning], sConstName, aParams, True, iSettingID>0, [mbbOK]);
      if (iSettingID>0) and (mbrDontShow in mbr) then SetSettingValueBool(iSettingID, False);
    end;
  end;

  function PhoaConfirm(bWarning: Boolean; const sConstName: String; iSettingID: Integer = 0): Boolean;
  const aKinds: Array[Boolean] of TMessageBoxKind = (mbkConfirm, mbkConfirmWarning);
  var mbr: TMessageBoxResults;
  begin
    if (iSettingID<=0) or SettingValueBool(iSettingID) then begin
      mbr := PhoaMsgBox(aKinds[bWarning], sConstName, True, iSettingID>0, [mbbOK, mbbCancel]);
      Result := mbrOK in mbr;
      if Result and (iSettingID>0) and (mbrDontShow in mbr) then SetSettingValueBool(iSettingID, False);
    end else
      Result := True;
  end;

  function PhoaConfirm(bWarning: Boolean; const sConstName: String; const aParams: Array of const; iSettingID: Integer = 0): Boolean;
  const aKinds: Array[Boolean] of TMessageBoxKind = (mbkConfirm, mbkConfirmWarning);
  var mbr: TMessageBoxResults;
  begin
    if (iSettingID<=0) or SettingValueBool(iSettingID) then begin
      mbr := PhoaMsgBox(aKinds[bWarning], sConstName, aParams, True, iSettingID>0, [mbbOK, mbbCancel]);
      Result := mbrOK in mbr;
      if Result and (iSettingID>0) and (mbrDontShow in mbr) then SetSettingValueBool(iSettingID, False);
    end else
      Result := True;
  end;

  procedure PhoaError(const sConstName: String);
  begin
    PhoaMsgBox(mbkError, sConstName, True, False, [mbbOK]);
  end;

  procedure PhoaError(const sConstName: String; const aParams: Array of const);
  begin
    PhoaMsgBox(mbkError, sConstName, aParams, True, False, [mbbOK]);
  end;

   //===================================================================================================================
   // TdMsgBox
   //===================================================================================================================

  procedure TdMsgBox.AdjustBounds;
  var iCWidth, iCHeight: Integer;
  begin
     // ��������� ������� �������
    iCWidth  := lMessage.Left+lMessage.Width+IMsgBox_LabelRightMargin;
    iCHeight := iIcon.Top+Max(iIcon.Height, lMessage.Height);
     // ��������� ������� ������ / cbDontShowAgain
    Inc(iCHeight, IMsgBox_ButtonTopMargin+IMsgBox_ButtonHeight+IMsgBox_ButtonBottomMargin);
    iCWidth := Max(iCWidth, FButtonWidths+iif(FDiscardable, IMsgBox_CBDontShowWidth, 0));
     // ���������, ��� ������ �� ������ �����������
    iCWidth := Max(iCWidth, IMsgBox_MinClientWidth);
     // ������������� ������
    SetBounds(
      0,
      0,
      Min(iCWidth+(Width-ClientWidth), Screen.WorkAreaWidth-IMsgBox_ScreenWidthGap),
      Min(iCHeight+(Height-ClientHeight), Screen.WorkAreaHeight-IMsgBox_ScreenHeightGap));
  end;

  procedure TdMsgBox.AdjustButtons;
  var
    iBtnRightX: Integer;
    btn: TMessageBoxButton;

     // ������ ������, ���� ��� ���������, � ��������� FButtonRightX �� ������ ������ + ����� ����� ��������
    procedure MakeButton(mbb: TMessageBoxButton);
    const
      aBtnCaptionConsts: Array[TMessageBoxButton] of String = (
        'SBtn_Help',     // mbbHelp
        'SBtn_Cancel',   // mbbCancel
        'SBtn_OK',       // mbbOK
        'SBtn_NoToAll',  // mbbNoToAll
        'SBtn_No',       // mbbNo
        'SBtn_YesToAll', // mbbYesToAll
        'SBtn_Yes');     // mbbYes
      aBtnResults: Array[TMessageBoxButton] of TMessageBoxResult = (
        TMessageBoxResult(-1), // mbbHelp
        mbrCancel,             // mbbCancel
        mbrOK,                 // mbbOK
        mbrNoToAll,            // mbbNoToAll
        mbrNo,                 // mbbNo
        mbrYesToAll,           // mbbYesToAll
        mbrYes);               // mbbYes
    var Button: TButton;
    begin
      Button := TButton.Create(Self);
      with Button do begin
        Parent  := Self;
        SetBounds(
          iBtnRightX-IMsgBox_ButtonWidth,
          Self.ClientHeight-IMsgBox_ButtonHeight-IMsgBox_ButtonBottomMargin,
          IMsgBox_ButtonWidth,
          IMsgBox_ButtonHeight);
        Anchors := [akRight, akBottom];
        Cancel  := (mbb=mbbCancel) or ((mbb=mbbOK) and not (mbbCancel in FButtons)) or ((mbb=mbbNo) and (FButtons*[mbbOK, mbbCancel]=[]));
        Caption := ConstVal(aBtnCaptionConsts[mbb]);
        Default := (mbb=mbbOK) or ((mbb=mbbYes) and not (mbbOK in FButtons));
        if Default then Self.ActiveControl := Button;
        if mbb=mbbHelp then OnClick := BtnHelpClick else OnClick := BtnClick;
        Tag     := Byte(aBtnResults[mbb]);
      end;
    end;

  begin
    iBtnRightX := ClientWidth-IMsgBox_ButtonRightMargin;
    if FButtons<>[] then begin
       // ���������� � ������ ������
      for btn := Low(btn) to High(btn) do
        if btn in FButtons then begin
          MakeButton(btn);
          Dec(iBtnRightX, IMsgBox_ButtonWidth);
          if btn<High(btn) then Dec(iBtnRightX, IMsgBox_ButtonGap);
        end;
    end;
     // ������� ������
    FButtonWidths := ClientWidth-iBtnRightX+IMsgBox_ButtonLeftMargin;
     // ����������� �������������
    if FDiscardable then
      cbDontShowAgain.SetBounds(
        IMsgBox_CBDontShowLeftMargin,
        Self.ClientHeight-IMsgBox_ButtonBottomMargin-((IMsgBox_ButtonHeight+cbDontShowAgain.Height) div 2),
        IMsgBox_CBDontShowWidth,
        cbDontShowAgain.Height);
    cbDontShowAgain.Visible := FDiscardable;
  end;

  procedure TdMsgBox.AdjustCaption;
  const
    aCaptionConsts: Array[TMessageBoxKind] of String = (
      'SDlgTitle_Info',           // mbkInfo
      'SDlgTitle_Warning',        // mbkWarning
      'SDlgTitle_Confirm',        // mbkConfirm
      'SDlgTitle_ConfirmWarning', // mbkConfirmWarning
      'SDlgTitle_Error');         // mbkError
  begin
    Caption := ConstVal(aCaptionConsts[FKind]);
  end;

  procedure TdMsgBox.AdjustIcon;
  const
    aIconIDs: Array[TMessageBoxKind] of PAnsiChar = (
      IDI_ASTERISK,    // mbkInfo
      IDI_EXCLAMATION, // mbkWarning
      IDI_QUESTION,    // mbkConfirm
      IDI_EXCLAMATION, // mbkConfirmWarning
      IDI_HAND);       // mbkError
  begin
    iIcon.Picture.Icon.Handle := LoadIcon(0, aIconIDs[FKind]);
  end;

  procedure TdMsgBox.AdjustMessage;
  begin
    with lMessage do begin
      Caption  := FMessage;
       // ���������� ������ ������ �������� � ������������� ������� �������
      Width    := Screen.WorkAreaWidth-IMsgBox_ScreenWidthGap-Left-IMsgBox_LabelRightMargin;
      AutoSize := True;
       // ���� ������ ������� ������ ������ ������, ���������� �� ��������� ������� ������������ ������
      if Height<iIcon.Height then Top := iIcon.Top+((iIcon.Height-Height) div 2);
    end;
  end;

  procedure TdMsgBox.AdjustSound;
  const
    aSndConsts: Array[TMessageBoxKind] of Integer = (
      MB_ICONINFORMATION, // mbkInfo
      MB_ICONEXCLAMATION, // mbkWarning
      MB_ICONQUESTION,    // mbkConfirm
      MB_ICONEXCLAMATION, // mbkConfirmWarning
      MB_ICONERROR);      // mbkError
  begin
    MessageBeep(aSndConsts[FKind]);
  end;

  procedure TdMsgBox.BtnClick(Sender: TObject);
  begin
    FResults := [];
    Include(FResults, TMessageBoxResult(TComponent(Sender).Tag));
    ModalResult := mrOK;
  end;

  procedure TdMsgBox.BtnHelpClick(Sender: TObject);
  begin
    HtmlHelpContext(HelpContext);
  end;

  function TdMsgBox.Execute: TMessageBoxResults;
  begin
    InitializeDlg;
    ShowModal;
    if FDiscardable and cbDontShowAgain.Checked then Include(FResults, mbrDontShow);
    Result := FResults;
  end;

  procedure TdMsgBox.InitializeDlg;
  begin
    FResults := [mbrCancel];
     // ����������� ������
    AdjustCaption;
    AdjustIcon;
    AdjustMessage;
    AdjustButtons;
    AdjustBounds;
    AdjustSound;
  end;

end.
