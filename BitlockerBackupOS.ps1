###############################################################################################################
#
# ABOUT THIS PROGRAM
#
#   BitlockerBackupOS.ps1
#   https://github.com/Headbolt/BitlockerBackupOS
#
#   This script was designed to Backup the Bitlocker Recovery Details of a Machines OS Disk 
#	To the AD DS machine Object, and to Azure AD
#
#	Intended use is in Microsoft Endpoint Manager, as the "Check" half of a Proactive Remediation Script
#
###############################################################################################################
#
# HISTORY
#
#   Version: 1.0 - 06/04/2022
#
#   - 06/04/2022 - V1.0 - Created by Headbolt, with assistance from CS 
#
$osVolMountPoint=( (Get-BitlockerVolume | where-object {$_.VolumeType -eq 'OperatingSystem'}).MountPoint )
$osVolRecPassKeyProtectorID=( (Get-BitlockerVolume | where-object {$_.VolumeType -eq 'OperatingSystem'}).KeyProtector | where {$_.KeyProtectorType -eq "RecoveryPassword"} | select -ExpandProperty KeyProtectorID )
#
Write-Host ""
Write-Host "###############################################################################################################"
Write-Host ""
#
Write-Host "Backing Up Key Protector to Azure AD"
Write-Host "Running Command"
Write-Host ""
Write-Host "BackupToAAD-BitLockerKeyProtector -MountPoint $osVolMountPoint -KeyProtectorID $osVolRecPassKeyProtectorID -WarningAction SilentlyContinue | OUT-NULL"
#
BackupToAAD-BitLockerKeyProtector -MountPoint $osVolMountPoint -KeyProtectorID $osVolRecPassKeyProtectorID -WarningAction SilentlyContinue | OUT-NULL
#
Write-Host ""
Write-Host "###############################################################################################################"
Write-Host ""
#
Write-Host "Testing Secure Channel"
Write-Host ""
#
if (Test-ComputerSecureChannel)
{
	Write-Host "Secure Channel Verified"
	#
	Write-Host "Backing Up Key Protector to AD DS"
	Write-Host "Running Command"
	Write-Host ""
	Write-Host "Backup-BitLockerKeyProtector -MountPoint $osVolMountPoint -KeyProtectorID $osVolRecPassKeyProtectorID -WarningAction SilentlyContinue | OUT-NULL"
	#
	Backup-BitLockerKeyProtector -MountPoint $osVolMountPoint -KeyProtectorID $osVolRecPassKeyProtectorID -WarningAction SilentlyContinue | OUT-NULL
	#
	Write-Host ""
	Write-Host "###############################################################################################################"
	Write-Host ""
	#
	Write-Host "END"
	#
	Write-Host ""
	Write-Host "###############################################################################################################"
	Write-Host ""
	#
	Exit 0
}
else
{
	Write-Host "Secure Channel Verification Failed, Cannot Write to AD DS"
	Write-Host ""
	Write-Host "Exiting"
	#
	Write-Host ""
	Write-Host "###############################################################################################################"
	Write-Host ""
	#
	Exit 1
}
