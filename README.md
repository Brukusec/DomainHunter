# DomainHunter: Pre2k Password Discovery Tool

<p align="center">
  <h3 align="center">Advanced Pre-Windows 2000 Password Discovery Tool</h3>
</p>

## About The Project
DomainHunter is a specialized PowerShell tool designed to identify domain computers using predictable pre-Windows 2000 password patterns. It enables security professionals to discover potentially vulnerable computer accounts in Active Directory environments.

## Key Features
- Domain-wide computer enumeration
- Pre-Windows 2000 password pattern testing
- Age-based password filtering (30+ days)
- Real-time discovery alerts
- Detailed logging of findings

## Getting Started

### Prerequisites
- Windows PowerShell 5.1+
- Domain user access
- RSAT Tools installed

### Basic Usage
```powershell
.\DomainHunter_Pre2k.ps1
```

The tool will prompt for:
- Output file location
- Password age filtering preference

## How It Works

DomainHunter performs the following operations:
- Enumerates all computer accounts in the domain
- Applies age-based filtering if selected
- Tests each computer using the pre-Windows 2000 password pattern
- Logs successful discoveries

## Password Pattern Logic
- Takes computer name minus last character
- Converts to lowercase
- Truncates to 14 characters maximum

## Output Format

Successful discoveries are logged as:

`[DISCOVERED] Computer: COMPUTER001 Password: computer001 (Last password set: 2024-01-20)`

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
