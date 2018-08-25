Import-Module ('{0}\AddItemToContext\AddItemToContext' -f $modulesPaths)
Import-Module ('{0}\Scripts' -f $modulesPaths)
Import-Module ('{0}\ZipTransferTool\Compress' -f $modulesPaths)

Function Ini-TransferMenu(){
    #Remove-OSCContextItem -Directory -DisplayName:"Copy To Server" -force
    #Remove-OSCContextItem -Folder    -DisplayName:"Copy To Server" -force
    Remove-OSCContextItem -Directory -DisplayName:"Paste To Server" -force
    Remove-OSCContextItem -Directory -DisplayName:"Paste From Server" -force
    #Add-OSCContextItem -Directory -DisplayName:"Copy To Server" -Argument:"Powershell -windowstyle hidden  Copy-ToServer %L"#"Powershell -noexit Set-Variable -Name `"copyPath`" %L"
    #Add-OSCContextItem -Folder    -DisplayName:"Copy To Server" -Argument:"Powershell -windowstyle hidden  Copy-ToServer %L"#"Powershell -noexit Set-Variable -Name `"copyPath`" %L"
    Add-OSCContextItem -Directory -DisplayName:"Paste To Server" -Argument:"Powershell -noexit Paste-ToServer %v"
    Add-OSCContextItem -Directory -DisplayName:"Paste From Server" -Argument:"Powershell -noexit Paste-FromServer %v"
}

Function Copy-ToServer($path){
    Write-Host "Path : " $path
    $global:copyPath = $path
    $path | foreach {$_ > $copyPathFile}
}

Function Paste-ToServer($path){
    $eraseAnyWay = $False
    $update = $False
    $toCompressAndTransfer = Get-Clipboard  -Format FileDropList
    if($toCompressAndTransfer.Count -eq 0){
        return;
    }
    elseif ($toCompressAndTransfer.Count -eq 1){
        $fileName = [System.IO.Path]::GetFileName($toCompressAndTransfer)
        if (Test-Path $toCompressAndTransfer -PathType Leaf){
            if (Test-Path ("{0}\{1}" -f $path,$fileName)){
                $eraseAnyWay = Select-Item -Caption:"Already Existing File" -Message:"Do you want to: " -choice:"&Cancel","&OverWrite"
                if ($eraseAnyWay -eq 0){
                    return;
                }
            }
            Copy-Item -Path:$toCompressAndTransfer -Destination:$path -Force
        }
        else{
            $destinationFullPath = ("{0}\{1}.zip" -f $path,$fileName)
        }
    }else{
        $commingFromDirectory = Split-Path -Parent $toCompressAndTransfer[0];
        $commingFromDirectory = [System.IO.Path]::GetFileName($commingFromDirectory)
        $destinationFullPath = ("{0}\{1}.zip" -f $path,$commingFromDirectory)
    }
    if (Test-Path $destinationFullPath){
        $eraseAnyWay = Select-Item -Caption:"Already Existing Archive" -Message:"Do you want to: " -choice:"&Cancel","&OverWrite","&Update"
        if ($eraseAnyWay -eq 0){
            return;
        }elseif($eraseAnyWay -eq 1){
            #Compress-Archive -Path:$toCompressAndTransfer -DestinationPath:$destinationFullPath -CompressionLevel:NoCompression -Force
            Compress-ArchiveForTransfer -Path:$toCompressAndTransfer -DestinationPath:$destinationFullPath -Force
            return;
        }elseif($eraseAnyWay -eq 2){
            #Compress-Archive -Path:$toCompressAndTransfer -DestinationPath:$destinationFullPath -CompressionLevel:NoCompression -Update
            Compress-ArchiveForTransfer -Path:$toCompressAndTransfer -DestinationPath:$destinationFullPath -Update
            return;
        }
    }
    #Compress-Archive -Path:$toCompressAndTransfer -DestinationPath:$destinationFullPath -CompressionLevel:NoCompression
    Compress-ArchiveForTransfer -Path:$toCompressAndTransfer -DestinationPath:$destinationFullPath
}

Function Paste-FromServer($path){
    $eraseAnyWay = $False
    $update = $False
    $toTransfer = Get-Clipboard  -Format FileDropList
    if($toTransfer.Count -eq 0){
        Write-Host "No copied file, exit"
        return;
    }
    #If single selection
    elseif ($toTransfer.Count -eq 1){
        if (Test-Path $toTransfer -PathType Leaf){
            Paste-SingleFileFromServer -path:$path -toTransfer:$toTransfer -force
        }
        else{
            Paste-SingleFolderFromServer -path:$path -toTransfer:$toTransfer
        }
    }
    #If multiple selected files
    else{
        $commingFromDirectory = Split-Path -Parent $toTransfer[0];
        $commingFromDirectory = [System.IO.Path]::GetFileName($commingFromDirectory)
        $destinationFullPath = ("{0}{1}.zip" -f $path,$commingFromDirectory)
        
        $zips = New-Object System.Collections.ArrayList
        $folders = New-Object System.Collections.ArrayList
        $files = New-Object System.Collections.ArrayList
        $toZips = New-Object System.Collections.ArrayList
        $toTransfer | foreach {
            $fName = [System.IO.Path]::GetFileName($_)
            if (Test-Path $_ -PathType Leaf){
                if ($fName -match ".zip"){
                    $zips.Add($_) | Out-Null
                }else{
                    $files.Add($_) | Out-Null
                    $toZips.Add($_) | Out-Null
                }
            }else{
                $folders.Add($_) | Out-Null
                $toZips.Add($_) | Out-Null
            }
        }
        $zips | foreach { Copy-Item -Path:$_ -Destination:$path}
        Write-Host $destinationFullPath
        Compress-ArchiveForTransfer -Path:$toZips -Destination:$destinationFullPath
        Expand-ArchiveForTransfer -Path:$destinationFullPath -Destination:$path
    }
    <#
    if (Test-Path $destinationFullPath){
        $eraseAnyWay = Select-Item -Caption:"Already Existing Archive" -Message:"Do you want to: " -choice:"&Cancel","&OverWrite","&Update"
        if ($eraseAnyWay -eq 0){
            return;
        }elseif($eraseAnyWay -eq 1){
            Compress-Archive -Path:$toTransfer -DestinationPath:$destinationFullPath -CompressionLevel:NoCompression -Force
            return;
        }elseif($eraseAnyWay -eq 2){
            Compress-Archive -Path:$toTransfer -DestinationPath:$destinationFullPath -CompressionLevel:NoCompression -Update
            return;
        }
    }
    Compress-Archive -Path:$toTransfer -DestinationPath:$destinationFullPath -CompressionLevel:NoCompression
    #>
}

Function Paste-SingleFolderFromServer($path,$toTransfer){
    $fileName = [System.IO.Path]::GetFileName($toTransfer)
    $destinationFullPath = ("{0}{1}.zip" -f $path,$fileName)

    $files = Get-ChildItem $toTransfer | foreach { ("{0}\{1}" -f $toTransfer,$_)}
    Write-Host $files
    #Compress-Archive -Path:$files -DestinationPath:$destinationFullPath -CompressionLevel:NoCompression
    Compress-ArchiveForTransfer -Path:$files -DestinationPath:$destinationFullPath
    Write-Host $path
    Write-Host $destinationFullPath
    Paste-SingleFileFromServer -path:$path -toTransfer:$destinationFullPath -InFolder
}

Function Paste-SingleFileFromServer($path, $toTransfer, [switch]$force, [switch]$InFolder){
    Write-Host $path
    Write-Host $toTransfer

    $fileName = [System.IO.Path]::GetFileName($toTransfer)
    $fileNameWithoutExtension = [System.IO.Path]::GetFileNameWithoutExtension($toTransfer)
    $finalDestinationFolder = ("{0}\{1}" -f $path,$fileNameWithoutExtension)
    #Check for same named folder in destination
    if (Test-Path finalDestinationFolder){
        $eraseAnyWay = Select-Item -Caption:"Already Existing File or Folder" -Message:"Do you want to: " -choice:"&Cancel","&OverWrite all existing files"
        if ($eraseAnyWay -eq 0){
            return;
        }
    }
    #Copy or expand if zip
    if ($fileName -match ".zip"){
        if ($fileNameWithoutExtension.Length -ne 0){
            #mkdir $fileNameWithoutExtension -Force
            #Expand-Archive -Path:$toTransfer -Destination:("{0}\{1}" -f $path,$fileNameWithoutExtension) -Force:$force
            if ($InFolder){
                Expand-ArchiveForTransfer -Path:$toTransfer -Destination:$finalDestinationFolder -Force:$force
            }else{
                Expand-ArchiveForTransfer -Path:$toTransfer -Destination:("{0}" -f $path) -Force:$force
            }
        }
    }else{
        Copy-Item -Path:$toTransfer -Destination:$path -Force:$force
    }
}

Export-ModuleMember -Function "*"
Export-ModuleMember -Function "Paste-ToServer"
Export-ModuleMember -Function "Paste-FromServer"