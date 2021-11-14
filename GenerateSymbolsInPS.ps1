function GenerateSymbolsLookupDatabaseInSQL
{
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing");
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms");
    [void] [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo");
    [void] [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SqlWmiManagement");

    function GenerateSymbolsForDatabase
    {
        [CmdletBinding()]param ([String]$Server, [String]$Database)
        $ClientNAVDir = 'C:\Program Files (x86)\Microsoft Dynamics NAV\110\RoleTailored Client'
        $Command = """$ClientNAVDir\finsql.exe"" command=generatesymbolreference,servername=$Server,database=$Database"
       
        Write-host $Command
        cmd /c $Command
    }
    function Get-SQLServerList()
    {
        $comboBox2.Items.Clear();       
        $computer = "$env:COMPUTERNAME"
        $MC = New-Object Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer($computer);
        
        foreach($instance in ($MC.Services | Where-Object {$_.Type -eq "SqlServer"}))
        {
            if (($instance.DisplayName -eq 'MSSQLSERVER') -or ($instance.DisplayName -eq 'SQL Server (MSSQLSERVER)'))
                {$comboBox2.Items.Add($computer)}
            elseif ($instance.DisplayName.Contains('SQL Server ('))
                {[int]$lenght = $instance.DisplayName.Length - 13
                $comboBox2.Items.Add(-join ($computer,'\',($instance.DisplayName.SubString(12,$lenght))))}
        }
        $com
    }

    function Get-DBList($server)
    {
        $comboBox1.Items.Clear();
        $script:DatabaseName  = @{}
        $srv = New-Object 'Microsoft.SqlServer.Management.Smo.Server' $server
   
        [int]$i = 0
        foreach($sqlDatabase in $srv.Databases)
        {
            $i++
            $DatabaseName.Add($i,$sqlDatabase)
        }
        foreach($databaseID in $databasename.keys)
        {
   
            $DBname =  $databasename[$databaseID]
            $DBname2 = $DBname.ToString()
            $DBname2 = $DBname2.trimstart('[')
            $DBname2 = $DBname2.trimend(']')
            $IsSystemDatabase = ($DBname2 -like 'master') -or ($DBname2 -like 'tempdb') -or ($DBname2 -like  'model') -or ($DBname2 -like 'msdb') -or ($DBname2.startswith('ReportServer'))
            if (-not $IsSystemDatabase)
            {$comboBox1.Items.add($DBname2)}
        }

    }

    #Create the Main Window
    $objForm = New-Object System.Windows.Forms.Form
    $objForm.Text = "Generate Dynamics BC Symbols"
    $objForm.Size = New-Object System.Drawing.Size(300,300)
    $objForm.StartPosition = "CenterScreen"

    $objForm.KeyPreview = $True
    $objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") {$script:x1=$comboBox2.Text;$script:x2=$comboBox1.Text;$objForm.Close()}})

    $objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape")
    {$objForm.Close()}})

   
    #Create the Buttons
    $GetSQLButton = New-Object System.Windows.Forms.Button
    $GetSQLButton.Location = New-Object System.Drawing.Size(10,125)
    $GetSQLButton.Size = New-Object System.Drawing.Size(260,23)
    $GetSQLButton.Text = "Load List Of Servers"
    $GetSQLButton.Add_Click({Get-SQLServerList})
    $objForm.Controls.Add($GetSQLButton)

    $GetDBButton = New-Object System.Windows.Forms.Button
    $GetDBButton.Location = New-Object System.Drawing.Size(10,155)
    $GetDBButton.Size = New-Object System.Drawing.Size(260,23)
    $GetDBButton.Text = "Load List Of Databases"
    $GetDBButton.Add_Click({
            $script:x1=$comboBox2.Text
            if ($script:x1 -ne '') 
                {Get-DBlist($script:x1)} 
            else
                {[System.Windows.Forms.MessageBox]::Show("Please enter <servername>\<instance> in the server field.")}
            })
    $objForm.Controls.Add($GetDBButton)

    $CancelButton = New-Object System.Windows.Forms.Button
    $CancelButton.Location = New-Object System.Drawing.Size(15,220)
    $CancelButton.Size = New-Object System.Drawing.Size(75,23)
    $CancelButton.Text = "Cancel"
    $CancelButton.Add_Click({$objForm.Close()})
    $objForm.Controls.Add($CancelButton)

    $OKButton = New-Object System.Windows.Forms.Button
    $OKButton.Location = New-Object System.Drawing.Size(190,220)
    $OKButton.Size = New-Object System.Drawing.Size(75,23)
    $OKButton.Text = "OK"
    $OKButton.Add_Click({$script:x1=$ComboBox2.Text;$script:x2=$ComboBox1.Text;$objForm.Close()})
    $objForm.Controls.Add($OKButton)


    #Create Labels and ComboBox
    $objLabel = New-Object System.Windows.Forms.Label
    $objLabel.Location = New-Object System.Drawing.Size(10,20)
    $objLabel.Size = New-Object System.Drawing.Size(280,20)
    $objLabel.Text = "Server"
    $objForm.Controls.Add($objLabel)

    $script:comboBox2 = New-Object System.Windows.Forms.ComboBox
    $comboBox2.Location = New-Object System.Drawing.Size(10,40)
    $comboBox2.Size = New-Object System.Drawing.Size(260,20)
    $objForm.Controls.Add($comboBox2)

    $objLabel2 = New-Object System.Windows.Forms.Label
    $objLabel2.Location = New-Object System.Drawing.Size(10,65)
    $objLabel2.Size = New-Object System.Drawing.Size(280,20)
    $objLabel2.Text = "Database"
    $objForm.Controls.Add($objLabel2)

    $script:comboBox1 = New-Object System.Windows.Forms.ComboBox
    $comboBox1.Location = New-Object System.Drawing.Size(10,85)
    $comboBox1.Size = New-Object System.Drawing.Size(260,20)
    $objForm.Controls.Add($comboBox1)

    $objForm.Topmost = $True

    $objForm.Add_Shown({$objForm.Activate()})
    [void] $objForm.ShowDialog()

    if (($x1 -ne '') -and ($x2 -ne ''))
    {GenerateSymbolsForDatabase -Server $x1 -Database $x2}
    else
    {
        [System.Windows.Forms.MessageBox]::Show("Please enter server and database")
        Write-Error 'Please enter server and database'
    }
}

GenerateSymbolsLookupDatabaseInSQL