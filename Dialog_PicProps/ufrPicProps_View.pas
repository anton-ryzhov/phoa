//**********************************************************************************************************************
//  $Id: ufrPicProps_View.pas,v 1.4 2007-07-01 18:07:22 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Copyright DK Software, http://www.dk-soft.org/
//**********************************************************************************************************************
unit ufrPicProps_View;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, GR32_Layers, TBXLists, ConsVars,
  phIntf, phMutableIntf, phNativeIntf, phObj, phOps, phGraphics,
  phWizard, Menus, TB2Item, TBX, ActnList, GR32_Image, TB2ExtItems,
  TBXExtItems, TB2Dock, TB2Toolbar, phPicPropsDlgPage, DKLang, TntActnList;

type
  TfrPicProps_View = class(TPicPropsDialogPage)
    aFlipHorz: TTntAction;
    aFlipVert: TTntAction;
    alMain: TTntActionList;
    aRotate0: TTntAction;
    aRotate180: TTntAction;
    aRotate270: TTntAction;
    aRotate90: TTntAction;
    aZoomActual: TTntAction;
    aZoomFit: TTntAction;
    aZoomIn: TTntAction;
    aZoomOut: TTntAction;
    bFlipHorz: TTBXItem;
    bFlipVert: TTBXItem;
    bRotate0: TTBXItem;
    bRotate180: TTBXItem;
    bRotate270: TTBXItem;
    bRotate90: TTBXItem;
    bViewZoomActual: TTBXItem;
    bViewZoomFit: TTBXItem;
    bViewZoomIn: TTBXItem;
    bViewZoomOut: TTBXItem;
    cbViewFile: TTBXComboBoxItem;
    dkBottom: TTBXDock;
    dklcMain: TDKLanguageController;
    dkLeft: TTBXDock;
    dkRight: TTBXDock;
    dkTop: TTBXDock;
    gipmMainToolbar: TTBGroupItem;
    gipmToolsToolbar: TTBGroupItem;
    iMain: TImage32;
    ipmSep: TTBXSeparatorItem;
    pmMain: TTBXPopupMenu;
    tbMain: TTBXToolbar;
    tbSepFlipHorz: TTBXSeparatorItem;
    tbTools: TTBXToolbar;
    procedure aaFlipHorz(Sender: TObject);
    procedure aaFlipVert(Sender: TObject);
    procedure aaRotate0(Sender: TObject);
    procedure aaRotate180(Sender: TObject);
    procedure aaRotate270(Sender: TObject);
    procedure aaRotate90(Sender: TObject);
    procedure aaZoomActual(Sender: TObject);
    procedure aaZoomFit(Sender: TObject);
    procedure aaZoomIn(Sender: TObject);
    procedure aaZoomOut(Sender: TObject);
    procedure cbViewFileAdjustImageIndex(Sender: TTBXComboBoxItem; const AText: String; AIndex: Integer; var ImageIndex: Integer);
    procedure cbViewFileChange(Sender: TObject; const Text: String);
    procedure FrameContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure FrameMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure iMainMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
    procedure iMainMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
    procedure iMainMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
    procedure iMainResize(Sender: TObject);
  private
     // ���� ����, ��� �������� �������������������
    FInitialized: Boolean;
     // ������������ ��������� ��������
    FZoomFactorChange: Single;
     // ������� iMain
    FWView, FHView: Integer;
     // ������� ����������������� �����������
    FWScaled, FHScaled: Integer;
     // ������ ��� iView (crHand ��� crDefault)
    FImageCursor: TCursor;
     // ���� � ��������� �������������� �����������
    FTrackDrag: Boolean;
    FTrackX: Integer;
    FTrackY: Integer;
     // ���� ����, ��� ����������� ���������
    FImageLoaded: Boolean;
     // ������� ������������ ����������� (���������������� � LoadViewImage)
    FPic: IPhoaPic;
     // �������������� �����������
    FTransform: TPicTransform;
     // ����, ����������������� � ���, ��� ������� � ���������� ����������� ������, � ��������� ������� �� Transform ��
     //   ����� 
    FNoRotation: Boolean;
     // �����, ����������������� � ���, ��� ������� ��������� � ���������� ����������� ������, � ��������� �����.
     //   ��������� �� Transform �� �����
    FNoFlipHorz: Boolean;
    FNoFlipVert: Boolean;
     // True � �������� ����������� �����������
    FDisplayingImage: Boolean;
     // ���������� ����������� ������������ �������� �����������
    function  BestFitZoomFactor: Single;
     // ��������� ������ �� �������� �����������
    procedure SetViewImageTimer;
     // ��������� � ���������� �����������
    procedure LoadViewImage;
     // ������� ������� ���� � ������������� ������� ���, ����� ����������� ������� ���� ���������
    procedure AdjustView;
     // ������� ��������������
    procedure TransformApplied(Sender: TObject);
     // ����������� �������� Checked ��� Actions ��������������
    procedure UpdateTransformActions;
     // ����������� ����������� Actions
    procedure EnableActions;
     // ���������� ������� ������� ��������
    procedure WMTimer(var Msg: TWMTimer); message WM_TIMER;
     // ���������� ��������� �������������� ��� ����������� � ������ ������ FNoRotation, FNoFlipHorz, FNoFlipVert
    procedure GetRequiredTransform(Pic: IPhoaPic; out Rotation: TPicRotation; out Flips: TPicFlips);
     // Prop handlers
    function  GetViewOffset: TPoint;
    function  GetViewZoomFactor: Single;
    procedure SetViewOffset(const Value: TPoint);
    procedure SetViewZoomFactor(Value: Single);
  protected
    procedure DoCreate; override;
    procedure DoDestroy; override;
    function  GetRegistrySection: WideString; override;
    procedure BeforeDisplay(ChangeMethod: TPageChangeMethod); override;
  public
    procedure Apply(var wsOpParamName: WideString; var OpParams: IPhoaOperationParams); override;
    procedure FileChanged(iIndex: Integer); override;
     // Props
     // -- ������� ���������������� �����������
    property ViewZoomFactor: Single read GetViewZoomFactor write SetViewZoomFactor;
     // -- �������� ������ �������� ���� ���������������� �����������
    property ViewOffset: TPoint read GetViewOffset write SetViewOffset;
  end;

implementation
{$R *.dfm}
uses phUtils, Main, phSettings;

  procedure TfrPicProps_View.aaFlipHorz(Sender: TObject);
  begin
    FNoFlipHorz := False;
    FTransform.ToggleFlip(pflHorz);
  end;

  procedure TfrPicProps_View.aaFlipVert(Sender: TObject);
  begin
    FNoFlipVert := False;
    FTransform.ToggleFlip(pflVert);
  end;

  procedure TfrPicProps_View.aaRotate0(Sender: TObject);
  begin
    FNoRotation := False;
    FTransform.Rotation := pr0;
  end;

  procedure TfrPicProps_View.aaRotate180(Sender: TObject);
  begin
    FNoRotation := False;
    FTransform.Rotation := pr180;
  end;

  procedure TfrPicProps_View.aaRotate270(Sender: TObject);
  begin
    FNoRotation := False;
    FTransform.Rotation := pr270;
  end;

  procedure TfrPicProps_View.aaRotate90(Sender: TObject);
  begin
    FNoRotation := False;
    FTransform.Rotation := pr90;
  end;

  procedure TfrPicProps_View.aaZoomActual(Sender: TObject);
  begin
    ViewZoomFactor := 1.0;
  end;

  procedure TfrPicProps_View.aaZoomFit(Sender: TObject);
  begin
    ViewZoomFactor := BestFitZoomFactor;
  end;

  procedure TfrPicProps_View.aaZoomIn(Sender: TObject);
  begin
    ViewZoomFactor := ViewZoomFactor*FZoomFactorChange;
  end;

  procedure TfrPicProps_View.aaZoomOut(Sender: TObject);
  begin
    ViewZoomFactor := ViewZoomFactor/FZoomFactorChange;
  end;

  procedure TfrPicProps_View.AdjustView;
  begin
     // ���� ����������� ���������
    if FImageLoaded then begin
      FWView := iMain.Width;
      FHView := iMain.Height;
      ViewZoomFactor := BestFitZoomFactor;
    end;
  end;

  procedure TfrPicProps_View.Apply(var wsOpParamName: WideString; var OpParams: IPhoaOperationParams);
  var ChgList: IPhoaPicPropertyChangeList;
  begin
     // ���� �������� ����������������, ������ �������� ���������� ��������������
    if FInitialized and not (FNoRotation and FNoFlipHorz and FNoFlipVert) then begin
       // ���������� ������ ���������
      ChgList := NewPhoaPicPropertyChangeList;
      if not FNoRotation                  then ChgList.Add(Byte(FTransform.Rotation), ppRotation);
      if not (FNoFlipHorz or FNoFlipVert) then ChgList.Add(Byte(FTransform.Flips),    ppFlips);
       // ���� ���� ��������� - ���������� ��������� �����������
      if ChgList.Count>0 then begin
        wsOpParamName := 'EditViewOpParams';
        OpParams      := NewPhoaOperationParams(['Pics', EditedPics, 'ChangeList', ChgList]);
      end;
    end;
  end;

  procedure TfrPicProps_View.BeforeDisplay(ChangeMethod: TPageChangeMethod);
  var
    i: Integer;
    Pic: IPhoaPic;
  begin
    inherited BeforeDisplay(ChangeMethod);
     // ���� �������� �������������������
    if FInitialized then begin
       // ���� ����� ��������� �����������
      if not FImageLoaded then SetViewImageTimer;
     // ����� ��������������
    end else begin
       // ������ ��������������
      FTransform := TPicTransform.Create(iMain.Bitmap);
      FTransform.OnApplied := TransformApplied;
       // ��������� ����� ������ � ��������� �������� ��������������
      for i := 0 to EditedPics.Count-1 do begin
        Pic := EditedPics[i];
        cbViewFile.Strings.Add(Dialog.PictureFiles[i]);
        if i=0 then
          FTransform.InitValues(Pic.Rotation, Pic.Flips)
        else begin
          if Pic.Rotation<>FTransform.Rotation                     then FNoRotation := True;
          if (pflHorz in Pic.Flips)<>(pflHorz in FTransform.Flips) then FNoFlipHorz := True;
          if (pflVert in Pic.Flips)<>(pflVert in FTransform.Flips) then FNoFlipVert := True;
        end;
      end;
      cbViewFile.ItemIndex := 0;
      FInitialized := True;
    end;
  end;

  function TfrPicProps_View.BestFitZoomFactor: Single;
  begin
    Result := MinS(FWView/iMain.Bitmap.Width, FHView/iMain.Bitmap.Height);
  end;

  procedure TfrPicProps_View.cbViewFileAdjustImageIndex(Sender: TTBXComboBoxItem; const AText: String; AIndex: Integer; var ImageIndex: Integer);
  begin
    if AIndex=-1 then AIndex := cbViewFile.Strings.IndexOf(AText);
    ImageIndex := FileImageIndex[AIndex];
  end;

  procedure TfrPicProps_View.cbViewFileChange(Sender: TObject; const Text: String);
  begin
    SetViewImageTimer;
  end;

  procedure TfrPicProps_View.DoCreate;
  begin
    inherited DoCreate;
    gipmMainToolbar.LinkSubitems  := tbMain.Items;
    gipmToolsToolbar.LinkSubitems := tbTools.Items;
    cbViewFile.Images        := FileImages;
    cbViewFile.SubMenuImages := FileImages;
    FZoomFactorChange := adMagnifications[SettingValueInt(ISettingID_View_ZoomFactor)];
  end;

  procedure TfrPicProps_View.DoDestroy;
  begin
    FTransform.Free;
    inherited DoDestroy;
  end;

  procedure TfrPicProps_View.EnableActions;
  begin
    aZoomIn.Enabled     := FImageLoaded and (ViewZoomFactor<SMaxPicZoom);
    aZoomOut.Enabled    := FImageLoaded and (ViewZoomFactor>SMinPicZoom);
    aZoomActual.Enabled := FImageLoaded and (ViewZoomFactor<>1);
    aZoomFit.Enabled    := FImageLoaded and (ViewZoomFactor<>BestFitZoomFactor);
  end;

  procedure TfrPicProps_View.FileChanged(iIndex: Integer);
  begin
    inherited FileChanged(iIndex);
     // ��� ��������� ����� ��������� ������� � cbViewFile
    if FInitialized then begin
      cbViewFile.Strings[iIndex] := Dialog.PictureFiles[iIndex];
       // ���� ��� ������� ������������ �����������, ��� ����� �����������
      if cbViewFile.ItemIndex=iIndex then
        if Visible then SetViewImageTimer else FImageLoaded := False;
    end;
  end;

  procedure TfrPicProps_View.FrameContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
  begin
     // ��� ������� Ctrl ������ ������������ ���������� Shell Context Menu ��� �������� �����
    if GetKeyState(VK_CONTROL) and $80<>0 then begin
      ShowFileShellContextMenu(Dialog.PictureFiles[cbViewFile.ItemIndex]);
      Handled := True;
    end;
  end;

  procedure TfrPicProps_View.FrameMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
  begin
    if WheelDelta<0 then aZoomOut.Execute else aZoomIn.Execute;
    Handled := True;
  end;

  function TfrPicProps_View.GetRegistrySection: WideString;
  begin
    Result := SRegWizPage_PicProp_View;
  end;

  procedure TfrPicProps_View.GetRequiredTransform(Pic: IPhoaPic; out Rotation: TPicRotation; out Flips: TPicFlips);
  begin
    if FNoRotation then Rotation := Pic.Rotation else Rotation := FTransform.Rotation;
    Flips := [];
    if (FNoFlipHorz and (pflHorz in Pic.Flips)) or (not FNoFlipHorz and (pflHorz in FTransform.Flips)) then Include(Flips, pflHorz);
    if (FNoFlipVert and (pflVert in Pic.Flips)) or (not FNoFlipVert and (pflVert in FTransform.Flips)) then Include(Flips, pflVert);
  end;

  function TfrPicProps_View.GetViewOffset: TPoint;
  begin
    Result := Point(Trunc(iMain.OffsetHorz), Trunc(iMain.OffsetVert));
  end;

  function TfrPicProps_View.GetViewZoomFactor: Single;
  begin
    Result := iMain.Scale;
  end;

  procedure TfrPicProps_View.iMainMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
  begin
    if (Button=mbLeft) and (FWScaled>FWView) or (FHScaled>FHView) then begin
      FTrackDrag := True;
      iMain.Cursor := crHandDrag;
      FTrackX := ViewOffset.x-x;
      FTrackY := ViewOffset.y-y;
    end;
  end;

  procedure TfrPicProps_View.iMainMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
  begin
    if FTrackDrag then ViewOffset := Point(x+FTrackX, y+FTrackY);
  end;

  procedure TfrPicProps_View.iMainMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
  begin
    if FTrackDrag then begin
      FTrackDrag := False;
       // ���������� ������� ������
      iMain.Cursor := FImageCursor;
    end;
  end;

  procedure TfrPicProps_View.iMainResize(Sender: TObject);
  begin
    AdjustView;
  end;

  procedure TfrPicProps_View.LoadViewImage;
  var
    Rotation: TPicRotation;
    Flips: TPicFlips;
    ImgSize: TSize;
  begin
     // ��������� ��������� Modified
    BeginUpdate;
    StartWait;
    FDisplayingImage := True;
    try
      FPic := EditedPics[cbViewFile.ItemIndex];
       // ��������� �����������
      try
        LoadGraphicFromFile(Dialog.PictureFiles[cbViewFile.ItemIndex], iMain.Bitmap, MakeSize(0, 0), ImgSize, nil);
        FImageLoaded := True;
      except
        FImageLoaded := False;
        raise;
      end;
       // ���������� ��������� ��������������
      GetRequiredTransform(FPic, Rotation, Flips);
       // ��������� ��������������
      FTransform.InitValues(pr0, []);
      FTransform.ApplyValues(Rotation, Flips);
       // ����������� ������� �����������
      AdjustView;
      UpdateTransformActions;
    finally
      FDisplayingImage := False;
      StopWait;
      EndUpdate;
      EnableActions;
    end;
  end;

  procedure TfrPicProps_View.SetViewImageTimer;
  begin
    KillTimer(Handle, IPicPropsViewTimerID);
    SetTimer(Handle, IPicPropsViewTimerID, 500, nil);
  end;

  procedure TfrPicProps_View.SetViewOffset(const Value: TPoint);
  var ix, iy: Integer;
  begin
    if FWScaled>FWView then ix := Min(0, Max(Value.x, FWView-FWScaled)) else ix := (FWView-FWScaled) div 2;
    if FHScaled>FHView then iy := Min(0, Max(Value.y, FHView-FHScaled)) else iy := (FHView-FHScaled) div 2;
    iMain.OffsetHorz := ix;
    iMain.OffsetVert := iy;
  end;

  procedure TfrPicProps_View.SetViewZoomFactor(Value: Single);
  begin
     // Verify zoom value
    if Value>SMaxPicZoom then Value := SMaxPicZoom
    else if Value<SMinPicZoom then Value := SMinPicZoom;
     // Apply zoom
    iMain.Scale := Value;
     // ������� ������� ����������������� �����������
    FWScaled := Round(iMain.Bitmap.Width*Value);
    FHScaled := Round(iMain.Bitmap.Height*Value);
     // ������������� ��������� ��������� �����������
    ViewOffset := Point((FWView-FWScaled) div 2, (FHView-FHScaled) div 2);
     // ����������� ������
    FImageCursor := aImgViewCursors[(FWScaled>FWView) or (FHScaled>FHView)];
    iMain.Cursor := FImageCursor;
    EnableActions;
  end;

  procedure TfrPicProps_View.TransformApplied(Sender: TObject);
  begin
    if FDisplayingImage then Exit;
    AdjustView;
    UpdateTransformActions;
    Modified;
  end;

  procedure TfrPicProps_View.UpdateTransformActions;
  begin
    aRotate0.Checked   := not FNoRotation and (FTransform.Rotation=pr0);
    aRotate90.Checked  := not FNoRotation and (FTransform.Rotation=pr90);
    aRotate180.Checked := not FNoRotation and (FTransform.Rotation=pr180);
    aRotate270.Checked := not FNoRotation and (FTransform.Rotation=pr270);
    aFlipHorz.Checked  := not FNoFlipHorz and (pflHorz in FTransform.Flips);
    aFlipVert.Checked  := not FNoFlipVert and (pflVert in FTransform.Flips);
  end;

  procedure TfrPicProps_View.WMTimer(var Msg: TWMTimer);
  begin
    if Msg.TimerID=IPicPropsViewTimerID then begin
      KillTimer(Handle, IPicPropsViewTimerID);
      LoadViewImage;
    end;
  end;

end.

