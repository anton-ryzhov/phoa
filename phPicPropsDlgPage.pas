//**********************************************************************************************************************
//  $Id: phPicPropsDlgPage.pas,v 1.15 2007-06-30 10:36:20 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Copyright DK Software, http://www.dk-soft.org/
//**********************************************************************************************************************
unit phPicPropsDlgPage;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs,
  phIntf, phMutableIntf, phNativeIntf, phObj, phOps, ConsVars, udPicProps,
  phWizard;

type
   // ������� ����� ��������� ������� ������� �����������
  TPicPropsDialogPage = class(TWizardPage)
  private
     // Prop storage
    FDialog: TdPicProps;
     // Prop handlers 
    function  GetApp: IPhotoAlbumApp;
    function  GetEditedPics: IPhotoAlbumPicList;
    function  GetFileImageIndex(Index: Integer): Integer;
    function  GetFileImages: TImageList;
  protected
    procedure DoCreate; override;
     // ���������� ����� ������� �� ���������
    procedure Modified;
     // ���������/������ ���������� ��������� Modified
    procedure BeginUpdate;
    procedure EndUpdate;
     // ��������, ���������� ����� ������������ ������
     // -- ����������
    property App: IPhotoAlbumApp read GetApp;
     // -- ������ ������� ����������� (�������� ��������)
    property Dialog: TdPicProps read FDialog;
     // -- ������ �� ������������� ����������� �� �������
    property EditedPics: IPhotoAlbumPicList read GetEditedPics;
     // -- ImageIndices ������ ������������� �����������
    property FileImageIndex[Index: Integer]: Integer read GetFileImageIndex;
     // -- ImageList �� �������� ������
    property FileImages: TImageList read GetFileImages;
  public
     // ���������� �������� ��� ����������� �� ��������� ����� � ����������� � �������� ��������. � ������� ������ ��
     //   ������ ������
    procedure FileChanged(iIndex: Integer); virtual;
     // ���������� �������� ��� ������� ������ ��. ������ ������� True, ����� ��������� ��������, ����� ������ ����
     //   ��������� ������������ ������� ������. � ������� ������ ������ ���������� True
    function  CanApply: Boolean; virtual;
     // ���������� �������� ��� ������� ������ ��. ������ ������� ��� ��������� - �������� ��������, � ����� ����� �
     //   ���������� ��� ���������� ���������. � ������� ������ �� ������ ������
    procedure Apply(var wsOpParamName: WideString; var OpParams: IPhoaOperationParams); virtual;
  end;

implementation
{$R *.dfm}

  procedure TPicPropsDialogPage.Apply(var wsOpParamName: WideString; var OpParams: IPhoaOperationParams);
  begin
    { does nothing }
  end;

  procedure TPicPropsDialogPage.BeginUpdate;
  begin
    FDialog.BeginUpdate;
  end;

  function TPicPropsDialogPage.CanApply: Boolean;
  begin
    Result := True;
  end;

  procedure TPicPropsDialogPage.DoCreate;
  begin
    inherited DoCreate;
    FDialog := StorageForm as TdPicProps;
  end;

  procedure TPicPropsDialogPage.EndUpdate;
  begin
    FDialog.EndUpdate;
  end;

  procedure TPicPropsDialogPage.FileChanged(iIndex: Integer);
  begin
    { does nothing }
  end;

  function TPicPropsDialogPage.GetApp: IPhotoAlbumApp;
  begin
    Result := FDialog.App;
  end;

  function TPicPropsDialogPage.GetEditedPics: IPhotoAlbumPicList;
  begin
    Result := FDialog.EditedPics;
  end;

  function TPicPropsDialogPage.GetFileImageIndex(Index: Integer): Integer;
  begin
    Result := FDialog.FileImageIndex[Index];
  end;

  function TPicPropsDialogPage.GetFileImages: TImageList;
  begin
    Result := FDialog.ilFiles;
  end;

  procedure TPicPropsDialogPage.Modified;
  begin
    FDialog.Modified := True;
  end;

end.
