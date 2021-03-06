﻿$binSDKPath = "C:\Program Files (x86)\Windows Kits\10\bin\10.0.17134.0\x86"
Set-Alias makecert ("{0}\makecert.exe" -f $binSDKPath)
Set-Alias signtool ("{0}\signtool.exe" -f $binSDKPath)


$XCN_OID_PKIX_KP_CODE_SIGNING = "1.3.6.1.5.5.7.3.3"

Function New-CertificateAuthority($NameOfCA){
    New-SelfSignedCertificate -Type Custom -Subject ("CN={0} Local Authority" -f $NameOfCA) -KeyUsage CertSign -CertStoreLocation "Cert:\CurrentUser\My\" -FriendlyName ("{0} Local Authority" -f $NameOfCA)
}

Function New-CodeSigningCertificate([string]$nameOfCoder, [string]$nameofCA){
    [string]$fullNameOfCA = ("{0} Local Authority" -f $NameOfCA)
    $CAcert= Get-ChildItem Cert:\CurrentUser\My | where { $_.FriendlyName -match $fullNameOfCA}
    if ($CAcert.Count -ne 1){
        Write-Error "Could not find only One Certificate"
        return;
    }
    New-SelfSignedCertificate -Type CodeSigningCert -Subject ("CN={0} Signing Certificate" -f ((Get-Culture).TextInfo.ToTitleCase($nameOfCoder))) -CertStoreLocation "Cert:\CurrentUser\My\" -FriendlyName ("{0}@{1}" -f $nameOfCoder.ToLower(), $nameofCA.ToLower()) -Signer $CAcert
}

Function New-CertificateAuthorityOld($NameOfCA){
    $fullNameOfCA = ("CN={0} Texplained Local Authority" -f $NameOfCA)
    makecert -n $fullNameOfCA -a sha1 -eku $XCN_OID_PKIX_KP_CODE_SIGNING -r -sv LDPowerShell.pvk LDPowerShell.cer -ss Root -sr localMachine
    makecert -pe -n $fullNameOfCA -ss My -a sha1 -eku $XCN_OID_PKIX_KP_CODE_SIGNING -iv LDPowerShell.pvk -ic LDPowerShell.cer
}

Function Set-Certificate($NameOfCA, $path){
    $cert= Get-ChildItem Cert:\CurrentUser\My -CodeSigningCert | where { $_ -match $NameOfCA}
    Set-AuthenticodeSignature $path $cert
}

Function Assert-PowershellAuthenticity(){
    signtool verify /c KB926140.CAT powershell.exe
}

Export-ModuleMember -Function "New-CertificateAuthority"
Export-ModuleMember -Function "New-CodeSigningCertificate"
Export-ModuleMember -Function "Set-Certificate"