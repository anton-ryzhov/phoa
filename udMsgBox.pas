unit udMsgBox;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ConsVars,
  phDlg, StdCtrls, ExtCtrls, DTLangTools;

type
  TdMsgBox = class(TForm)
    bvBottom: TBevel;
    pButtonsBottom: TPanel;
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
     // ��������� ������ ������� ������ ��� ����� ������, ���������������� � AdjustButtons()
    FButtonRightX: Integer;
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
  end;

   // ���������� [�����] ����������� ������-���������.
   //   AKind           - ��� ���������. ������ �� ���������, ������ � �������� ������
   //   sMessage        - ����� ���������
   //   AButtons        - ������, ������� ������ ������������ � �������
   //   bMsgIsConstName - ���� True, �� sMessage ���������� ��� ��� ���������, � � �������� ������������� ������ ������
   //   bDiscardable    - ���� True, �� ������������� ���������� checkbox '������ �� ���������� ������ ���������'
   //   ���������� �����, ��������� �� ����� �� ������ �, �����������, mbrDontShow (���� ������� ������������� "������
   //     �� ����������..." � bDiscardable=True)
  function PhoaMsgBox(AKind: TMessageBoxKind; const sMessage: String; AButtons: TMessageBoxButtons; bMsgIsConstName, bDiscardable: Boolean): TMessageBoxResults; overload;
   // �� �� �����, �� ������������� ��������� ������ ���������� ��� ��������������
  function PhoaMsgBox(AKind: TMessageBoxKind; const sMessage: String; const aParams: Array of const; AButtons: TMessageBoxButtons; bMsgIsConstName, bDiscardable: Boolean): TMessageBoxResults; overload;

const
   // ����������� ������� ����� ������� ������ � ������� ����
  IMsgBox_ScreenGap         = 100;
   // ���������� �� ������� ���� ������� (������ ���������) �� ������� ���� ����
  IMsgBox_LabelRightMargin  = 12;
   // ���������� �� ������� ���� ������� ��� ������ �� ������� ���� ������� �������
  IMsgBox_BottomMargin      = 12;
   // ������ ������ �������
  IMsgBox_ButtonWidth       = 75;
   // ������ ������ �������
  IMsgBox_ButtonHeight      = 23;
   // ��������� �������� ���� ������ ������ pButtonsBottom
  IMsgBox_ButtonTop         = 8;
   // ���������� �� ������� ���� ����� ������ ������ �� ������� ���� ����
  IMsgBox_ButtonRightMargin = 8;
   // ����������� ���������� �� ������ ���� ����� ����� ������ �� ������ ���� ����
  IMsgBox_ButtonLeftMargin  = 8;
   // ���������� ����� �������� �� �����������
  IMsgBox_ButtonGap         = 8;

implementation
{$R *.dfm}
uses phUtils;

  function PhoaMsgBox(AKind: TMessageBoxKind; const sMessage: String; AButtons: TMessageBoxButtons; bMsgIsConstName, bDiscardable: Boolean): TMessageBoxResults;
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

  function PhoaMsgBox(AKind: TMessageBoxKind; const sMessage: String; const aParams: Array of const; AButtons: TMessageBoxButtons; bMsgIsConstName, bDiscardable: Boolean): TMessageBoxResults;
  begin
    if bMsgIsConstName then
      Result := PhoaMsgBox(AKind, ConstVal(sMessage, aParams), AButtons, False, bDiscardable)
    else
      Result := PhoaMsgBox(AKind, Format(sMessage, aParams), AButtons, False, bDiscardable);
  end;

   //===================================================================================================================
   // TdMsgBox
   //===================================================================================================================

  procedure TdMsgBox.AdjustBounds;
  var iCWidth, iCHeight: Integer;
  begin
     // ��������� ������� �������
    iCWidth  := lMessage.Left+lMessage.Width+IMsgBox_LabelRightMargin;
    iCHeight := Max(iIcon.Height, lMessage.Height)+IMsgBox_BottomMargin+pButtonsBottom.Height;
     // ��������� cbDontShowAgain
    if FDiscardable then Inc(iCHeight, bvBottom.Top-cbDontShowAgain.Top);
     // ��������� ������ ������
    iCWidth := Max(iCWidth, ); 
  end;

  procedure TdMsgBox.AdjustButtons;
  var btn: TMessageBoxButton;

     // ������ ������, ���� ��� ���������, � ��������� FButtonRightX �� ������ ������ + ����� ����� ��������
    procedure MakeButton(mbb: TMessageBoxButton);
    const
      aBtnCaptionConsts: Array[TMessageBoxButton] of String = (
        'SBtn_Yes',      // mbbYes
        'SBtn_No',       // mbbNo
        'SBtn_OK',       // mbbOK
        'SBtn_Cancel',   // mbbCancel
        'SBtn_YesToAll', // mbbYesToAll
        'SBtn_NoToAll',  // mbbNoToAll
        'SBtn_Help');    // mbbHelp
    var Button: TButton;
    begin
      Button := TButton.Create(Self);
      with Button do begin
        Parent  := pButtonsBottom;
        SetBounds(FButtonRightX-IMsgBox_ButtonWidth, IMsgBox_ButtonTop, IMsgBox_ButtonWidth, IMsgBox_ButtonHeight);
        Anchors := [akRight, akBottom];
        Cancel  := (mbb=mbbCancel) or ((mbb=mbbNo) and not (mbbCancel in FButtons));
        Caption := ConstVal(aBtnCaptionConsts[mbb]);
        Default := (mbb=mbbOK) or ((mbb=mbbYes) and not (mbbOK in FButtons));
        OnClick := BtnClick;
        Tag     := Byte(mbb);
        FButtonRightX := Left-IMsgBox_ButtonGap;
      end;
    end;

  begin
    FButtonRightX := pButtonsBottom.ClientWidth-IMsgBox_ButtonRightMargin;
    if FButtons<>[] then begin
       // ���������� � ������ ������
      for btn := Low(btn) to High(btn) do
        if btn in FButtons then MakeButton(btn);
       // ������� ��������� �����
      Inc(FButtonRightX, IMsgBox_ButtonGap);
    end;
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
  begin
    //!!!
  end;

  procedure TdMsgBox.AdjustMessage;
  begin
    with lMessage do begin
      Text  := FMessage;
       // ���������� ������ ������ �������� � ������������� ������� �������
      Width := Screen.WorkAreaWidth-IMsgBox_ScreenGap-Left-IMsgBox_LabelRightMargin;
      AutoSize := True;
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
    AdjustMessage;
    AdjustButtons;
    AdjustBounds;
    AdjustSound;
  end;

end.
