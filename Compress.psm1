﻿Function Initialize-CompressModule(){
}

Function Compress-ArchiveForTransfer($Path, $DestinationPath, [switch]$Force, [switch]$Update){
    if ($Force){
        Compress-Archive -Path:$Path -DestinationPath:$DestinationPath -CompressionLevel:NoCompression -Force:$Force
    }elseif($Update){
        Compress-Archive -Path:$Path -DestinationPath:$DestinationPath -CompressionLevel:NoCompression -Update:$Update
    }else{
        Compress-Archive -Path:$Path -DestinationPath:$DestinationPath -CompressionLevel:NoCompression
    }
}

Function Expand-ArchiveForTransfer($Path, $DestinationPath, [switch]$Force){
    if ($Force){
        Expand-Archive -Path:$Path -DestinationPath:$DestinationPath -Force:$Force
    }else{
        Expand-Archive -Path:$Path -DestinationPath:$DestinationPath
    }
}

Function Get-FilesInZip($LitteralPath){
    Add-Type -assembly "system.io.compression.filesystem"
    [io.compression.zipfile]::OpenRead($LitteralPath).Entries.Name
}