**MAC MDM Evasion Utility**  
**Version: 1.8**  
**Author: Darknessownsu

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
   enrollment
   ```

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

## **Author**
This utility was created by **Darknessownsu**  
Enhanced and patched for Watchdog-Class deployment

> Version 1.8 is not just a utility — it’s a weapon. Use with precision.