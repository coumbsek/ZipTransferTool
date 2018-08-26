$SevenZipInstallPath = "E:\ProgramFiles\7-Zip\7z.exe"  
set-alias SevenZip  $SevenZipInstallPath 
# use remove-item alias:SevenZip  if you want to remove t later

Function Initiliaze-CompressModule(){
}

Function Compress-ArchiveForTransfer($Path, $DestinationPath, [switch]$Force, [switch]$Update){
    if ($Update){
        SevenZip u -m0=Copy $destinationPath $path
    }
    elseif ($Force){
        SevenZip a -m0=Copy $DestinationPath $Path
    }
    else{
        SevenZip a -m0=Copy $DestinationPath $Path
    }
}

Function Expand-ArchiveForTransfer($Path, $DestinationPath, [switch]$Force, [switch]$Update){
    SevenZip e $destinationPath $path
}

Function Get-FilesInZip($LitteralPath){
    SevenZip l -r $LitteralPath
}