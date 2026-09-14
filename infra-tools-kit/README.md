# Infra Tools Kit

This module installs the Infra team's diagnostic and maintenance scripts as commands available from any shell. Each `*.sh` file in the module (except `install.sh` and `test.sh`) is symlinked into `~/.local/bin` under its name without the extension, so the commands follow the repository when it is updated.

## Features

- Network and WiFi diagnostic report
- System log diagnostic report over the last two boots
- One-command update of this dotfiles repository
- Symlinks into `~/.local/bin`, with a timestamped backup of any real file they replace

## Installation

To install the commands:

```bash
cd infra-tools-kit
./install.sh
```

The installation process includes:
1. Creating `~/.local/bin` if it is missing (the `zsh` module already puts it on `PATH`)
2. Making every script executable
3. Symlinking each script into `~/.local/bin`, replacing a previous symlink in place and moving a real file to `backup/modules/infra-tools-kit/<timestamp>/`

Do not run the installer with `sudo`: the commands belong to the user.

## Commands

| Command | What it does | Output |
| --- | --- | --- |
| `diag-network-report` | Collects the network state (interfaces, routes, DNS, WiFi link, NetworkManager), pings a LAN target, a public DNS resolver and a public IP, then downloads three 10 MB test files to measure throughput | `net_diagnose_<hostname>_<date>.log` in the current directory, also printed on screen |
| `diag-log-report` | Reads `journalctl` for the current and the previous boot: critical errors, freezes and OOM kills, MCE and memory errors, fingerprint reader (`fprintd`), PAM and unlock, GPU and DRM, GNOME Shell and GDM, Wayland, thermal throttling, NVMe and I/O errors, USB and HID | `log-diag-<date>/report.txt` in the current directory |
| `update-dotfiles` | Runs `git fetch origin` then `git pull --ff-only` on the repository this module lives in; refuses to pull when the checkout is not on `main` or `develop` | Git output |

Attach the report file to the support ticket rather than pasting it: both reports are long.

## Usage

```bash
# Laptop without network or with a flaky WiFi
diag-network-report

# Laptop that froze, rebooted on its own or refuses to unlock
diag-log-report

# Get the latest version of the dotfiles
update-dotfiles
```

`diag-log-report` needs `sudo` to read the full journal and `dmidecode`; run it as `sudo diag-log-report` if the plain run reports empty sections.

## Testing

Run the module test script:

```bash
./test.sh
```

## Notes

- The commands are Linux only: they rely on `nmcli`, `journalctl`, `ip` and `lspci`.
- `diag-network-report` pings `172.25.3.240` as its LAN target: the management interface of the Lyon office firewall (OPNsense), reachable from the Lyon LAN and WiFi. On any other site or from home the LAN ping fails by design; read the WiFi link, routing and public ping sections instead.
- `diag-log-report` prints its section titles in French.
