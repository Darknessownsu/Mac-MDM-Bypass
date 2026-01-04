**MAC MDM Evasion Utility**  
**Version: 1.8**  
**Author: Darknessownsu**

---

## **⚠️ IMPORTANT LEGAL WARNING**

This utility is provided **for educational purposes only**. Bypassing MDM or DEP on a device you do not own or have explicit permission to modify may violate:
- Local, state, and federal laws
- Corporate policies and employment agreements  
- Educational institution policies
- Terms of service agreements

**The user assumes full responsibility for their actions.** The author is not liable for any misuse, damage, or legal consequences resulting from the use of this software.

---

## **Overview**
The **MAC MDM Evasion Utility** is a secure, menu-driven system tool designed for managing macOS MDM enrollment, configuration profiles, and system integrity states.  

Built to mimic a legitimate Apple configuration tool, it provides powerful admin-level functions for:  
- Evading or removing MDM profiles  
- Blocking DEP (Device Enrollment Program) endpoints  
- Obfuscating iCloud/Find My tracking  
- Detecting and purging MDM daemons (Jamf, etc.)  
- Auto-repairing bypass profile installs  
- Enforcing stealth logging and secure trace wiping  
- Reverting systems to compliance  

---

## **New in v1.8 — Watchdog-Class Enhancements**
-  **Self-Healing LaunchAgent**: Reinstalls bypass profile every 5 minutes if removed.
-  **Daemon Watchdog LaunchDaemon**: Kills MDM/Jamf daemons that reappear after reboot.
-  **iCloud/FindMy Obfuscation**: Wipes NVRAM variables related to iCloud tracking.
-  **Expanded log encryption**: AES-256 with session-bound key generation.
-  **Sealed snapshot creation** after all actions for rollback protection.

---

## **Features**
### 1. **Run Evasion**
- Disables SIP and authenticated root.
- Mounts system volume as writable.
- Blocks DEP endpoints in `/etc/hosts`.
- Removes active MDM profiles.
- Kills and deletes Jamf/MDM daemons.
- Clears logs, resets NVRAM, activates firewall stealth.
- Installs fake `.mobileconfig` bypass profile.
- Deploys persistent LaunchAgent & Watchdog Daemon.
- Creates APFS snapshot post-operation.

### 2. **Run Reversion**
- Removes bypass profiles and restore `/etc/hosts` from backup.
- Re-enables SIP and root authentication.
- Removes stealth agents/daemons.
- Creates fresh APFS snapshot to lock in restore.

### 3. **Shadow Log Info**
- Encrypted logs stored at `/var/db/.shadow/mdm.log.enc`
- Log decryption example:
  ```
  openssl enc -aes-256-cbc -d -a -in /var/db/.shadow/mdm.log.enc -pass pass:<SESSION_KEY>
  ```

### 4. **Self-Destruct / Wipe Traces**
- Deletes shadow log + host backups.
- Clears shell history.
- Ghosts your tracks.

### 5. **About This Utility**
- Clean "About Panel" styled after legit Apple config apps.
- Shows name, version, author, and patch lineage.

---

## **Prerequisites**

Before using this utility, ensure:
- You have **physical access** to the Mac
- You can boot into **Recovery Mode** (to disable SIP)
- You have **administrator/root privileges**
- You understand the **risks and legal implications**
- You have a **backup** of important data
- The Mac is running **macOS Big Sur (11.x) or newer** up to Sonoma

### Required Steps Before First Use:
1. Reboot into Recovery Mode (⌘+R at startup)
2. Open Terminal from Utilities menu
3. Run: `csrutil disable` to disable System Integrity Protection
4. Run: `csrutil authenticated-root disable` for authenticated root
5. Reboot normally
6. Now you can run this utility

---

## **Installation**
1. Save the script as:
   ```
   MAC_MDM_Evasion_Utility_v1.8.sh
   ```

2. Make it executable and install:
   ```bash
   sudo cp MAC_MDM_Evasion_Utility_v1.8.sh /usr/local/bin/enrollment
   sudo chmod +x /usr/local/bin/enrollment
   ```

3. Launch with:
   ```bash
   sudo enrollment
   ```
   
   **Note:** The utility will automatically check for root privileges and prompt if not running as sudo.

---

## **Script Versions**

This repository contains two versions:
- **MAC_MDM_Evasion.sh** (v1.7) - Basic MDM evasion without watchdog features
- **MAC_MDM_Evasion_Utility_v1.8.sh** (v1.8) - Enhanced with self-healing and watchdog capabilities

Choose v1.8 for persistent protection or v1.7 for a simpler, one-time bypass.

---

## **Usage**
When launched, you’ll see a terminal interface:

```
=================================================
        MAC MDM Evasion Utility
        Version 1.8
        Author: Darknessownsu
-------------------------------------------------
 Manage enrollment and configuration profiles
 on your Mac with a secure, menu-driven utility.
-------------------------------------------------
```

Choose:
1. Run Evasion  
2. Run Reversion  
3. Shadow Log Info  
4. Self-Destruct / Wipe Traces  
5. Exit  
6. About This Utility  

---

## **Encrypted Shadow Logging**
- Logs mirror each printed action, encoded with AES-256.
- Stored at `/var/db/.shadow/mdm.log.enc`.
- Decrypt with session key:
  ```bash
  openssl enc -aes-256-cbc -d -a -in /var/db/.shadow/mdm.log.enc -pass pass:<SESSION_KEY>
  ```

---

## **Testing and Verification**

After running the evasion utility, you can verify it worked:

### Check MDM Status:
```bash
sudo profiles -P  # Should show the bypass profile
sudo profiles status -type enrollment  # Check enrollment status
```

### Check Launch Agents/Daemons (v1.8 only):
```bash
launchctl list | grep -i mdm  # Check for watchdog processes
ls -la /Library/LaunchAgents/com.apple.mdmselfheal.plist
ls -la /Library/LaunchDaemons/com.watchdog.mdm.plist
```

### Check Hosts File:
```bash
cat /etc/hosts | grep -i mdm  # Should show blocked endpoints
```

### Check SIP Status:
```bash
csrutil status  # Should show "disabled"
```

### Verify Shadow Log:
```bash
ls -la /var/db/.shadow/mdm.log.enc  # Check if log exists
```

---

## **Troubleshooting**

### Common Issues:

**"This utility must be run as root"**
- Solution: Run with `sudo` prefix

**"Mount failed"**
- Solution: Ensure you've disabled SIP and authenticated-root in Recovery Mode
- The system volume must be remountable as read-write

**"Operation not permitted"**
- Solution: Check that SIP is disabled: `csrutil status`
- May need to boot into Recovery Mode again

**LaunchAgent/Daemon not loading**
- Solution: Check permissions: `sudo chmod 644 /Library/Launch{Agents,Daemons}/*.plist`
- Verify plist syntax: `plutil -lint /path/to/file.plist`

**Profiles not installing**
- Solution: Check that the profiles command works: `/usr/bin/profiles -P`
- Ensure no existing MDM is blocking profile installation

### If Something Goes Wrong:

1. Boot into Recovery Mode
2. Use Terminal to manually restore `/etc/hosts` from backup:
   ```bash
   cp /Volumes/Macintosh\ HD/etc/hosts.backup.* /Volumes/Macintosh\ HD/etc/hosts
   ```
3. Re-enable SIP if needed:
   ```bash
   csrutil enable
   csrutil authenticated-root enable
   ```

---

## **Security Considerations**

- This utility modifies critical system files and settings
- It disables important security features (SIP, authenticated root)
- Shadow logs contain sensitive operation details
- The encryption key is stored in memory during execution
- Bypass profiles may be detectable by sophisticated MDM systems
- Watchdog daemons run persistently and consume system resources

**Best Practices:**
- Only use on devices you own or have explicit permission to modify
- Keep the encryption key secure if you need to access shadow logs
- Use the reversion function to restore normal operation
- Re-enable SIP after you're done to restore system security

---

## **Author**
This utility was created by **Darknessownsu**  
Enhanced and patched for Watchdog-Class deployment

> Version 1.8 is not just a utility — it’s a weapon. Use with precision.