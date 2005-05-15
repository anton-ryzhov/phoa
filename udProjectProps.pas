//**********************************************************************************************************************
//  $Id: udProjectProps.pas,v 1.4 2005-05-15 09:03:08 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Copyright DK Software, http://www.dk-soft.org/
//**********************************************************************************************************************
unit udProjectProps;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  phIntf, phMutableIntf, phNativeIntf, phObj, phOps,
  phDlg, DKLang, RXSpin, ComCtrls, StdCtrls, ExtCtrls;

type
  TdProjectProps = class(TPhoaDialog)
    dklcMain: TDKLanguageController;
    eThumbSizeX: TRxSpinEdit;
    eThumbSizeY: TRxSpinEdit;
    lDesc: TLabel;
    lThQuality1: TLabel;
    lThQuality2: TLabel;
    lThumbQuality: TLabel;
    lThumbSize: TLabel;
    lThumbSizeX: TLabel;
    mDesc: TMemo;
    tbThumbQuality: TTrackBar;
  private
     // ����������
    FApp: IPhotoAlbumApp;
     // ����� ������
    FUndoOperations: TPhoaOperations;
  protected
    procedure ButtonClick_OK; override;
    procedure DoCreate; override;
    procedure ExecuteInitialize; override;
  end;

  function EditProject(AApp: IPhotoAlbumApp; UndoOperations: TPhoaOperations): Boolean;

implementation
{$R *.DFM}
uses ConsVars, phUtils, Main;

  function EditProject(AApp: IPhotoAlbumApp; UndoOperations: TPhoaOperations): Boolean;
  begin
    with TdProjectProps.Create(Application) do
      try
        FApp            := AApp;
        FUndoOperations := UndoOperations;
        Result := ExecuteModal(False, False);
      finally
        Free;
      end;
  end;

   //===================================================================================================================
   // TdPhoAProps
   //===================================================================================================================

  procedure TdProjectProps.ButtonClick_OK;
  begin
    FApp.PerformOperation(
      'ProjectEdit',
      ['NewThWidth',     eThumbSizeX.AsInteger,
       'NewThHeight',    eThumbSizeY.AsInteger,
       'NewThQuality',   Byte(tbThumbQuality.Position),
       'NewDescription', mDesc.Text]);
    inherited ButtonClick_OK;
  end;

  procedure TdProjectProps.DoCreate;
  begin
    inherited DoCreate;
    HelpContext := IDH_intf_album_props;
  end;

  procedure TdProjectProps.ExecuteInitialize;
  var Project: IPhotoAlbumProject;
  begin
    inherited ExecuteInitialize;
    Project := FApp.ProjectX;
    eThumbSizeX.AsInteger   := Project.ThumbnailSize.cx;
    eThumbSizeY.AsInteger   := Project.ThumbnailSize.cy;
    tbThumbQuality.Position := Project.ThumbnailQuality;
    mDesc.Lines.Text        := Project.Description;
  end;

end.


