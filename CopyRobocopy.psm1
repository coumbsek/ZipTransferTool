Import-Module ('{0}\Scripts' -f $modulesPaths)

Function Copy-ItemForTransfer($Path, $DestinationPath, [switch]$Force){
    if (-not (Test-Path $Path)){
        Write-Error ("Path {0} not existing" -f $Path)
        return
    }
    $folder = Get-Item $Path
    $fullDestinationPath = ("{0}\{1}" -f $DestinationPath,$folder.Name)
    $canContinue = $True
    
    if (Test-Path -PathType Container $fullDestinationPath){
        $eraseAnyWay = Select-Item -Caption:"Already Existing Folder" -Message:"Do you want to: " -choice:"&Cancel","&OverWrite"
        if ($eraseAnyWay -eq 0){$canContinue=$False}
    }
    if ($canContinue -eq $True){
        mkdir $fullDestinationPath
        Robocopy $Path $fullDestinationPath /e
    }
}

Export-ModuleMember -Function "Copy-ItemForTransfer"