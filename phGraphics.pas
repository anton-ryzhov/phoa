//**********************************************************************************************************************
//  $Id: phGraphics.pas,v 1.1 2004-05-28 13:30:13 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Copyright 2002-2004 Dmitry Kann, http://phoa.narod.ru
//**********************************************************************************************************************
unit phGraphics;

interface
uses Windows, Graphics, GR32;

type

   // �������� ����� ������ ��������� ������ (���� -> �����) 
  TChannelByteMap = Array[Byte] of Byte;

   // ����� ������ �� �������
  TColor32Map = class(TObject)
  private
     // Prop storage
    FMapA: TChannelByteMap;
    FMapG: TChannelByteMap;
    FMapR: TChannelByteMap;
    FMapB: TChannelByteMap;
     // ��������� ������ ��������� ����������
    procedure ChannelBuildLinear(var Map: TChannelByteMap);
     // ��������� ������ ����������
    procedure ChannelBuildConstant(var Map: TChannelByteMap; bValue: Byte);
  public
    constructor Create;
     // ��������� ������ ��������� ����������
    procedure BuildLinear;
     // ��������� ����� � ���������� �����
    function  ApplyToColor(c: TColor32): TColor32;
     // Props
     // -- ����� �������
    property MapR: TChannelByteMap read FMapR;
    property MapG: TChannelByteMap read FMapG;
    property MapB: TChannelByteMap read FMapB;
    property MapA: TChannelByteMap read FMapA;
  end;

const
  BColor_Alpha_Transparent = $00;
  BColor_Alpha_Opaque      = $FF;

implementation

uses phUtils;

   //===================================================================================================================
   // TColor32Map
   //===================================================================================================================

  function TColor32Map.ApplyToColor(c: TColor32): TColor32;
//  type TColor32Rec = packed record b,g,r,a: Byte; end;
//  var
//    cc: TColor32Rec absolute c;
//    cr: TColor32Rec absolute Result;
  begin
//    TColor32Rec(Result).a := FMapA[TColor32Rec(c).a];
//    TColor32Rec(Result).b := FMapB[TColor32Rec(c).b];
//    TColor32Rec(Result).g := FMapG[TColor32Rec(c).g];
//    TColor32Rec(Result).r := FMapR[TColor32Rec(c).r];

  asm
    xor edx, edx
    mov Result,edx
     // Put B value
    mov dl, byte ptr [c+0]
    mov dl, byte ptr [eax+FMapB+edx]
    mov byte ptr [Result+0], dl
     // Put G value
    mov dl, byte ptr [c+1]
    mov dl, byte ptr [eax+FMapG+edx]
    mov byte ptr [Result+1], dl
     // Put R value
    mov dl, byte ptr [c+2]
    mov dl, byte ptr [eax+FMapR+edx]
    mov byte ptr [Result+2], dl
     // Put A value
    mov dl, byte ptr [c+3]
    mov dl, byte ptr [eax+FMapA+edx]
    mov byte ptr [Result+3], dl
  end;
  end;

  procedure TColor32Map.BuildLinear;
  begin
     // ��������� �������� ������� ��������� ����������
    ChannelBuildLinear(FMapR);
    ChannelBuildLinear(FMapG);
    ChannelBuildLinear(FMapB);
     // �����-����� ������ ������������
    ChannelBuildConstant(FMapA, BColor_Alpha_Opaque);
  end;

  procedure TColor32Map.ChannelBuildConstant(var Map: TChannelByteMap; bValue: Byte);
  begin
    FillChar(Map, SizeOf(Map), bValue);
  end;

  procedure TColor32Map.ChannelBuildLinear(var Map: TChannelByteMap);
  var b: Byte;
  begin
    for b := Low(Byte) to High(Byte) do Map[b] := iif(b<128, b*2, 255);
  end;

  constructor TColor32Map.Create;
  begin
    inherited Create;
    BuildLinear;
  end;

end.
