//**********************************************************************************************************************
//  $Id: phoa.dpr,v 1.3 2004-04-17 12:06:22 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Copyright 2002-2004 Dmitry Kann, http://phoa.narod.ru
//**********************************************************************************************************************
program phoa;

uses
  Forms,
  Windows,
  phObj in 'phObj.pas',
  phPhoa in 'phPhoa.pas',
  phMetadata in 'phMetadata.pas',
  ConsVars in 'ConsVars.pas',
  phUtils in 'phUtils.pas',
  Main in 'Main.pas' {fMain},
  udPicProps in 'udPicProps.pas' {dPicProps},
  udSettings in 'udSettings.pas' {dSettings},
  ufImgView in 'ufImgView.pas' {fImgView},
  udSearch in 'udSearch.pas' {dSearch},
  udPhoAProps in 'udPhoAProps.pas' {dPhoAProps},
  udAbout in 'udAbout.pas' {dAbout},
  ChmHlp in 'ChmHlp.pas',
  udPicOps in 'udPicOps.pas' {dPicOps},
  udSortPics in 'udSortPics.pas' {dSortPics},
  udSelKeywords in 'udSelKeywords.pas' {dSelKeywords},
  udViewProps in 'udViewProps.pas' {dViewProps},
  udSelPhoaGroup in 'udSelPhoaGroup.pas' {dSelPhoaGroup},
  phDlg in 'phDlg.pas' {PhoaDialog},
  ufAddFilesWizard in 'ufAddFilesWizard.pas' {fAddFilesWizard},
  ufrWzPageAddFiles_SelFiles in 'ufrWzPageAddFiles_SelFiles.pas' {frWzPageAddFiles_SelFiles: TFrame},
  phWizard in 'phWizard.pas' {WizardPage: TFrame},
  phWizForm in 'phWizForm.pas' {PhoaWizardForm},
  ufrWzPageAddFiles_CheckFiles in 'ufrWzPageAddFiles_CheckFiles.pas' {frWzPageAddFiles_CheckFiles: TFrame},
  ufrWzPage_Processing in 'ufrWzPage_Processing.pas' {frWzPage_Processing: TFrame},
  ufrPicProps_FileProps in 'ufrPicProps_FileProps.pas' {frPicProps_FileProps: TFrame},
  ufrPicProps_Metadata in 'ufrPicProps_Metadata.pas' {frPicProps_Metadata: TFrame},
  ufrPicProps_View in 'ufrPicProps_View.pas' {frPicProps_View: TFrame},
  ufrPicProps_Data in 'ufrPicProps_Data.pas' {frPicProps_Data: TFrame},
  ufrPicProps_Keywords in 'ufrPicProps_Keywords.pas' {frPicProps_Keywords: TFrame},
  ufrPicProps_Groups in 'ufrPicProps_Groups.pas' {frPicProps_Groups: TFrame},
  phPicPropsDlgPage in 'phPicPropsDlgPage.pas' {PicPropsDialogPage: TFrame},
  ufrWzPage_Log in 'ufrWzPage_Log.pas' {frWzPage_Log: TFrame},
  ufrSorting in 'ufrSorting.pas' {frSorting: TFrame},
  udStats in 'udStats.pas' {dStats},
  udFileOpsWizard in 'udFileOpsWizard.pas' {dFileOpsWizard},
  ufrWzPageFileOps_SelTask in 'ufrWzPageFileOps_SelTask.pas' {frWzPageFileOps_SelTask: TFrame},
  ufrWzPageFileOps_SelPics in 'ufrWzPageFileOps_SelPics.pas' {frWzPageFileOps_SelPics: TFrame},
  ufrWzPageFileOps_SelFolder in 'ufrWzPageFileOps_SelFolder.pas' {frWzPageFileOps_SelFolder: TFrame},
  ufrWzPageFileOps_MoveOptions in 'ufrWzPageFileOps_MoveOptions.pas' {frWzPageFileOps_MoveOptions: TFrame},
  ufrWzPageFileOps_DelOptions in 'ufrWzPageFileOps_DelOptions.pas' {frWzPageFileOps_DelOptions: TFrame},
  ufrWzPageFileOps_RepairOptions in 'ufrWzPageFileOps_RepairOptions.pas' {frWzPageFileOps_RepairOptions: TFrame},
  ufrWzPageFileOps_CDOptions in 'ufrWzPageFileOps_CDOptions.pas' {frWzPageFileOps_CDOptions: TFrame},
  ufrWzPageFileOps_RepairSelLinks in 'ufrWzPageFileOps_RepairSelLinks.pas' {frWzPageFileOps_RepairSelLinks: TFrame},
  ufrWzPageFileOps_MoveOptions2 in 'ufrWzPageFileOps_MoveOptions2.pas' {frWzPageFileOps_MoveOptions2: TFrame};

{$R *.res}

begin
  CreateMutex(nil, False, 'PHOA_RUNNING_MUTEX'); 
  Application.Initialize;
  Application.CreateForm(TfMain, fMain);
  Application.Run;
end.
