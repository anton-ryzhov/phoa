unit udStats;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, PhObj, ConsVars, VirtualShellUtilities,
  Dialogs, phDlg, DTLangTools, StdCtrls, VirtualTrees, ExtCtrls;

type
  PPStatsData = ^PStatsData;
  PStatsData = ^TStatsData;
  TStatsData = record
    sName:   String;
    sValue:  String;
    iImgIdx: Integer;
  end;

  TdStats = class(TPhoaDialog)
    tvMain: TVirtualStringTree;
    procedure tvMainGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString);
    procedure tvMainFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure tvMainPaintText(Sender: TBaseVirtualTree; const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType);
    procedure tvMainGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer);
  private
     // ����������
    FPhoA: TPhotoAlbum;
     // ������� ������
    FGroup: TPhoaGroup;
     // ��������� �����������
    FSelPics: TPicArray;
     // ������ � ������ ����� ������ ������ ����������
    function NewStatData(const sName, sValue: String; iImgIdx: Integer = -1): PStatsData; overload;
    function NewStatData(const sName: String; iValue: Integer): PStatsData; overload;
  protected
    procedure InitializeDialog; override;
  end;

  procedure ShowPhoaStats(PhoA: TPhotoAlbum; Group: TPhoaGroup; aSelPics: TPicArray);

implementation
{$R *.dfm}
uses phUtils, Main, phPhoa;

  procedure ShowPhoaStats(PhoA: TPhotoAlbum; Group: TPhoaGroup; aSelPics: TPicArray);
  begin
    with TdStats.Create(Application) do
      try
        FPhoA    := PhoA;
        FGroup   := Group;
        FSelPics := aSelPics;
        Execute;
      finally
        Free;
      end;
  end;

  procedure TdStats.InitializeDialog;
  var n0, n1: PVirtualNode;

     // ��������� ���� ������� ����� �����������
    procedure AddPhoaFileProps(nParent: PVirtualNode);
    var
      ns: TNamespace;
      DFProp: TDiskFileProp;
    begin
      if FPhoA.FileName<>'' then
        try
          ns := TNamespace.CreateFromFileName(FPhoA.FileName);
          for DFProp := Low(DFProp) to High(DFProp) do tvMain.AddChild(nParent, NewStatData(DiskFilePropName(DFProp), DiskFilePropValue(DFProp, ns)));
        except
          on EVSTInvalidFileName do {ignore};
        end;
    end;

     // ��������� ���� ���������� ������
    procedure AddGroupStats(Group: TPhoaGroup; nParent: PVirtualNode);
    var
      iCntNestedGroups: Integer;  // ���������� ��������� ��������
      iCntPicsInGroup: Integer;   // ���������� ����������� � ������
      iCntPics: Integer;          // ����� ���������� ����������� (� ������ � ��������� ����������)
      iCntDistinctPics: Integer;  // ���������� ��������� ����������� � ������ � ��������� ����������
      iTotalFileSize: Integer;    // ��������� ������ ������ �����������
      iAverageFileSize: Integer;  // ������� ������ ������ �����������
      iTotalThumbSize: Integer;   // ��������� ������ �������
      iAverageThumbSize: Integer; // ������� ������ �������
      iMaxFileSize: Integer;      // ������ ������ �������� �����
      iMinFileSize: Integer;      // ������ ������ ���������� �����
      sMaxFileName: String;       // ��� ������ �������� �����
      sMinFileName: String;       // ��� ������ ���������� �����
      i, iFSize: Integer;
      IDs: TIntegerList;
      Pic: TPhoaPic;

      procedure ProcessGroup(Group: TPhoaGroup);
      var
        i: Integer;
        gChild: TPhoaGroup;
      begin
        Inc(iCntPics, Group.PicIDs.Count);
         // ��������� ID ����������� � ������
        for i := 0 to Group.PicIDs.Count-1 do IDs.Add(Group.PicIDs[i]);
         // ���������� �������� ��� ��������� ����� 
        for i := 0 to Group.Groups.Count-1 do begin
          gChild := Group.Groups[i];
          Inc(iCntNestedGroups);
          ProcessGroup(gChild);
        end;
      end;

    begin
      iCntNestedGroups := 0;
      iCntPics         := 0;
      iTotalFileSize   := 0;
      iTotalThumbSize  := 0;
      IDs := TIntegerList.Create(False);
      try
        iCntPicsInGroup  := Group.PicIDs.Count;
         // ���������� ��������� ������
        ProcessGroup(Group);
        iCntDistinctPics := IDs.Count;
         // ������� ������� ������/�������
        iMaxFileSize := 0;
        iMinFileSize := MaxInt;
        sMaxFileName := '';
        sMinFileName := '';
        for i := 0 to IDs.Count-1 do begin
          Pic := FPhoA.Pics.PicByID(IDs[i]);
          iFSize := Pic.PicFileSize;
          Inc(iTotalFileSize,  iFSize);
          Inc(iTotalThumbSize, Length(Pic.ThumbnailData));
           // -- ���� ����� ������� ����
          if iFSize>iMaxFileSize then begin
            iMaxFileSize := iFSize;
            sMaxFileName := Pic.PicFileName;
          end;
           // -- ���� ����� ��������� ����
          if iFSize<iMinFileSize then begin
            iMinFileSize := iFSize;
            sMinFileName := Pic.PicFileName;
          end;
        end;
         // -- ������� ������� ��������
        if iCntDistinctPics=0 then begin
          iAverageFileSize  := 0;
          iAverageThumbSize := 0;
        end else begin
          iAverageFileSize  := iTotalFileSize  div iCntDistinctPics;
          iAverageThumbSize := iTotalThumbSize div iCntDistinctPics;
        end;
      finally
        IDs.Free;
      end;
      with tvMain do begin
        AddChild(nParent, NewStatData('@SStat_CntNestedGroups', iCntNestedGroups));
        AddChild(nParent, NewStatData('@SStat_CntPicsInGroup',  iCntPicsInGroup));
        AddChild(nParent, NewStatData('@SStat_CntPics',         iCntPics));
        AddChild(nParent, NewStatData('@SStat_CntDistinctPics', iCntDistinctPics));
        AddChild(nParent, NewStatData('@SStat_TotalFileSize',   HumanReadableSize(iTotalFileSize)));
        AddChild(nParent, NewStatData('@SStat_AvgFileSize',     HumanReadableSize(iAverageFileSize)));
        AddChild(nParent, NewStatData('@SStat_TotalThumbSize',  HumanReadableSize(iTotalThumbSize)));
        AddChild(nParent, NewStatData('@SStat_AvgThumbSize',    HumanReadableSize(iAverageThumbSize)));
        if sMaxFileName<>'' then begin
          AddChild(nParent, NewStatData('@SStat_MaxFileName',   sMaxFileName));
          AddChild(nParent, NewStatData('@SStat_MaxFileSize',   HumanReadableSize(iMaxFileSize)));
        end;
        if sMinFileName<>'' then begin
          AddChild(nParent, NewStatData('@SStat_MinFileName',   sMinFileName));
          AddChild(nParent, NewStatData('@SStat_MinFileSize',   HumanReadableSize(iMinFileSize)));
        end;
      end;
    end;

  begin
    inherited InitializeDialog;
    HelpContext := IDH_intf_stats;
    tvMain.NodeDataSize := SizeOf(Pointer);
    ApplyTreeSettings(tvMain);
     // ��������� ������
    StartWait;
    try
       // -- ����������
      n0 := tvMain.AddChild(nil, NewStatData('@SStat_PhotoAlbum', '', iiPhoA));
        n1 := tvMain.AddChild(n0, NewStatData('@SStat_PhoaFilename', FPhoA.FileName));
          AddPhoaFileProps(n1);
          tvMain.AddChild(n1, NewStatData('@SStats_PhoaFileRevision', aPhFileRevisions[ValidRevisionIndex(GetIndexOfRevision(FPhoA.FileRevision))].sName));
        tvMain.AddChild(n0, NewStatData('@SStats_DistinctPics', FPhoA.Pics.Count));
        AddGroupStats(FPhoA.RootGroup, n0);
       // -- ������� ������
      if (FGroup<>nil) and (FGroup<>FPhoA.RootGroup) then begin
        n0 := tvMain.AddChild(nil, NewStatData('@SStat_Group', '', iiFolder));
          AddGroupStats(FGroup, n0);
      end;
       // ������������� �� ������
      tvMain.FullExpand;
    finally
      StopWait;
    end;
  end;

  function TdStats.NewStatData(const sName, sValue: String; iImgIdx: Integer = -1): PStatsData;
  var s: String;
  begin
     // ���� ������ ���������� �� '@' - ��� ��� ��������� �� TdStats.dtlsMain
    if sName[1]='@' then s := dtlsMain.Consts[Copy(sName, 2, MaxInt)] else s := sName;
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
