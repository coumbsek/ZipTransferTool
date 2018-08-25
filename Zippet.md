# Changelog
All notable changes to this project will be documented in this file.

ZIPPET      ZIPPEd Transfer

ACTS 	  Auto Compress To Server 

PACT 	  PACk To

ACTANT 	  Auto Compress TrANsfer To

PATRAS 	  PAck TRAnsfer Server

## [Unreleased] 
- Check if copied thing is a .zip or not. If it is when pasting decompress instead of compress.
- Use Ordinateur\HKEY_CURRENT_USER\Software\Classes\*\shell instead, does not requires privileges
- Abstract Zip compression method

##[0.1.0] - 2018-08-24

### Added
- __Functionnality__ Paste to server :
  - Single File
    - Copy it to destination
    - Ask for confirmation to overwrite when file with similar name exists at destination
  - Multiples Files/Directories
    - Zip all files and directory contain in the clipboard together
    - Push the Zip file to destination
    - Ask for confirmation to overwrite or update when Zip with similar name exists at destination

### Changed
- 

### Removed
- 

### Fixed
- .

