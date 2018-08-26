Function Initiliaze-CompressModule(){
    $SevenZipInstallPath = "E:\ProgramFiles\7-Zip\7z.exe"  
    set-alias SevenZip  $SevenZipInstallPath 
    # use remove-item alias:SevenZip  if you want to remove t later
}

Function Compress-ArchiveForTransfer($Path, $DestinationPath, [switch]$Force, [switch]$Update){7
    if ($Update){
        SevenZip u $destinationPath $path
    }
    if ($Force){
        SevenZip a
    }
}

Function Expand-ArchiveForTransfer($Path, $DestinationPath, [switch]$Force, [switch]$Update){
    SevenZip e $destinationPath $path
}