#!/usr/bin/env bash

set -euo pipefail

RUN_USER_HOME="${SUDO_USER:+$(getent passwd "$SUDO_USER" | cut -d: -f6)}"
OUTPUT_DIR="$(pwd)/log-diag-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUTPUT_DIR"
LOG="$OUTPUT_DIR/report.txt"

sep() { echo -e "\n========== $1 ==========\n" | tee -a "$LOG"; }
run() { echo "--- $1 ---" | tee -a "$LOG"; eval "$2" 2>&1 | tee -a "$LOG" || true; echo | tee -a "$LOG"; }
run_boot() {
    local label="$1"
    local boot="$2"
    local cmd="$3"
    echo "--- $label [boot $boot] ---" | tee -a "$LOG"
    eval "$cmd" 2>&1 | tee -a "$LOG" || echo "(aucun résultat ou boot non disponible)" | tee -a "$LOG"
    echo | tee -a "$LOG"
}

echo "=== Log Diagnostic Report ===" | tee "$LOG"
echo "Date   : $(date)" | tee -a "$LOG"
echo "Host   : $(hostname)" | tee -a "$LOG"
echo "User   : ${SUDO_USER:-$(whoami)}" | tee -a "$LOG"
echo "PWD    : $(pwd)" | tee -a "$LOG"
echo | tee -a "$LOG"

sep "BOOTS DISPONIBLES"
run "Liste des boots" "journalctl --list-boots --no-pager 2>/dev/null"

sep "SYSTEME"
run "OS / Kernel"        "uname -a && lsb_release -a 2>/dev/null || cat /etc/os-release"
run "Modele PC"          "dmidecode -s system-product-name 2>/dev/null || cat /sys/devices/virtual/dmi/id/product_name 2>/dev/null"
run "CPU"                "lscpu | grep -E 'Model name|Architecture|CPU\(s\)|Thread|Socket'"
run "RAM totale"         "free -h"
run "Firmware / BIOS"    "dmidecode -s bios-version 2>/dev/null || echo 'Non disponible'"

for BOOT in -1 0; do
    if [ "$BOOT" = "0" ]; then LABEL="BOOT ACTUEL (boot 0)"; else LABEL="BOOT PRECEDENT (boot -1)"; fi
    sep "$LABEL"
    run_boot "Erreurs critiques"      "$BOOT" "journalctl -b $BOOT --priority=3 --no-pager"
    run_boot "Freeze / Hang / OOM"    "$BOOT" "journalctl -b $BOOT --no-pager | grep -iE 'freeze|hang|killed|oom|segfault|taint|panic|rcu_sched|soft lockup|hard lockup' || echo 'Rien trouve'"
    run_boot "MCE / RAM errors"       "$BOOT" "journalctl -b $BOOT --no-pager | grep -iE 'mce|memory error|edac|corrected' || echo 'Rien trouve'"
    run_boot "fprintd logs"           "$BOOT" "journalctl -b $BOOT -u fprintd --no-pager || echo 'Service fprintd non trouve'"
    run_boot "PAM / unlock / auth"    "$BOOT" "journalctl -b $BOOT --no-pager | grep -iE 'pam|fprintd|fingerprint|gdm|gnome-screensaver|unlock' | tail -40 || echo 'Rien trouve'"
    run_boot "GPU / DRM"              "$BOOT" "journalctl -b $BOOT --no-pager | grep -iE 'drm|gpu|i915|amdgpu|nouveau|xe|timeout|reset|hang' | tail -50 || echo 'Rien trouve'"
    run_boot "GNOME Shell / GDM"      "$BOOT" "journalctl -b $BOOT -u gdm -u gnome-shell --no-pager | tail -60 || echo 'Rien trouve'"
    run_boot "Wayland / Mutter"       "$BOOT" "journalctl -b $BOOT --no-pager | grep -iE 'mutter|wayland|compositor' | tail -30 || echo 'Rien trouve'"
    run_boot "Thermal / throttling"   "$BOOT" "journalctl -b $BOOT --no-pager | grep -iE 'thermal|temperature|overheat|throttl|critical trip' | tail -20 || echo 'Rien trouve'"
    run_boot "IO / NVMe errors"       "$BOOT" "journalctl -b $BOOT --no-pager | grep -iE 'nvme|sata|ata|io error|blk_update_request' | tail -30 || echo 'Rien trouve'"
    run_boot "OOM killer"             "$BOOT" "journalctl -b $BOOT --no-pager | grep -iE 'out of memory|oom.killer|killed process' || echo 'Pas de OOM detecte'"
    run_boot "USB / HID / fingerprint" "$BOOT" "journalctl -b $BOOT --no-pager | grep -iE 'usb|hid|fingerprint reader|goodix|elan|validity' | tail -30 || echo 'Rien trouve'"
done

sep "ETAT ACTUEL DU SYSTEME"
run "Swap"                "swapon --show 2>/dev/null; free -h"
run "Processus lourds"    "ps aux --sort=-%mem | head -15"
run "Kernel logs recents" "dmesg --level=err,crit,warn 2>/dev/null | tail -40"
run "fprintd status"      "systemctl status fprintd --no-pager 2>/dev/null || echo 'Service non trouve'"
run "Modules kernel HID"  "lsmod 2>/dev/null | grep -iE 'hid_sensor|i2c|thunderbolt|mei' || echo 'Rien trouve'"
run "Xorg errors user"    "[ -n \"${RUN_USER_HOME:-}\" ] && grep '(EE)' \"$RUN_USER_HOME/.local/share/xorg/Xorg.0.log\" 2>/dev/null || echo 'Pas de log Xorg user'"