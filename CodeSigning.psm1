$binSDKPath = "C:\Program Files (x86)\Windows Kits\10\bin\10.0.17134.0\x86"
Set-Alias makecert ("{0}\makecert.exe" -f $binSDKPath)
Set-Alias signtool ("{0}\signtool.exe" -f $binSDKPath)


$XCN_OID_PKIX_KP_CODE_SIGNING = "1.3.6.1.5.5.7.3.3"

Function New-CertificateAuthority($NameOfCA){
    $fullNameOfCA = ("CN={0} Local Authority" -f $NameOfCA)
    makecert -n $fullNameOfCA -a sha1 -eku $XCN_OID_PKIX_KP_CODE_SIGNING -r -sv LDPowerShell.pvk LDPowerShell.cer -ss Root -sr localMachine
    makecert -pe -n $fullNameOfCA -ss My -a sha1 -eku $XCN_OID_PKIX_KP_CODE_SIGNING -iv LDPowerShell.pvk -ic LDPowerShell.cer
}

Function Set-Certificate($NameOfCA, $path){
    $cert= Get-ChildItem Cert:\CurrentUser\My | where { $_ -match $NameOfCA}
    Set-AuthenticodeSignature $path $cert
}

Function Assert-PowershellAuthenticity(){
    signtool verify /c KB926140.CAT powershell.exe
}