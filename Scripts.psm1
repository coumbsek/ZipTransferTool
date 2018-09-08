Function Select-Item 
{    
<# 
     .Synopsis
        Allows the user to select simple items, returns a number to indicate the selected item. 

    .Description 

        Produces a list on the screen with a caption followed by a message, the options are then
        displayed one after the other, and the user can one. 
  
        Note that help text is not supported in this version. 

    .Example 

        PS> select-item -Caption "Configuring RemoteDesktop" -Message "Do you want to: " -choice "&Disable Remote Desktop",
           "&Enable Remote Desktop","&Cancel"  -default 1
       Will display the following 
  
        Configuring RemoteDesktop   
        Do you want to:   
        [D] Disable Remote Desktop  [E] Enable Remote Desktop  [C] Cancel  [?] Help (default is "E"): 

    .Parameter Choicelist 

        An array of strings, each one is possible choice. The hot key in each choice must be prefixed with an & sign 

    .Parameter Default 

        The zero based item in the array which will be the default choice if the user hits enter. 

    .Parameter Caption 

        The First line of text displayed 

     .Parameter Message 

        The Second line of text displayed     
#> 

Param(   [String[]]$choiceList, 

         [String]$Caption="Please make a selection", 

         [String]$Message="Choices are presented below", 

         [int]$default=0 

      ) 

   $choicedesc = New-Object System.Collections.ObjectModel.Collection[System.Management.Automation.Host.ChoiceDescription] 

   $choiceList | foreach  { $choicedesc.Add((New-Object "System.Management.Automation.Host.ChoiceDescription" -ArgumentList $_))} 

   $Host.ui.PromptForChoice($caption, $message, $choicedesc, $default) 
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

Function New-TestData1(){
    mkdir "TestData1"
    cd "TestData1"
    mkdir "zipTest"
    cd "zipTest"

    foreach ($i in (1..100)){
        New-TestFile ("test100_{0}.txt" -f $i) 100
    }
    foreach ($i in (1..50)){
        New-TestFile ("test50_{0}.txt" -f $i) 50 k
    }
    foreach ($i in (1..20)){
        New-TestFile ("test20_{0}.txt" -f $i) 20 m
    }
    New-TestFile ("test{0}.txt" -f $i) 1 g

    cd ..
    Compress-Archive zipTest -DestinationPath:"test.zip"

    mkdir "dir1\dir11"
    foreach ($i in (1..20)){
        New-TestFile ("dir1\test1_{0}.txt" -f $i) 20 m
    }
    foreach ($i in (1..20)){
        New-TestFile ("dir1\dir11\test11_{0}.txt" -f $i) 20 m
    }
    mkdir "dir1\dir12"
    foreach ($i in (1..20)){
        New-TestFile ("dir1\dir12\test12_{0}.txt" -f $i) 20 m
    }
    mkdir "dir2\dir21"
    foreach ($i in (1..20)){
        New-TestFile ("dir2\test2_{0}.txt" -f $i) 20 m
    }
    foreach ($i in (1..20)){
        New-TestFile ("dir2\dir21\test21_{0}.txt" -f $i) 20 m
    }
    mkdir "dir2\dir22"
    foreach ($i in (1..20)){
        New-TestFile ("dir2\dir22\test22_{0}.txt" -f $i) 20 m
    }
}

Function New-Test1(){
    
}

Export-ModuleMember -Function 'Select-Item'
Export-ModuleMember -Function 'New-Test1'
Export-ModuleMember -Function 'New-TestData1'