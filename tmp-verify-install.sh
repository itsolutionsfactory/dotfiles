#!/bin/bash
#
# tmp-verify-install.sh — Post-install verification for Ubuntu (target: 26.04 "Resolute Raccoon")
#
# Read-only health check: confirms that everything `./install.sh` (--all) lays down on
# an Ubuntu laptop is actually present and correctly wired. Makes NO changes.
#
# Disposable helper (note the "tmp-" prefix); not part of the repo's module suite.
#
# NOTE: unlike the install/test scripts, this script intentionally does NOT use `set -e`.
#       A verifier must run every check and report a full picture instead of aborting on
#       the first failure. Run it as your normal user (not root). It can be run from
#       anywhere: the symlink checks validate that each config is a live stow symlink,
#       independently of where this script is located.

# Directory this script lives in — informational only (the symlink checks no longer depend on it).
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

# Catppuccin Mocha color scheme
BASE="\033[0m"
RED="\033[38;2;243;139;168m"       # Red
GREEN="\033[38;2;166;227;161m"     # Green
YELLOW="\033[38;2;249;226;175m"    # Yellow
BLUE="\033[38;2;137;180;250m"      # Blue
MAUVE="\033[38;2;203;166;247m"     # Mauve

PASS=0
FAIL=0
WARN=0

pass()   { echo -e "${GREEN}[✓]${BASE} $1"; PASS=$((PASS+1)); }
fail()   { echo -e "${RED}[✗]${BASE} $1"; FAIL=$((FAIL+1)); }
warn()   { echo -e "${YELLOW}[!]${BASE} $1"; WARN=$((WARN+1)); }
info()   { echo -e "${BLUE}[i]${BASE} $1"; }
header() { echo -e "\n${MAUVE}=== $1 ===${BASE}\n"; }

have() { command -v "$1" >/dev/null 2>&1; }

# --- Generic checks --------------------------------------------------------

check_cmd() { # <command> [label]
    local cmd="$1" label="${2:-$1}"
    if have "$cmd"; then pass "$label (commande '$cmd' présente)"
    else fail "$label — commande '$cmd' introuvable"; fi
}

check_dpkg() { # <package> [label]
    local pkg="$1" label="${2:-paquet apt $1}"
    if dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q "install ok installed"; then
        pass "$label"
    else
        fail "$label — non installé"
    fi
}

check_snap() { # <snap-name> [label]
    local name="$1" label="${2:-snap $1}"
    if ! have snap; then warn "$label — snap indisponible, non vérifié"; return; fi
    if snap list "$name" >/dev/null 2>&1; then pass "$label"
    else fail "$label — non installé"; fi
}

check_service() { # <unit> [label]
    local unit="$1" label="${2:-service $1}"
    if systemctl is-active --quiet "$unit"; then pass "$label actif"
    elif systemctl is-enabled --quiet "$unit" 2>/dev/null; then warn "$label activé mais pas actif"
    else fail "$label inactif"; fi
}

check_file() { # <path> <label>
    if [ -f "$1" ]; then pass "$2 ($1)"; else fail "$2 — absent: $1"; fi
}

# Confirms a config path is a valid stow symlink. Location-independent: a non-broken
# symlink passes regardless of where this script lives or is launched from.
check_stow() { # <path> <label>
    local p="$1" label="$2" real
    if [ -L "$p" ]; then
        if [ -e "$p" ]; then
            real="$(readlink -f "$p" 2>/dev/null)"
            pass "$label — lien stow valide ($p → $real)"
        else
            fail "$label — lien symbolique cassé: $p → $(readlink "$p" 2>/dev/null)"
        fi
    elif [ -e "$p" ]; then
        warn "$label — présent mais pas un lien symbolique (non géré par stow): $p"
    else
        fail "$label — absent: $p"
    fi
}

check_placeholder() { # <file> <string> <hint>
    [ -f "$1" ] || return 0
    if grep -qF "$2" "$1" 2>/dev/null; then warn "$3 — placeholder « $2 » encore présent dans $1"; fi
}

# --- 0. Environment --------------------------------------------------------

header "Environnement"

if [ "$(uname -s)" != "Linux" ]; then
    fail "OS non-Linux détecté ($(uname -s)) — ce script ne vérifie que l'installation Ubuntu"
    echo -e "${RED}Abandon.${BASE}"; exit 1
fi

if [ "$EUID" -eq 0 ]; then
    warn "Lancé en root — lance-le en utilisateur normal pour vérifier les configs de \$HOME"
fi

if [ -r /etc/os-release ]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    info "OS: ${PRETTY_NAME:-inconnu} (VERSION_ID=${VERSION_ID:-?})"
    case "${VERSION_ID:-}" in
        26.04) pass "Ubuntu 26.04 confirmé" ;;
        "")    warn "/etc/os-release sans VERSION_ID" ;;
        *)     warn "Version ${VERSION_ID} — ce script cible 26.04" ;;
    esac
else
    warn "/etc/os-release illisible"
fi
info "Script exécuté depuis: $REPO_DIR (les liens stow sont validés où qu'il soit)"

# --- 1. Base tools (install_ubuntu.sh: REQUIRED_APT_PACKAGES) ---------------

header "Outils de base (apt requis)"
check_dpkg stow
check_dpkg git
check_dpkg wget
check_dpkg unzip
check_dpkg fontconfig
check_dpkg curl
check_dpkg libfuse2t64 "paquet apt libfuse2t64 (FUSE2 — ex-libfuse2, requis sur 26.04)"
check_cmd stow
check_cmd git
check_cmd curl

# --- 2. apt-packages -------------------------------------------------------

header "Module apt-packages"
check_dpkg wireguard
check_dpkg net-tools
check_dpkg git-flow
check_cmd wg "WireGuard (wg)"

# --- 3. certs (real file + system trust store, NOT a symlink) --------------

header "Module certs"
CERT_USER="$HOME/.certs/root-ca.crt"
CERT_SYS="/usr/local/share/ca-certificates/root-ca.crt"
check_file "$CERT_USER" "Certificat utilisateur"
if [ -f "$CERT_USER" ]; then
    perms="$(stat -c '%a' "$CERT_USER" 2>/dev/null)"
    [ "$perms" = "644" ] && pass "Permissions du certificat (644)" || warn "Permissions du certificat = $perms (attendu 644)"
    if have openssl && openssl x509 -in "$CERT_USER" -noout >/dev/null 2>&1; then
        pass "Format X.509 du certificat valide"
    else
        warn "Impossible de valider le format X.509 (openssl absent ou certificat invalide)"
    fi
fi
check_file "$CERT_SYS" "Certificat dans le trust store système"
if [ -d /etc/ssl/certs ] && ls /etc/ssl/certs 2>/dev/null | grep -qi root-ca; then
    pass "Certificat présent dans /etc/ssl/certs (update-ca-certificates)"
else
    warn "root-ca introuvable dans /etc/ssl/certs — relancer 'sudo update-ca-certificates' ?"
fi

# --- 4. zsh ----------------------------------------------------------------

header "Module zsh"
check_dpkg zsh
check_cmd zsh
[ -d "$HOME/.oh-my-zsh" ] && pass "Oh My Zsh (~/.oh-my-zsh)" || fail "Oh My Zsh absent (~/.oh-my-zsh)"
[ -f "$HOME/.oh-my-zsh/custom/themes/catppuccin.zsh-theme" ] \
    && pass "Thème Catppuccin Oh My Zsh" || fail "Thème Catppuccin absent"
for plugin in zsh-autosuggestions zsh-syntax-highlighting zsh-z zsh-history-substring-search zsh-dirhistory; do
    [ -d "$HOME/.oh-my-zsh/custom/plugins/$plugin" ] \
        && pass "Plugin zsh: $plugin" || fail "Plugin zsh manquant: $plugin"
done
if have fzf || [ -x "$HOME/.fzf/bin/fzf" ]; then pass "fzf installé"; else fail "fzf absent"; fi
if fc-list 2>/dev/null | grep -qi "Hack Nerd Font"; then pass "Police Hack Nerd Font installée"
else warn "Hack Nerd Font introuvable (fc-list)"; fi
check_stow "$HOME/.zshrc" "Configuration .zshrc"
login_shell="$(getent passwd "$(id -un)" | cut -d: -f7)"
case "$login_shell" in
    */zsh) pass "Shell de connexion = zsh ($login_shell)" ;;
    *)     warn "Shell de connexion = ${login_shell:-inconnu} (attendu zsh — reconnexion requise ?)" ;;
esac

# --- 5. hyfetch ------------------------------------------------------------

header "Module hyfetch"
check_cmd hyfetch
check_stow "$HOME/.config/hyfetch.json" "Configuration hyfetch.json"
check_stow "$HOME/.config/neowofetch/config.conf" "Configuration neowofetch"

# --- 6. snap-config --------------------------------------------------------

header "Module snap-config"
check_service snapd.socket "snapd.socket"
for s in brave spotify signal-desktop zoom-client htop onlyoffice-desktopeditors \
         freelens intellij-idea-ultimate datagrip bruno postman xmind glpi-agent; do
    check_snap "$s"
done
if have glpi-agent || snap list glpi-agent >/dev/null 2>&1; then
    info "GLPI agent installé — vérifier la conf serveur: snap get glpi-agent server"
fi

# --- 7. flatpak-config -----------------------------------------------------

header "Module flatpak-config"
check_dpkg flatpak
check_cmd flatpak
if have flatpak; then
    if flatpak remotes --columns=name 2>/dev/null | grep -qw flathub; then
        pass "Remote Flathub configuré"
    else
        fail "Remote Flathub absent"
    fi
    if flatpak info --system com.github.IsmaelMartinez.teams_for_linux >/dev/null 2>&1; then
        pass "Teams for Linux (Flatpak) installé"
    else
        fail "Teams for Linux (Flatpak) absent"
    fi
fi

# --- 8. vim / neovim -------------------------------------------------------

header "Module vim (neovim)"
check_dpkg neovim
check_cmd nvim "Neovim"
check_cmd rg "ripgrep (rg)"
check_cmd fdfind "fd-find (fdfind)"
check_stow "$HOME/.config/nvim/init.lua" "Configuration Neovim (init.lua)"

# --- 9. kitty --------------------------------------------------------------

header "Module kitty"
# Kitty vient de l'installeur binaire amont (~/.local/kitty.app), pas d'apt :
# le module installe/met à jour toujours la dernière version publiée.
if [ -x "$HOME/.local/kitty.app/bin/kitty" ]; then
    pass "Kitty amont installé (~/.local/kitty.app)"
    KITTY_LOCAL_VERSION="$("$HOME/.local/kitty.app/bin/kitty" --version 2>/dev/null | awk 'NR==1 {print $2}')"
    KITTY_LATEST_VERSION="$(curl -fsSL --max-time 10 https://sw.kovidgoyal.net/kitty/current-version.txt 2>/dev/null | tr -d '[:space:]')"
    if [ -z "$KITTY_LATEST_VERSION" ]; then
        info "Version amont non vérifiable (réseau) — version locale: ${KITTY_LOCAL_VERSION:-inconnue}"
    elif [ "$KITTY_LOCAL_VERSION" = "$KITTY_LATEST_VERSION" ]; then
        pass "Kitty à jour ($KITTY_LOCAL_VERSION)"
    else
        warn "Kitty ${KITTY_LOCAL_VERSION:-inconnue} < dernière version $KITTY_LATEST_VERSION — relancer kitty/install.sh"
    fi
else
    fail "Kitty amont absent — ~/.local/kitty.app/bin/kitty introuvable"
fi
check_cmd kitty
check_file "$HOME/.local/share/applications/kitty.desktop" "Entrée de bureau Kitty"
if dpkg-query -W -f='${Status}' kitty 2>/dev/null | grep -q "install ok installed"; then
    warn "Paquet apt 'kitty' encore installé (version obsolète) — sudo apt-get remove -y kitty"
fi
check_stow "$HOME/.config/kitty/kitty.conf" "Configuration Kitty"

# --- 10. kubectl -----------------------------------------------------------

header "Module kubectl"
check_cmd kubectl
if have kubelogin || [ -x "$HOME/.local/bin/kubelogin" ]; then pass "kubelogin installé"
else fail "kubelogin absent (PATH ou ~/.local/bin)"; fi
check_stow "$HOME/.config/kubectl/config.zsh" "Configuration kubectl (config.zsh)"
[ -f "$HOME/.config/kubectl/completion.zsh" ] && pass "Complétion kubectl générée" || warn "Complétion kubectl absente (~/.config/kubectl/completion.zsh)"
check_stow "$HOME/.kube/config" "Kubeconfig (~/.kube/config)"

# --- 11. github-cli --------------------------------------------------------

header "Module github-cli"
check_dpkg gh "paquet apt gh (GitHub CLI)"
check_cmd gh "GitHub CLI (gh)"
[ -f /etc/apt/sources.list.d/github-cli.list ] && pass "Dépôt apt GitHub CLI configuré" || warn "Dépôt apt GitHub CLI absent"
check_stow "$HOME/.config/gh/config.yml" "Configuration gh"

# --- 12. slack -------------------------------------------------------------

header "Module slack"
check_dpkg slack-desktop "paquet slack-desktop"
check_cmd slack

# --- 13. docker ------------------------------------------------------------

header "Module docker"
for p in docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin; do
    check_dpkg "$p"
done
check_cmd docker
if have docker; then
    docker compose version >/dev/null 2>&1 && pass "Plugin docker compose fonctionnel" || warn "Plugin docker compose indisponible"
fi
check_service docker "service docker"
[ -f /etc/apt/sources.list.d/docker.list ] && pass "Dépôt apt Docker configuré" || warn "Dépôt apt Docker absent"
if grep -rq "resolute" /etc/apt/sources.list.d/docker.list 2>/dev/null; then
    info "Dépôt Docker sur le codename 'resolute' (26.04) — si vide, basculer sur 'noble'"
fi
check_stow "$HOME/.docker/config.json" "Configuration Docker (config.json)"
groups | grep -qw docker && pass "Utilisateur dans le groupe docker" || warn "Utilisateur hors du groupe docker (sudo usermod -aG docker \$USER, puis reconnexion)"

# --- 14. nvm / node --------------------------------------------------------

header "Module nvm"
NVM_SH="$HOME/.nvm/nvm.sh"
[ -n "${XDG_CONFIG_HOME:-}" ] && [ -s "$XDG_CONFIG_HOME/nvm/nvm.sh" ] && NVM_SH="$XDG_CONFIG_HOME/nvm/nvm.sh"
if [ -s "$NVM_SH" ]; then
    pass "nvm installé ($NVM_SH)"
    node_v="$( . "$NVM_SH" >/dev/null 2>&1; nvm use default >/dev/null 2>&1; node --version 2>/dev/null )"
    if [ -n "$node_v" ]; then pass "Node.js $node_v (via nvm default)"; else fail "Node.js introuvable via nvm"; fi
else
    fail "nvm absent ($NVM_SH)"
fi
check_stow "$HOME/.npmrc" "Configuration .npmrc"

# --- 15. gitlab-cli (glab via snap sur Ubuntu) -----------------------------

header "Module gitlab-cli"
check_snap glab "snap glab (GitLab CLI)"
check_cmd glab "GitLab CLI (glab)"
check_stow "$HOME/.config/glab/config.yml" "Configuration glab"

# --- 16. claude-code -------------------------------------------------------

header "Module claude-code"
# Claude Code est installé par l'installeur officiel Anthropic dans ~/.local/bin,
# aucune configuration n'est gérée par stow (état dans ~/.claude).
if have claude; then
    pass "Claude Code (commande 'claude' présente)"
    CLAUDE_VERSION="$(claude --version 2>/dev/null | awk 'NR==1 {print $1}')"
    [ -n "$CLAUDE_VERSION" ] && info "Version Claude Code: $CLAUDE_VERSION"
elif [ -x "$HOME/.local/bin/claude" ]; then
    warn "Claude Code installé (~/.local/bin/claude) mais absent du PATH — relancer le shell"
else
    fail "Claude Code absent — relancer claude-code/install.sh"
fi
[ -d "$HOME/.claude" ] && pass "Répertoire de données Claude Code (~/.claude)" \
    || warn "Aucun ~/.claude — lancer 'claude' une fois pour terminer la configuration"

# --- 17. Secrets / placeholders à compléter --------------------------------

header "Secrets à compléter (rappel)"
ph_warn_start=$WARN
check_placeholder "$HOME/.npmrc" "YOUR_JWT_TOKEN" "JFrog npm (.npmrc)"
check_placeholder "$HOME/.npmrc" "YOUR_BASE64_ENCODED_CREDENTIALS" "JFrog npm (.npmrc)"
check_placeholder "$HOME/.npmrc" "your.email@itsf.io" "JFrog npm (.npmrc)"
check_placeholder "$HOME/.docker/config.json" "token from jfrog" "JFrog Docker (config.json)"
[ "$WARN" -eq "$ph_warn_start" ] && info "Aucun placeholder de secret détecté"

# --- Summary ---------------------------------------------------------------

header "Résumé"
echo -e "${GREEN}Réussis : $PASS${BASE}   ${YELLOW}Avertissements : $WARN${BASE}   ${RED}Échecs : $FAIL${BASE}"
if [ "$FAIL" -gt 0 ]; then
    echo -e "${RED}[✗] Des composants manquent ou sont mal installés — voir les lignes [✗] ci-dessus.${BASE}"
    exit 1
fi
echo -e "${GREEN}[✓] Tous les composants critiques sont installés.${BASE}"
[ "$WARN" -gt 0 ] && echo -e "${YELLOW}[!] Quelques avertissements à revoir (police, secrets, reconnexion…).${BASE}"
exit 0
