object dMsgBox: TdMsgBox
  Left = 505
  Top = 439
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = '<>'
  ClientHeight = 83
  ClientWidth = 312
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poMainFormCenter
  DesignSize = (
    312
    83)
  PixelsPerInch = 96
  TextHeight = 13
  object iIcon: TTntImage
    Left = 11
    Top = 11
    Width = 32
    Height = 32
  end
  object lMessage: TTntLabel
    Left = 60
    Top = 20
    Width = 16
    Height = 13
    AutoSize = False
    Caption = '<>'
    WordWrap = True
  end
  object cbDontShowAgain: TTntCheckBox
    Left = 11
    Top = 54
    Width = 277
    Height = 17
    Anchors = [akLeft, akRight, akBottom]
    Caption = 'Don'#39't &show this message again'
    TabOrder = 0
  end
  object dklcMain: TDKLanguageController
    IgnoreList.Strings = (
      '*.Font.Name'
      '*.SecondaryShortCuts'
      '.Caption'
      'lMessage.Caption')
    Left = 280
    Top = 4
    LangData = {
      0700644D7367426F7800010300000005006949636F6E000008006C4D65737361
      676500000F006362446F6E7453686F77416761696E01010000000C0000000700
      43617074696F6E00}
  end
end
