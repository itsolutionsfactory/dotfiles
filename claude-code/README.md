# Claude Code

This module installs [Claude Code](https://code.claude.com/docs), Anthropic's agentic
coding CLI, on both Ubuntu and MacOS using the official Anthropic installer:

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

## What it does

- Ensures `curl` is available (installs it via apt on Ubuntu if missing)
- Runs the official installer, which downloads the release binary for the current
  platform, verifies its SHA-256 checksum against the release manifest, and runs
  `claude install` to set up the launcher
- Reports the installed version and warns if `~/.local/bin` is not yet on `PATH`

The same installer is used on MacOS, so no Homebrew formula or cask is needed and the
`Brewfile` is unchanged.

## Install location

| Path | Contents |
| --- | --- |
| `~/.local/bin/claude` | Launcher placed on `PATH` |
| `~/.claude/` | Configuration, projects, and downloads |

`~/.local/bin` is already prepended to `PATH` by this repo's `zsh` module
(`zsh/.zshrc`), so `claude` is available after restarting your shell.

## Updating

Re-running the module installs the latest release over the existing one:

```bash
cd claude-code
./install.sh
```

The script prints the previous and new versions, and says "already up to date" when
nothing changed. Claude Code can also update itself with `claude update`.

## Usage

```bash
cd claude-code
./install.sh   # install or update
./test.sh      # verify the installation
```

After installation, run `claude` once to sign in. `claude doctor` reports the health of
the installation.

## Notes

- **Never run this module (or the installer) with `sudo`.** Claude Code installs into
  `$HOME`; under `sudo` it would land in root's home and `claude` would not be found in
  your own shell. Both this script and the upstream installer refuse to run that way.
- No configuration is stowed by this module. Claude Code keeps its own state in
  `~/.claude`, which is intentionally left unmanaged so credentials and project history
  are not committed to this repository.
