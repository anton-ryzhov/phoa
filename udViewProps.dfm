inherited dViewProps: TdViewProps
  Caption = 'Properties: photo album view'
  ClientHeight = 435
  ClientWidth = 426
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  inherited bvBottom: TBevel
    Top = 398
    Width = 426
  end
  object lName: TLabel [1]
    Left = 12
    Top = 12
    Width = 31
    Height = 13
    Caption = '&Name:'
    FocusControl = eName
  end
  object lGrouping: TLabel [2]
    Left = 12
    Top = 52
    Width = 111
    Height = 13
    Caption = '&Picture grouping order:'
  end
  inherited pButtonsBottom: TPanel
    Top = 400
    Width = 426
    DesignSize = (
      426
      35)
    inherited bCancel: TButton
      Left = 266
    end
    inherited bOK: TButton
      Left = 186
    end
    inherited bHelp: TButton
      Left = 344
    end
  end
  object eName: TEdit [4]
    Left = 12
    Top = 28
    Width = 403
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 1
    OnChange = DlgDataChange
  end
  object tvGrouping: TVirtualStringTree [5]
    Left = 12
    Top = 68
    Width = 402
    Height = 161
    Anchors = [akLeft, akTop, akRight, akBottom]
    Header.AutoSizeIndex = 0
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'MS Shell Dlg 2'
    Header.Font.Style = []
    Header.Options = [hoAutoResize, hoColumnResize, hoVisible]
    Images = fMain.ilActionsSmall
    ParentBackground = False
    PopupMenu = pmGrouping
    TabOrder = 2
    TreeOptions.AutoOptions = [toAutoDropExpand, toAutoScroll, toAutoScrollOnExpand, toAutoTristateTracking]
    TreeOptions.MiscOptions = [toAcceptOLEDrop, toCheckSupport, toFullRepaintOnResize, toGridExtensions, toInitOnSave, toToggleOnDblClick, toWheelPanning, toFullRowDrag]
    TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowHorzGridLines, toShowTreeLines, toShowVertGridLines, toThemeAware, toUseBlendedImages]
    TreeOptions.SelectionOptions = [toExtendedFocus, toRightClickSelect]
    OnAfterCellPaint = tvGroupingAfterCellPaint
    OnChange = tvGroupingChange
    OnChecked = tvGroupingChecked
    OnDragAllowed = tvGroupingDragAllowed
    OnDragOver = tvGroupingDragOver
    OnDragDrop = tvGroupingDragDrop
    OnGetText = tvGroupingGetText
    OnGetImageIndex = tvGroupingGetImageIndex
    OnInitNode = tvGroupingInitNode
    OnKeyAction = tvGroupingKeyAction
    OnMouseDown = tvGroupingMouseDown
    Columns = <
      item
        Options = [coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible]
        Position = 0
        Width = 248
      end
      item
        Options = [coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible]
        Position = 1
        Width = 150
      end>
    WideDefaultText = ''
  end
  inline frSorting: TfrSorting [6]
    Left = 12
    Top = 231
    Width = 402
    Height = 154
    Anchors = [akLeft, akRight, akBottom]
    TabOrder = 3
    inherited lMain: TLabel
      Width = 402
      Caption = '&Sort pictures in each group by:'
    end
    inherited tvMain: TVirtualStringTree
      Width = 402
      Height = 139
      Columns = <
        item
          Options = [coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible]
          Position = 0
          Width = 248
        end
        item
          Options = [coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible]
          Position = 1
          Width = 150
        end>
      WideDefaultText = ''
    end
    inherited pmMain: TTBXPopupMenu
      inherited ipmsmProp: TTBXSubmenuItem
        Caption = '&Picture property'
      end
      inherited ipmDelete: TTBXItem
        Caption = '&Delete'
      end
      inherited ipmMoveUp: TTBXItem
        Caption = 'Move &up'
      end
      inherited ipmMoveDown: TTBXItem
        Caption = 'Move do&wn'
      end
    end
  end
  inherited dtlsMain: TDTLanguageSwitcher
    Left = 72
    Top = 104
    LangData = {
      0A00645669657750726F707304000000070043617074696F6E05000000190423
      00D1E2EEE9F1F2E2E03A20EFF0E5E4F1F2E0E2EBE5EDE8E520F4EEF2EEE0EBFC
      E1EEECE009041C0050726F706572746965733A2070686F746F20616C62756D20
      7669657707042000456967656E736368616674656E3A20466F746F616C62756D
      20416E73696368741604230050726F7072696564616465733A2076697375616C
      697A61E7E36F20646F20E16C62756D22042600C2EBE0F1F2E8E2EEF1F2B33A20
      EFF0E5E4F1F2E0E2EBE5EDEDFF20F4EEF2EEE0EBFCE1EEECF3080048656C7046
      696C650500000019040000090400000704000016040000220400000B0048656C
      704B6579776F7264050000001904000009040000070400001604000022040000
      040048696E740500000019040000090400000704000016040000220400000200
      0000160053436F6C4E616D655F47726F757050726F7065727479050000000904
      1000506963747572652070726F706572747919041400D1E2EEE9F1F2E2EE20E8
      E7EEE1F0E0E6E5EDE8FF07040F0042696C64656967656E736368616674160415
      0050726F707269656461646520646120696D6167656D22041600C2EBE0F1F2E8
      E2B3F1F2FC20E7EEE1F0E0E6E5EDEDFF150053436F6C4E616D655F47726F7570
      556E6F776E65640500000019041700CDE5EAEBE0F1F1E8F42E20E220EEF2E42E
      20EFE0EFEAE509041A00556E636C617373696669656420696E206F776E20666F
      6C646572070426004E69636874206B6C6173736966697A696572746520696E20
      656967656E656D204F72646E6572160421004EE36F20636C6173736966696361
      646F206E61207072F37072696120706173746122041600CDE5EAEBE0F1E8F42E
      20E220EEEAF02E20EFE0EFF6B31100000007006243616E63656C030000000700
      43617074696F6E0500000019040600CEF2ECE5EDE00904060043616E63656C07
      04090041626272656368656E1604080043616E63656C617222040700C2B3E4EC
      B3EDE00B0048656C704B6579776F726405000000190400000904000007040000
      1604000022040000040048696E74050000001904000009040000070400001604
      000022040000000000000000000005006248656C700300000007004361707469
      6F6E0500000019040700D1EFF0E0E2EAE00904040048656C700704050048696C
      666516040500416A75646122040700C4EEE2B3E4EAE00B0048656C704B657977
      6F7264050000001904000009040000070400001604000022040000040048696E
      7405000000190400000904000007040000160400002204000000000000000000
      000300624F4B03000000070043617074696F6E0500000019040200CECA090402
      004F4B070402004F4B160402004F4B22040200CECA0B0048656C704B6579776F
      7264050000001904000009040000070400001604000022040000040048696E74
      0500000019040000090400000704000016040000220400000000000000000000
      08006276426F74746F6D020000000B0048656C704B6579776F72640100000009
      040000040048696E7401000000090400000000000000000000080064746C734D
      61696E0000000000000000000000000500654E616D65040000000B0048656C70
      4B6579776F726405000000190400000904000007040000160400002204000004
      0048696E74050000001904000009040000070400001604000022040000070049
      6D654E616D650500000019040000090400000704000016040000220400000400
      5465787405000000190400000904000007040000160400002204000000000000
      0000000009006672536F7274696E67020000000B0048656C704B6579776F7264
      050000001904000009040000070400001604000022040000040048696E740500
      0000190400000904000007040000160400002204000000000000080000000900
      69706D44656C65746502000000070043617074696F6E050000001904080026D3
      E4E0EBE8F2FC090407002644656C65746507040800264CF6736368656E160408
      00264578636C7569722204090026C2E8E4E0EBE8F2E8040048696E7405000000
      190400000904000007040000160400002204000000000000000000000B006970
      6D4D6F7665446F776E02000000070043617074696F6E0500000019040E00D1E4
      E2E8EDF3F2FC20E226EDE8E709040A004D6F766520646F26776E07040B004E61
      63682026756E74656E160411004D6F76657220267061726120626169786F2204
      0D00C7F0F3F8E8F2E82026F3EDE8E7040048696E740500000019040000090400
      000704000016040000220400000000000000000000090069706D4D6F76655570
      02000000070043617074696F6E0500000019040F00D1E4E2E8EDF3F2FC2026E2
      E2E5F0F5090408004D6F76652026757007040A004E61636820266F62656E1604
      10004D6F7665722026706172612063696D6122040E00C7F0F3F8E8F2E820E226
      E3EEF0F3040048696E7405000000190400000904000007040000160400002204
      00000000000000000000060069706D53657001000000040048696E7405000000
      1904000009040000070400001604000022040000000000000000000009006970
      6D736D50726F7002000000070043617074696F6E050000001904150026D1E2EE
      E9F1F2E2EE20E8E7EEE1F0E0E6E5EDE8FF090411002650696374757265207072
      6F7065727479070410002642696C64656967656E736368616674160416002650
      726F707269656461646520646120696D6167656D22041700C226EBE0F1F2E8E2
      B3F1F2FC20E7EEE1F0E0E6E5EDEDFF040048696E740500000019040000090400
      00070400001604000022040000000000000000000005006C4D61696E03000000
      070043617074696F6E0500000019042900CFEE26F0FFE4EEEA20F1EEF0F2E8F0
      EEE2EAE820E8E7EEE1F0E0E6E5EDE8E920E220E3F0F3EFEFE53A090420002653
      6F727420706963747572657320696E20656163682067726F75702062793A0704
      260026536F7274696572652042696C64657220696E206A656465722047727570
      7065206E6163683A1604260026436C61737369666963617220696D6167656D20
      656D206361646120677275706F20706F723A22042600CFEE26F0FFE4EEEA20F1
      EEF0F2F3E2E0EDEDFF20E7EEE1F0E0E6E5EDFC20F320E3F0F3EFB33A0B004865
      6C704B6579776F72640500000019040000090400000704000016040000220400
      00040048696E7405000000190400000904000007040000160400002204000000
      000000000000000600706D4D61696E000000000000000000000000060074764D
      61696E030000001000436C6970626F617264466F726D61747305000000190400
      00090400000704000016040000220400000B0048656C704B6579776F72640500
      00001904000009040000070400001604000022040000040048696E7405000000
      1904000009040000070400001604000022040000000000000000000009006970
      6D44656C65746502000000070043617074696F6E050000001904080026D3E4E0
      EBE8F2FC090407002644656C65746507040800264CF6736368656E1604080026
      4578636C7569722204090026C2E8E4E0EBE8F2E8040048696E74050000001904
      00000904000007040000160400002204000000000000000000000B0069706D4D
      6F7665446F776E02000000070043617074696F6E0500000019040E00D1E4E2E8
      EDF3F2FC20E226EDE8E709040A004D6F766520646F26776E07040B004E616368
      2026756E74656E160411004D6F76657220267061726120626169786F22040D00
      C7F0F3F8E8F2E82026F3EDE8E7040048696E7405000000190400000904000007
      04000016040000220400000000000000000000090069706D4D6F766555700200
      0000070043617074696F6E0500000019040F00D1E4E2E8EDF3F2FC2026E2E2E5
      F0F5090408004D6F76652026757007040A004E61636820266F62656E16041000
      4D6F7665722026706172612063696D6122040E00C7F0F3F8E8F2E820E226E3EE
      F0F3040048696E74050000001904000009040000070400001604000022040000
      0000000000000000060069706D53657001000000040048696E74050000001904
      0000090400000704000016040000220400000000000000000000090069706D73
      6D50726F7002000000070043617074696F6E050000001904150026D1E2EEE9F1
      F2E2EE20E8E7EEE1F0E0E6E5EDE8FF0904110026506963747572652070726F70
      65727479070410002642696C64656967656E736368616674160415002650726F
      7072696564616420646120696D6167656D22041700C226EBE0F1F2E8E2B3F1F2
      FC20E7EEE1F0E0E6E5EDEDFF040048696E740500000019040000090400000704
      00001604000022040000000000000000000009006C47726F7570696E67030000
      00070043617074696F6E050000001904210026CFEEF0FFE4EEEA20E3F0F3EFEF
      E8F0EEE2EAE820E8E7EEE1F0E0E6E5EDE8E93A09041800265069637475726520
      67726F7570696E67206F726465723A07041500264772757070696572756E6773
      6F72646E756E673A16042200264F7264656D206465206167727570616D656E74
      6F2064617320696D6167656E733A22041F0026CFEEF0FFE4EEEA20F3E3F0F3EF
      EEE2E0EDEDFF20E7EEE1F0E0E6E5EDFC3A0B0048656C704B6579776F72640500
      00001904000009040000070400001604000022040000040048696E7405000000
      1904000009040000070400001604000022040000000000000000000005006C4E
      616D6503000000070043617074696F6E0500000019040E0026CDE0E8ECE5EDEE
      E2E0EDE8E53A09040600264E616D653A07040600264E616D653A16040600264E
      6F6D653A22040E0026CDE0E9ECE5EDF3E2E0EDEDFF3A0B0048656C704B657977
      6F7264050000001904000009040000070400001604000022040000040048696E
      7405000000190400000904000007040000160400002204000000000000000000
      000E0070427574746F6E73426F74746F6D03000000070043617074696F6E0100
      0000090400000B0048656C704B6579776F72640100000009040000040048696E
      74010000000904000000000000000000000A00706D47726F7570696E67000000
      0000000000000000000A00747647726F7570696E67030000001000436C697062
      6F617264466F726D617473050000001904000009040000070400001604000022
      0400000B0048656C704B6579776F726405000000190400000904000007040000
      1604000022040000040048696E74050000001904000009040000070400001604
      0000220400000000000000000000}
  end
  object pmGrouping: TTBXPopupMenu
    Images = fMain.ilActionsSmall
    Left = 32
    Top = 104
    object ipmsmProp: TTBXSubmenuItem
      Caption = '&Picture property'
    end
    object ipmDelete: TTBXItem
      Caption = '&Delete'
      ImageIndex = 7
      ShortCut = 46
      OnClick = ipmDeleteClick
    end
    object ipmSep: TTBXSeparatorItem
    end
    object ipmMoveUp: TTBXItem
      Caption = 'Move &up'
      ImageIndex = 55
      ShortCut = 16422
      OnClick = ipmMoveUpClick
    end
    object ipmMoveDown: TTBXItem
      Caption = 'Move do&wn'
      ImageIndex = 56
      ShortCut = 16424
      OnClick = ipmMoveDownClick
    end
  end
end
