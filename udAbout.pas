unit udAbout;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, GR32, GR32_Layers,
  StdCtrls, GR32_Image, DTLangTools, ExtCtrls;

type
  TShowDetail = (sdTitle, sdAuthor, sdCredits, sdTranslation);

  TdAbout = class(TForm)
    dtlsMain: TDTLanguageSwitcher;
    iMain: TImage32;
    lWebsite: TLabel;
    lOK: TLabel;
    TheTimer: TTimer;
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure lWebsiteClick(Sender: TObject);
    procedure lOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure TheTimerTick(Sender: TObject);
    procedure iMainMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
    procedure iMainMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
    procedure iMainMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
  private
     // ����, �� ������� �������� ���������
    FTitleLayer: TPositionedLayer;
     // �������� ���������
    FBmpTitle, FBmpAuthor, FBmpCredits, FBmpTranslation: TBitmap32;
     // ������� ������������ ������
    FShowDetail: TShowDetail;
     // ���� ��������� ��������
    FFading: Boolean;
     // ����� ������������� ���������/���������� ��������
    FStopAnimation: Boolean;
    FAnimationTerminated: Boolean;
     // ���� ��� �������������� �����
    FTrackDrag: Boolean;
    FTrackPos: TPoint;
     // �������� ��� ����� ���������
    procedure FadeTitle(bIn: Boolean);
     // ������� ����
    procedure PaintTitleLayer(Sender: TObject; Buffer: TBitmap32);
     // ������ ������� ����
    procedure Fadeout;
     // ������ TBitmap32 � ��������� ��� �� PNG-�������
    function  CreatePNGBitmap(const sResourceName: String; bAlpha: Byte): TBitmap32;
     // ���������� ������� ������������ Bitmap ���������
    function  CurBitmap: TBitmap32;
     // �������� �������� ������
    procedure StartClosing; 
  end;

  procedure ShowAbout;

implementation
{$R *.dfm}
uses ConsVars, GraphicEx, phUtils;

  procedure ShowAbout;
  begin
    with TdAbout.Create(Application) do
      try
        ShowModal;
      finally
        Free;
      end;
  end;

  function TdAbout.CreatePNGBitmap(const sResourceName: String; bAlpha: Byte): TBitmap32;
  var Png: TPNGGraphic;
  begin
    Png := TPNGGraphic.Create;
    try
      Png.LoadFromResourceName(HInstance, sResourceName);
      Result := TBitmap32.Create;
      Result.Assign(Png);
      Result.DrawMode := dmBlend;
      Result.MasterAlpha := bAlpha;
    finally
      Png.Free;
    end;
  end;

  function TdAbout.CurBitmap: TBitmap32;
  begin
    case FShowDetail of
      sdTitle:   Result := FBmpTitle;
      sdAuthor:  Result := FBmpAuthor;
      sdCredits: Result := FBmpCredits;
      else       Result := FBmpTranslation;
    end;
  end;

  procedure TdAbout.Fadeout;
  var b: Byte;
  begin
     // Enable fadeout effect on Win2K+
    if (Win32Platform=VER_PLATFORM_WIN32_NT) and (Win32MajorVersion>=5) then begin
      AlphaBlend := True;
      Update;
      for b := 12 downto 1 do begin
        AlphaBlendValue := b*20;
        Sleep(20);
      end;
    end;
    Close;
  end;

  procedure TdAbout.FadeTitle(bIn: Boolean);
  var
    i, iWait: Integer;
    cStart: Cardinal;
  begin
    FFading := True;
    cStart := GetTickCount;
    for i := 0 to 255 do begin
      CurBitmap.MasterAlpha := iif(bIn, i, 255-i);
      iMain.Invalidate;
      Application.ProcessMessages;
      if FAnimationTerminated then Break;
       // ����������� ����� �� 2 �������
      iWait := (i*2000) div 255-Integer(GetTickCount-cStart);
      if iWait>0 then Sleep(iWait);
    end;
    FFading := False;
    if FAnimationTerminated then Fadeout;
  end;

  procedure TdAbout.FormCreate(Sender: TObject);
  var Png: TPNGGraphic;
  begin
    Png := TPNGGraphic.Create;
    try
       // ��������� ����������� ����
      Png.LoadFromResourceName(HInstance, 'PNG_BACK');
      iMain.Bitmap.Assign(Png);
    finally
      Png.Free;
    end;
     // ������ ���� ���������
    FTitleLayer := TPositionedLayer.Create(iMain.Layers);
    FTitleLayer.OnPaint := PaintTitleLayer;
     // ��������� ����������� ���������
    FBmpTitle       := CreatePNGBitmap('PNG_TITLE',       255);
    FBmpAuthor      := CreatePNGBitmap('PNG_AUTHOR',      0);
    FBmpCredits     := CreatePNGBitmap('PNG_CREDITS',     0);
    FBmpTranslation := CreatePNGBitmap('PNG_TRANSLATION', 0);
  end;

  procedure TdAbout.FormDestroy(Sender: TObject);
  begin
    FBmpTitle.Free;
    FBmpAuthor.Free;
    FBmpCredits.Free;
    FBmpTranslation.Free;
  end;

  procedure TdAbout.FormKeyPress(Sender: TObject; var Key: Char);
  begin
    if Key in [#13, #27] then StartClosing;
  end;

  procedure TdAbout.iMainMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
  begin
    FTrackDrag := True;
    FTrackPos := Point(x, y);
  end;

  procedure TdAbout.iMainMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
  begin
    if FTrackDrag then
      with iMain.ClientToScreen(Point(x-FTrackPos.x, y-FTrackPos.y)) do SetBounds(x, y, Width, Height);
  end;

  procedure TdAbout.iMainMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
  begin
    FTrackDrag := False;
  end;

  procedure TdAbout.lOKClick(Sender: TObject);
  begin
    StartClosing;
  end;

  procedure TdAbout.lWebsiteClick(Sender: TObject);
  begin
    OpenWebsite;
  end;

  procedure TdAbout.PaintTitleLayer(Sender: TObject; Buffer: TBitmap32);
  var bmp: TBitmap32;
  begin
    bmp := CurBitmap;
    if bmp<>nil then Buffer.Draw((Width-bmp.Width) div 2, (Height-bmp.Height) div 2, bmp);
  end;

  procedure TdAbout.StartClosing;
  begin
    if FFading then FAnimationTerminated := True else Fadeout;
  end;

  procedure TdAbout.TheTimerTick(Sender: TObject);
  begin
    TheTimer.Enabled := False;
     // ������� �������
    FadeTitle(False);
    if FAnimationTerminated then Exit;
     // ���������� ����� �������
    FShowDetail := Succ(FShowDetail);
    if FShowDetail>High(FShowDetail) then begin
      FShowDetail := sdTitle;
      FStopAnimation := True;
    end;
    FadeTitle(True);
    if FStopAnimation or FAnimationTerminated then Exit;
     // ��������� ������
    TheTimer.Enabled := True;
  end;

end.
