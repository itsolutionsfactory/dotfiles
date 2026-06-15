#!/usr/bin/env bash
#
# Network & Wi-Fi diagnostic script — no extra tools needed
# Usage: chmod +x net_diagnose.sh && ./net_diagnose.sh
#

set -u

########################
# CONFIGURABLE TARGETS #
########################
TARGET_LAN_IP="172.25.3.240"
TARGET_DNS_IP="1.1.1.1"
TARGET_WAN_IP="8.8.8.8"
TARGET_WEBSITE="https://www.google.com"

# Multiple fallback URLs for speed test (tried in order)
SPEEDTEST_URLS=(
  "http://speedtest.tele2.net/10MB.zip"
  "http://proof.ovh.net/files/10Mb.dat"
  "http://ipv4.download.thinkbroadband.com/10MB.zip"
)

#####################
# REPORT INITIALIZE #
#####################
HOSTNAME="$(hostname 2>/dev/null || echo unknown-host)"
DATE_STR="$(date '+%Y-%m-%d_%H-%M-%S' 2>/dev/null || echo unknown-date)"
REPORT_FILE="net_diagnose_${HOSTNAME}_${DATE_STR}.log"

exec > >(tee -a "$REPORT_FILE") 2>&1

echo "==========================================="
echo " Network & Wi-Fi Diagnostic Report"
echo " Host:    $HOSTNAME"
echo " Date:    $(date)"
echo "==========================================="
echo

#####################
# HELPER FUNCTIONS  #
#####################
has_cmd() { command -v "$1" >/dev/null 2>&1; }

section() {
  echo
  echo "--------------------------------------------------"
  echo "$1"
  echo "--------------------------------------------------"
}

run_cmd() {
  local desc="$1"; shift
  echo
  echo ">>> $desc"
  echo "\$ $*"
  "$@" 2>&1 || echo "[WARN] Command returned non-zero: $*"
}

#####################
# 1. SYSTEM INFO    #
#####################
section "1. System information"
has_cmd uname && uname -a
echo "User: $USER"
echo "Date: $(date)"

#####################
# 2. NETWORK CONFIG #
#####################
section "2. Network configuration"

if has_cmd ip; then
  run_cmd "IP addresses" ip addr show
  run_cmd "Routing table" ip route show
elif has_cmd ifconfig; then
  run_cmd "IP addresses (ifconfig)" ifconfig -a
fi

#####################
# 3. GATEWAY        #
#####################
section "3. Default gateway detection"

DEFAULT_GW=""
if has_cmd ip; then
  DEFAULT_GW="$(ip route 2>/dev/null | awk '/default/ {print $3; exit}')"
elif has_cmd netstat; then
  DEFAULT_GW="$(netstat -rn 2>/dev/null | awk '/^0\.0\.0\.0/ {print $2; exit}')"
fi

if [ -n "$DEFAULT_GW" ]; then
  echo "Detected default gateway: $DEFAULT_GW"
else
  echo "[WARN] Could not detect default gateway automatically."
fi

#######################
# 4. WIFI / INTERFACE #
#######################
section "4. Interface & Wi-Fi information"

OS_TYPE="$(uname -s 2>/dev/null || echo Unknown)"

case "$OS_TYPE" in
  Linux)
    # Active interface toward internet
    if has_cmd ip; then
      echo; echo "Active interface for 1.1.1.1:"
      ip route get 1.1.1.1 2>/dev/null
    fi

    # Detect active wireless interface
    WIFI_IFACE=""
    if has_cmd iw; then
      WIFI_IFACE="$(iw dev 2>/dev/null | awk '/Interface/ {print $2; exit}')"
    fi
    if [ -z "$WIFI_IFACE" ] && has_cmd iwconfig; then
      WIFI_IFACE="$(iwconfig 2>/dev/null | awk 'NR==1 {print $1}')"
    fi
    # Also try via /proc
    if [ -z "$WIFI_IFACE" ]; then
      for iface in /proc/net/wireless; do
        [ -f "$iface" ] && WIFI_IFACE="$(awk 'NR==3 {gsub(/:/, ""); print $1}' "$iface")"
      done
    fi
    echo; echo "Wi-Fi interface detected: ${WIFI_IFACE:-none found}"

    # nmcli (best info if available)
    if has_cmd nmcli; then
      run_cmd "nmcli - devices" nmcli device status
      run_cmd "nmcli - active connection" nmcli connection show --active
      run_cmd "nmcli - Wi-Fi link details" nmcli -f all dev wifi list 2>/dev/null | head -20
      if [ -n "$WIFI_IFACE" ]; then
        run_cmd "nmcli - current AP signal" nmcli -f IN-USE,SSID,BSSID,MODE,CHAN,FREQ,RATE,SIGNAL,BARS,SECURITY dev wifi list ifname "$WIFI_IFACE" 2>/dev/null
      fi
    fi

    # iwconfig fallback
    if has_cmd iwconfig; then
      run_cmd "iwconfig (signal/tx/mode)" iwconfig 2>/dev/null
    fi

    # iw detailed stats — TX/RX errors, retries, signal
    if has_cmd iw && [ -n "$WIFI_IFACE" ]; then
      run_cmd "iw dev - link info (RSSI, tx/rx bitrate)" iw dev "$WIFI_IFACE" link 2>/dev/null
      run_cmd "iw dev - station statistics (tx_retries, tx_failed, rx_errors)" iw dev "$WIFI_IFACE" station dump 2>/dev/null
    fi

    # /proc/net/wireless: per-interface real-time counters
    if [ -f /proc/net/wireless ]; then
      echo; echo ">>> /proc/net/wireless (signal, noise, nwid/discarded packets)"
      cat /proc/net/wireless
    fi

    # ethtool for wired adapters (errors)
    if has_cmd ethtool; then
      for iface in $(ip link show 2>/dev/null | awk -F': ' '/^[0-9]+:/{print $2}' | grep -v lo | grep -v '@'); do
        echo; echo ">>> ethtool stats: $iface"
        ethtool -S "$iface" 2>/dev/null | grep -i -E 'error|drop|miss|fail|crc|collision|discard|retry' || echo "  (no relevant errors found)"
      done
    fi
    ;;

  Darwin)
    echo "macOS detected."
    if has_cmd networksetup; then
      run_cmd "Network hardware ports" networksetup -listallhardwareports
      run_cmd "Wi-Fi info" networksetup -getinfo Wi-Fi
    fi
    AIRPORT="/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport"
    if [ -x "$AIRPORT" ]; then
      run_cmd "Airport link details (RSSI, noise, tx rate)" "$AIRPORT" -I
      run_cmd "Airport scan nearby networks" "$AIRPORT" -s
    fi
    ;;
esac

##################
# 5. PING TESTS  #
##################
section "5. Connectivity tests (ping — 20 packets)"

PING_COUNT=20

ping_target() {
  local label="$1" target="$2"
  [ -z "$target" ] && { echo "[SKIP] $label (no target set)"; return; }
  echo; echo "### $label -> $target"
  if has_cmd ping; then
    # Detect Linux vs macOS syntax
    if ping -c 1 -W 1 127.0.0.1 >/dev/null 2>&1; then
      ping -c "$PING_COUNT" -W 2 "$target" 2>&1 || echo "[ERROR] ping to $target failed"
    else
      ping -c "$PING_COUNT" "$target" 2>&1 || echo "[ERROR] ping to $target failed"
    fi
  else
    echo "[WARN] ping command not available"
  fi
}

ping_target "Default gateway" "$DEFAULT_GW"
ping_target "Internal LAN IP (OPNsense)" "$TARGET_LAN_IP"
ping_target "DNS (1.1.1.1)" "$TARGET_DNS_IP"
ping_target "Public IP (8.8.8.8)" "$TARGET_WAN_IP"

##################
# 6. TRACEROUTE  #
##################
section "6. Traceroute"

trace_target() {
  local label="$1" target="$2"
  [ -z "$target" ] && { echo "[SKIP] $label"; return; }
  echo; echo "### $label -> $target"
  if has_cmd traceroute; then
    traceroute -n -m 20 "$target" 2>&1
  elif has_cmd tracert; then
    tracert -d "$target" 2>&1
  else
    echo "[SKIP] no traceroute/tracert found"
  fi
}

trace_target "Traceroute to 8.8.8.8" "$TARGET_WAN_IP"

##################
# 7. HTTP / DNS  #
##################
section "7. HTTP and DNS tests"

if has_cmd curl; then
  run_cmd "HTTP HEAD $TARGET_WEBSITE" curl -sS -I --max-time 10 "$TARGET_WEBSITE"
fi

for dns_tool in getent host nslookup; do
  if has_cmd "$dns_tool"; then
    case "$dns_tool" in
      getent)  run_cmd "DNS via getent" getent hosts www.google.com; break;;
      host)    run_cmd "DNS via host" host www.google.com; break;;
      nslookup)run_cmd "DNS via nslookup" nslookup www.google.com; break;;
    esac
  fi
done

##################
# 8. SPEED TEST  #
##################
section "8. Approximate download speed test"

if ! has_cmd curl; then
  echo "[INFO] curl not available — skipping speed test"
else
  SPEED_OK=0
  for url in "${SPEEDTEST_URLS[@]}"; do
    echo; echo "Trying: $url"
    # -L follows redirects, --max-time hard caps the total time
    RESULT="$(curl -sS -L \
      --connect-timeout 10 \
      --max-time 30 \
      -o /dev/null \
      -w '%{size_download} %{time_total} %{speed_download}' \
      "$url" 2>&1)"
    CURL_RC=$?
    if [ $CURL_RC -eq 0 ]; then
      BYTES="$(echo "$RESULT" | awk '{print $1}')"
      TIME="$(echo  "$RESULT" | awk '{print $2}')"
      SPEED_BPS="$(echo "$RESULT" | awk '{print $3}')"  # bytes/s from curl
      if [ "$BYTES" -gt 0 ] 2>/dev/null; then
        MBITS="$(echo "$BYTES $TIME" | awk '{if ($2>0) printf("%.2f", ($1*8)/($2*1000000)); else print "0"}')"
        echo "Bytes downloaded : $BYTES"
        echo "Total time (s)   : $TIME"
        echo "Approx. speed    : $MBITS Mbit/s"
        SPEED_OK=1
        break
      else
        echo "[WARN] 0 bytes downloaded from $url (rc=$CURL_RC)"
      fi
    else
      echo "[WARN] curl failed on $url (rc=$CURL_RC)"
    fi
  done
  [ $SPEED_OK -eq 0 ] && echo "[ERROR] All speed test URLs failed. Check firewall / proxy / DNS."
fi

##################
# 9. WIFI ERRORS #
##################
section "9. Wi-Fi errors and retransmissions (kernel / driver level)"

case "$OS_TYPE" in
  Linux)
    # dmesg — Wi-Fi driver errors, firmware issues, reconnects
    if has_cmd dmesg; then
      echo; echo ">>> dmesg: Wi-Fi related messages (errors, firmware, assoc, deauth)"
      dmesg 2>/dev/null | grep -i -E \
        'wlan|wlp|mt79|iwlwifi|ath|brcm|rtw|wifi|80211|deauth|disassoc|auth|reassoc|beacon|firmware|error|timeout|hang|reset|failed|disconnect|roam' \
        | tail -80 || echo "[INFO] No relevant dmesg output (may need sudo)"
    fi

    # iw station dump — key wireless counters
    if has_cmd iw && [ -n "${WIFI_IFACE:-}" ]; then
      echo; echo ">>> iw station dump (tx_retries, tx_failed, beacon_loss, rx_errors)"
      iw dev "$WIFI_IFACE" station dump 2>/dev/null | grep -E \
        'tx bytes|rx bytes|tx packets|rx packets|tx retries|tx failed|rx drop|beacon loss|signal|tx bitrate|rx bitrate' \
        || echo "[INFO] no station dump (not associated?)"
    fi

    # /proc/net/wireless — nwid/discard/miss counters
    if [ -f /proc/net/wireless ]; then
      echo; echo ">>> /proc/net/wireless counters (nwid discarded, crypt discarded, misc missed)"
      cat /proc/net/wireless
    fi

    # ip -s link — L2 TX/RX errors on all interfaces
    if has_cmd ip; then
      echo; echo ">>> ip -s link (L2 tx/rx errors, drops)"
      ip -s link 2>/dev/null
    fi

    # journalctl NetworkManager/wpa_supplicant — roam events
    if has_cmd journalctl; then
      echo; echo ">>> journalctl: NetworkManager (last 100 Wi-Fi lines)"
      journalctl -u NetworkManager --no-pager -n 100 2>/dev/null \
        | grep -i -E 'wifi|wlan|80211|ap|bss|roam|deauth|disassoc|connect|disconnect|scan' \
        || echo "[INFO] No relevant NM journal (or access denied)"

      echo; echo ">>> journalctl: wpa_supplicant (last 50 lines)"
      journalctl -u wpa_supplicant --no-pager -n 50 2>/dev/null \
        || echo "[INFO] No wpa_supplicant journal (or access denied)"
    fi
    ;;

  Darwin)
    echo "[INFO] Collect Wi-Fi diagnostics on macOS: Wireless Diagnostics → Window → Wi-Fi Scan / Statistics."
    echo "       Or run: sudo /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I"
    ;;
esac

##################
# 10. SYS LOGS   #
##################
section "10. System logs (general errors)"

case "$OS_TYPE" in
  Linux)
    if has_cmd journalctl; then
      echo; echo ">>> Last 30 system errors (priority err or higher)"
      journalctl -p err --no-pager -n 30 2>/dev/null || true
    fi
    ;;
esac

##################
# 11. SUMMARY    #
##################
section "11. Summary & next steps"

echo "Report includes:"
echo "  1.  System info"
echo "  2.  Network config (IPs, routes)"
echo "  3.  Default gateway"
echo "  4.  Wi-Fi interface details (RSSI, channel, tx/rx rates, driver errors)"
echo "  5.  Ping tests (GW / LAN / DNS / WAN)"
echo "  6.  Traceroute"
echo "  7.  HTTP + DNS"
echo "  8.  Download speed test"
echo "  9.  Wi-Fi errors (dmesg, iw station, /proc/net/wireless, NM journal)"
echo "  10. System logs"
echo
echo "Report saved to: $REPORT_FILE"
echo "Please send this file to IT support for analysis."
echo
echo "End of report — $(date)"
