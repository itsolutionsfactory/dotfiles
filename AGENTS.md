# AGENTS.md

Guidance for coding agents (Claude Code, Cursor, and others) working in this repository. `CLAUDE.md` only includes this file.

Cross-platform dotfiles for **Ubuntu 24.04 and 26.04 LTS** (26.04 validated on a real laptop on 2026-05-29, report in `docs/ubuntu-26.04-compatibility.md`) and **macOS**, managed with **GNU Stow**. Each tool is a self-contained "module" with its own installer, tests, and (usually) a stowed config payload. There is no build step — everything is Bash + Stow.

## Commands

```bash
# Install (root install.sh auto-detects OS and execs the right installer)
./install.sh                # interactive menu
./install.sh --all          # install everything in predefined order, no prompts
./install.sh --update       # update packages (apt/snap/flatpak on Linux; brew on macOS)
./install.sh --backup       # only ensure backup/ and ~/.config exist
./install.sh --help

# Install a single module
cd kitty && ./install.sh

# Test everything (functional; assumes a real Linux/Docker env)
./test-all.sh

# macOS / CI validation: bash -n syntax, module layout, Brewfile, dry stow,
# and portable per-module symlink tests in a throwaway $HOME
./test-macos.sh

# Test a single module
cd kitty && ./test.sh

# Post-install check on a real Ubuntu laptop (read-only, no set -e): exit 0 = all good,
# [!] lines are the expected manual leftovers (chsh, docker group, JFrog secrets)
./scripts/verify-install.sh

# Syntax-lint a script (this is the CI gate). shellcheck is also recommended.
bash -n install_macos.sh

# Docker test harness (Ubuntu 24.04): runs install --all then test-all
docker-compose up --build
```

## Architecture

**OS dispatch.** `install.sh` is a thin dispatcher: it switches on `uname -s` and `exec`s `install_ubuntu.sh` (Linux) or `install_macos.sh` (Darwin), forwarding all args. The two OS installers are the real entry points and share the same flags (`--all`, `--backup`, `--update`, `--help`). `install_old.sh` is a pre-split legacy monolith — **not used**; do not edit it.

**Modules.** Every top-level directory that contains an `install.sh` is a module (e.g. `kitty/`, `zsh/`, `kubectl/`). The installers and `test-all.sh` discover modules by globbing for `install.sh`, excluding `.cursor`, `backup`, and `scripts`. A module typically holds: `install.sh`, `test.sh`, an optional `README.md`, the stowed payload, and a `.stow-local-ignore`. Fifteen modules are in the Ubuntu `--all` order (`infra-tools-kit` last, it symlinks diagnostic scripts into `~/.local/bin`); three are manual only: `appimaged`, `powershell`, `linux-config` (WiFi driver fixes).

**Two Stow link patterns** — match the one a sibling module already uses:
- **`.config` payload** (kitty, hyfetch, vim, kubectl, github-cli, gitlab-cli): files live in `module/.config/<name>/`, stowed with `stow -t "$HOME/.config" .config` → `~/.config/<name>`.
- **`$HOME` payload** (zsh, nvm, certs): files like `.zshrc` live at the module root, stowed with `stow -t "$HOME" .`. These need a `.stow-local-ignore` listing `install.sh`/`test.sh` so the scripts aren't symlinked into `$HOME`.
- `kubectl` does **both** (`.config/kubectl` and a `.kube/` payload).

**Install order matters.** Ubuntu installs in a fixed list in `install_ubuntu.sh` (`apt-packages` first — it provides `stow`/deps — then `certs`, `zsh`, …). macOS uses a different, smaller list in `install_macos.sh` (`MACOS_MODULE_ORDER`) and **skips Linux-only modules** (`MACOS_SKIP_MODULES`: apt-packages, snap-config, flatpak-config, appimaged, docker, slack, powershell). On macOS, packages come from `Brewfile` via `brew bundle` (Homebrew is bootstrapped if missing); the skipped modules' apps are installed as Brew casks instead of running their Linux scripts.

**Testing layers.**
- `test-all.sh` — runs each module's `test.sh` for real. Used inside Docker (`entrypoint.sh`).
- `test-macos.sh` — the CI workflow (`.github/workflows/macos-validation.yml`, runs on `macos-14`). Validates syntax/layout/Brewfile, dry-runs stow into a temp `$HOME`, then runs each module's `test.sh` in **portable mode**.
- **Portable test mode**: when `DOTFILES_TEST_MODE=1`, a module's `test.sh` sources `scripts/test-lib.sh` and only checks symlink integrity, then exits. `test-lib.sh` exists because macOS/BSD `readlink` has no `-f`; use `test_stow_link_portable` there, not `readlink -f`.

**Backups.** Module installers back up any pre-existing real config to `backup/` (timestamped tar or dir) before stowing, but **detect and just delete an existing repo-managed symlink** instead of backing it up (see `kubectl/install.sh` `backup_config`). `backup/` is created at install time and is not committed.

## Conventions (enforced — see `.cursor/rules/`)

- **Every script** uses `set -e`, the **Catppuccin Mocha** ANSI color palette, and the `print_status` / `print_success` / `print_error` / `print_warning` / `print_header` helpers. Copy this preamble from any existing module when adding a script.
- **Never copy config files — always Stow symlinks.** (The one exception is `certs`, which must `cp` the CA into the system trust store, then stows the rest.)
- Installers must be **idempotent** and guard the environment: skip GUI/privileged steps when `[ -f /.dockerenv ]`, branch on `uname -s` for macOS vs Linux (and `uname -m` for arch), and `command -v` / `brew list` before installing.
- All code, comments, and output in **English**.
- A new module needs `install.sh` + `test.sh` (give `test.sh` a `DOTFILES_TEST_MODE` branch so it joins macOS CI), and a `.stow-local-ignore` if it stows into `$HOME`. To make it part of `--all`, add it to the order array(s) in the OS installer(s).

## Known drift (don't be misled)

- The WireGuard dispatcher (`apt-packages/wireguard-setup.sh`, changelog 1.3.0) **skips the VPN on the `ITSF-Wifi` SSID** and stops it when the WiFi goes down. From the office some Monaco Telecom services are only reachable through the tunnel (they allow the VPN exit IP, not the office one), which is why `infra-tools-kit/fix-vpn.sh` (command `fix-vpn`) removes the dispatcher and re-enables autoconnect. Whether the dispatcher should skip the VPN on the office WiFi at all is an open question for the Infra team; do not "fix" one script to match the other without that decision.
- `infra-tools-kit/diag-network-report` pings `172.25.3.240`, the Lyon office firewall GUI: the LAN check only means something in Lyon.
- The `kitty-latest-and-claude-code` branch (2026-09-08, unmerged) adds a `claude-code` module (16th in `--all`, 10th on macOS) and installs Kitty from upstream instead of apt. The `add-flux-cli` branch (2025-12, unmerged) adds a `flux-cli` module and is far behind `main`.
- `kubectl/.kube/config` only carries the two K8sv3 clusters (`v3-prd`, `v3-stg`, OIDC via `kubelogin`); no RKE2 context is shipped.
- `snap-config/` has an `install.sh` but **no `test.sh`**, so `test-all.sh` would error if it reaches that module (it's root-only and skipped in Docker/macOS).
- `docker/.docker/config.json` and `nvm/.npmrc` are stowed with placeholders (JFrog token, e-mail, `cafile` path): filling them is a manual step after `--all`, and `scripts/verify-install.sh` reports them as `[!]` until done.
- `install_old.sh` is the pre-split monolith, not used; do not edit it.
