#!/bin/bash

echo "MDM Evasion Suite initiated, proceed with discretion..."

# Detect and Remove MDM Profile
echo "Detecting MDM presence..."
MDM_PROFILE_ID=$(profiles -P | grep -oE 'uuid:[0-9A-F-]+' | cut -d: -f2 | tr -d ' ' | head -1)

if [ -n "$MDM_PROFILE_ID" ]; then
    echo "MDM Profile detected: $MDM_PROFILE_ID"
    profiles -R -p "$MDM_PROFILE_ID"
    echo "MDM profile purged from existence."
else
    echo "No MDM profile found."
fi

# Block Apple DEP Servers to Prevent Re-Enrollment
echo "Blocking DEP servers..."
echo "127.0.0.1 mdmenrollment.apple.com" | sudo tee -a /etc/hosts
echo "DEP server blocked."

# Disable MDM Daemon
echo "Disabling MDM daemon..."
launchctl unload -w /Library/LaunchDaemons/com.apple.mdmclient.plist
echo "MDM daemon disabled."

# Remove MDM Framework (if Jamf or other MDM exists)
echo "Removing MDM framework..."
jamf removeFramework || echo "Jamf not found, skipping."
echo "MDM framework removal attempted."

# Flush System Cache
echo "Flushing system cache..."
dscacheutil -flushcache && killall -HUP mDNSResponder
echo "Cache cleared."

# Adjust Firewall for Stealth
echo "Adjusting firewall settings..."
/usr/libexec/ApplicationFirewall/socketfilterfw --setloggingmode off
/usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on
echo "Firewall configured for stealth."

# Reset NVRAM to Clear Any Persistent Settings
echo "Resetting NVRAM..."
nvram -c
echo "NVRAM reset complete."

# Verify MDM Removal
echo "Checking MDM status..."
profiles -P

echo "MDM & DEP Bypass Complete. Restarting..."
reboot
