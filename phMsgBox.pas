//**********************************************************************************************************************
//  $Id: phMsgBox.pas,v 1.2 2007-06-24 17:47:59 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Copyright DK Software, http://www.dk-soft.org/
//**********************************************************************************************************************
unit phMsgBox;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ConsVars,
  phDlg, StdCtrls, ExtCtrls, DKLang;

type
  TdMsgBox = class(TForm)
    iIcon: TImage;
    lMessage: TLabel;
    cbDontShowAgain: TCheckBox;
    dklcMain: TDKLanguageController;
  private
     // ��� ���������
    FKind: TMessageBoxKind;
     // ����� ���������
    FMessage: WideString;
     // ������, ������� ������ ������������ � �������
    FButtons: TMessageBoxButtons;
     // ���� True, �� ������������� ���������� checkbox '������ �� ���������� ������ ���������'
    FDiscardable: Boolean;
     // ������ �������
    FButtonCtls: Array of TButton;
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
     // ������ � ����������� ������ � ������������� "������ �� ����������..."
    procedure AdjustButtons;
     // ����������� ������/��������� ���� � ������������� ������ (���������) 
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
   //   wsMessage       - ����� ���������
   //   AButtons        - ������, ������� ������ ������������ � �������
   //   bDiscardable    - ���� True, �� ������������� ���������� checkbox '������ �� ���������� ������ ���������'
   //   ���������� �����, ��������� �� ����� �� ������ �, �����������, mbrDontShow (���� ������� ������������� "������
   //     �� ����������..." � bDiscardable=True)
  function PhoaMsgBox(AKind: TMessageBoxKind; const wsMessage: WideString; bDiscardable: Boolean; AButtons: TMessageBoxButtons): TMessageBoxResults; overload;
   // �� �� �����, �� ������������� ��������� ������ ���������� ��� ��������������
  function PhoaMsgBox(AKind: TMessageBoxKind; const wsMessage: WideString; const aParams: Array of const; bDiscardable: Boolean; AButtons: TMessageBoxButtons): TMessageBoxResults; overload;
   // �� �� �����, �� ������ ������ ��������� ��������� ��� ��������������� ���������
  function PhoaMsgBoxConst(AKind: TMessageBoxKind; const sConstName: AnsiString; bDiscardable: Boolean; AButtons: TMessageBoxButtons): TMessageBoxResults; overload;
  function PhoaMsgBoxConst(AKind: TMessageBoxKind; const sConstName: AnsiString; const aParams: Array of const; bDiscardable: Boolean; AButtons: TMessageBoxButtons): TMessageBoxResults; overload;
   // ���������� ������ ����������, ���� iSettingID<=0 ��� �������� ��������� iSettingID=True, ����� ������ ��
   //   ������������. ��� iSettingID>0 � ������� ������������ ����� ������������� "������ �� ����������...". ����
   //   ������������ ������� ��� � ����� ��, �� � �������� ��������� ��������� False
   //   ���� bWarning=True, �� ������������ � ������ mbkWarning, ����� - mbkInfo
  procedure PhoaInfo(bWarning: Boolean; const wsConstName: WideString; iSettingID: Integer = 0); overload;
  procedure PhoaInfo(bWarning: Boolean; const wsConstName: WideString; const aParams: Array of const; iSettingID: Integer = 0); overload;
   // ���������� ������ �������������, ���� iSettingID<=0 ��� �������� ��������� iSettingID=True, ����� ������ ��
   //   ������������, � ������ ���������� True. ��� iSettingID>0 � ������� ������������ ����� ������������� "������ ��
   //   ����������...". ���� ������������ ������� ��� � ����� ��, �� � �������� ��������� ��������� False
   //   ���� bWarning=True, �� ������������ � ������ mbkConfirmWarning, ����� - mbkConfirm
  function  PhoaConfirm(bWarning: Boolean; const wsConstName: WideString; iSettingID: Integer = 0): Boolean; overload;
  function  PhoaConfirm(bWarning: Boolean; const wsConstName: WideString; const aParams: Array of const; iSettingID: Integer = 0): Boolean; overload;
   // ���������� ������ ������
  procedure PhoaError(const wsConstName: WideString); overload;
  procedure PhoaError(const wsConstName: WideString; const aParams: Array of const); overload;

const
   // ����������� ������� ����� ������� ������ � ������� ����
  IMsgBox_ScreenWidthGap       = 100;
   // ����������� ������� ����� ������� ������ � ������� ����
  IMsgBox_ScreenHeightGap      = 100;
   // ����������� ������ ���������� ����� �������
  IMsgBox_MinClientWidth       = 300;
   // ���������� �� ������� ���� ������� (������ ���������) �� ������� ���� ����
  IMsgBox_LabelRightMargin     = 11;
   // ���������� �� �������� ���� �������� "������ �� ����������..." �� ��������� (������� ��� ������)
  IMsgBox_CBDontShowTopMargin  = 11;
   // ����� ������ �������� "������ �� ����������..."
  IMsgBox_CBDontShowLeftMargin = 11;
   // ������ �������� "������ �� ����������..."
  IMsgBox_CBDontShowWidth      = 280;
   // ������ ������ �������
  IMsgBox_ButtonWidth          = 79;
   // ������ ������ �������
  IMsgBox_ButtonHeight         = 23;
   // ���������� �� �������� ���� ������ �� ���������
  IMsgBox_ButtonTopMargin      = 11;
   // ���������� �� ������� ���� ������ �� ���� ����
  IMsgBox_ButtonBottomMargin   = 11;
   // ���������� �� ������� ���� ����� ������ ������ �� ������� ���� ����
  IMsgBox_ButtonRightMargin    = 11;
   // ����������� ���������� �� ������ ���� ����� ����� ������ �� ������ ���� ����
  IMsgBox_ButtonLeftMargin     = 11;
   // ���������� ����� �������� �� �����������
  IMsgBox_ButtonGap            = 6;

implementation
{$R *.dfm}
uses phUtils, phSettings, phChmHlp;

  function PhoaMsgBox(AKind: TMessageBoxKind; const wsMessage: WideString; bDiscardable: Boolean; AButtons: TMessageBoxButtons): TMessageBoxResults;
  begin
    with TdMsgBox.Create(Application) do
      try
        FKind        := AKind;
        FButtons     := AButtons;
        FDiscardable := bDiscardable;
        if bMsgIsConstName then FMessage := ConstVal(wsMessage) else FMessage := wsMessage;
        Result := Execute;
      finally
        Free;
      end;
  end;

  function PhoaMsgBox(AKind: TMessageBoxKind; const wsMessage: WideString; const aParams: Array of const; bDiscardable: Boolean; AButtons: TMessageBoxButtons): TMessageBoxResults;
  begin
    Result := PhoaMsgBox(AKind, WideFormat(wsMessage, aParams), bDiscardable, AButtons);
  end;

  function PhoaMsgBoxConst(AKind: TMessageBoxKind; const sConstName: AnsiString; bDiscardable: Boolean; AButtons: TMessageBoxButtons): TMessageBoxResults;
  begin
    Result := PhoaMsgBox(AKind, ConstVal(sConstName), bDiscardable, AButtons);
  end;

  function PhoaMsgBoxConst(AKind: TMessageBoxKind; const sConstName: AnsiString; const aParams: Array of const; bDiscardable: Boolean; AButtons: TMessageBoxButtons): TMessageBoxResults;
  begin
    Result := PhoaMsgBox(AKind, ConstVal(sConstName, aParams), bDiscardable, AButtons);
  end;

  procedure PhoaInfo(bWarning: Boolean; const wsConstName: WideString; iSettingID: Integer = 0);
  const aKinds: Array[Boolean] of TMessageBoxKind = (mbkInfo, mbkWarning);
  var mbr: TMessageBoxResults;
  begin
    if (iSettingID<=0) or SettingValueBool(iSettingID) then begin
      mbr := PhoaMsgBoxConst(aKinds[bWarning], wsConstName, iSettingID>0, [mbbOK]);
      if (iSettingID>0) and (mbrDontShow in mbr) then SetSettingValueBool(iSettingID, False);
    end;
  end;

  procedure PhoaInfo(bWarning: Boolean; const wsConstName: WideString; const aParams: Array of const; iSettingID: Integer = 0);
  const aKinds: Array[Boolean] of TMessageBoxKind = (mbkInfo, mbkWarning);
  var mbr: TMessageBoxResults;
  begin
    if (iSettingID<=0) or SettingValueBool(iSettingID) then begin
      mbr := PhoaMsgBoxConst(aKinds[bWarning], wsConstName, aParams, iSettingID>0, [mbbOK]);
      if (iSettingID>0) and (mbrDontShow in mbr) then SetSettingValueBool(iSettingID, False);
    end;
  end;

  function PhoaConfirm(bWarning: Boolean; const wsConstName: WideString; iSettingID: Integer = 0): Boolean;
  const aKinds: Array[Boolean] of TMessageBoxKind = (mbkConfirm, mbkConfirmWarning);
  var mbr: TMessageBoxResults;
  begin
    if (iSettingID<=0) or SettingValueBool(iSettingID) then begin
      mbr := PhoaMsgBoxConst(aKinds[bWarning], wsConstName, iSettingID>0, [mbbOK, mbbCancel]);
      Result := mbrOK in mbr;
      if Result and (iSettingID>0) and (mbrDontShow in mbr) then SetSettingValueBool(iSettingID, False);
    end else
      Result := True;
  end;

  function PhoaConfirm(bWarning: Boolean; const wsConstName: WideString; const aParams: Array of const; iSettingID: Integer = 0): Boolean;
  const aKinds: Array[Boolean] of TMessageBoxKind = (mbkConfirm, mbkConfirmWarning);
  var mbr: TMessageBoxResults;
  begin
    if (iSettingID<=0) or SettingValueBool(iSettingID) then begin
      mbr := PhoaMsgBoxConst(aKinds[bWarning], wsConstName, aParams, iSettingID>0, [mbbOK, mbbCancel]);
      Result := mbrOK in mbr;
      if Result and (iSettingID>0) and (mbrDontShow in mbr) then SetSettingValueBool(iSettingID, False);
    end else
      Result := True;
  end;

  procedure PhoaError(const wsConstName: WideString);
  begin
    PhoaMsgBoxConst(mbkError, wsConstName, False, [mbbOK]);
  end;

  procedure PhoaError(const wsConstName: WideString; const aParams: Array of const);
  begin
    PhoaMsgBoxConst(mbkError, wsConstName, aParams, False, [mbbOK]);
  end;

   //===================================================================================================================
   // TdMsgBox
   //===================================================================================================================

  procedure TdMsgBox.AdjustBounds;
  var i, iBtnX, iBtnY, iCWidth, iCHeight: Integer;
  begin
     // ��������� ������� �������
    iCWidth  := lMessage.Left+lMessage.Width+IMsgBox_LabelRightMargin;
    iCHeight := iIcon.Top+Max(iIcon.Height, lMessage.Height);
     // ��������� ������� ������ / cbDontShowAgain
    Inc(iCHeight, IMsgBox_ButtonTopMargin+IMsgBox_ButtonHeight+IMsgBox_ButtonBottomMargin);
    if FDiscardable then Inc(iCHeight, IMsgBox_CBDontShowTopMargin+cbDontShowAgain.Height);
    iCWidth := Max(iCWidth, FButtonWidths+iif(FDiscardable, IMsgBox_CBDontShowWidth, 0));
     // ���������, ��� ������ �� ������ �����������
    iCWidth := Max(iCWidth, IMsgBox_MinClientWidth);
     // ������������� ������
    SetBounds(
      0,
      0,
      Min(iCWidth+(Width-ClientWidth), Screen.WorkAreaWidth-IMsgBox_ScreenWidthGap),
      Min(iCHeight+(Height-ClientHeight), Screen.WorkAreaHeight-IMsgBox_ScreenHeightGap));
     // ������������� ������ �� ������ �������
    iBtnX := (ClientWidth-FButtonWidths) div 2 + IMsgBox_ButtonLeftMargin;
    iBtnY := ClientHeight-IMsgBox_ButtonBottomMargin-IMsgBox_ButtonHeight;
    for i := 0 to High(FButtonCtls) do begin
      FButtonCtls[i].SetBounds(iBtnX, iBtnY, IMsgBox_ButtonWidth, IMsgBox_ButtonHeight);
      Inc(iBtnX, IMsgBox_ButtonWidth+IMsgBox_ButtonGap);
    end;
  end;

  procedure TdMsgBox.AdjustButtons;
  var
    iBtnCount: Integer;
    btn: TMessageBoxButton;

     // ������ ���������� ������
    function MakeButton(mbb: TMessageBoxButton): TButton;
    const
      asBtnCaptionConsts: Array[TMessageBoxButton] of AnsiString = (
        'SBtn_Yes',      // mbbYes
        'SBtn_YesToAll', // mbbYesToAll
        'SBtn_No',       // mbbNo
        'SBtn_NoToAll',  // mbbNoToAll
        'SBtn_OK',       // mbbOK
        'SBtn_Cancel',   // mbbCancel
        'SBtn_Help');    // mbbHelp
      aBtnResults: Array[TMessageBoxButton] of TMessageBoxResult = (
        mbrYes,                 // mbbYes
        mbrYesToAll,            // mbbYesToAll
        mbrNo,                  // mbbNo
        mbrNoToAll,             // mbbNoToAll
        mbrOK,                  // mbbOK
        mbrCancel,              // mbbCancel
        TMessageBoxResult(-1)); // mbbHelp
    begin
      Result := TButton.Create(Self);
      with Result do begin
        Parent   := Self;
        Cancel   := (mbb=mbbCancel) or ((mbb=mbbOK) and not (mbbCancel in FButtons)) or ((mbb=mbbNo) and (FButtons*[mbbOK, mbbCancel]=[]));
        Caption  := ConstVal(asBtnCaptionConsts[mbb]);
        Default  := (mbb=mbbOK) or ((mbb=mbbYes) and not (mbbOK in FButtons));
        if Default then Self.ActiveControl := Result;
        if mbb=mbbHelp then OnClick := BtnHelpClick else OnClick := BtnClick;
        Tag      := Byte(aBtnResults[mbb]);
        TabOrder := iBtnCount-1;
      end;
    end;

  begin
     // ���������� � ������ ������
    iBtnCount := 0;
    for btn := Low(btn) to High(btn) do
      if btn in FButtons then begin
        Inc(iBtnCount);
        SetLength(FButtonCtls, iBtnCount);
        FButtonCtls[iBtnCount-1] := MakeButton(btn);
      end;
     // ������� ������
    FButtonWidths :=
      IMsgBox_ButtonLeftMargin+
      iBtnCount*IMsgBox_ButtonWidth+
      (iBtnCount-1)*IMsgBox_ButtonGap+
      IMsgBox_ButtonRightMargin;
     // ����������� �������������
    if FDiscardable then
      cbDontShowAgain.SetBounds(
        IMsgBox_CBDontShowLeftMargin,
        Self.ClientHeight-IMsgBox_ButtonBottomMargin-IMsgBox_ButtonHeight-IMsgBox_ButtonTopMargin-cbDontShowAgain.Height,
        IMsgBox_CBDontShowWidth,
        cbDontShowAgain.Height);
    cbDontShowAgain.Visible := FDiscardable;
  end;

  procedure TdMsgBox.AdjustCaption;
  const
    asCaptionConsts: Array[TMessageBoxKind] of AnsiString = (
      'SDlgTitle_Info',           // mbkInfo
      'SDlgTitle_Warning',        // mbkWarning
      'SDlgTitle_Confirm',        // mbkConfirm
      'SDlgTitle_ConfirmWarning', // mbkConfirmWarning
      'SDlgTitle_Error');         // mbkError
  begin
    Caption := ConstVal(asCaptionConsts[FKind]);
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
       // ������ ����� � �����, ���� � ���
      if (FMessage<>'') and not (FMessage[Length(FMessage)] in ['.', '!', '?', '�']) then FMessage := FMessage+'.';
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

