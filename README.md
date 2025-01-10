# DomainHunter: Pre2k Password Discovery Tool

<p align="center">
  <h3 align="center">Advanced tool for discovering and testing pre-Windows 2000 computer account passwords in Active Directory environments.</h3>
</p>

## About The Project
DomainHunter is a specialized PowerShell tool designed to identify domain computers using predictable pre-Windows 2000 password patterns. It enables security professionals to discover potentially vulnerable computer accounts in Active Directory environments.

## Key Features
- Domain-wide computer enumeration
- Works in PowerShell Constrained Language Mode
- Runs with standard domain user permissions
- No local admin rights required
- Pre-Windows 2000 password pattern testing
- Age-based password filtering (30+ days)
- Real-time discovery alerts
- Detailed logging of findings

## Getting Started

### Prerequisites
- Domain User account
- Basic PowerShell execution rights
- Network connectivity to Domain Controllers


### Basic Usage
```powershell
.\DomainHunter_Pre2k.ps1
```

The tool will prompt for:
- Output file location
- Password age filtering preference (y/n)
- Pre-Windows 2000 Compatible Access group targeting (y/n)

## How It Works

DomainHunter performs the following operations:
- Enumerates computer accounts (all or group-specific)
- Shows password age for group members when targeting Pre-Windows 2000 group
- Applies age-based filtering if selected
- Tests each computer using the pre-Windows 2000 password pattern
- Logs successful discoveries

## Password Pattern Logic
- Takes computer name minus last character
- Converts to lowercase
- Truncates to 14 characters maximum

## Output Format

Group member display:
`[+] Computers in group:
    - COMPUTER001$ - Password Last Set 45 days
    - COMPUTER002$ - Password Last Set 120 days`


Test results:

`[TESTING] Computer: COMPUTERNAME$ Password: password SUCCESS/FAILED`

## Security Notes
- Run in authorized test environments only
- Monitor domain controller logs during testing
- Follow organizational security policies

## Author
Bruno Monteiro

## License
MIT License

## Disclaimer
For authorized security testing only. Use responsibly and with proper authorization.
