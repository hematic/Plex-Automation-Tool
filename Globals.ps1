#--------------------------------------------
# Declare Global Variables and Functions here
#--------------------------------------------

$LogfilePath = "$ENV:TEMP\ToolLog.txt"
#region 7Zip Variables
$7ZipDownloadLink = "http://www.7-zip.org/a/7z1602-x64.exe"
$7ZipSavePath = "$ENV:TEMP\7Zip.exe"
$Global:7ZipInstallPath = "C:\Program Files\7-Zip\"
$Global:7ZipExe = "$($Global:7ZipInstallPath)7Z.exe"
#endregion
#region Python 2.7 Variables
$Python27DownloadLink = "https://www.python.org/ftp/python/2.7/python-2.7.amd64.msi"
$Python27SavePath = "$ENV:TEMP\Python27.msi"
$Global:Python27InstallPath = "C:\Python27\"
#endregion
#region Sonarr Variables
$SonarrDownloadLink = "https://download.sonarr.tv/v2/master/latest/NzbDrone.master.exe"
$SonarrSavePath = "$ENV:TEMP\Sonarr.exe"
$Global:SonarrInstallpath = "$ENV:ProgramData\NzbDrone"
#endregion
#region CouchPotato Variables
$CouchPotatoDownloadLink = "https://couchpota.to/updates/latest/installer/"
$CouchPotatoSavepath = "$ENV:TEMP\CouchPotato.exe"
$Global:CPInstallPath = "C:\Users\$ENV:username\AppData\Roaming\CouchPotato\application\"
#endregion
#region Deluge Variables
$DelugeDownloadLink = "http://download.deluge-torrent.org/windows/deluge-1.3.13-win32-py2.7-0.exe"
$DelugeSavepath = "$ENV:TEMP\Deluge.exe"
$Global:DelugeInstallPath = "C:\Program Files (x86)\Deluge\DelugeD.exe"
#endregion
#region Jackett Variables
$JackettDownloadLink = "https://github.com/Jackett/Jackett/releases/download/v0.7.303/Jackett.Installer.Windows.exe"
$JackettSavepath = "$ENV:TEMP\Jackett"
$Global:JackettInstallPath = "$ENV:Programdata\Jackett"
#endregion
#region PlexPy Variables
$PlexPyDownloadLink = "https://github.com/drzoidberg33/plexpy/zipball/master"
$PlexPySavepath = "$ENV:TEMP\PlexPy.zip"
$Global:PlexPyInstallPath = "C:\Users\$ENV:username\AppData\Roaming\PlexPy"
#endregion
#region PlexEmail Variables
$PlexEmailDownloadLink = "https://github.com/jakewaldron/plexemail/archive/master.zip"
$PlexEmailSavepath = "$ENV:TEMP\PlexEmail.zip"
$Global:PlexEmailInstallPath = "C:\Users\$ENV:username\AppData\Roaming\PlexEmail"
#endregion
#region PlexRequests Variables
$PlexRequestsDownloadLink = "https://github.com/tidusjar/PlexRequests.Net/releases/download/v1.8.4/PlexRequests.1.zip"
$PlexRequestsSavepath = "$ENV:TEMP\PlexRequests.zip"
$Global:PlexRequestsInstallPath = "C:\Users\$ENV:username\AppData\Roaming\PlexRequests"
#endregion
#region HTPC Manager Variables
$HTPCManagerDownloadLink = "https://github.com/Hellowlol/HTPC-Manager/archive/master2.zip"
$HTPCManagerSavepath = "$ENV:TEMP\HTPCManager.zip"
$Global:HTPCManagerInstallPath = "C:\Users\$ENV:username\AppData\Roaming\HTPCManager"
#endregion

Function Write-Log{
		<#
		.SYNOPSIS
			A function to write ouput messages to a logfile.
		
		.DESCRIPTION
			This function is designed to send timestamped messages to a logfile of your choosing.
			Use it to replace something like write-host for a more long term log.
		
		.PARAMETER Message
			The message being written to the log file.
		
		.EXAMPLE
			PS C:\> Write-Log -Message 'This is the message being written out to the log.' 
		
		.NOTES
			N/A
	#>
	
	Param
	(
		[Parameter(Mandatory = $True, Position = 0)]
		[String]$Message
	)
	
	
	add-content -path $LogFilePath -value ($Message)
}

Function Write-RichText{
	<#
	.SYNOPSIS
		A function to output text to a Rich Text Box.
	
	.DESCRIPTION
		This function appends text to a Rich Text Box and colors it based 
        upon the type of message being displayed.

    .PARAM Logtype
        Used to determine if the text is a success or error message or purely
        informational.

    .PARAM LogMSG
        The message to be added to the RichTextBox.
	
	.EXAMPLE
		Write-Richtext -LogType Error -LogMsg "This is an Error."
		Write-Richtext -LogType Success -LogMsg "This is a Success."
		Write-Richtext -LogType Informational -LogMsg "This is Informational."
	
	.NOTES
		Added Time stamps cause why not.
#>
	
	Param
	(
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
		[String]$LogType,
		[Parameter(Mandatory = $true, Position = 1, ValueFromPipeline, ValueFromPipelineByPropertyName)]
		[String]$LogMsg
	)
	
	switch ($logtype)
	{
		Error {
			$richtextbox1.SelectionColor = 'Red'
			$richtextbox1.AppendText("`n $(Get-date -Format "hh:mm:ss") - $logmsg")
			Write-Log -Message $logmsg
			
		}
		Success {
			$richtextbox1.SelectionColor = 'Green'
			$richtextbox1.AppendText("`n $(Get-date -Format "hh:mm:ss") - $logmsg")
			Write-Log -Message $logmsg
			
		}
		Informational {
			$richtextbox1.SelectionColor = 'Blue'
			$richtextbox1.AppendText("`n $(Get-date -Format "hh:mm:ss") - $logmsg")
			Write-Log -Message $logmsg
			
		}
		
	}
	
}

function Download-File{
	
	param
	(
		[parameter(Mandatory = $true)]
		[String]$DownloadLink,
		[parameter(Mandatory = $true)]
		[String]$Savepath,
		[parameter(Mandatory = $true)]
		[String]$Software
	)
	
	Invoke-WebRequest -Uri $DownloadLink `
					  -OutFile $Savepath
	
	If (!(Test-path $Savepath))
	{
		write-log "$Software failed to download"
		Return $false
	}
	
	Else
	{
		write-log "$Software downloaded successfully"
		Return $true
	}
}

function Install-Software{
	
	param
	(
		[parameter(Mandatory = $true)]
		[String]$Filepath,
		[parameter(Mandatory = $false)]
		[String]$Arguments,
		[parameter(Mandatory = $false)]
		[System.Management.Automation.PSCredential]$Credential,
		[parameter(Mandatory = $True)]
		[String]$Software
	)
	
	Write-RichText -LogType Informational -LogMsg "Beginning install of $Software"
	
	switch ($Filepath)
	{
		{ $Filepath -and $Arguments -and $Credential } {
			Start-Process -FilePath "$Filepath" -ArgumentList $Arguments -Credential $Credential -Wait
		}
		
		{ $Filepath -and !$Arguments -and !$Credential  } {
			Start-Process -FilePath "$Filepath" -Wait
		}
		
		{ $Filepath -and $Arguments -and !$Credential } {
			Start-Process -FilePath "$Filepath" -ArgumentList $Arguments -Wait
		}
		
		{ $Filepath -and !$Arguments -and $Credential } {
			Start-Process -FilePath "$Filepath" -Credential $Credential -Wait
		}
	}
	
}

function Verify-SonarrInstall{
	
	If (Test-Path -Path $Global:SonarrInstallpath\NZBDrone.exe)
	{
		$SonarrService = Get-Service -Name NZBDrone
		If (!$SonarrService)
		{
			Write-RichText -LogType error -logmsg "Sonarr service is not installed."
			Return $false
		}
		
		Else
		{
			Write-RichText -LogType Success -logmsg "Sonarr is installed!"
			Return $true
		}
	}
	
	Else
	{
		Write-RichText -LogType error -logmsg "Sonarr did not install correctly."
		return $false
	}
	
}

function Verify-CPInstall{
	
	If (Test-Path -Path $Global:CPInstallPath\CouchPotato.exe)
	{
		Write-RichText -LogType success -logmsg "CouchPotato is installed!"
		Return $true
	}
	
	Else
	{
		Write-RichText -LogType error -logmsg "CouchPotato did not install correctly."
		return $false
	}
	
}

function Verify-DelugeInstall{
	
	If (Test-Path -Path $Global:DelugeInstallPath)
	{
		Write-RichText -LogType success -logmsg "Deluge is installed!"
		Return $true
	}
	
	Else
	{
		Write-RichText -LogType error -logmsg "Deluge did not install correctly."
		Return $false
	}
	
}

function Verify-JackettInstall{
	
	If (Test-Path -Path $Global:JackettInstallPath )
	{
		$JackettService = Get-Service -Name Jackett
		If (!$JackettService)
		{
			Write-RichText -LogType error -logmsg "Jackett service is not installed."
			Return $false
		}
		
		Else
		{
			Write-RichText -LogType Success -logmsg "Jackett is installed!"
			Return $true
		}
	}
	
	Else
	{
		Write-RichText -LogType error -logmsg "Jackett did not install correctly."
		return $false
	}
	
}

function Verify-7ZipInstall{
	
	If (Test-Path -Path "$Global:7ZipInstallPath\7Z.exe"){
		
		Write-RichText -LogType success -logmsg "7Zip is installed!"
		Return $true
	}
	
	Else
	{
		Write-RichText -LogType error -logmsg "7Zip Failed to Install"
		Return $false
	}
}

function Verify-PythonInstall{
	
	If (Test-Path -Path $Global:Python27InstallPath\Python.exe){
		Write-RichText -LogType success -logmsg "Python 2.7 installed successfully!"
		Return $true
	}
	
	Else
	{
		Write-RichText -LogType error -logmsg "Python 2.7 failed to install."
		Return $false
	}
}

function Verify-PlexPyInstall{
	
	If (Test-Path -Path $Global:PlexPyInstallPath)
	{
		Rename-Item -Path "$Global:PlexPyInstallPath\drzoidberg33-plexpy-2150961" -NewName "Master" -Force
		$Global:PlexPyInstallPath = "C:\Users\$ENV:username\AppData\Roaming\PlexPy\Master\Plexpy.py"
		Write-RichText -LogType success -logmsg "PlexPy is installed!"
		Return $true
	}
	
	Else
	{
		Write-RichText -LogType error -logmsg "PlexPy Failed to Install"
		Return $false
	}
}

function Verify-PlexEmailInstall{
	
	If (Test-Path -Path $Global:PlexEmailInstallPath)
	{
		Rename-Item -Path "$Global:PlexEmailInstallPath\PlexEmail-Master" -NewName "Master" -Force
		$Global:PlexEmailInstallPath = "C:\Users\$ENV:username\AppData\Roaming\PlexPy\Master\Plexpy.py"
		Write-RichText -LogType success -logmsg "PlexEmail is installed!"
		Return $true
	}
	
	Else
	{
		Write-RichText -LogType error -logmsg "PlexEmail Failed to Install"
		Return $false
	}
}

function Verify-PlexRequestsInstall{
	
	If (Test-Path -Path $Global:PlexRequestsInstallPath)
	{
		Rename-Item -Path "$Global:PlexRequestsInstallPath\release" -NewName "Master" -Force
		$Global:PlexRequestsInstallPath = "C:\Users\$ENV:username\AppData\Roaming\PlexPy\Master\Plexrequests.exe"
		Write-RichText -LogType success -logmsg "PlexRequests is installed!"
		Return $true
	}
	
	Else
	{
		Write-RichText -LogType error -logmsg "PlexRequests Failed to Install"
		Return $false
	}
}

function Verify-HTPCManagerInstall{
	
	If (Test-Path -Path $Global:HTPCManagerInstallPath)
	{
		Rename-Item -Path "$Global:HTPCManagerInstallPath\HTPC-Manager-master2" -NewName "Master" -Force
		$Global:HTPCManagerInstallPath = "C:\Users\$ENV:username\AppData\Roaming\HTPCManager\Master\HTPC.py"
		Write-RichText -LogType success -logmsg "HTPCManager is installed!"
		Return $true
	}
	
	Else
	{
		Write-RichText -LogType error -logmsgWrite-Log "HTPCManager Failed to Install"
		Return $false
	}
	
	
	
	
}