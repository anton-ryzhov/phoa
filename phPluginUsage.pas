//**********************************************************************************************************************
//  $Id: phPluginUsage.pas,v 1.1 2005-02-14 19:34:08 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Copyright DK Software, http://www.dk-soft.org/
//**********************************************************************************************************************
unit phPluginUsage;

interface
uses Windows, SysUtils, Classes, phPlugin;

   // ��������� ������� �������� � ������������ ��������� �������
  procedure ScanForPlugins;

   // ���������� ���������� ������������������ ������� ��������
  function PluginGetClassCount: Integer;
   // ���������� ����� ������� � �������� Index
  function PluginGetClass(iIndex: Integer): IPhoaPluginClass;

implementation
uses ConsVars;

var
   // ������ ������� ������������������ ��������
  PluginClasses: IInterfaceList;

   // ��������� ����������� �������
  procedure RegisterPlugin(const sPluginLib: String);
  var
    hLib: HINST;
    GetClassCountProc: TPhoaPluginGetClassCountProc;
    GetClassProc: TPhoaPluginGetClassProc;
    i, iCount: Integer;
    PluginClass: IPhoaPluginClass;
  begin
     // ������ ����������
    hLib := LoadLibrary(PChar(sPluginLib));
    if hLib=0 then RaiseLastOSError;
     // �������� �������� ���������
    GetClassCountProc := GetProcAddress(hLib, 'PhoaPluginGetClassCount');
    GetClassProc      := GetProcAddress(hLib, 'PhoaPluginGetClass');
    if Assigned(GetClassCountProc) and Assigned(GetClassProc) then begin
       // �������� ���������� ������� � ����������
      iCount := 0;
      GetClassCountProc(iCount);
       // ������������ ������
      for i := 0 to iCount-1 do begin
        PluginClass := nil;
        GetClassProc(i, PluginClass);
        if PluginClass<>nil then PluginClasses.Add(PluginClass);
      end;
    end else
      FreeLibrary(hLib);
  end;

   // ����������� ��������� ������������ ��������
  procedure ScanPluginDir(const sDir: String);
  var
    sPath: String;
    SRec: TSearchRec;
  begin
    sPath := IncludeTrailingPathDelimiter(sDir);
    if FindFirst(sPath+'*.*', faAnyFile, SRec)=0 then
      try
        repeat
           // ����, �������� ������
          if SRec.Attr and faDirectory=0 then begin
            if UpperCase(ExtractFileExt(SRec.Name))='.DLL' then RegisterPlugin(sPath+SRec.Name);
           // �������
          end else if SRec.Name[1]<>'.' then
            ScanPluginDir(sPath+SRec.Name);
        until FindNext(SRec)<>0;
      finally
        FindClose(SRec);
      end;
  end;

  procedure ScanForPlugins;
  begin
     // ��������� ������� ��������
    ScanPluginDir(sApplicationPath+SRelativePluginPath);
  end;

  function PluginGetClassCount: Integer;
  begin
    Result := PluginClasses.Count;
  end;

  function PluginGetClass(iIndex: Integer): IPhoaPluginClass;
  begin
    Result := IPhoaPluginClass(PluginClasses[iIndex]);
  end;

initialization
  PluginClasses := TInterfaceList.Create;
finalization
  PluginClasses := nil;
end.
 
