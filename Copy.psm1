Import-Module ('{0}\Scripts' -f $modulesPaths)

Function Copy-ItemForTransfer($Path, $DestinationPath, [switch]$Force){
    if (-not (Test-Path $Path)){
        Write-Error ("Path {0} not existing" -f $Path)
        return
    }
    $canContinue = $True
    $folder = Get-Item $Path
    $fullDestinationPath = ("{0}\{1}" -f $DestinationPath,$folder.Name)
    if (Test-Path -PathType Container $fullDestinationPath){
        $eraseAnyWay = -1
        $eraseAnyWay = Select-Item -Caption:"Already Existing Folder" -Message:"Do you want to: " -choice:"&Cancel","&OverWrite"
        if ($eraseAnyWay -eq 0){$canContinue=$False}
    }
    if ($canContinue -eq $True){
        Copy-Item -Path:$Path -Destination:$DestinationPath -Force:$Force -Recurse
    }
}

Function Copy-OneItemWithProgress {
    param( [string]$from, [string]$to)
    $ffile = [io.file]::OpenRead($from)
    $tofile = [io.file]::OpenWrite($to)
    Write-Progress -Activity "Copying file" -status "$from -> $to" -PercentComplete 0
    try {
        [byte[]]$buff = new-object byte[] 4096
        [int]$total = [int]$count = 0
        do {
            $count = $ffile.Read($buff, 0, $buff.Length)
            $tofile.Write($buff, 0, $count)
            $total += $count
            if ($total % 1mb -eq 0) {
                Write-Progress -Activity "Copying file" -status "$from -> $to" `
                   -PercentComplete ([int]($total/$ffile.Length* 100))
            }
        } while ($count -gt 0)
    }
    finally {
        $ffile.Dispose()
        $tofile.Dispose()
        Write-Progress -Activity "Copying file" -Status "Ready" -Completed
    }
}

Export-ModuleMember -Function "Copy-ItemForTransfer"