Function Copy-ItemForTransfer($Path, $DestinationPath, [switch]$Force){
    Copy-Item -Path:$Path -Destination:$DestinationPath -Force:$Force
}