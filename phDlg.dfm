object PhoaDialog: TPhoaDialog
  Left = 480
  Top = 237
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'PhoaDialog'
  ClientHeight = 169
  ClientWidth = 290
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poMainFormCenter
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object bvBottom: TBevel
    Left = 0
    Top = 132
    Width = 290
    Height = 2
    Align = alBottom
    Shape = bsBottomLine
  end
  object pButtonsBottom: TPanel
    Left = 0
    Top = 134
    Width = 290
    Height = 35
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      290
      35)
    object bCancel: TButton
      Left = 131
      Top = 6
      Width = 75
      Height = 23
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Cancel'
      TabOrder = 0
      OnClick = bCancelClick
    end
    object bOK: TButton
      Left = 51
      Top = 6
      Width = 75
      Height = 23
      Anchors = [akTop, akRight]
      Caption = 'OK'
      Default = True
      Enabled = False
      TabOrder = 1
      OnClick = bOKClick
    end
    object bHelp: TButton
      Left = 209
      Top = 6
      Width = 75
      Height = 23
      Anchors = [akTop, akRight]
      Caption = 'Help'
      TabOrder = 2
      OnClick = bHelpClick
    end
  end
  object dklcMain: TDKLanguageController
    Left = 4
    Top = 136
    LangData = {
      0A0050686F614469616C6F67010100000003000000070043617074696F6E0105
      00000008006276426F74746F6D00000E0070427574746F6E73426F74746F6D00
      0007006243616E63656C01010000000C000000070043617074696F6E00030062
      4F4B01010000000F000000070043617074696F6E0005006248656C7001010000
      0012000000070043617074696F6E00}
  end
end
