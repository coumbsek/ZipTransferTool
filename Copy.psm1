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

Export-ModuleMember -Function "Copy-ItemForTransfer"