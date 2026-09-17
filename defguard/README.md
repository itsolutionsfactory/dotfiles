# Defguard client

Installs the [Defguard](https://github.com/DefGuard/client) desktop client on Ubuntu (24.04 and 26.04, amd64 and arm64) and on MacOS (13.5 or later). Last module of `./install.sh --all` on both, so its warnings are the last thing printed; skipped in Docker.

```bash
cd defguard && ./install.sh
./test.sh
```

## What the installer does on Ubuntu

1. Downloads the pinned release (`DEFGUARD_VERSION` in `install.sh`), the `ubuntu-22-04-lts` package for the machine architecture, and checks its sha256 against the digest pinned in the script. The unsuffixed `_amd64.deb` asset targets Debian 13, not Ubuntu.
2. Installs it with `apt-get install`, which pulls the dependencies. The package postinst creates the `defguard` group, adds the user running `sudo` to it, then enables and starts `defguard-service`.
3. Makes sure the user is in the `defguard` group, the service is running and the socket `/var/run/defguard.socket` exists.
4. Warns when `resolvconf` is missing: the client needs it to apply the DNS servers of a location.
5. Checks whether a reboot is required (below), then asks before rebooting. During `./install.sh --all` (`DOTFILES_INSTALL_ALL=1`) it does not ask and only warns.

Running it again is safe: an installed pinned version is not reinstalled, a newer one is kept, and the group and reboot checks run every time.

## Why a reboot can be required

The client does not create the tunnel itself: it asks `defguard-service` through `/var/run/defguard.socket`, which only `root` and the `defguard` group can open. A process only gets the groups its session had when it started. Desktop apps are launched by the user's systemd manager (`systemd --user`), which can outlive a logout, so a logout and login is not always enough on Ubuntu: a reboot is.

The installer reads the `Groups:` line of `/proc/<pid>/status`:

- of the user's systemd manager (or of the script itself when there is none): without the `defguard` gid, a reboot is required;
- of the running `defguard-client`, when the manager already has the gid: without it, quitting and relaunching the client is enough.

Manual equivalent:

```bash
getent group defguard
grep Groups /proc/$(pgrep -u "$(id -u)" -x systemd | head -1)/status
grep Groups /proc/$(pgrep -u "$(id -u)" -x defguard-client | head -1)/status
```

## What the installer does on MacOS

The Homebrew cask `defguard-client` is stuck on 1.5.x and deprecated, so the module uses the release DMG.

1. Leaves Defguard alone when it was installed from the App Store (the App Store keeps it up to date) or when the installed version is the pinned one or newer.
2. Stops if Defguard is running: quit it from its menu bar icon first.
3. Downloads `Defguard_<version>_universal.dmg`, checks its sha256 against `DEFGUARD_SHA256_DMG`, mounts it read-only.
4. Checks the code signature, that it is signed by the vendor's Apple Developer team (`DEFGUARD_MACOS_TEAM_ID`, the same team signs the App Store build) and that Gatekeeper accepts it.
5. Copies `Defguard.app` into `/Applications` with `ditto` (with `sudo` only when `/Applications` is not writable).

On first launch MacOS asks to allow the Defguard VPN system extension and VPN configuration. `./test.sh` checks the application, its signature and whether the extension is activated.

## Troubleshooting

On Ubuntu, `Failed to establish VPN connection` right after entering a valid MFA code: the server accepted the code, but the client could not reach `defguard-service`. The session lacks the `defguard` group; run `./install.sh` again and reboot if it says so.

## Upgrading

Bump `DEFGUARD_VERSION` and the three `DEFGUARD_SHA256_*` values in `install.sh` (digests are listed on the GitHub release page), then run `./install.sh`. On Ubuntu the package restarts the service on upgrade; on MacOS quit Defguard before running the script.
