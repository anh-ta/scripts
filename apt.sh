#!/usr/bin/env bash
# Sets up unattended security updates with optional scheduled auto-reboot.
# Usage examples:
#   bash setup-unattended-upgrades.sh
#   bash setup-unattended-upgrades.sh --reboot-time 02:00
#   bash setup-unattended-upgrades.sh --reboot-time 03:30 --no-dry-run
#   bash setup-unattended-upgrades.sh --reboot-now-once   (forces a single reboot at end if needed)
#  curl -fsSL https://raw.githubusercontent.com/<USER>/<REPO>/main/setup-unattended-upgrades.sh | sudo bash

set -euo pipefail

# -------- Defaults --------
REBOOT_TIME=""               # Empty = reboot ASAP after updates
DO_DRY_RUN=0                 # 0 = actually apply updates right away
FORCE_REBOOT_NOW_ONCE=1      # 1 = reboot once at end if needed

# -------- Args parsing ----
while [[ $# -gt 0 ]]; do
  case "$1" in
    --reboot-time)
      REBOOT_TIME="${2:-}"
      shift 2
      ;;
    --no-dry-run)
      DO_DRY_RUN=0
      shift
      ;;
    --reboot-now-once)
      FORCE_REBOOT_NOW_ONCE=1
      shift
      ;;
    -h|--help)
      cat <<EOF
Usage: $(basename "$0") [options]

Options:
  --reboot-time HH:MM   Schedule reboots for a fixed time (default: 02:00).
                        Use "" (empty) to reboot immediately after updates.
  --no-dry-run          Perform a real unattended-upgrades run right away.
  --reboot-now-once     If updates require a reboot, perform one at the end of this script.
  -h, --help            Show this help.

Examples:
  $(basename "$0")
  $(basename "$0") --reboot-time 03:30 --no-dry-run
  $(basename "$0") --reboot-time ""   # reboot ASAP after updates
EOF
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

# -------- Root check -------
if [[ $EUID -ne 0 ]]; then
  echo "Please run as root (e.g., prefix with: sudo bash ...)" >&2
  exit 1
fi

# -------- Env & sanity -----
export DEBIAN_FRONTEND=noninteractive
if ! command -v apt-get >/dev/null 2>&1; then
  echo "This script requires a Debian/Ubuntu-like system with apt." >&2
  exit 1
fi

echo "[*] Updating package lists..."
apt-get update -y

echo "[*] Installing unattended-upgrades..."
apt-get install -y unattended-upgrades

# Ensure periodic APT automation is enabled (daily checks, downloads, installs)
echo "[*] Writing /etc/apt/apt.conf.d/20auto-upgrades ..."
cat >/etc/apt/apt.conf.d/20auto-upgrades <<'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";
EOF

# Configure auto-reboot policy
REBOOT_CONF="/etc/apt/apt.conf.d/51unattended-reboot"
echo "[*] Configuring reboot policy in $REBOOT_CONF ..."
{
  echo 'Unattended-Upgrade::Automatic-Reboot "true";'
  if [[ -n "$REBOOT_TIME" ]]; then
    # Fixed-time reboot (safer for servers)
    echo "Unattended-Upgrade::Automatic-Reboot-Time \"$REBOOT_TIME\";"
  else
    # Empty value = reboot ASAP when required
    # (i.e., do not set a time -> immediate reboot after upgrade if needed)
    :
  fi
} > "$REBOOT_CONF"

# Make sure the automation services are active
# (These are typically enabled by default on Ubuntu/Debian)
echo "[*] Ensuring timers/services are active..."
systemctl enable --now unattended-upgrades.service >/dev/null 2>&1 || true
systemctl enable --now apt-daily.timer apt-daily-upgrade.timer >/dev/null 2>&1 || true

# Show the timers for visibility (not an error if missing on some derivatives)
echo "[i] Current APT timers (if available):"
systemctl list-timers 'apt-daily*' 2>/dev/null || true

# Optional first run: dry-run or real
if [[ "$DO_DRY_RUN" -eq 1 ]]; then
  echo "[*] Performing a dry-run to verify configuration..."
  unattended-upgrades --dry-run --debug || true
else
  echo "[*] Triggering a real unattended-upgrades run..."
  # Start the upgrade unit if present; otherwise call the binary directly
  if systemctl list-unit-files | grep -q '^unattended-upgrades\.service'; then
    systemctl start unattended-upgrades.service || true
  fi
  unattended-upgrades --debug || true
fi

# If requested, reboot once at the end if updates require it
if [[ "$FORCE_REBOOT_NOW_ONCE" -eq 1 ]]; then
  NEED_REBOOT=0
  if [[ -f /var/run/reboot-required ]] || [[ -f /run/reboot-required ]]; then
    NEED_REBOOT=1
  fi
  if [[ "$NEED_REBOOT" -eq 1 ]]; then
    echo "[*] System reports a reboot is required."
    echo "[*] Rebooting now (because --reboot-now-once was provided)..."
    reboot
  else
    echo "[i] No reboot required right now."
  fi
fi

echo
echo "✅ Done. Daily security updates are enabled."
if [[ -n "$REBOOT_TIME" ]]; then
  echo "   If a reboot is needed, it will occur daily at ${REBOOT_TIME}."
else
  echo "   If a reboot is needed, it will occur immediately after updates."
fi
echo "   Logs: /var/log/unattended-upgrades/"
