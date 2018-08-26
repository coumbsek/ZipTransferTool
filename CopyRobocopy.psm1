Function Copy-ItemForTransfer($Path, $DestinationPath, [switch]$Force){
    Copy-Item -Path:$Path -Destination:$DestinationPath -Force:$Force
    $folder = Get-Item $Path
    $fullDestinationPath = ("{0}\{1}" -f $DestinationPath,)
    Test-Path
}