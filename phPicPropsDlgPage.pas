//**********************************************************************************************************************
//  $Id: phPicPropsDlgPage.pas,v 1.9 2004-10-19 15:03:31 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Copyright 2002-2004 DK Software, http://www.dk-soft.org/
//**********************************************************************************************************************
unit phPicPropsDlgPage;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs,
  phIntf, phMutableIntf, phNativeIntf, phObj, phOps, ConsVars,
  udPicProps, ImgList,
  phWizard;

type
   // ������� ����� ��������� ������� ������� �����������
  TPicPropsDialogPage = class(TWizardPage)
  private
     // ������ ������� ����������� (�������� ��������)
    FDialog: TdPicProps;
     // Prop handlers 
    function  GetApp: IPhotoAlbumApp;
    function  GetEditedPics: IPhotoAlbumPicList;
    function  GetFileImageIndex(Index: Integer): Integer;
    function  GetFileImages: TImageList;
  protected
    procedure InitializePage; override;
     // ���������� ����� ������� �� ���������
    procedure Modified;
     // ���������/������ ���������� ��������� Modified
    procedure BeginUpdate;
    procedure EndUpdate;
     // ��������, ���������� ����� ������������ ������
     // -- ����������
    property App: IPhotoAlbumApp read GetApp;
     // -- ������ �� ������������� ����������� �� �������
    property EditedPics: IPhotoAlbumPicList read GetEditedPics;
     // -- ImageIndices ������ ������������� �����������
    property FileImageIndex[Index: Integer]: Integer read GetFileImageIndex;
     // -- ImageList �� �������� ������
    property FileImages: TImageList read GetFileImages;
  public
     // ���������� �������� ��� ������� ������ ��. ������ ������� True, ����� ��������� ��������, ����� ������ ����
     //   ��������� ������������ ������� ������. � ������� ������ ������ ���������� True
    function  CanApply: Boolean; virtual;
     // ���������� �������� ��� ������� ������ ��. ������ ������� ��� ��������� - �������� ��������, � ����� ����� �
     //   ���������� ��� ���������� ���������. � ������� ������ �� ������ ������
    procedure Apply(var sOpParamName: String; var OpParams: IPhoaOperationParams); virtual;
  end;

implementation
{$R *.dfm}

  procedure TPicPropsDialogPage.Apply(var sOpParamName: String; var OpParams: IPhoaOperationParams);
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

  procedure TPicPropsDialogPage.EndUpdate;
  begin
    FDialog.EndUpdate;
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

  procedure TPicPropsDialogPage.InitializePage;
  begin
    inherited InitializePage;
    FDialog := StorageForm as TdPicProps;
  end;

  procedure TPicPropsDialogPage.Modified;
  begin
    FDialog.Modified := True;
  end;

end.
