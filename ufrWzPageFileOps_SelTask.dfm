inherited frWzPageFileOps_SelTask: TfrWzPageFileOps_SelTask
  object lCopyFiles: TLabel
    Left = 28
    Top = 24
    Width = 543
    Height = 29
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 
      'Copies the files of pictures you select, in the specified folder' +
      '. Use this option to prepare photo album to write onto a CD or D' +
      'VD'
    Transparent = False
    WordWrap = True
  end
  object lMoveFiles: TLabel
    Left = 28
    Top = 76
    Width = 543
    Height = 29
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 
      'Moves the files of pictures you select, into the specified folde' +
      'r, and updates picture file links appropriately'
    Transparent = False
    WordWrap = True
  end
  object lDeleteFiles: TLabel
    Left = 28
    Top = 128
    Width = 543
    Height = 29
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 
      'Deletes pictures you select, and physically deletes correspondin' +
      'g files. Use this option to delete unwanted picture files'
    Transparent = False
    WordWrap = True
  end
  object lRepairFileLinks: TLabel
    Left = 28
    Top = 232
    Width = 543
    Height = 29
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 
      'Allows you to repair broken file links by finding the files in t' +
      'he specified folder, and, optionally, to delete pictures no long' +
      'er associated with valid (existent) files'
    Transparent = False
    Visible = False
    WordWrap = True
  end
  object lNBUndoable: TLabel
    Left = 0
    Top = 264
    Width = 576
    Height = 20
    Align = alBottom
    AutoSize = False
    Caption = #8226' NB: These operations are not undoable!'
    Layout = tlCenter
    WordWrap = True
  end
  object lRebuildThumbs: TLabel
    Left = 28
    Top = 180
    Width = 543
    Height = 29
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 
      'Rereads the picture files, recreates the thumbnails and updates ' +
      'the file-related information, such as image dimensions'
    Transparent = False
    WordWrap = True
  end
  object rbCopyFiles: TRadioButton
    Left = 4
    Top = 4
    Width = 567
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = '&Copy picture files to a folder'
    TabOrder = 0
    OnClick = PageDataChange
  end
  object rbMoveFiles: TRadioButton
    Left = 4
    Top = 56
    Width = 551
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = '&Move picture files to a folder'
    TabOrder = 1
    OnClick = PageDataChange
  end
  object rbDeleteFiles: TRadioButton
    Left = 4
    Top = 108
    Width = 551
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = '&Delete pictures and files'
    TabOrder = 2
    OnClick = PageDataChange
  end
  object rbRepairFileLinks: TRadioButton
    Left = 4
    Top = 212
    Width = 567
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Re&pair picture file links'
    TabOrder = 4
    Visible = False
    OnClick = PageDataChange
  end
  object rbRebuildThumbs: TRadioButton
    Left = 4
    Top = 160
    Width = 567
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = '&Rebuild thumbnails'
    TabOrder = 3
    OnClick = PageDataChange
  end
  object dtlsMain: TDTLanguageSwitcher
    Language = 1033
    Left = 508
    Top = 264
    LangData = {
      17006672577A5061676546696C654F70735F53656C5461736B020000000B0048
      656C704B6579776F7264020000000904000019040000040048696E7402000000
      0904000019040000000000000C000000080064746C734D61696E000000000000
      0000000000000A006C436F707946696C657303000000070043617074696F6E02
      00000009048200436F70696573207468652066696C6573206F66207069637475
      72657320796F752073656C6563742C20696E2074686520737065636966696564
      20666F6C6465722E205573652074686973206F7074696F6E20746F2070726570
      6172652070686F746F20616C62756D20746F207772697465206F6E746F206120
      4344206F722044564419048800CAEEEFE8F0F3E5F220F4E0E9EBFB20E2FBE1F0
      E0EDEDFBF520C2E0ECE820E8E7EEE1F0E0E6E5EDE8E920E220E7E0E4E0EDEDF3
      FE20EFE0EFEAF32E20C8F1EFEEEBFCE7F3E9F2E520FDF2F320EEEFF6E8FE2C20
      F7F2EEE1FB20EFEEE4E3EEF2EEE2E8F2FC20F4EEF2EEE0EBFCE1EEEC20E4EBFF
      20E7E0EFE8F1E820EDE020434420E8EBE8204456440B0048656C704B6579776F
      7264020000000904000019040000040048696E74020000000904000019040000
      00000000000000000C006C44656C65746546696C657303000000070043617074
      696F6E020000000904790044656C6574657320706963747572657320796F7520
      73656C6563742C20616E6420706879736963616C6C792064656C657465732063
      6F72726573706F6E64696E672066696C65732E205573652074686973206F7074
      696F6E20746F2064656C65746520756E77616E74656420706963747572652066
      696C657319048D00D3E4E0EBFFE5F220E2FBE1F0E0EDEDFBE520C2E0ECE820E8
      E7EEE1F0E0E6E5EDE8FF20E820F4E8E7E8F7E5F1EAE820F1F2E8F0E0E5F220F1
      EEEEF2E2E5F2F1F2E2F3FEF9E8E520F4E0E9EBFB20F120E4E8F1EAE02E20C8F1
      EFEEEBFCE7F3E9F2E520FDF2F320EEEFF6E8FE20E4EBFF20F3E4E0EBE5EDE8FF
      20EDE5EDF3E6EDFBF520E8E7EEE1F0E0E6E5EDE8E90B0048656C704B6579776F
      7264020000000904000019040000040048696E74020000000904000019040000
      00000000000000000A006C4D6F766546696C657303000000070043617074696F
      6E0200000009046F004D6F766573207468652066696C6573206F662070696374
      7572657320796F752073656C6563742C20696E746F2074686520737065636966
      69656420666F6C6465722C20616E642075706461746573207069637475726520
      66696C65206C696E6B7320617070726F7072696174656C7919047B00CFE5F0E5
      ECE5F9E0E5F220F4E0E9EBFB20E2FBE1F0E0EDEDFBF520C2E0ECE820E8E7EEE1
      F0E0E6E5EDE8E920E220E7E0E4E0EDEDF3FE20EFE0EFEAF320E820F1EEEEF2E2
      E5F2F1F2E2F3FEF9E8EC20EEE1F0E0E7EEEC20E8F1EFF0E0E2EBFFE5F220F1F1
      FBEBEAE820E8E7EEE1F0E0E6E5EDE8E920EDE020EDE8F50B0048656C704B6579
      776F7264020000000904000019040000040048696E7402000000090400001904
      000000000000000000000B006C4E42556E646F61626C65030000000700436170
      74696F6E020000000904280095204E423A205468657365206F7065726174696F
      6E7320617265206E6F7420756E646F61626C652119043D009520C2CDC8CCC0CD
      C8C53A20FDF2E820EEEFE5F0E0F6E8E820EDE520ECEEE3F3F220E1FBF2FC20E2
      EFEEF1EBE5E4F1F2E2E8E820EEF2ECE5EDE5EDFB210B0048656C704B6579776F
      7264020000000904000019040000040048696E74020000000904000019040000
      00000000000000000E006C52656275696C645468756D62730300000007004361
      7074696F6E020000000904760052657265616473207468652070696374757265
      2066696C65732C2072656372656174657320746865207468756D626E61696C73
      20616E642075706461746573207468652066696C652D72656C6174656420696E
      666F726D6174696F6E2C207375636820617320696D6167652064696D656E7369
      6F6E7319048000CFE5F0E5F7E8F2FBE2E0E5F220F4E0E9EBFB20E8E7EEE1F0E0
      E6E5EDE8E92C20EFE5F0E5F1F2F0E0E8E2E0E5F220FDF1EAE8E7FB20E820EEE1
      EDEEE2EBFFE5F220E8EDF4EEF0ECE0F6E8FE2C20F1E2FFE7E0EDEDF3FE20F120
      F4E0E9EBEEEC209720F2E0EAF3FE2C20EAE0EA20F0E0E7ECE5F0FB20E8E7EEE1
      F0E0E6E5EDE8FF0B0048656C704B6579776F7264020000000904000019040000
      040048696E74020000000904000019040000000000000000000010006C526570
      61697246696C654C696E6B7303000000070043617074696F6E020000000904A9
      00416C6C6F777320796F7520746F207265706169722062726F6B656E2066696C
      65206C696E6B732062792066696E64696E67207468652066696C657320696E20
      7468652073706563696669656420666F6C6465722C20616E642C206F7074696F
      6E616C6C792C20746F2064656C657465207069637475726573206E6F206C6F6E
      676572206173736F63696174656420776974682076616C696420286578697374
      656E74292066696C65731904A400CFEEE7E2EEEBFFE5F220E2EEF1F1F2E0EDEE
      E2E8F2FC20E8F1EFEEF0F7E5EDEDFBE520F1F1FBEBEAE820EDE020F4E0E9EBFB
      20EFF3F2B8EC20EFEEE8F1EAE020EFEEE4F5EEE4FFF9E8F520F4E0E9EBEEE220
      E220E7E0E4E0EDEDEEE920EFE0EFEAE52C20E020F2E0EAE6E520F3E4E0EBE8F2
      FC20E8E7EEE1F0E0E6E5EDE8FF2C20F1F1FBEBE0FEF9E8E5F1FF20EDE020EDE5
      F1F3F9E5F1F2E2F3FEF9E8E520F4E0E9EBFB0B0048656C704B6579776F726402
      0000000904000019040000040048696E74020000000904000019040000000000
      00000000000B007262436F707946696C657303000000070043617074696F6E02
      00000009041F0026436F707920706963747572652066696C657320746F206120
      666F6C6465721904250026CAEEEFE8F0EEE2E0F2FC20F4E0E9EBFB20E8E7EEE1
      F0E0E6E5EDE8E920E220EFE0EFEAF30B0048656C704B6579776F726402000000
      0904000019040000040048696E74020000000904000019040000000000000000
      00000D00726244656C65746546696C657303000000070043617074696F6E0200
      000009041A002644656C65746520706963747572657320616E642066696C6573
      19041C0026D3E4E0EBE8F2FC20E8E7EEE1F0E0E6E5EDE8FF20E820F4E0E9EBFB
      0B0048656C704B6579776F7264020000000904000019040000040048696E7402
      000000090400001904000000000000000000000B0072624D6F766546696C6573
      03000000070043617074696F6E0200000009041F00264D6F7665207069637475
      72652066696C657320746F206120666F6C6465721904260026CFE5F0E5ECE5F1
      F2E8F2FC20F4E0E9EBFB20E8E7EEE1F0E0E6E5EDE8E920E220EFE0EFEAF30B00
      48656C704B6579776F7264020000000904000019040000040048696E74020000
      00090400001904000000000000000000000F00726252656275696C645468756D
      627303000000070043617074696F6E02000000090413002652656275696C6420
      7468756D626E61696C7319041300CFE526F0E5F1F2F0EEE8F2FC20FDF1EAE8E7
      FB0B0048656C704B6579776F7264020000000904000019040000040048696E74
      0200000009040000190400000000000000000000110072625265706169724669
      6C654C696E6B7303000000070043617074696F6E0200000009041A0052652670
      61697220706963747572652066696C65206C696E6B7319041D0026C2EEF1F1F2
      E0EDEEE2E8F2FC20F1F1FBEBEAE820EDE020F4E0E9EBFB0B0048656C704B6579
      776F7264020000000904000019040000040048696E7402000000090400001904
      00000000000000000000}
  end
end
