//**********************************************************************************************************************
//  $Id: udStats.pas,v 1.19 2004-12-31 13:38:58 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Copyright DK Software, http://www.dk-soft.org/
//**********************************************************************************************************************
unit udStats;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs,
  phIntf, phMutableIntf, phNativeIntf, phObj, phOps, ConsVars, phDlg, VirtualShellUtilities,
  DKLang, VirtualTrees, StdCtrls, ExtCtrls;

type
  PPStatsData = ^PStatsData;
  PStatsData = ^TStatsData;
  TStatsData = record
    sName:   String;
    sValue:  String;
    iImgIdx: Integer;
  end;

  TdStats = class(TPhoaDialog)
    dklcMain: TDKLanguageController;
    tvMain: TVirtualStringTree;
    procedure tvMainGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString);
    procedure tvMainFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure tvMainPaintText(Sender: TBaseVirtualTree; const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType);
    procedure tvMainGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer);
  private
     // ����������
    FApp: IPhotoAlbumApp;
     // ������ � ������ ����� ������ ������ ����������
    function NewStatData(const sName, sValue: String; iImgIdx: Integer = -1): PStatsData; overload;
    function NewStatData(const sName: String; iValue: Integer): PStatsData; overload;
  protected
    procedure InitializeDialog; override;
    function  GetFormRegistrySection: String; override;
    function  GetSizeable: Boolean; override;
  end;

  procedure ShowProjectStats(AApp: IPhotoAlbumApp);

implementation
{$R *.dfm}
uses phUtils, Main, phPhoa, phSettings;

  procedure ShowProjectStats(AApp: IPhotoAlbumApp);
  begin
    with TdStats.Create(Application) do
      try
        FApp := AApp;
        Execute;
      finally
        Free;
      end;
  end;

  function TdStats.GetFormRegistrySection: String;
  begin
    Result := SRegStats_Root;
  end;

  function TdStats.GetSizeable: Boolean;
  begin
    Result := True;
  end;

  procedure TdStats.InitializeDialog;
  var n0, n1: PVirtualNode;

     // ��������� ���� ������� ����� �����������
    procedure AddPhoaFileProps(nParent: PVirtualNode);
    var
      ns: TNamespace;
      DFProp: TDiskFileProp;
    begin
      if FApp.Project.FileName<>'' then
        try
          ns := TNamespace.CreateFromFileName(FApp.Project.FileName);
          for DFProp := Low(DFProp) to High(DFProp) do tvMain.AddChild(nParent, NewStatData(DiskFilePropName(DFProp), DiskFilePropValue(DFProp, ns)));
        except
          on EVSTInvalidFileName do {ignore};
        end;
    end;

     // ��������� ���� ���������� ������
    procedure AddGroupStats(Group: IPhotoAlbumPicGroup; nParent: PVirtualNode);
    var
      iCntNestedGroups: Integer;  // ���������� ��������� ��������
      iCntPicsInGroup: Integer;   // ���������� ����������� � ������
      iCntPics: Integer;          // ����� ���������� ����������� (� ������ � ��������� ����������)
      iCntDistinctPics: Integer;  // ���������� ��������� ����������� � ������ � ��������� ����������
      i64TotalFileSize: Int64;    // ��������� ������ ������ �����������
      i64AverageFileSize: Int64;  // ������� ������ ������ �����������
      i64TotalThumbSize: Int64;   // ��������� ������ �������
      i64AverageThumbSize: Int64; // ������� ������ �������
      i64MaxFileSize: Int64;      // ������ ������ �������� �����
      i64MinFileSize: Int64;      // ������ ������ ���������� �����
      sMaxFileName: String;       // ��� ������ �������� �����
      sMinFileName: String;       // ��� ������ ���������� �����
      i: Integer;
      i64FSize: Int64;
      IDs: TIntegerList;
      Pic: IPhoaPic;

      procedure ProcessGroup(Group: IPhotoAlbumPicGroup);
      var
        i: Integer;
        gChild: IPhotoAlbumPicGroup;
      begin
        Inc(iCntPics, Group.Pics.Count);
         // ��������� ID ����������� � ������
        for i := 0 to Group.Pics.Count-1 do IDs.Add(Group.Pics[i].ID);
         // ���������� �������� ��� ��������� �����
        for i := 0 to Group.Groups.Count-1 do begin
          gChild := Group.GroupsX[i];
          Inc(iCntNestedGroups);
          ProcessGroup(gChild);
        end;
      end;

    begin
      iCntNestedGroups  := 0;
      iCntPics          := 0;
      i64TotalFileSize  := 0;
      i64TotalThumbSize := 0;
      IDs := TIntegerList.Create(False);
      try
        iCntPicsInGroup  := Group.Pics.Count;
         // ���������� ��������� ������
        ProcessGroup(Group);
        iCntDistinctPics := IDs.Count;
         // ������� ������� ������/�������
        i64MaxFileSize := 0;
        i64MinFileSize := MaxInt;
        sMaxFileName   := '';
        sMinFileName   := '';
        for i := 0 to IDs.Count-1 do begin
          Pic := FApp.Project.Pics.ItemsByID[IDs[i]];
          i64FSize := Pic.FileSize;
          Inc(i64TotalFileSize,  i64FSize);
          Inc(i64TotalThumbSize, Length(Pic.ThumbnailData));
           // -- ���� ����� ������� ����
          if i64FSize>i64MaxFileSize then begin
            i64MaxFileSize := i64FSize;
            sMaxFileName   := Pic.FileName;
          end;
           // -- ���� ����� ��������� ����
          if i64FSize<i64MinFileSize then begin
            i64MinFileSize := i64FSize;
            sMinFileName   := Pic.FileName;
          end;
        end;
         // -- ������� ������� ��������
        if iCntDistinctPics=0 then begin
          i64AverageFileSize  := 0;
          i64AverageThumbSize := 0;
        end else begin
          i64AverageFileSize  := i64TotalFileSize  div iCntDistinctPics;
          i64AverageThumbSize := i64TotalThumbSize div iCntDistinctPics;
        end;
      finally
        IDs.Free;
      end;
      with tvMain do begin
        AddChild(nParent, NewStatData('@SStat_CntNestedGroups', iCntNestedGroups));
        AddChild(nParent, NewStatData('@SStat_CntPicsInGroup',  iCntPicsInGroup));
        AddChild(nParent, NewStatData('@SStat_CntPics',         iCntPics));
        AddChild(nParent, NewStatData('@SStat_CntDistinctPics', iCntDistinctPics));
        AddChild(nParent, NewStatData('@SStat_TotalFileSize',   HumanReadableSize(i64TotalFileSize)));
        AddChild(nParent, NewStatData('@SStat_AvgFileSize',     HumanReadableSize(i64AverageFileSize)));
        AddChild(nParent, NewStatData('@SStat_TotalThumbSize',  HumanReadableSize(i64TotalThumbSize)));
        AddChild(nParent, NewStatData('@SStat_AvgThumbSize',    HumanReadableSize(i64AverageThumbSize)));
        if sMaxFileName<>'' then begin
          AddChild(nParent, NewStatData('@SStat_MaxFileName',   sMaxFileName));
          AddChild(nParent, NewStatData('@SStat_MaxFileSize',   HumanReadableSize(i64MaxFileSize)));
        end;
        if sMinFileName<>'' then begin
          AddChild(nParent, NewStatData('@SStat_MinFileName',   sMinFileName));
          AddChild(nParent, NewStatData('@SStat_MinFileSize',   HumanReadableSize(i64MinFileSize)));
        end;
      end;
    end;

  begin
    inherited InitializeDialog;
    HelpContext := IDH_intf_stats;
     // ����������� tvMain
    tvMain.NodeDataSize := SizeOf(Pointer);
    ApplyTreeSettings(tvMain);
     // ��������� ������
    StartWait;
    tvMain.BeginUpdate;
    try
       // -- ����������
      n0 := tvMain.AddChild(nil, NewStatData('@SStat_PhotoAlbum', '', iiPhoA));
        n1 := tvMain.AddChild(n0, NewStatData('@SStat_PhoaFilename', FApp.Project.FileName));
          AddPhoaFileProps(n1);
          tvMain.AddChild(n1, NewStatData('@SStats_PhoaFileRevision', aPhFileRevisions[ValidRevisionIndex(GetIndexOfRevision(FApp.Project.FileRevision))].sName));
        tvMain.AddChild(n0, NewStatData('@SStats_DistinctPics', FApp.Project.Pics.Count));
        AddGroupStats(FApp.Project.RootGroupX, n0);
       // -- ������� ������
      if (FApp.CurGroup<>nil) and (FApp.CurGroup.ID<>FApp.Project.RootGroup.ID) then begin
        n0 := tvMain.AddChild(nil, NewStatData('@SStat_Group', '', iiFolder));
        AddGroupStats(FApp.CurGroup, n0);
      end;
       // ������������� �� ������
      tvMain.FullExpand;
    finally
      tvMain.EndUpdate;
      StopWait;
    end;
  end;

  function TdStats.NewStatData(const sName, sValue: String; iImgIdx: Integer = -1): PStatsData;
  var s: String;
  begin
     // ���� ������ ���������� �� '@' - ��� ��� ���������
    if sName[1]='@' then s := ConstVal(Copy(sName, 2, MaxInt)) else s := sName;
    New(Result);
    Result^.sName   := s;
    Result^.sValue  := sValue;
    Result^.iImgIdx := iImgIdx;
  end;

  function TdStats.NewStatData(const sName: String; iValue: Integer): PStatsData;
  begin
    Result := NewStatData(sName, IntToStr(iValue));
  end;

  procedure TdStats.tvMainFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
  begin
    Dispose(PPStatsData(Sender.GetNodeData(Node))^);
  end;

  procedure TdStats.tvMainGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer);
  begin
    if Column=0 then ImageIndex := PPStatsData(Sender.GetNodeData(Node))^^.iImgIdx;
  end;

  procedure TdStats.tvMainGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString);
  var ppsd: PPStatsData;
  begin
    ppsd := Sender.GetNodeData(Node);
    case Column of
      0: CellText := AnsiToUnicodeCP(ppsd^^.sName,  cMainCodePage);
      1: CellText := AnsiToUnicodeCP(ppsd^^.sValue, cMainCodePage);
    end;
  end;

  procedure TdStats.tvMainPaintText(Sender: TBaseVirtualTree; const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType);
  begin
    if Sender.NodeParent[Node]=nil then TargetCanvas.Font.Style := [fsBold];
  end;

end.

