inherited frPicProps_View: TfrPicProps_View
  Height = 298
  OnMouseWheel = FrameMouseWheel
  object iMain: TImage32
    Left = 9
    Top = 52
    Width = 558
    Height = 237
    Align = alClient
    BitmapAlign = baCustom
    PopupMenu = pmMain
    Scale = 1.000000000000000000
    ScaleMode = smScale
    TabOrder = 0
    TabStop = True
    OnMouseDown = iMainMouseDown
    OnMouseMove = iMainMouseMove
    OnMouseUp = iMainMouseUp
    OnResize = iMainResize
  end
  object dkTop: TTBXDock
    Left = 0
    Top = 0
    Width = 576
    Height = 52
    object tbMain: TTBXToolbar
      Left = 0
      Top = 0
      Align = alTop
      Caption = 'Main Toolbar'
      ChevronHint = 'More buttons|'
      DockMode = dmCannotFloat
      Images = fMain.ilActionsSmall
      SystemFont = False
      TabOrder = 0
      object cbViewFile: TTBXComboBoxItem
        EditWidth = 330
        Hint = 'File to view'
        ShowImage = True
        OnChange = cbViewFileChange
        DropDownList = True
        MinListWidth = 330
        ShowListImages = True
        OnAdjustImageIndex = cbViewFileAdjustImageIndex
      end
      object bViewZoomIn: TTBXItem
        Action = aZoomIn
        DisplayMode = nbdmImageAndText
      end
      object bViewZoomOut: TTBXItem
        Action = aZoomOut
        DisplayMode = nbdmImageAndText
      end
      object bViewZoomActual: TTBXItem
        Action = aZoomActual
        DisplayMode = nbdmImageAndText
      end
      object bViewZoomFit: TTBXItem
        Action = aZoomFit
        DisplayMode = nbdmImageAndText
      end
    end
    object tbTools: TTBXToolbar
      Left = 0
      Top = 26
      Caption = 'Tools'
      DockMode = dmCannotFloat
      DockPos = -8
      DockRow = 1
      Images = fMain.ilActionsSmall
      TabOrder = 1
      object bRotate0: TTBXItem
        Action = aRotate0
      end
      object bRotate90: TTBXItem
        Action = aRotate90
      end
      object bRotate180: TTBXItem
        Action = aRotate180
      end
      object bRotate270: TTBXItem
        Action = aRotate270
      end
      object tbSepFlipHorz: TTBXSeparatorItem
      end
      object bFlipHorz: TTBXItem
        Action = aFlipHorz
      end
      object bFlipVert: TTBXItem
        Action = aFlipVert
      end
    end
  end
  object dkLeft: TTBXDock
    Left = 0
    Top = 52
    Width = 9
    Height = 237
    Position = dpLeft
  end
  object dkRight: TTBXDock
    Left = 567
    Top = 52
    Width = 9
    Height = 237
    Position = dpRight
  end
  object dkBottom: TTBXDock
    Left = 0
    Top = 289
    Width = 576
    Height = 9
    Position = dpBottom
  end
  object alMain: TActionList
    Images = fMain.ilActionsSmall
    Left = 36
    Top = 252
    object aZoomIn: TAction
      Category = 'Zoom'
      Caption = 'Zoom &in'
      Hint = 'Zoom in|Enlarge the image'
      ImageIndex = 25
      OnExecute = aaZoomIn
    end
    object aZoomOut: TAction
      Category = 'Zoom'
      Caption = 'Zoom ou&t'
      Hint = 'Zoom out|Zoom image out'
      ImageIndex = 26
      OnExecute = aaZoomOut
    end
    object aZoomActual: TAction
      Category = 'Zoom'
      Caption = 'Zoom &actual'
      Hint = 'Set zoom to 1:1'
      ImageIndex = 28
      OnExecute = aaZoomActual
    end
    object aZoomFit: TAction
      Category = 'Zoom'
      Caption = '&Fit window'
      Hint = 'Set zoom to fit window'
      ImageIndex = 27
      OnExecute = aaZoomFit
    end
    object aRotate0: TAction
      Category = 'Tools'
      Caption = '&No rotation'
      Hint = 'No rotation|Don'#39't apply rotation to the image'
      ImageIndex = 66
      OnExecute = aaRotate0
    end
    object aRotate90: TAction
      Category = 'Tools'
      Caption = 'Rotate CW by &90'#176
      Hint = 'Rotate CW by 90'#176'|Rotate the image clockwise by 90'#176
      ImageIndex = 67
      OnExecute = aaRotate90
    end
    object aRotate180: TAction
      Category = 'Tools'
      Caption = 'Rotate by &180'#176
      Hint = 'Rotate by 180'#176'|Rotate the image by 180'#176
      ImageIndex = 68
      OnExecute = aaRotate180
    end
    object aRotate270: TAction
      Category = 'Tools'
      Caption = 'Rotate CCW by 9&0'#176
      Hint = 
        'Rotate CCW by 90'#176'|Rotate the image counter-clockwise by 90'#176' (or ' +
        'clockwise by 270'#176')'
      ImageIndex = 69
      OnExecute = aaRotate270
    end
    object aFlipHorz: TAction
      Category = 'Tools'
      Caption = 'Flip &horizontally'
      Hint = 'Flip horizontally|Flip the image horizontally'
      ImageIndex = 70
      OnExecute = aaFlipHorz
    end
    object aFlipVert: TAction
      Category = 'Tools'
      Caption = 'Flip &vertically'
      Hint = 'Flip vertically|Flip the image vertically'
      ImageIndex = 71
      OnExecute = aaFlipVert
    end
  end
  object pmMain: TTBXPopupMenu
    Images = fMain.ilActionsSmall
    Left = 64
    Top = 252
  end
  object dtlsMain: TDTLanguageSwitcher
    Language = 1033
    Left = 8
    Top = 252
    LangData = {
      0F00667250696350726F70735F56696577020000000B0048656C704B6579776F
      7264050000001904000009040000070400001604000022040000040048696E74
      0500000019040000090400000704000016040000220400000000000020000000
      090061466C6970486F727A05000000070043617074696F6E0300000009041200
      466C69702026686F72697A6F6E74616C6C7919041700CEF2F0E0E7E8F2FC2026
      E3EEF0E8E7EEEDF2E0EBFCEDEE22041700CEF2F0E0E7E8F2FC2026E3EEF0E8E7
      EEEDF2E0EBFCEDEE080043617465676F72790100000009040500546F6F6C730B
      0048656C704B6579776F72640100000009040000040048696E74030000000904
      2D00466C697020686F72697A6F6E74616C6C797C466C69702074686520696D61
      676520686F72697A6F6E74616C6C7919043900CEF2F0E0E7E8F2FC20E3EEF0E8
      E7EEEDF2E0EBFCEDEE7CCEF2F0E0E7E8F2FC20E8E7EEE1F0E0E6E5EDE8E520E3
      EEF0E8E7EEEDF2E0EBFCEDEE22043900CEF2F0E0E7E8F2FC20E3EEF0E8E7EEED
      F2E0EBFCEDEE7CCEF2F0E0E7E8F2FC20E8E7EEE1F0E0E6E5EDE8E520E3EEF0E8
      E7EEEDF2E0EBFCEDEE12005365636F6E6461727953686F727443757473010000
      00090400000000000000000000090061466C6970566572740500000007004361
      7074696F6E0300000009041000466C69702026766572746963616C6C79190415
      00CEF2F0E0E7E8F2FC2026E2E5F0F2E8EAE0EBFCEDEE22041500CEF2F0E0E7E8
      F2FC2026E2E5F0F2E8EAE0EBFCEDEE080043617465676F727901000000090405
      00546F6F6C730B0048656C704B6579776F72640100000009040000040048696E
      740300000009042900466C697020766572746963616C6C797C466C6970207468
      6520696D61676520766572746963616C6C7919043500CEF2F0E0E7E8F2FC20E2
      E5F0F2E8EAE0EBFCEDEE7CCEF2F0E0E7E8F2FC20E8E7EEE1F0E0E6E5EDE8E520
      E2E5F0F2E8EAE0EBFCEDEE22043500CEF2F0E0E7E8F2FC20E2E5F0F2E8EAE0EB
      FCEDEE7CCEF2F0E0E7E8F2FC20E8E7EEE1F0E0E6E5EDE8E520E2E5F0F2E8EAE0
      EBFCEDEE12005365636F6E6461727953686F7274437574730100000009040000
      00000000000000000600616C4D61696E00000000000000000000000008006152
      6F746174653005000000070043617074696F6E0300000009040C00264E6F2072
      6F746174696F6E19040D0026C1E5E720EFEEE2EEF0EEF2E022040D0026C1E5E7
      20EFEEE2EEF0EEF2E0080043617465676F72790100000009040500546F6F6C73
      0B0048656C704B6579776F72640100000009040000040048696E740300000009
      042D004E6F20726F746174696F6E7C446F6E2774206170706C7920726F746174
      696F6E20746F2074686520696D61676519042F00C1E5E720EFEEE2EEF0EEF2E0
      7CCDE520EFF0E8ECE5EDFFF2FC20EFEEE2EEF0EEF220EA20E8E7EEE1F0E0E6E5
      EDE8FE22042F00C1E5E720EFEEE2EEF0EEF2E07CCDE520EFF0E8ECE5EDFFF2FC
      20EFEEE2EEF0EEF220EA20E8E7EEE1F0E0E6E5EDE8FE12005365636F6E646172
      7953686F727443757473010000000904000000000000000000000A0061526F74
      61746531383005000000070043617074696F6E0300000009040F00526F746174
      652062792026313830B019041200CFEEE2E5F0EDF3F2FC20EDE02026313830B0
      22041200CFEEE2E5F0EDF3F2FC20EDE02026313830B0080043617465676F7279
      0100000009040500546F6F6C730B0048656C704B6579776F7264010000000904
      0000040048696E740300000009042700526F7461746520627920313830B07C52
      6F746174652074686520696D61676520627920313830B019042F00CFEEE2E5F0
      EDF3F2FC20EDE020313830B07CCFEEE2E5F0EDF3F2FC20E8E7EEE1F0E0E6E5ED
      E8E520EDE020313830B022042F00CFEEE2E5F0EDF3F2FC20EDE020313830B07C
      CFEEE2E5F0EDF3F2FC20E8E7EEE1F0E0E6E5EDE8E520EDE020313830B0120053
      65636F6E6461727953686F727443757473010000000904000000000000000000
      000A0061526F7461746532373005000000070043617074696F6E030000000904
      1200526F746174652043435720627920392630B019042800CFEEE2E5F0EDF3F2
      FC20EFF0EEF2E8E220F7E0F1EEE2EEE920F1F2F0E5EBEAE820EDE020392630B0
      22042800CFEEE2E5F0EDF3F2FC20EFF0EEF2E8E220F7E0F1EEE2EEE920F1F2F0
      E5EBEAE820EDE020392630B0080043617465676F72790100000009040500546F
      6F6C730B0048656C704B6579776F72640100000009040000040048696E740300
      000009045200526F7461746520434357206279203930B07C526F746174652074
      686520696D61676520636F756E7465722D636C6F636B77697365206279203930
      B020286F7220636C6F636B7769736520627920323730B02919047C00CFEEE2E5
      F0EDF3F2FC20EFF0EEF2E8E220F7E0F1EEE2EEE920F1F2F0E5EBEAE820EDE020
      3930B07CCFEEE2E5F0EDF3F2FC20E8E7EEE1F0E0E6E5EDE8E520EFF0EEF2E8E2
      20F7E0F1EEE2EEE920F1F2F0E5EBEAE820EDE0203930B02028E8EBE820EFEE20
      F7E0F1EEE2EEE920F1F2F0E5EBEAE520EDE020323730B02922047C00CFEEE2E5
      F0EDF3F2FC20EFF0EEF2E8E220F7E0F1EEE2EEE920F1F2F0E5EBEAE820EDE020
      3930B07CCFEEE2E5F0EDF3F2FC20E8E7EEE1F0E0E6E5EDE8E520EFF0EEF2E8E2
      20F7E0F1EEE2EEE920F1F2F0E5EBEAE820EDE0203930B02028E8EBE820EFEE20
      F7E0F1EEE2EEE920F1F2F0E5EBEAE520EDE020323730B02912005365636F6E64
      61727953686F7274437574730100000009040000000000000000000009006152
      6F74617465393005000000070043617074696F6E0300000009041100526F7461
      746520435720627920263930B019042400CFEEE2E5F0EDF3F2FC20EFEE20F7E0
      F1EEE2EEE920F1F2F0E5EBEAE520EDE020263930B022042400CFEEE2E5F0EDF3
      F2FC20EFEE20F7E0F1EEE2EEE920F1F2F0E5EBEAE520EDE020263930B0080043
      617465676F72790100000009040500546F6F6C730B0048656C704B6579776F72
      640100000009040000040048696E740300000009043200526F74617465204357
      206279203930B07C526F746174652074686520696D61676520636C6F636B7769
      7365206279203930B019045300CFEEE2E5F0EDF3F2FC20EFEE20F7E0F1EEE2EE
      E920F1F2F0E5EBEAE520EDE0203930B07CCFEEE2E5F0EDF3F2FC20E8E7EEE1F0
      E0E6E5EDE8E520EFEE20F7E0F1EEE2EEE920F1F2F0E5EBEAE520EDE0203930B0
      22045300CFEEE2E5F0EDF3F2FC20EFEE20F7E0F1EEE2EEE920F1F2F0E5EBEAE5
      20EDE0203930B07CCFEEE2E5F0EDF3F2FC20E8E7EEE1F0E0E6E5EDE8E520EFEE
      20F7E0F1EEE2EEE920F1F2F0E5EBEAE520EDE0203930B012005365636F6E6461
      727953686F727443757473010000000904000000000000000000000B00615A6F
      6F6D41637475616C05000000070043617074696F6E0500000019040C00CC26E0
      F1F8F2E0E120313A3109040C005A6F6F6D202661637475616C07041300265461
      7473E463686C6963686572205A6F6F6D16040D0054616D616E686F2052652661
      6C22040C00CC26E0F1F8F2E0E120313A31080043617465676F72790500000019
      040000090404005A6F6F6D0704000016040000220400000B0048656C704B6579
      776F726405000000190400000904000007040000160400002204000004004869
      6E740500000019041600D3F1F2E0EDEEE2E8F2FC20ECE0F1F8F2E0E120313A31
      09040F00536574207A6F6F6D20746F20313A31070414005A6F6F6D2061756620
      313A31207374656C6C656E16041000416A7573746172207A6F6F6D20313A3122
      041600C2F1F2E0EDEEE2E8F2E820ECE0F1F8F2E0E120313A3112005365636F6E
      6461727953686F72744375747305000000190400000904000007040000160400
      002204000000000000000000000800615A6F6F6D466974050000000700436170
      74696F6E0500000019040E0026C220F0E0E7ECE5F020EEEAEDE009040B002646
      69742077696E646F770704150044656D202646656E7374657220616E70617373
      656E16040F00264D656C686F722074616D616E686F22040F0026D320F0EEE7EC
      B3F020E2B3EAEDE0080043617465676F72790500000019040000090404005A6F
      6F6D0704000016040000220400000B0048656C704B6579776F72640500000019
      04000009040000070400001604000022040000040048696E7405000000190423
      00D3F1F2E0EDEEE2E8F2FC20ECE0F1F8F2E0E120EFEE20F0E0E7ECE5F0E0EC20
      EEEAEDE009041600536574207A6F6F6D20746F206669742077696E646F770704
      20005A6F6F6D206175662046656E737465726772F6DF652065696E7374656C6C
      656E16042200416A7573746172207A6F6F6D2070617261206361626572206E61
      206A616E656C612022042400C2F1F2E0EDEEE2E8F2E820ECE0F1F8F2E0E120EF
      EE20F0EEE7ECB3F0E0F520E2B3EAEDE012005365636F6E6461727953686F7274
      4375747305000000190400000904000007040000160400002204000000000000
      000000000700615A6F6F6D496E05000000070043617074696F6E050000001904
      0A0026D3E2E5EBE8F7E8F2FC090408005A6F6F6D2026696E070408005A6F6F6D
      2026696E1604080026416D706C69617222040A0026C7E1B3EBFCF8E8F2E80800
      43617465676F72790500000019040000090404005A6F6F6D0704000016040000
      220400000B0048656C704B6579776F7264050000001904000009040000070400
      001604000022040000040048696E740500000019041F00D3E2E5EBE8F7E8F2FC
      7CD3E2E5EBE8F7E8F2FC20E8E7EEE1F0E0E6E5EDE8E5090419005A6F6F6D2069
      6E7C456E6C617267652074686520696D61676507041B005A6F6F6D20696E7C56
      65726772F6DF657274206461732042696C6416042100416D706C6961727C416D
      706C6961E7E36F20646120696D6167656D20766973746122041E00C7E1B3EBFC
      F8E8F2E87CC7E1B3EBFCF8E8F2E820E7EEE1F0E0E6E5EDEDFF12005365636F6E
      6461727953686F72744375747305000000190400000904000007040000160400
      002204000000000000000000000800615A6F6F6D4F7574050000000700436170
      74696F6E0500000019040A00D326ECE5EDFCF8E8F2FC090409005A6F6F6D206F
      752674070409005A6F6F6D206F7526741604080026526564757A697222040900
      C726ECE5EDF8E8F2E8080043617465676F72790500000019040000090404005A
      6F6F6D0704000016040000220400000B0048656C704B6579776F726405000000
      1904000009040000070400001604000022040000040048696E74050000001904
      1F00D3ECE5EDFCF8E8F2FC7CD3ECE5EDFCF8E8F2FC20E8E7EEE1F0E0E6E5EDE8
      E5090417005A6F6F6D206F75747C5A6F6F6D20696D616765206F757407041500
      5A6F6F6D206F75747C5A6F6F6D742068657261757316041F00526564757A6972
      7C52656475E7E36F20646120696D6167656D20766973746122041C00C7ECE5ED
      F8E8F2E87CC7ECE5EDF8E8F2E820E7EEE1F0E0E6E5EDEDFF12005365636F6E64
      61727953686F7274437574730500000019040000090400000704000016040000
      220400000000000000000000090062466C6970486F727A000000000000000000
      000000090062466C697056657274000000000000000000000000080062526F74
      617465300000000000000000000000000A0062526F7461746531383000000000
      00000000000000000A0062526F74617465323730000000000000000000000000
      090062526F7461746539300000000000000000000000000F0062566965775A6F
      6F6D41637475616C0000000000000000000000000C0062566965775A6F6F6D46
      69740000000000000000000000000B0062566965775A6F6F6D496E0000000000
      000000000000000C0062566965775A6F6F6D4F75740000000000000000000000
      000A0063625669657746696C6505000000070043617074696F6E050000001904
      0000090400000704000016040000220400000B004564697443617074696F6E05
      0000001904000009040000070400001604000022040000040048696E74050000
      0019041200D4E0E9EB20E4EBFF20EFF0EEF1ECEEF2F0E009040C0046696C6520
      746F207669657707041000416E67657A6569677465732042696C641604120056
      697375616C697A6172206172717569766F22041200D4E0E9EB20E4EBFF20EFE5
      F0E5E3EBFFE4F30700537472696E677305000000190400000904000007040000
      1604000022040000040054657874050000001904000009040000070400001604
      00002204000000000000000000000800646B426F74746F6D020000000B004865
      6C704B6579776F72640100000009040000040048696E74010000000904000000
      000000000000000600646B4C656674020000000B0048656C704B6579776F7264
      0100000009040000040048696E74010000000904000000000000000000000700
      646B5269676874020000000B0048656C704B6579776F72640100000009040000
      040048696E74010000000904000000000000000000000500646B546F70020000
      000B0048656C704B6579776F72640100000009040000040048696E7401000000
      090400000000000000000000080064746C734D61696E00000000000000000000
      00000500694D61696E020000000B0048656C704B6579776F7264050000001904
      000009040000070400001604000022040000040048696E740500000019040000
      0904000007040000160400002204000000000000000000000600706D4D61696E
      000000000000000000000000060074624D61696E03000000070043617074696F
      6E0500000019041C00CEF1EDEEE2EDE0FF20EFE0EDE5EBFC20E8EDF1F2F0F3EC
      E5EDF2EEE209040C004D61696E20546F6F6C62617207040C004D61696E20546F
      6F6C62617216040C004D61696E20546F6F6C62617222041C00CEF1EDEEE2EDE0
      FF20EFE0EDE5EBFC20E8EDF1F2F0F3ECE5EDF2EEE20B0043686576726F6E4869
      6E740500000019040B00C5F9B820EAEDEEEFEAE87C09040D004D6F7265206275
      74746F6E737C070416005765697465726520536368616C74666CE46368656E7C
      16040C004D61697320626F74F565737C22040A00D9E520EAEDEEEFEAE87C0B00
      48656C704B6579776F7264050000001904000009040000070400001604000022
      04000000000000000000000D007462536570466C6970486F727A010000000400
      48696E740100000009040000000000000000000007007462546F6F6C73020000
      00070043617074696F6E0100000009040500546F6F6C730B0048656C704B6579
      776F726401000000090400000000000000000000}
  end
end
