//**********************************************************************************************************************
//  $Id: phWizard.pas,v 1.4 2004-06-01 13:27:52 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Copyright 2002-2004 Dmitry Kann, http://phoa.narod.ru
//**********************************************************************************************************************
unit phWizard;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs;

type
   // Exception
  EPhoaWizardError = class(Exception);

   // ����� ����� �������� �������
  TPageChangeMethod = (pcmBackBtn, pcmNextBtn, pcmForced);

   // ��������� ����-��������
  IWizardHostForm = interface(IInterface)
    ['{265DFB55-F29D-40F7-BAC7-3440D04D17ED}']
     // ���������� � �������� ����� ��������. ������ ������� True, ����� ��������� �����
    function  PageChanging(ChangeMethod: TPageChangeMethod; var iNewPageID: Integer): Boolean;
     // ���������� ����� ����������� [������] ��������
    procedure PageChanged(ChangeMethod: TPageChangeMethod; iPrevPageID: Integer);
     // ���������� ��� ��������� ��������� �������
    procedure StatusChanged;
     // Prop handlers
    function  GetHostControl: TWinControl; 
    function  GetNextPageID: Integer;
    function  GetStorageForm: TForm;
     // Props
     // -- ����-������� ��� ���������� �������
    property HostControl: TWinControl read GetHostControl;
     // -- ������ ���������� ID ��������� ��������, ��� 0, ���� ��� ������ �������
    property NextPageID: Integer read GetNextPageID;
     // -- ����� �������
    property StorageForm: TForm read GetStorageForm;
  end;

  TWizardController = class;

  TWizardPage = class(TFrame)
     // ������� ��������� ������ ��������, �������� OnStatusChange
    procedure PageDataChange(Sender: TObject);
  private
     // Prop storage
    FController: TWizardController;
    FID: Integer;
    FPageTitle: String;
     // Prop handlers
    function GetStorageForm: TForm;
    function GetIndex: Integer;
  protected
     // �������� Controller.OnStatusChange
    procedure StatusChanged;
     // �������������/����������� ��������. � ������� ������ ���������������/��������� ������ ������������
    procedure InitializePage; virtual;
    procedure FinalizePage; virtual;
     // ���������� ����� ������������ ��������. � ������� ������ �� ������ ������
    procedure BeforeDisplay(ChangeMethod: TPageChangeMethod); virtual;
     // ���������� ����� ����������� ��������. � ������� ������ �� ������ ������
    procedure AfterDisplay(ChangeMethod: TPageChangeMethod); virtual;
     // ���������� ����� �������� ��������. � ������� ������ �� ������ ������
    procedure BeforeHide(ChangeMethod: TPageChangeMethod); virtual;
     // ���������� ����� ������� ��������. � ������� ������ �� ������ ������
    procedure AfterHide(ChangeMethod: TPageChangeMethod); virtual;
     // ���������� ��� ������� ������������� ������ �����. ������ ������� True, ����� ��������� ����� ��������, �����
     //   ������ ���� ��������� ������������ ������� ������
    function  NextPage: Boolean; virtual;
     // Prop handlers
    function  GetDataValid: Boolean; virtual;
    function  GetRegistrySection: String; virtual;
  public
    constructor Create(Controller: TWizardController; iID, iHelpContext: Integer; const sPageTitle: String); reintroduce; virtual;
    destructor Destroy; override;
     // Props
     // -- ������ ���������� True, ���� �������� �������� ���������� ������. � ������� ������ ������ True
    property DataValid: Boolean read GetDataValid;
     // -- ���������� ������������� �������� � ������
    property ID: Integer read FID;
     // -- ������ �������� � ������ �����������
    property Index: Integer read GetIndex;
     // -- �������� ��������
    property Controller: TWizardController read FController;
     // -- �����, ��������� � �������� ��������
    property PageTitle: String read FPageTitle;
     // -- ������ ������� ��� ���������� ��������� �������� ��������. ���� ������ (��� � ������� ������), ���������� ��
     //    ���������
    property RegistrySection: String read GetRegistrySection;
     // -- ����� �������. ���������� ����� Controller
    property StorageForm: TForm read GetStorageForm;
  end;

  TWizardPageClass = class of TWizardPage;

   // ������ ������� �������
  TWizardController = class(TList)
  private
     // ������� ����� �������
    FPageIDHistory: Array of Integer;
     // Prop storage
    FHostFormIntf: IWizardHostForm;
    FKeepHistory: Boolean;
    function  GetItems(Index: Integer): TWizardPage;
    function  GetItemsByID(iID: Integer): TWizardPage;
    function  GetVisiblePageID: Integer;
    function  GetVisiblePage: TWizardPage;
    function  GetHistoryEmpty: Boolean;
    procedure SetKeepHistory(Value: Boolean);
  public
    constructor Create(AHostFormIntf: IWizardHostForm);
    destructor Destroy; override;
    procedure Add(Page: TWizardPage);
    procedure Remove(Page: TWizardPage);
    procedure Delete(Index: Integer);
    procedure Clear; override;
     // ������ � ���������� �������� ��������� ������, ��������� � � ����� ������
    function  CreatePage(PClass: TWizardPageClass; iID, iHelpContext: Integer; const sPageTitle: String): TWizardPage; virtual;
     // ���� ��������. ���������� -1, ���� �� �������
    function  IndexOf(Page: TWizardPage): Integer;
     // ���� �������� �� ID. ���������� -1, ���� �� �������
    function  IndexOfID(iID: Integer): Integer;
     // ������������� ������� ��������. bCommit ���������, ������ �� �������� ��������� ������
    function  SetVisiblePageID(iNewID: Integer; ChangeMethod: TPageChangeMethod): Boolean;
     // ���������� ���������� ���������� ��������
    procedure SetPrevPageFromHistory;
     // ���������� ��������� ��������
    procedure SetNextPage;
     // Props
     // -- True, ���� ������� ����� ������� �����
    property HistoryEmpty: Boolean read GetHistoryEmpty;
     // -- ��������� ����� �������
    property HostFormIntf: IWizardHostForm read FHostFormIntf;
     // -- �������� �� �������
    property Items[Index: Integer]: TWizardPage read GetItems; default;
     // -- �������� �� ID. ���������� Exception, ���� ��� ����� ��������
    property ItemsByID[iID: Integer]: TWizardPage read GetItemsByID;
     // -- ������� �� ������� ����� �������. �� ��������� True
    property KeepHistory: Boolean read FKeepHistory write SetKeepHistory;
     // -- ID ������������ �������� � �������. 0, ���� ���
    property VisiblePageID: Integer read GetVisiblePageID;
     // -- ������������ �������� � �������. nil, ���� ���
    property VisiblePage: TWizardPage read GetVisiblePage;
  end;

   // Raises EPhoaWizardError
  procedure PhoaWizardError(const sMsg: String); overload;
  procedure PhoaWizardError(const sMsg: String; const aParams: Array of const); overload;

implementation
{$R *.dfm}
uses VCLUtils, ConsVars, TB2Dock;

  procedure PhoaWizardError(const sMsg: String);
  begin
    raise EPhoaWizardError.Create(sMsg);
  end;

  procedure PhoaWizardError(const sMsg: String; const aParams: Array of const);
  begin
    raise EPhoaWizardError.CreatefMT(sMsg, aParams);
  end;

   //===================================================================================================================
   // TWizardPage
   //===================================================================================================================

  procedure TWizardPage.AfterDisplay(ChangeMethod: TPageChangeMethod);
  begin
    { does nothing }
  end;

  procedure TWizardPage.AfterHide(ChangeMethod: TPageChangeMethod);
  begin
    { does nothing }
  end;

  procedure TWizardPage.BeforeDisplay(ChangeMethod: TPageChangeMethod);
  begin
    { does nothing }
  end;

  procedure TWizardPage.BeforeHide(ChangeMethod: TPageChangeMethod);
  begin
    { does nothing }
  end;

  constructor TWizardPage.Create(Controller: TWizardController; iID, iHelpContext: Integer; const sPageTitle: String);
  begin
    inherited Create(Controller.HostFormIntf.StorageForm);
    FID         := iID;
    HelpContext := iHelpContext;
    FPageTitle  := sPageTitle;
    FController := Controller;
    FController.Add(Self);
  end;

  destructor TWizardPage.Destroy;
  begin
    FController.Remove(Self);
    inherited Destroy;
  end;

  procedure TWizardPage.FinalizePage;
  begin
     // ��������� ������ ������������
    if RegistrySection<>'' then TBRegSavePositions(Self, HKEY_CURRENT_USER, SRegRoot+'\'+SRegWizPagesRoot+'\'+RegistrySection+SRegWizPages_Toolbars);
  end;

  function TWizardPage.GetDataValid: Boolean;
  begin
    Result := True;
  end;

  function TWizardPage.GetIndex: Integer;
  begin
    Result := FController.IndexOf(Self);
  end;

  function TWizardPage.GetRegistrySection: String;
  begin
    Result := '';
  end;

  function TWizardPage.GetStorageForm: TForm;
  begin
    Result := FController.HostFormIntf.StorageForm;
  end;

  procedure TWizardPage.InitializePage;
  begin
     // ��������������� ������ ������������
    if RegistrySection<>'' then TBRegLoadPositions(Self, HKEY_CURRENT_USER, SRegRoot+'\'+SRegWizPagesRoot+'\'+RegistrySection+SRegWizPages_Toolbars);
  end;

  function TWizardPage.NextPage: Boolean;
  begin
    Result := True;
  end;

  procedure TWizardPage.PageDataChange(Sender: TObject);
  begin
    StatusChanged;
  end;

  procedure TWizardPage.StatusChanged;
  begin
    FController.HostFormIntf.StatusChanged;
  end;

   //===================================================================================================================
   // TWizardController
   //===================================================================================================================

  procedure TWizardController.Add(Page: TWizardPage);
  begin
    inherited Add(Page);
  end;

  procedure TWizardController.Clear;
  begin
    while Count>0 do Delete(Count-1);
    inherited Clear;
  end;

  constructor TWizardController.Create(AHostFormIntf: IWizardHostForm);
  begin
    inherited Create;
    FKeepHistory  := True;
    FHostFormIntf := AHostFormIntf;
  end;

  function TWizardController.CreatePage(PClass: TWizardPageClass; iID, iHelpContext: Integer; const sPageTitle: String): TWizardPage;
  begin
    Result := PClass.Create(Self, iID, iHelpContext, sPageTitle);
    Result.Parent := FHostFormIntf.HostControl;
    Result.Align := alClient;
    Result.InitializePage;
  end;

  procedure TWizardController.Delete(Index: Integer);
  begin
    GetItems(Index).Free;
  end;

  destructor TWizardController.Destroy;
  var i: Integer;
  begin
    for i := 0 to Count-1 do GetItems(i).FinalizePage;
    inherited Destroy;
  end;

  function TWizardController.GetHistoryEmpty: Boolean;
  begin
    Result := High(FPageIDHistory)<0;
  end;

  function TWizardController.GetItems(Index: Integer): TWizardPage;
  begin
    Result := TWizardPage(inherited Items[Index]);
  end;

  function TWizardController.GetItemsByID(iID: Integer): TWizardPage;
  var idx: Integer;
  begin
    idx := IndexOfID(iID);
    if idx<0 then PhoaWizardError('Invalid wizard page ID (%d)', [iID]);
    Result := GetItems(idx);
  end;

  function TWizardController.GetVisiblePage: TWizardPage;
  var i: Integer;
  begin
    for i := 0 to Count-1 do begin
      Result := GetItems(i);
      if Result.Visible then Exit;
    end;
    Result := nil;
  end;

  function TWizardController.GetVisiblePageID: Integer;
  var p: TWizardPage;
  begin
    p := GetVisiblePage;
    if p=nil then Result := 0 else Result := p.ID;
  end;

  function TWizardController.IndexOf(Page: TWizardPage): Integer;
  begin
    Result := inherited IndexOf(Page);
  end;

  function TWizardController.IndexOfID(iID: Integer): Integer;
  begin
    for Result := 0 to Count-1 do
      if GetItems(Result).ID=iID then Exit;
    Result := -1;
  end;

  procedure TWizardController.Remove(Page: TWizardPage);
  begin
    inherited Remove(Page);
  end;

  procedure TWizardController.SetKeepHistory(Value: Boolean);
  begin
    if FKeepHistory<>Value then begin
      FKeepHistory := Value;
       // ���� �� ���� �������, ������� �������
      if not Value and (High(FPageIDHistory)>=0) then begin
        FPageIDHistory := nil;
        FHostFormIntf.StatusChanged;
      end;
    end;
  end;

  procedure TWizardController.SetNextPage;
  var
    CurPage: TWizardPage;
    iNextPageID: Integer;
  begin
    CurPage := GetVisiblePage;
     // ���� ������� �������� � ��������� �����
    if (CurPage=nil) or CurPage.NextPage then begin
      iNextPageID := FHostFormIntf.NextPageID;
      if iNextPageID>0 then SetVisiblePageID(iNextPageID, pcmNextBtn);
    end;
  end;

  procedure TWizardController.SetPrevPageFromHistory;
  var i, iLastPageID: Integer;
  begin
     // ��������� ������� ������� � �������
    i := High(FPageIDHistory);
    if i=-1 then PhoaWizardError('Page history is empty');
     // ��������� ID ��������� ��������
    iLastPageID := FPageIDHistory[i];
     // ������� ��������� ������ �������
    SetLength(FPageIDHistory, i);
     // ���������� ���������� �������� (����� �������� � �� �������, ����� ���������� ������� ��������� ����� �����)
    SetVisiblePageID(iLastPageID, pcmBackBtn);
  end;

  function TWizardController.SetVisiblePageID(iNewID: Integer; ChangeMethod: TPageChangeMethod): Boolean;
  var
    CurPage, NewPage: TWizardPage;
    i, iPrevPageID: Integer;
  begin
    Result := False;
    NewPage := ItemsByID[iNewID];
    CurPage := VisiblePage;
    iPrevPageID := GetVisiblePageID;
     // ���� �������� ��������
    if iPrevPageID<>iNewID then begin
      StartWait;
      try
         // ���� ������� �������� � ���������� OnPageChanging ��������� �����
        if FHostFormIntf.PageChanging(ChangeMethod, iNewID) then begin
           // ���������� ������� ��������
          if CurPage<>nil then CurPage.BeforeHide(ChangeMethod);
           // ���������� ����� ��������
          NewPage.BeforeDisplay(ChangeMethod);
           // ������������� ����� ��������
          for i := 0 to Count-1 do
            with GetItems(i) do Visible := ID=iNewID;
             // ������������ �������� � �������
          if FKeepHistory and (iPrevPageID>0) and (ChangeMethod=pcmNextBtn) then begin
            i := High(FPageIDHistory)+1;
            SetLength(FPageIDHistory, i+1);
            FPageIDHistory[i] := iPrevPageID;
          end;
           // ������������� HelpContext
          FHostFormIntf.StorageForm.HelpContext := NewPage.HelpContext;
           // ���������� �� ����� ��������
          FHostFormIntf.PageChanged(ChangeMethod, iPrevPageID);
           // ���������� ������� ��������
          if CurPage<>nil then CurPage.AfterHide(ChangeMethod);
           // ���������� ����� ��������
          NewPage.AfterDisplay(ChangeMethod);
           // ���������� �� ��������� �������
          FHostFormIntf.StatusChanged;
          Result := True;
        end;
      finally
        StopWait;
      end;
    end;
  end;

end.
