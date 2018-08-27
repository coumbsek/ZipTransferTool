#This function is to add an item to context menu
Function Add-OSCContextItem
{
<#
 	.SYNOPSIS
        Add-OSCContextItem is an advanced function which can be used to add a program or command to context menu.
    .DESCRIPTION
        Add-OSCContextItem is an advanced function which can be used to add a program or command to context menu.
    .PARAMETER DisplayName
		Give the item a display name.
	.PARAMETER Argument
		Specifies program or command.
    .EXAMPLE
        C:\PS> Add-OSCContextItem -DisplayName "NotePad" -Argument "C:\windows\system32\notepad.exe"
		
		This command shows how to add program “Notepad.exe” with display name “NotePad” to context menu.
	.EXAMPLE
        C:\PS> Add-OSCContextItem -DisplayName "Restart" -Argument "cmd.exe /c shutdown /r /t 0"
		
		This command shows how to add a command “cmd.exe /c shutdown /r /t 0” with display name “Restart“ to context menu.
#>
	[CmdletBinding()]
	Param
	(	
		[Parameter(Mandatory=$true,Position=0)]
		[String]$DisplayName,
		[Parameter(Mandatory=$true,Position=1)]
		[String]$Argument,
        [switch]$Directory,
        [switch]$Folder,
        [switch]$All
	)

	New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null #Create PSDrive
    
    if ($Folder){
        $RegistryPathRoot = "HKCR:\Folder\shell"
    }elseif ($Directory){
        $RegistryPathRoot = "HKCR:\Directory\Background\shell"
    }elseif ($All){
        $RegistryPathRoot = "HKCR:\*\shell"
    }

	$RegistryPath = ("{0}\$DisplayName" -f $RegistryPathRoot)

	If(Test-Path -LiteralPath $RegistryPath)
	{
		Write-Warning "A same key exists,please use another one."

	}
	Else
	{
		#Modify the registry to add an item to context menu
        Set-Location -LiteralPath $RegistryPathRoot | Out-Null
		New-Item -Name $DisplayName| Out-Null
		New-Item -Name ("{0}\Command" -f $DisplayName)| Out-Null
		Set-ItemProperty -LiteralPath $RegistryPath -Name "(Default)" -Value $DisplayName| Out-Null
		Set-ItemProperty -LiteralPath  $RegistryPath"\Command" -Name "(Default)"  -Value $Argument| Out-Null
		If(Test-Path -LiteralPath $RegistryPath)
		{
			Write-Host "Add '$DisplayName' to Context successfully."
		}
		Else
		{
			Write-Warning "Failed to add '$DisplayName' to Context successfully "
		}
	}
	

}

#This function is to delete an item from context menu
Function Remove-OSCContextItem
{
<#
 	.SYNOPSIS
        Remove-OSCContextItem is an advanced function which can be used to remove a item from context menu.
    .DESCRIPTION
        Remove-OSCContextItem is an advanced function which can be used to remove a item from context menu.
    .PARAMETER DisplayName
		Specifies item in context menu.
    .EXAMPLE
        C:\PS> Remove-OSCContextItem -DisplayName "NotePad" 
		
		This command shows how to delete “NotePad“ from context menu.
#>	
	[CmdletBinding()]
	Param
	(	
		[Parameter(Mandatory=$true,Position=0)]
		[String]$DisplayName,
        [switch]$Directory,
        [switch]$Folder,
        [switch]$All,
        [switch]$force
	)
	New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null
    
    if ($Folder){
        $RegistryPathRoot = "HKCR:\Folder\shell"
    }elseif ($Directory){
        $RegistryPathRoot = "HKCR:\Directory\Background\shell"
    }elseif ($All){
        $RegistryPathRoot = "HKCR:\*\shell"
    }

	$RegistryPath = ("{0}\$DisplayName" -f $RegistryPathRoot)

	If(Test-Path -LiteralPath $RegistryPath)
	{	
		#Modify the registry to delete an item from context menu
		Remove-Item -LiteralPath $RegistryPath -Force:$force -Recurse:$force
		If(Test-Path -LiteralPath $RegistryPath)
		{
			Write-Warning "Failed to delete '$DisplayName' From Context."
		}
		Else
		{
			Write-Host "Delete '$DisplayName' from Context successfully."
		}	
	}
	Else 
	{
		Write-Warning "Can not find the item: $DisplayName."	
	}
}
