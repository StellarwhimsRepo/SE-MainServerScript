

    #requires -version 3 -RunAsAdministrator

    #disable recovery task
    ($TaskScheduler = New-Object -ComObject Schedule.Service).Connect("localhost")
    #$MyTask = $TaskScheduler.GetFolder('\').GetTask("SEAutomatic Recovery")
    #$MyTask.Enabled = $false
    $MyTask2 = $TaskScheduler.GetFolder('\').GetTask("SEBackup")
    $MyTask2.Enabled = $false


    Write-Host -ForegroundColor Green "Starting Daily Maintenance."
    sleep -Seconds 2
    
    #stop the space engineer services
    Write-Host -ForegroundColor Green "Stopping Space Engineers Services."
        
    Stop-Service 'Dedicated Imports' -EA SilentlyContinue
    Stop-Service 'VPS Dedicated 1' -EA SilentlyContinue
    Stop-Service 'admin creative' -EA SilentlyContinue
    Stop-Process -processname 'SEServerExtender' -EA SilentlyContinue
    sleep -Seconds 10

    #make sure any abandoned process id's are ended
    Stop-Process -processname 'Space Engineers Dedicated' -EA SilentlyContinue
    Stop-Process -processname 'SEServerExtender' -EA SilentlyContinue
    Stop-Process -processname 'Windows Command Processor' -EA SilentlyContinue
    sleep 3 

    Write-Host -ForegroundColor Green "Checking Player and object names ... "
    #player name clean script
    C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File " replace this text with path to \cleannames.ps1"
    sleep -Seconds 2

    #runwebsitebackup
    Write-Host -ForegroundColor Green "Backing up website please wait ... "
    C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File " replace this text with path to\SeServerwebsiteBackup.ps1"
    sleep -Seconds 2

    #runbackup
    Write-Host -ForegroundColor Green "Backing up SE server please wait ... "
    C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File " replace this text with path to\SeServerGameDataBackup.ps1"
    sleep -Seconds 2

    #game world audits
    #C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File " replace this text with path to\Audit.ps1"

    #rules enforcement

    #Player Maintenance script and spyders script

    Write-Host -ForegroundColor Green "Asteroid Refresh and Offlining objects ..."

    C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File "replace this text with path to\WorldEditorauto2.ps1"
    sleep -Seconds 2
   
   #C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File "replace this text with path to\WorldEditorauto.ps1"
   #C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File "replace this text with path to\playermaintenance.ps1"

    
   $day = Get-Date

   IF($day.DayOfWeek -eq "Thursday" -or $day.DayOfWeek -eq "Sunday" -or $day.DayOfWeek -eq "Tuesday"){
       IF($day.hour -eq "4" -or $day.hour -eq "5"){
             Write-Host -ForegroundColor Green "Cleaning Players and Factions ... "
             C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File "replace this text with path to\playermaintenance.ps1"
             #C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File "replace this text with path to\WorldEditorauto.ps1"
       }
   }
   
    sleep -Seconds 2
    
    Write-Host -ForegroundColor Green "Checking Grid Compliance ... "
    #Ship Maintenance script
    C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File "replace this text with path to\shipclassdetection.ps1"
    sleep -Seconds 2
    
   <# Write-Host -ForegroundColor Green "Checking Station Compliance ... "
    #station Maintenance script
    C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File "replace this text with path to\stationpolicy.ps1"
    sleep -Seconds 2
    
    Write-Host -ForegroundColor Green "Running Fleet Assignment and report ... "
    #fleet report
    C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File "replace this text with path to\Fleetcheck.ps1"
    sleep -Seconds 2
    #>
       
    $filePath = 'replace this text with path to\SANDBOX_0_0_0_.sbs'
    #$filePath = 'replace this text with path to\SANDBOX_0_0_0_.sbs'

    #load saves for xml manipulation
    Write-Host -ForegroundColor Green "loading saves please wait ... "
    [xml]$myXML = Get-Content $filePath -Encoding UTF8
    $ns = New-Object System.Xml.XmlNamespaceManager($myXML.NameTable)
    $ns.AddNamespace("xsi", "http://www.w3.org/2001/XMLSchema-instance")

    #Shutdown all thrusters
    Write-Host -ForegroundColor Green "Thrusters Shutdown!!"
    $nodes = $myXML.SelectNodes("//SectorObjects/MyObjectBuilder_EntityBase/CubeBlocks/MyObjectBuilder_CubeBlock[(@xsi:type='MyObjectBuilder_Thrust')]/Enabled"  , $ns) 
    
    ForEach($node in $nodes){
        $node.InnerText = "false"
    }

    #kill thruster override
    Write-Host -ForegroundColor Green "Thruster Override Disabled!!"
    $node4s = $myXML.SelectNodes("//SectorObjects/MyObjectBuilder_EntityBase/CubeBlocks/MyObjectBuilder_CubeBlock[(@xsi:type='MyObjectBuilder_Thrust')]/ThrustOverride"  , $ns) 

    ForEach($node in $node4s){
        $node.Parentnode.RemoveChild($node)
        }


    #set velocities to zero.
    Write-Host -ForegroundColor Green "Object Velocities set to zero!!"
    $node3s = $myXML.SelectNodes("//SectorObjects/MyObjectBuilder_EntityBase/LinearVelocity|//SectorObjects/MyObjectBuilder_EntityBase/AngularVelocity" ,$ns)
    ForEach($node in $node3s){
        $node.X = "0"
        $node.Y = "0"
        $node.Z = "0"
    }

    #all projector reset
    Write-Host -ForegroundColor Green "Projectors Resetting ... "
    $allprojections = $myXML.SelectNodes("//SectorObjects/MyObjectBuilder_EntityBase[(@xsi:type='MyObjectBuilder_CubeGrid')]/CubeBlocks/MyObjectBuilder_CubeBlock[(@xsi:type='MyObjectBuilder_Projector')]/ProjectedGrid", $ns)
    ForEach($projection in $allprojections){
    $projection.ParentNode.RemoveChild($projection)
    }
    Write-Host -ForegroundColor Green "All Projectors Reset!! "

    #shutdown assembler co operative mode
    #Write-Host -ForegroundColor Green "Assembler Co-op functions disabled!!"
    #$node42s = $myXML.SelectNodes("//MyObjectBuilder_CubeBlock[@xsi:type='MyObjectBuilder_Assembler']/RepeatAssembleEnabled | //MyObjectBuilder_CubeBlock[@xsi:type='MyObjectBuilder_Assembler']/RepeatDisassembleEnabled | //MyObjectBuilder_CubeBlock[@xsi:type='MyObjectBuilder_Assembler']/SlaveEnabled",$ns)
    #ForEach($node in $node42s){
    #    $node.InnerText = 'false'
    #}

    #Import X,Y,Z beacons to public save.
    #Write-Host -ForegroundColor Green "Importing Coordinate Beacons"
    #sleep -Seconds 2
    
   #$source = Get-Content 'F:\SE Dedicated Server Files\Station_XYZ.sbc' -raw
   #$sbs = Get-Content 'F:\DedicatedServer\DataDir\VPS Dedicated 1\Saves\Sagittaron Sector\SANDBOX_0_0_0_.sbs' -raw
   #$sbs = $sbs -replace "</SectorObjects>",$source
   #$sbs | Out-File 'F:\DedicatedServer\DataDir\VPS Dedicated 1\Saves\Sagittaron Sector\SANDBOX_0_0_0_.sbs' -Encoding ascii

   #automated restore?

   #delete import server save?

   $CurrentDateTime = Get-Date -Format "MM-dd-yyyy_HH-mm"
   $deletedfilename = "Owned_Audit_" +$CurrentDateTime+ ".log"
   $deletedlogs = "W:\Google Drive\Admin Logs\Audits\deleted\"
   $deletedpath = $deletedLogs + $deletedfilename

   New-Item -path $deletedpath -type file
   
   Write-Host -ForegroundColor Green "No-Beacon Check ... "
   Add-Content -path $deletedpath -Value "No-Beacon Check ... "
   Add-Content -path $deletedpath -Value "[  ]"

    #delete grid if no beacon or no beacon owner set, then if no wheels, rotor, piston pieces. ignore NAV beacons

    $nodes = $myXML.SelectNodes("//SectorObjects/MyObjectBuilder_EntityBase[(@xsi:type='MyObjectBuilder_CubeGrid')]"  , $ns) 
    ForEach($node in $nodes){
        $randombeacon = $node.SelectNodes("CubeBlocks/MyObjectBuilder_CubeBlock[(@xsi:type='MyObjectBuilder_Beacon')]/Owner" , $ns)
        $beaconcount = $node.SelectNodes("CubeBlocks/MyObjectBuilder_CubeBlock[@xsi:type='MyObjectBuilder_Beacon']", $ns).count
        $ignorebeacon = $node.SelectNodes("CubeBlocks/MyObjectBuilder_CubeBlock[(@xsi:type='MyObjectBuilder_Beacon')]/SubtypeName" , $ns)
        $ignorebeacon = $ignorebeacon | Get-Random
            IF($beaconcount -eq 0){
                IF($($ignorebeacon.InnerText) -ne "AstramiaBeacon"){
                $ignoretotal = 0
                $rotorcount = $node.SelectNodes("CubeBlocks/MyObjectBuilder_CubeBlock[@xsi:type='MyObjectBuilder_MotorRotor']", $ns)
                $pistoncount = $node.SelectNodes("CubeBlocks/MyObjectBuilder_CubeBlock[@xsi:type='MyObjectBuilder_PistonTop']", $ns)
                $wheelcount = $node.SelectNodes("CubeBlocks/MyObjectBuilder_CubeBlock[@xsi:type='MyObjectBuilder_Wheel']", $ns)
                $advrotorcount = $node.SelectNodes("CubeBlocks/MyObjectBuilder_CubeBlock[@xsi:type='MyObjectBuilder_MotorAdvancedRotor']", $ns)
                $ignoretotal = $ignoretotal + $rotorcount.count + $pistoncount.count + $wheelcount.count + $advrotorcount.count
                IF($ignoretotal -eq 0){
                    Write-Host -ForegroundColor Green "[$($node.DisplayName)] Deleted for no beacons"
                    Add-Content -path $deletedpath -Value "[$($node.DisplayName)] Deleted for no beacons"
                    Add-Content -path $deletedpath -Value "[  ]"
                    $node.ParentNode.RemoveChild($node)
                }
                #verify ignores (delete orphaned rotors piston wheels)
                IF($ignoretotal -ne 0){
                    $allgrids = $myXML.SelectNodes("//SectorObjects/MyObjectBuilder_EntityBase[(@xsi:type='MyObjectBuilder_CubeGrid')]" ,$ns)
                    ForEach($rotor in $rotorcount){
                        $flag = 0
                        $selectallstators = $allgrids.SelectNodes("CubeBlocks/MyObjectBuilder_CubeBlock[@xsi:type='MyObjectBuilder_MotorStator']", $ns)
                        ForEach($stator in $selectallstators){
                        IF($rotor.EntityId -eq $stator.RotorEntityId){
                            $flag = $flag + 1
                        }
                        }
                        IF($flag -eq 0){
                        $rotor.ParentNode.RemoveChild($rotor)
                        }
                    }
                    ForEach($piston in $pistoncount){
                        $flag = 0
                        $selectallpistonbase = $allgrids.SelectNodes("CubeBlocks/MyObjectBuilder_CubeBlock[@xsi:type='MyObjectBuilder_ExtendedPistonBase']", $ns)
                        ForEach($base in $selectallpistonbase){
                        IF($piston.EntityId -eq $base.TopBlockId){
                            $flag = $flag +1
                        }
                        }
                        IF($flag -eq 0){
                        $piston.ParentNode.RemoveChild($piston)
                        }
                    }
                    ForEach($wheel in $wheelcount){
                        $isolationcheck = $node.SelectNodes("CubeBlocks/MyObjectBuilder_CubeBlock[@xsi:type!='MyObjectBuilder_Wheel']", $ns).count
                        $flag = 0
                        IF($isolationcheck -lt 2){
                            $selectallwheelbase = $allgrids.SelectNodes("CubeBlocks/MyObjectBuilder_CubeBlock[@xsi:type='MyObjectBuilder_MyObjectBuilder_MotorSuspension']", $ns)
                            ForEach($suspension in $selectallwheelbase){
                            IF($wheel.EntityId -eq $suspension.RotorEntityId){
                                $flag = $flag +1
                            }
                            }
                            IF($flag -eq 0){
                            $wheel.ParentNode.RemoveChild($wheel)
                            }
                        }
                    }
                    ForEach($advrotor in $advrotorcount){
                        $isolationcheck = $node.SelectNodes("CubeBlocks/MyObjectBuilder_CubeBlock[@xsi:type!='MyObjectBuilder_MotorAdvancedRotor']", $ns).count
                        $flag = 0
                        IF($isolationcheck -lt 2){
                            $advrotor.ParentNode.RemoveChild($advrotor)
                        }
                    }
                }
            }
            }
            ElseIf(($randombeacon|Get-Random) -eq $null){
                IF($($ignorebeacon.InnerText) -ne "AstramiaBeacon"){
                $ignoretotal = 0
                $rotorcount = $node.SelectNodes("CubeBlocks/MyObjectBuilder_CubeBlock[@xsi:type='MyObjectBuilder_MotorRotor']", $ns)
                $pistoncount = $node.SelectNodes("CubeBlocks/MyObjectBuilder_CubeBlock[@xsi:type='MyObjectBuilder_PistonTop']", $ns)
                $wheelcount = $node.SelectNodes("CubeBlocks/MyObjectBuilder_CubeBlock[@xsi:type='MyObjectBuilder_Wheel']", $ns)
                $advrotorcount = $node.SelectNodes("CubeBlocks/MyObjectBuilder_CubeBlock[@xsi:type='MyObjectBuilder_MotorAdvancedRotor']", $ns)
                $ignoretotal = $ignoretotal + $rotorcount.count + $pistoncount.count + $wheelcount.count + $advrotorcount.count
                IF($ignoretotal -eq 0){
                    Write-Host -ForegroundColor Green "[$($node.DisplayName)] Deleted for no beacon owner"
                    Add-Content -path $deletedpath -Value "[$($node.DisplayName)] Deleted for no beacon owner"
                    Add-Content -path $deletedpath -Value "[  ]"
                    $node.ParentNode.RemoveChild($node)
                }
                #verify ignores (delete orphaned rotors piston wheels)
                IF($ignoretotal -ne 0){
                    $allgrids = $myXML.SelectNodes("//SectorObjects/MyObjectBuilder_EntityBase[(@xsi:type='MyObjectBuilder_CubeGrid')]" ,$ns)
                    ForEach($rotor in $rotorcount){
                        $flag = 0
                        $selectallstators = $allgrids.SelectNodes("CubeBlocks/MyObjectBuilder_CubeBlock[@xsi:type='MyObjectBuilder_MotorStator']", $ns)
                        ForEach($stator in $selectallstators){
                        IF($rotor.EntityId -eq $stator.RotorEntityId){
                            $flag = $flag + 1
                        }
                        }
                        IF($flag -eq 0){
                        $rotor.ParentNode.RemoveChild($rotor)
                        }
                    }
                    ForEach($piston in $pistoncount){
                        $flag = 0
                        $selectallpistonbase = $allgrids.SelectNodes("CubeBlocks/MyObjectBuilder_CubeBlock[@xsi:type='MyObjectBuilder_ExtendedPistonBase']", $ns)
                        ForEach($base in $selectallpistonbase){
                        IF($piston.EntityId -eq $base.TopBlockId){
                            $flag = $flag +1
                        }
                        }
                        IF($flag -eq 0){
                        $piston.ParentNode.RemoveChild($piston)
                        }
                    }
                    ForEach($wheel in $wheelcount){
                        $isolationcheck = $node.SelectNodes("CubeBlocks/MyObjectBuilder_CubeBlock[@xsi:type!='MyObjectBuilder_Wheel']", $ns).count
                        $flag = 0
                        IF($isolationcheck -lt 2){
                            $selectallwheelbase = $allgrids.SelectNodes("CubeBlocks/MyObjectBuilder_CubeBlock[@xsi:type='MyObjectBuilder_MyObjectBuilder_MotorSuspension']", $ns)
                            ForEach($suspension in $selectallwheelbase){
                            IF($wheel.EntityId -eq $suspension.RotorEntityId){
                                $flag = $flag +1
                            }
                            }
                            IF($flag -eq 0){
                            $wheel.ParentNode.RemoveChild($wheel)
                            }
                        }
                    }
                    ForEach($advrotor in $advrotorcount){
                        $isolationcheck = $node.SelectNodes("CubeBlocks/MyObjectBuilder_CubeBlock[@xsi:type!='MyObjectBuilder_MotorAdvancedRotor']", $ns).count
                        $flag = 0
                        IF($isolationcheck -lt 2){
                            $advrotor.ParentNode.RemoveChild($advrotor)
                        }
                    }
                }

                }
            }
    }
    
   
   #save XML changes
   $myXML.Save($filePath) 

   #update-space engineers
     
    ##### CONSTANTS #####
     
    # path to the root Space engineers folder
    $sePath = "replace this text with path to\DedicatedServer\"
     
    # the directory where steamcmd.exe is located
    $steamCmdPath = "replace this text with path to\SteamCMD\"
     
    # Steam username
    $steamUser = "steam user id"
     
    # Steam password. 
     
    $steamPassword = 'steam password'
     
    
    ##### VALIDATION #####
     
    Write-Host -ForegroundColor Green "Validating data."
    ## make sure the steamcmd path is valid and contains the steamcmd.exe file
    $steamCmdPath = $steamCmdPath.TrimEnd("\\")
    if (!(Test-Path "$steamCmdPath\steamcmd.exe")) {
     
        Write-Host -ForegroundColor Red "ERROR: The SteamCMD path is invalid. Please enter the path to the steamcmd.exe file. Path entered was: $steamCmdPath"
        sleep 3
        exit
    }

    sleep 3 
     
    ## run the app update once to
    Write-Host -ForegroundColor Green "Checking for updates to Steam."
    $steamCmd = "$steamCmdPath\steamcmd.exe"
    Start-Process $steamCmd -ArgumentList "+quit" -WorkingDirectory "$steamCmdPath"
    $myPID = Get-Process steamcmd | where {$steamCmdPids -notcontains $_.Id} | foreach {$_.Id}
    # wait for the steamcmd.exe process to complete
    if ($steamCmdPids) {
        do {sleep 1} until (!(Get-Process -Id $myPID -EA SilentlyContinue))
    } else {
        do {sleep 1} until (!(Get-Process steamcmd -EA SilentlyContinue))
    }

    sleep 3

    Write-Host -ForegroundColor Green "Checking for updates to Space Engineers."
    # run the app updater
    Start-Process $steamCmd -ArgumentList "+login $steamUser $steamPassword +force_install_dir $sePath +app_update 244850 +quit" -WorkingDirectory "$steamCmdPath"
    # get the steamcmd running PID
    $myPID = Get-Process steamcmd | where {$steamCmdPids -notcontains $_.Id} | foreach {$_.Id}
     
    # wait for the steamcmd.exe process to complete
    if ($steamCmdPids) {
        do {sleep 1} until (!(Get-Process -Id $myPID -EA SilentlyContinue))
    } else {
        do {sleep 1} until (!(Get-Process steamcmd -EA SilentlyContinue))
    }
   
   Write-Host -ForegroundColor Green "Daily Maintenance Complete."
   sleep -Seconds 3

   #start the servers
   Write-Host -ForegroundColor Green "Starting Space Engineers Services"
   
    
    $filePath2 = 'replace this text with path to\SANDBOX.sbc'
    Write-Host -ForegroundColor Green "loading small save please wait ... "
    [xml]$myXML2 = Get-Content $filePath2 -Encoding UTF8
    $ns2 = New-Object System.Xml.XmlNamespaceManager($myXML2.NameTable)
    $ns2.AddNamespace("xsi", "http://www.w3.org/2001/XMLSchema-instance")
    
    # use the below for SESE
    $autosave = $myXML2.SelectSingleNode("//Settings/AutoSaveInMinutes" , $ns2)
    If($autosave.InnerText -ne 0){
       $autosave.InnerText = 0 
    }
    #save XML changes
   $myXML2.Save($filePath2)

   # can use worldrequestreplace to unlink simspeed

   Set-Location replace this text with path to\DedicatedServer\DedicatedServer64
   start-process cmd.exe -argumentlist '/c "replace this text with path to\DedicatedServer\DedicatedServer64\SEServerExtender.exe restartoncrash nowcf autosave=15 autostart path="replace this text with path to\DedicatedServer\DataDir\VPS Dedicated 1"'
   #end SESE section
   

   
   <#stock dedi startup
   $autosave = $myXML2.SelectSingleNode("//Settings/AutoSaveInMinutes" , $ns2)
   If($autosave.InnerText -eq 0){
       $autosave.InnerText = 5 
    }
    #save XML changes
   $myXML2.Save($filePath2)
   Start-Service 'VPS Dedicated 1' -EA SilentlyContinue
   #>


   #Remove-Item "replace this text with path to\DedicatedServer\DataDir\Dedicated Imports\Saves\*" -recurse

   #start import server
   #Start-Service 'Dedicated Imports' -EA SilentlyContinue
   Set-Location replace this text with path to\DedicatedServer\DedicatedServer64
   start-process cmd.exe -argumentlist '/c "replace this text with path to\DedicatedServer\DedicatedServer64\SEServerExtender.exe restartoncrash nowcf autosave=15 autostart path="replace this text with path to\DedicatedServer\DataDir\Dedicated Imports"'

   #start experimental server
   #Set-Location replace this text with path to\DedicatedServer\DedicatedServer64
   #start-process cmd.exe -argumentlist '/c "replace this text with path to\DedicatedServer\DedicatedServer64\SEServerExtender.exe restartoncrash nowcf worldrequestreplace autosave=5 autostart path="replace this text with path to\DedicatedServer\DataDir\admin creative"'


   sleep -Seconds 3

   Add-Content -Path 'replace this text with path to\Servers Log.log' -Value "[$([DateTime]::Now)] SE Daily Maintenance was completed."

   #enable recovery task
   #$MyTask.Enabled = $true
   $MyTask2.Enabled = $true
