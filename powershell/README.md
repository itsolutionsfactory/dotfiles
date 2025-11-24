# PowerShell

This module manages the installation of PowerShell on Ubuntu 24 LTS using snap.

## Features

- Installation of PowerShell using snap (simpler and more reliable)
- Automatic snap package installation
- Comprehensive installation verification
- Post-installation guidance
- Optional Exchange Online PowerShell module installation

## Installation

To install PowerShell:

```bash
cd powershell
sudo ./install.sh
```

The installation process includes:
1. Checking for snap availability
2. Installing PowerShell using snap
3. Verifying installation
4. Optionally installing Exchange Online PowerShell module

## Prerequisites

The installation requires:
- `snapd` - Snap package manager (usually pre-installed on Ubuntu)
- `sudo` privileges

If snap is not available, install it with:
```bash
sudo apt-get install -y snapd
```

## Components Installed

### Core Components
- **powershell** - PowerShell Core (pwsh) installed via snap
- **ExchangeOnlineManagement** - Exchange Online PowerShell module (optional, installed during setup if selected)
- **MicrosoftTeams** - Microsoft Teams PowerShell module (optional, installed during setup if selected)

## Post-Installation Steps

### 1. Start PowerShell

After installation, you can start PowerShell by running:

```bash
pwsh
```

### 2. Verify Installation

Check the PowerShell version:

```bash
pwsh --version
```

### 3. Test PowerShell

Run a simple PowerShell command:

```bash
pwsh -Command "Write-Host 'Hello, PowerShell!'"
```

### 4. Install Exchange Online PowerShell Module (Optional)

During installation, you'll be prompted to install the Exchange Online PowerShell module. If you choose to install it, or if you want to install it later:

```powershell
Install-Module ExchangeOnlineManagement
Import-Module ExchangeOnlineManagement
```

Or from bash:

```bash
pwsh -Command "Install-Module ExchangeOnlineManagement; Import-Module ExchangeOnlineManagement"
```

### 5. Install Microsoft Teams PowerShell Module (Optional)

During installation, you'll be prompted to install the Microsoft Teams PowerShell module. If you choose to install it, or if you want to install it later:

```powershell
Install-Module -Name MicrosoftTeams -Force -AllowClobber
Import-Module MicrosoftTeams
```

Or from bash:

```bash
pwsh -Command "Install-Module -Name MicrosoftTeams -Force -AllowClobber; Import-Module MicrosoftTeams"
```

For more information, see the [Microsoft documentation](https://learn.microsoft.com/en-us/powershell/exchange/exchange-online-powershell-v2?view=exchange-ps#install-and-maintain-the-exchange-online-powershell-module).

## Configuration

PowerShell configuration files are located in:
- `~/.config/powershell/` - User-specific PowerShell configuration
- Profile files: `Microsoft.PowerShell_profile.ps1`

You can add custom configuration files to this module's `.config/powershell/` directory if needed.

## Usage

### Basic Commands

```bash
# Start PowerShell interactively
pwsh

# Run a PowerShell command
pwsh -Command "Get-Process"

# Execute a PowerShell script
pwsh -File script.ps1
```

### PowerShell Modules

Install PowerShell modules using:

```powershell
Install-Module -Name ModuleName -Scope CurrentUser
```

### Exchange Online PowerShell

If you've installed the Exchange Online PowerShell module, you can connect to Exchange Online:

```powershell
# Connect to Exchange Online
Connect-ExchangeOnline -UserPrincipalName your_admin_account@yourdomain.com

# List mailboxes
Get-Mailbox

# Disconnect when done
Disconnect-ExchangeOnline
```

For more information about using Exchange Online PowerShell, see the [Microsoft documentation](https://learn.microsoft.com/en-us/powershell/exchange/exchange-online-powershell-v2?view=exchange-ps).

### Microsoft Teams PowerShell

If you've installed the Microsoft Teams PowerShell module, you can connect to Microsoft Teams:

```powershell
# Connect to Microsoft Teams
Connect-MicrosoftTeams

# List teams
Get-Team

# Disconnect when done
Disconnect-MicrosoftTeams
```

For more information about using Microsoft Teams PowerShell, see the [Microsoft documentation](https://learn.microsoft.com/en-us/microsoftteams/teams-powershell-install).

## Testing

To test the PowerShell installation:

```bash
cd powershell
./test.sh
```

The test script verifies:
- PowerShell command availability
- PowerShell version
- PowerShell execution
- Snap installation verification
- Exchange Online PowerShell module (if installed)
- Microsoft Teams PowerShell module (if installed)

## Requirements

- Ubuntu 24 LTS (or compatible)
- sudo privileges (for installation)
- Internet connection (for downloading packages)

## Notes

- This module is **not included** in the automatic installation (`--all` option)
- PowerShell must be installed manually by running the install script
- The installation requires root privileges
- PowerShell Core (pwsh) is different from Windows PowerShell

## Troubleshooting

### PowerShell not found after installation

If `pwsh` command is not found after installation:

1. Verify snap installation: `snap list powershell`
2. Check PATH: `which pwsh`
3. Reload shell: `source ~/.bashrc` or `source ~/.zshrc`
4. Verify snap is working: `snap version`

### Snap installation errors

If you encounter snap installation errors:

1. Verify snap is installed: `which snap`
2. Check snap service: `sudo systemctl status snapd`
3. Install snapd if missing: `sudo apt-get install -y snapd`
4. Re-run the installation script

### Permission errors

If you encounter permission errors:

1. Ensure you're using `sudo` for installation
2. Check sudo privileges: `sudo -v`
3. Verify user is in sudo group: `groups`

## References

- [PowerShell Documentation](https://docs.microsoft.com/powershell/)
- [PowerShell GitHub](https://github.com/PowerShell/PowerShell)
- [PowerShell Snap Package](https://snapcraft.io/powershell)
- [Exchange Online PowerShell Module](https://learn.microsoft.com/en-us/powershell/exchange/exchange-online-powershell-v2?view=exchange-ps)

