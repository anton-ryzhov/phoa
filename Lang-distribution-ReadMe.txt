-------------------------------------------------------------------------------
Dmitry Kann :: http://phoa.narod.ru
Notes on language files distribution
Applicable to PhoA version 1.1.4 beta
-------------------------------------------------------------------------------

For RUSSIAN: ��. ����� �� ������

The distribution includes the following files:

  - dttm\dttm.exe                - The DaleTech Translation Manager 
  - *.dtls                       - DaleTech language snapshots
  - IS-install\phoa.iss          - PhoA setup script
  - IS-install\eula-eng.rtf      - Original English End-User License Agreement
  - IS-install\eula-rus.rtf      - Original Russian End-User License Agreement
  - Lang-distribution-ReadMe.txt - This file

Localizing the main program files
---------------------------------

Generally, you use the Translation Manager (dttm.exe) to open the accompanying
*.dtls files.

Then you must add the language you want to translate to by selecting the
Edit | Add language... menu item. I highly recommend highlighting the English
language column before, then adding your language having set 'Copy all current
language data to the new language' check box on.

The original program languages are Russian and English. So if you see that
translations of a property for these languages are the same, there's no need
(and even may be wrong) to localize this property.

Properties you should never translate:
  SecondaryShortCuts
  HelpKeyword
  all Ini- or registry-related entries (IniFileName, IniSection)
  mruOpen.Prefix
  all URL-related entries
  Application name (PhoA)

WARNING: the Translation Manager software was written by me, and the only
tester was me, so never expect it to be bug-free or even stable! Make backups
of all your work as often as you change the files. Well, you're warned ;)

Localizing the setup script
---------------------------

You open the supplied phoa.iss file in any text editor capable of editing
plain-text files in your language.

Then you should carefully read through this file to determine which entries you
are to translate. The file is pretty self-explanatory, but if it isn't clear
yet, feel free to ask me.

Note on [Languages] section: you don't need to specify MessagesFile value, I'll
do it myself once the translation is finished. Only give an appropriate
two-letter language code for Name value, then use it as values for Languages
entries below.

Localizing the End-User License Agreement
-----------------------------------------

Use Microsoft Word to translate the License Agreement into your language. Then
save it as *.rtf format.

How do I check the results?
---------------------------

You cannot view the final results of your translation before I've recompiled
the program. So send me all you've done, then I build the application and
send it back to you - for you to be able to check the accuracy of the
translation.

*******************************************************************************
Please note: I do NOT encourage any secondary redistribution of any of these
files! All the language files as well as the Translation Manager software are
my sole property, and I allow using them for personal use only!
*******************************************************************************

Personally, I want to ask you to be as accurate as you can, please. Just
because I always do the same ;)

Sure, I will mention the work you have done in every relevant place!

Thanks and good luck,
Dmitry Kann, phoa@narod.ru


=== The same in Russian =======================================================

����� �������� � ���� ��������� �����:

  - dttm\dttm.exe                - The DaleTech Translation Manager 
  - *.dtls                       - �������� ����� DaleTech
  - IS-install\phoa.iss          - ������������ �������� PhoA
  - IS-install\eula-eng.rtf      - ������������ ������������ ���������� �� ���������� �����
  - IS-install\eula-rus.rtf      - ������������ ������������ ���������� �� ������� �����
  - Lang-distribution-ReadMe.txt - ���� ����

����������� �������� ������ ���������
-------------------------------------

���� ������, �� ������ ������������ Translation Manager (dttm.exe), ����� ��������� �
������������� ����������� ����� *.dtls.

����� �� ������ �������� ����, �� ������� �� ���������� �������, ������ ����� ����
Edit | Add language... � ����� ���������� �������� ������� ������� � ������, �������
�������� ��������� ��� �������� (���������� ��� �������), � ����� ���������� ������
� ������������� 'Copy all current language data to the new language', �����
����������� �� ���� ��� �������� � ����� ����.

������������� ������� ��������� �������� ������� � ����������. ������� ���� �� ������, ���
������� ������-���� �������� � ���� ������ ���������, �� ����� (� ����, ��������, �������)
���������� ��� ��������.

��������, ������� �� ������� �� ������ ����������:
  SecondaryShortCuts
  HelpKeyword
  ��� Ini-������ � ������, ����������� � ������� (IniFileName, IniSection)
  mruOpen.Prefix
  ��� ������, ����������� � URL
  ������������ ���������� (PhoA)

��������������: ��������� Translation Manager �������� ����, � ������������, ��� �
����������, ��� �, ������� ������� �� ����������� �� ��, ��� ��� �������� ��� �����, � ����
�� � ������������! ������� ��������� ����� ���� ����� ������ ����� ������� ���������
������. � �����, � ��� ����������� ;)

����������� �������� ���������
------------------------------

�� ������ ������� ����������� ���� phoa.iss ����� ��������� ����������, ���������
������������� ����������������� ��������� ����� �� ����� �����.

����� ��� ����� ��������� "����������" ���� ����, ����� ���������� ������, ���������� ��������.
������ ����� ��� �� ���� ������ �������, �� ��� ����� ���������� �� ������ ���������� �� ���.

���������� �� ������� [Languages]: ��� �� ��������� ��������� �������� MessagesFile, � ������ 
��� ��� �� ��������� ��������. ��� ��������� ������ ���� ����������� ������������� �����������
����� � �������� �������� Name, � ������������ ������������ ��� � �������� �������� ���������
Languages.

����������� ������������� ����������
------------------------------------

����������� Microsoft Word, ����� ��������� ������������ ���������� �� ��� ����. ����� ���������
��� � ������� *.rtf.

��� ��� ��������� ��������� ��������?
-------------------------------------

�� �� ������ ����������� ������������� ��������� �������� �� ��� ���, ���� � �� ��������������
����������. ������� ����������� ��� ��, ��� �� �������, � ������ ��������� � ������ ��� ����� -
����� �� ����� ��������� �������� ��������.

*******************************************************************************
����������, ���������: � �� ������� ����� ��������� ��������������� �����
������, ���������� � ������ �����! ��� �������� �����, � ����� ���������
Translation Manager �������� ������������� ���� ��������������, � � ���
���������� ������ ��� �� ������������� �������������!
*******************************************************************************

����� � ����� �� ��������� ��� ���� ��������� ����������� (� ��������), ��������� ��� ������
��������. ������ ������, ��� � ��� ������ �������� ������ ��� ;)

����������, ���� ������ ����� ��������� � ������ ���������� ����� ������������!

������� � �����,
������� ����, phoa@narod.ru
