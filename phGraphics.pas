//**********************************************************************************************************************
//  $Id: phGraphics.pas,v 1.7 2004-09-24 16:44:29 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Copyright 2002-2004 DK Software, http://www.dk-soft.org/
//**********************************************************************************************************************
unit phGraphics;

interface
uses Windows, SysUtils, Classes, Graphics, GR32, ConsVars;

type

   // �������� ����� ������ ��������� ������ (���� -> �����)
  TChannelByteMap = Array[Byte] of Byte;

   //===================================================================================================================
   // ����� ������ �� �������
   //===================================================================================================================

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

   //===================================================================================================================
   // �������������� ����������� (����� ���������� ��������������)
   //===================================================================================================================

  TPicTransform = class(TObject)
  private
     // ������� ���������� ���������� ��������������
    FApplyLock: Integer;
     // ��������� ���������� [����������] �������� ��������
    FAppliedRotation: TPicRotation;
     // ��������� ���������� [����������] �������� ���������
    FAppliedFlips: TPicFlips;
     // Prop storage
    FBitmap: TBitmap32;
    FFlips: TPicFlips;
    FRotation: TPicRotation;
    FOnApplied: TNotifyEvent;
     // ������������ ����������� �� ARotation � �������� � ������������ ������� AFlips
    procedure ApplyRelativeTransform(ARotation: TPicRotation; AFlips: TPicFlips);
     // ��������� �������������� � �����������
    procedure ApplyTransform;
     // Prop handlers
    procedure SetFlips(Value: TPicFlips);
    procedure SetRotation(Value: TPicRotation);
  public
    constructor Create(ABitmap: TBitmap32);
     // ���������/������ ���������� ����������
    procedure BeginUpdate;
    procedure EndUpdate;
     // �������������� �������� ��� �������� (�.�. ��������������� �������� ��������� Bitmap)
    procedure InitValues(ARotation: TPicRotation; AFlips: TPicFlips);
     // ��������� �������� �������������� ������������
    procedure ApplyValues(ARotation: TPicRotation; AFlips: TPicFlips);
     // ����������� ���� �� ������ ���������
    procedure ToggleFlip(Flip: TPicFlip);
     // Props
     // -- �����������, � �������� ����������� ��������������
    property Bitmap: TBitmap32 read FBitmap;
     // -- ��������� ����������� ������������ ���������
    property Flips: TPicFlips read FFlips write SetFlips;
     // -- ������� ����������� ������������ ���������
    property Rotation: TPicRotation read FRotation write SetRotation;
     // -- ������� ���������� ��������������
    property OnApplied: TNotifyEvent read FOnApplied write FOnApplied;
  end;

   // ������������ �� Bitmap ����-��������� ���� � alpha-�������
  procedure RenderShadowTemplate(Bitmap: TBitmap32; iRadius: Integer; bOpacity: Byte; Color: TColor);
   // ������ �� Target ���� �� ��������� ShadowTemplate ��� �������������� rObject
  procedure DropShadow(Target, ShadowTemplate: TBitmap32; const rObject, rClipOuter: TRect; iOffsetX, iOffsetY: Integer; Color: TColor);

   // ��������� ����, ������ ����� � ���������� ��� ������ � ���� �������� ������
  function  GetThumbnailData(const sFileName: String; iMaxWidth, iMaxHeight: Integer; StretchFilter: TStretchFilter; bJPEGQuality: Byte; out iWidth, iHeight, iThWidth, iThHeight: Integer): String;
   // ������������ ����� �� ������� � �������� ��������������. � r ���������� ���������� �������������� ��� ���������
   //   �������������
  procedure PaintThumbnail(const sThumbnailData: String; Rotation: TPicRotation; Flips: TPicFlips; Bitmap32: TBitmap32; var r: TRect);

const
  BColor_Alpha_Transparent = $00;
  BColor_Alpha_Opaque      = $ff;

implementation
uses JPEG, phUtils;

  procedure RenderShadowTemplate(Bitmap: TBitmap32; iRadius: Integer; bOpacity: Byte; Color: TColor);
  var
    iSize, ix, iy, iR2, iy2: Integer;
    c32: TColor32;
    sAlpha: Single;
    bAlpha: Byte;

     // �������� "�����������" ����������� �� ����������� �/��� ���������
    procedure MirrorQuarter(ixq, iyq: Integer; bHorz, bVert: Boolean);
    var
      ixSrc, iySrc: Integer;
      pSrc, pTgt: PColor32;
    begin
       // ���� �� �������
      for iySrc := iyq to iyq+iRadius-1 do begin
         // ���������� ������ ������� � ������ �����: �������� � �������
        pSrc := Bitmap.PixelPtr[ixq, iySrc];
        pTgt := Bitmap.PixelPtr[iif(bHorz, iSize-ixq, ixq), iif(bVert, iSize-iySrc, iySrc)];
         // ������������ ������� ������ � �����
        for ixSrc := ixq to ixq+iRadius-1 do begin
          pTgt^ := pSrc^;
          Inc(pSrc);
          if bHorz then Dec(pTgt) else Inc(pTgt);
        end;
      end;
    end;

    // +---+---+
    // | 0 | 1 |
    // +---+---+
    // | 2 | 3 |
    // +---+---+

  begin
    iSize := iRadius*2;
    iR2 := iRadius*iRadius*iRadius;
    c32 := Color32(Color);
     // ������������� ��������� �������
    Bitmap.SetSize(iSize, iSize);
    Bitmap.DrawMode    := dmBlend;
    Bitmap.MasterAlpha := bOpacity;
     // �������� ������� (3)
    for iy := 0 to iRadius-1 do begin
       // ������� ������� ������� iy
      iy2 := iy*iy*iy;
      for ix := 0 to iRadius-1 do begin
        sAlpha := 1-(ix*ix*ix+iy2)/iR2; // ������� �������� �������������� � ��������� 0..1
        if sAlpha<0 then bAlpha := 0 else bAlpha := Trunc(255*sAlpha);
        Bitmap.SetPixelT(iRadius+ix, iRadius+iy, SetAlpha(c32, bAlpha));
      end;
    end;
     // �������� ���� � ��������� ����
    MirrorQuarter(iRadius, iRadius, False, True);  // (1)
    MirrorQuarter(iRadius, iRadius, True,  False); // (2)
    MirrorQuarter(iRadius, iRadius, True,  True);  // (0)
  end;

  procedure DropShadow(Target, ShadowTemplate: TBitmap32; const rObject, rClipOuter: TRect; iOffsetX, iOffsetY: Integer; Color: TColor);
  var
    r, rTotal, rQuarter: TRect;
    iRadius, iHalfRad: Integer;
    BMPObject: TBitmap32;

     // ������ ������� ���� ������� � iRadius � ������� � r, ������� � ������������ ���������� iy (������� ���� �
     //   ������� � ������������ ���������� iyTempl)
    procedure DrawHShadow(iy, iyTempl: Integer);
    var
      i: Integer;
      c: TColor32;
    begin
      for i := 0 to iRadius-1 do begin
        c := ShadowTemplate[iRadius, iyTempl];
        Target.HorzLineTS(r.Left, iy, r.Right-1, SetAlpha(c, Trunc(AlphaComponent(c)*Integer(ShadowTemplate.MasterAlpha)/255)));
        Inc(iy);
        Inc(iyTempl);
      end;
    end;

     // ������ ������� ���� ������� � iRadius � ������� � r, ������� � �������������� ���������� ix (������� ���� �
     //   ������� � �������������� ���������� ixTempl)
    procedure DrawVShadow(ix, ixTempl: Integer);
    var
      i: Integer;
      c: TColor32;
    begin
      for i := 0 to iRadius-1 do begin
        c := ShadowTemplate[ixTempl, iRadius];
        Target.VertLineTS(ix, r.Top, r.Bottom-1, SetAlpha(c, Trunc(AlphaComponent(c)*Integer(ShadowTemplate.MasterAlpha)/255)));
        Inc(ix);
        Inc(ixTempl);
      end;
    end;

  begin
     // ��������� ������ �� ��������� ������
    BMPObject := TBitmap32.Create;
    try
      BMPObject.SetSize(rObject.Right-rObject.Left, rObject.Bottom-rObject.Top);
      BMPObject.Draw(0, 0, rObject, Target); 
       // ��������� �������� ������ ���� �� 1/2 ������� � ������� ���� (������ ������������ �������)
      iRadius := ShadowTemplate.Width div 2;
      iHalfRad := iRadius div 2;
      r := rObject;
      with r do begin
        Inc(Left,   iOffsetX+iHalfRad);
        Inc(Top,    iOffsetY+iHalfRad);
        Inc(Right,  iOffsetX-iHalfRad);
        Inc(Bottom, iOffsetY-iHalfRad);
      end;
       // ������� ����� ������� ���� ����
      rTotal := r;
      InflateRect(rTotal, iRadius, iRadius);
       // ������ �������� ���� �������
      Target.FillRectTS(r, SetAlpha(Color32(Color), ShadowTemplate.MasterAlpha));
       // ������ ���� ����
       // -- Top left
      rQuarter := Rect(0, 0, iRadius, iRadius);
      Target.Draw(rTotal.Left, rTotal.Top, rQuarter, ShadowTemplate);
       // -- Top right
      OffsetRect(rQuarter, iRadius, 0);
      Target.Draw(rTotal.Right-iRadius, rTotal.Top, rQuarter, ShadowTemplate);
       // -- Bottom right
      OffsetRect(rQuarter, 0, iRadius);
      Target.Draw(rTotal.Right-iRadius, rTotal.Bottom-iRadius, rQuarter, ShadowTemplate);
       // -- Bottom left
      OffsetRect(rQuarter, -iRadius, 0);
      Target.Draw(rTotal.Left, rTotal.Bottom-iRadius, rQuarter, ShadowTemplate);
       // ������ ������� ���� ����� ������
      DrawHShadow(rTotal.Top,  0);
      DrawHShadow(r.Bottom,    iRadius);
      DrawVShadow(rTotal.Left, 0);
      DrawVShadow(r.Right,     iRadius);
       // ��������� ����������� ������� �������
      Target.Draw(rObject.Left, rObject.Top, BMPObject);
    finally
      BMPObject.Free;
    end;
  end;

  function GetThumbnailData(const sFileName: String; iMaxWidth, iMaxHeight: Integer; StretchFilter: TStretchFilter; bJPEGQuality: Byte; out iWidth, iHeight, iThWidth, iThHeight: Integer): String;
  var
    sScale: Single;
    ThumbBitmap, FullSizeBitmap: TBitmap32;
    Stream: TStringStream;
    bmp: TBitmap;
  begin
     // ������������ �����������
    ThumbBitmap := TBitmap32.Create;
    try
       // ������, ��������� �������� � ���������� � � Bitmap32
      FullSizeBitmap := LoadGraphicFromFile(sFileName);
      try
        FullSizeBitmap.StretchFilter := StretchFilter;
        iWidth  := FullSizeBitmap.Width;
        iHeight := FullSizeBitmap.Height;
         // ���������� ����������� ���������������
        if (iWidth>0) and (iHeight>0) then sScale := MinS(MinS(iMaxWidth/iWidth, iMaxHeight/iHeight), 1) else sScale := 1;
         // ������������ �����������
        iThWidth  := Max(Trunc(iWidth*sScale), 1);
        iThHeight := Max(Trunc(iHeight*sScale), 1);
        ThumbBitmap.SetSize(iThWidth, iThHeight);
        FullSizeBitmap.DrawTo(ThumbBitmap, ThumbBitmap.BoundsRect);
      finally
        FullSizeBitmap.Free;
      end;
       // ����������� TBitmap32 � TBitmap
      bmp := TBitmap.Create;
      try
        bmp.Assign(ThumbBitmap);
         // ����������� TBitmap � TJPEGImage
        with TJPEGImage.Create do
          try
             // �������� �����
            Assign(bmp);
             // �������
            CompressionQuality := bJPEGQuality;
            Compress;
             // ��������� ����� � �����
            Stream := TStringStream.Create('');
            try
              SaveToStream(Stream);
              Result := Stream.DataString;
            finally
              Stream.Free;
            end;
          finally
            Free;
          end;
      finally
        bmp.Free;
      end;
    finally
      ThumbBitmap.Free;
    end;
  end;

var
   // �������� ���������� ��� ��������� �������. Not thread-safe!
  JPGThumbBuffer: TJPEGImage = nil;
  BMPThumbBuffer: TBitmap32  = nil;

  procedure PaintThumbnail(const sThumbnailData: String; Rotation: TPicRotation; Flips: TPicFlips; Bitmap32: TBitmap32; var r: TRect);
  var
    Stream: TStringStream;
    Transform: TPicTransform;
    iw, ih: Integer;
    rSrc: TRect;
  begin
    if sThumbnailData='' then
      FillChar(r, SizeOf(r), 0)
    else begin
       // ������ �������� �����������
      if JPGThumbBuffer=nil then JPGThumbBuffer := TJPEGImage.Create;
      if BMPThumbBuffer=nil then BMPThumbBuffer := TBitmap32.Create;
       // ��������� JPEG-����������� ������
      Stream := TStringStream.Create(sThumbnailData);
      try
        JPGThumbBuffer.LoadFromStream(Stream);
      finally
        Stream.Free;
      end;
       // ���������� �����
      BMPThumbBuffer.Assign(JPGThumbBuffer);
       // ��������� ��������������, ���� ��� ����
      if (Rotation<>pr0) or (Flips<>[]) then begin
        Transform := TPicTransform.Create(BMPThumbBuffer);
        try
          Transform.Rotation := Rotation;
          Transform.Flips    := Flips;
        finally
          Transform.Free;
        end;
      end;
       // ���������� ������� ���������
      iw := Min(BMPThumbBuffer.Width,  r.Right-r.Left);
      ih := Min(BMPThumbBuffer.Height, r.Bottom-r.Top);
       // ���������� ������� ��� ��������� ������
      rSrc := Bounds(Max(0, (BMPThumbBuffer.Width-iw) div 2),  Max(0, (BMPThumbBuffer.Height-ih) div 2), iw, ih);
      r    := Bounds(r.Left+Max(0, (r.Right-r.Left-iw) div 2), r.Top+Max(0, (r.Bottom-r.Top-ih) div 2),  iw, ih);
       // ������������ ����������� �� �������
      Bitmap32.Draw(r.Left, r.Top, rSrc, BMPThumbBuffer);
    end;
  end;

   //===================================================================================================================
   // TColor32Map
   //===================================================================================================================

  function TColor32Map.ApplyToColor(c: TColor32): TColor32;
  asm
     // EAX = Self
     // EDX = C
     // out: EAX
    mov ebx, edx
    xor edx, edx
     // Put B value
    mov dl, bl
    mov dl, byte ptr [eax+FMapB+edx]
    mov byte ptr [Result+0], dl
     // Put G value
    mov dl, bh
    mov dl, byte ptr [eax+FMapG+edx]
    mov byte ptr [Result+1], dl
     // Put R value
    bswap ebx
    mov dl, bh
    mov dl, byte ptr [eax+FMapR+edx]
    mov byte ptr [Result+2], dl
     // Put A value
    mov dl, bl
    mov dl, byte ptr [eax+FMapA+edx]
    mov byte ptr [Result+3], dl
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
    for b := Low(b) to High(b) do Map[b] := b;
  end;

  constructor TColor32Map.Create;
  begin
    inherited Create;
    BuildLinear;
  end;

   //===================================================================================================================
   // TPicTransform
   //===================================================================================================================

  procedure TPicTransform.ApplyRelativeTransform(ARotation: TPicRotation; AFlips: TPicFlips);
  begin
     // ������� �� 180� � ��� ����� ���� �������� �����������
    if (FBitmap<>nil) and ((ARotation<>pr180) or (AFlips<>[pflHorz, pflVert])) then begin
      case ARotation of
        pr90:  FBitmap.Rotate90;
        pr180: FBitmap.Rotate180;
        pr270: FBitmap.Rotate270;
      end;
      if pflHorz in AFlips then FBitmap.FlipHorz;
      if pflVert in AFlips then FBitmap.FlipVert;
    end;
  end;

  procedure TPicTransform.ApplyTransform;
  var
    fl: TPicFlip;
    NewRotation: TPicRotation;
    NewFlips: TPicFlips;
  begin
    if FBitmap<>nil then begin
       // ��������� ������� � �������� � ����� � � NewRotation
      NewRotation := FRotation;
      if NewRotation<FAppliedRotation then Inc(NewRotation, Byte(Succ(High(NewRotation))));
      Dec(NewRotation, Byte(FAppliedRotation));
       // -- ���� ���� ���� �� ������, ������� � ��������������� �������
      if (FAppliedFlips<>[]) and (FAppliedFlips<>[pflHorz, pflVert]) then Byte(NewRotation) := Byte(Succ(High(NewRotation)))-Byte(NewRotation);
       // ��������� ������� � ���������� � ����� � � NewFlips
      NewFlips := FFlips;
      for fl := Low(fl) to High(fl) do
        if (fl in FAppliedFlips)=(fl in NewFlips) then Exclude(NewFlips, fl) else Include(NewFlips, fl);
       // ��������� ������� � ���������������
      ApplyRelativeTransform(NewRotation, NewFlips);
    end;
     // ��������� ������� �������� ��� ��������� ����������
    FAppliedRotation := FRotation;
    FAppliedFlips    := FFlips;
     // �������� ������� OnApplied
    if Assigned(FOnApplied) then FOnApplied(Self); 
  end;

  procedure TPicTransform.ApplyValues(ARotation: TPicRotation; AFlips: TPicFlips);
  begin
    if (FRotation<>ARotation) or (FFlips<>AFlips) then begin
      FRotation := ARotation;
      FFlips    := AFlips;
      if FApplyLock=0 then ApplyTransform;
    end;
  end;

  procedure TPicTransform.BeginUpdate;
  begin
    Inc(FApplyLock);
  end;

  constructor TPicTransform.Create(ABitmap: TBitmap32);
  begin
    inherited Create;
    FBitmap   := ABitmap;
  end;

  procedure TPicTransform.EndUpdate;
  begin
    if FApplyLock>0 then begin
      Dec(FApplyLock);
      if FApplyLock=0 then ApplyTransform;
    end;
  end;

  procedure TPicTransform.InitValues(ARotation: TPicRotation; AFlips: TPicFlips);
  begin
    FRotation        := ARotation;
    FAppliedRotation := ARotation;
    FFlips           := AFlips;
    FAppliedFlips    := AFlips;
  end;

  procedure TPicTransform.SetFlips(Value: TPicFlips);
  begin
    if FFlips<>Value then begin
      FFlips := Value;
      if FApplyLock=0 then ApplyTransform;
    end;
  end;

  procedure TPicTransform.SetRotation(Value: TPicRotation);
  begin
    if FRotation<>Value then begin
      FRotation := Value;
      if FApplyLock=0 then ApplyTransform;
    end;
  end;

  procedure TPicTransform.ToggleFlip(Flip: TPicFlip);
  begin
    if Flip in FFlips then Exclude(FFlips, Flip) else Include(FFlips, Flip);
    if FApplyLock=0 then ApplyTransform;
  end;

initialization
finalization
  JPGThumbBuffer.Free;
  BMPThumbBuffer.Free;
end.
