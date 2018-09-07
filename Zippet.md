# Changelog

All notable changes to this project will be documented in this file.

ZIPPET      ZIPPEd Transfer

ACTS 	  Auto Compress To Server 

PACT 	  PACk To

ACTANT 	  Auto Compress TrANsfer To

PATRAS 	  PAck TRAnsfer Server

HAREZ     Handle Automatic REpaste Zips

AREZ		  Automatic REpaste Zips

## [Unreleased] 

- Upgrade Copy function to display progress bar when copying multiple items (perhaps even single item, if big no user feedback)
- When extracting zip content from server everything in extract raw so need to check for duplicate file. Perhaps extracting first in temporary folder then move files to destination and check for duplicates and ask user what to do

## [Links to read/use]

- About Copy :
  - https://4sysops.com/archives/copy-item-move-item-copy-and-move-files-with-powershell/

  - https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-R2-and-2012/cc733145(v=ws.11)

  - https://blogs.technet.microsoft.com/heyscriptingguy/2015/12/20/build-a-better-copy-item-cmdlet-2/

  - https://keithga.wordpress.com/2014/06/23/copy-itemwithprogress/

  - https://stackoverflow.com/questions/13883404/custom-robocopy-progress-bar-in-powershell

  - ```powershell
    Import-Module BitsTransfer
    Start-BitsTransfer -Source $Source -Destination $Destination -Description "Backup" -DisplayName "Backup"
    ```

  - To use windows progress bar :

  - ```powershell
    $FOF_CREATEPROGRESSDLG = "&H0&"
    $objShell = New-Object -ComObject "Shell.Application"
    $objFolder = $objShell.NameSpace($DestLocation) 
    $objFolder.CopyHere($srcFile, $FOF_CREATEPROGRESSDLG)
    ```

## [Thought]

- What pasting multiples selected non zip files or folder from server should do along with zips one(s) should do ? Should-it unzip the zips at destination or not ?
  
## [0.2.0] - 2018-08-27

### Added

- __Functionnality__ :
  - Auto-detection of how to paste (from server or to server method)
  - Paste from server : If multiple files are selected including zips each zip is unzip in a directory with its name instead of extracting everything raw at destination. Prevent duplicate files issue.

### Changed

- Use HKEY_CURRENT_USER\Software\Classes\ as root key in registry instead of HKEY_CLASSES_ROOT\ : No more requires privileges to add/remove entry from contextual menu
- __Functionnality__ Paste from server :
  - Files are no more zips before transfer because it's a waste of performance. Machine is any way transfering non zips files to zip them and then we can unzip it.

## [0.1.0] - 2018-08-24

### Added

- __Functionnality__ Paste to server :
  - Single File
    - Copy it to destination
    - Ask for confirmation to overwrite when file with similar name exists at destination
  - Multiples Files/Directories
    - Zip all files and directory contain in the clipboard together
    - Push the Zip file to destination
    - Ask for confirmation to overwrite or update when Zip with similar name exists at destination
- __Functionnality__ Paste from server :
  - Single File
    - Copy it to destination if regular file or unzip to destination if .zip
  - Multiples Files/Directories
      - Zip all files and directory contain in the clipboard which are not .zip together
      - Push the Zip file to destination, unzip-it and erase the .zip
      - Copy all Zips file to destination; unzip-them and erase all the .zip

### Changed

- 

### Removed

- 

### Fixed

- .

