Import-Module ('{0}\ZipTransferTool\AddItemToContext' -f $modulesPaths)
Import-Module ('{0}\ZipTransferTool\Scripts' -f $modulesPaths)
Import-Module ('{0}\ZipTransferTool\Compress' -f $modulesPaths)
Import-Module ('{0}\ZipTransferTool\Copy' -f $modulesPaths)

Function Initialize-TransferMenu(){
    $savedtWorkingDirectory = Get-Location
    Remove-OSCContextItem -Directory -DisplayName:"Paste To Server" -force
    Remove-OSCContextItem -Directory -DisplayName:"Paste From Server" -force
    Remove-OSCContextItem -Directory -DisplayName:"Paste <-> Server" -force
    Add-OSCContextItem -Directory -DisplayName:"Paste To Server" -Argument:"Powershell Paste-ToServer %v"
    Add-OSCContextItem -Directory -DisplayName:"Paste From Server" -Argument:"Powershell Paste-FromServer %v"
    Add-OSCContextItem -Directory -DisplayName:"Paste <-> Server" -Argument:"Powershell -noexit Paste-Server %v"
    Initialize-CompressModule
    cd $savedtWorkingDirectory
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
            Copy-ItemForTransfer -Path:$toCompressAndTransfer -Destination:$path -Force
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

Function Paste-FromServer($path, $multiFilesEnabled = $false){
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
        $destinationFullPath = ("{0}\{1}.zip" -f $path,$commingFromDirectory)
        
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
        $zips | foreach { Copy-ItemForTransfer -Path:$_ -Destination:$path}
        if ($multiFilesEnabled -eq $True){
            Write-Host $destinationFullPath
            Compress-ArchiveForTransfer -Path:$toZips -Destination:$destinationFullPath
            Expand-ArchiveForTransfer -Path:$destinationFullPath -Destination:$path
            Remove-Item $destinationFullPath
        }else{
            Copy-ItemForTransfer -Path:$toZips -Destination:$path
        }
    }
}

Function Paste-SingleFolderFromServer($path,$toTransfer){
    $fileName = [System.IO.Path]::GetFileName($toTransfer)
    $destinationFullPath = ("{0}\{1}.zip" -f $path,$fileName)

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
        Copy-ItemForTransfer -Path:$toTransfer -Destination:$path -Force:$force
    }
}

Function Paste-Server($path){
    $isNetworkPath = Get-PathIdentity $path
    $clipBoardContent = Get-Clipboard -Format FileDropList
    $clipBoardPathSample = @($clipBoardContent)[0].DirectoryName
    $isClipoardPathSampleNetworkPath = Get-PathIdentity -Path:$clipBoardPathSample
    if ($isNetworkPath -eq $isClipoardPathSampleNetworkPath){
        Copy-ItemForTransfer -Path:$clipBoardContent -Destination:$path
    }
    elseif ($isNetworkPath -ge 1){
        Paste-ToServer $path
    }
    elseif ($isNetworkPath -eq 0){
        Paste-FromServer $path
    }
    else{
        Write-Error "Unsupported drive type"
    }
}

Function Get-PathIdentity($Path){
    cd $Path
    $driveName = (Get-Location).Drive.Name
    if ($driveName -eq $null){
        Write-Host "I'm a Network not mapped path : " $Path
        return 2
    }
    $drive = Get-PSDrive -Name $driveName
    if ($drive.DisplayRoot -ne $null){
        Write-Host "I'm a mapped Drive to : " $drive.DisplayRoot
        return 1
    }
    if ($drive.Root -ne $null){
        Write-Host "I'm a Drive to : " $drive.Root
        return 0
    }
}

Function New-TestFile($Path,$size, [ValidateSet("k","M","G")]$unit){
    Set-Alias fsutil "C:\Windows\System32\fsutil.exe"
    if ($unit -eq "k"){
        $size = 1024*$size
    }elseif($unit -eq "M"){
        $size = 1024*1024*$size
    }elseif($unit -eq "G"){
        $size = 1024*1024*1024*$size
    }
    fsutil file createnew $Path $size
}

Export-ModuleMember -Function "*"
Export-ModuleMember -Function "Paste-ToServer"
Export-ModuleMember -Function "Paste-FromServer"