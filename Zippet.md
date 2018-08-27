# Changelog

All notable changes to this project will be documented in this file.

ZIPPET      ZIPPEd Transfer

ACTS 	  Auto Compress To Server 

PACT 	  PACk To

ACTANT 	  Auto Compress TrANsfer To

PATRAS 	  PAck TRAnsfer Server

## [Unreleased] 

- Use Ordinateur\HKEY_CURRENT_USER\Software\Classes\\*\shell instead, does not requires privileges
- Upgrade Copy function to display progress bar when copying multiple items

## [Links to read/use]

- About Copy :
  - https://4sysops.com/archives/copy-item-move-item-copy-and-move-files-with-powershell/
  - https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-R2-and-2012/cc733145(v=ws.11)
  - https://blogs.technet.microsoft.com/heyscriptingguy/2015/12/20/build-a-better-copy-item-cmdlet-2/
  - https://keithga.wordpress.com/2014/06/23/copy-itemwithprogress/
  - https://stackoverflow.com/questions/13883404/custom-robocopy-progress-bar-in-powershell

## [0.2.0] - 2018-08-27

### Added

- __Functionnality__ :
	- Auto-detection of how to paste (from server or to server method)
  
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
  -  Multiples Files/Directories
    - Zip all files and directory contain in the clipboard which are not .zip together
    - Push the Zip file to destination, unzip-it and erase the .zip
    - Copy all Zips file to destination; unzip-them and erase all the .zip

### Changed

- 

### Removed

- 

### Fixed

- .

