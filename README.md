**MAC MDM Evasion Utility**  
**Version: 1.7**  
**Author: Darknessownsu**  

## **Overview**
The **MAC MDM Evasion Utility** is a menu-driven system tool designed for managing macOS enrollment, configuration profiles, and system volume states.  

It provides a simple, interactive interface that allows administrators to:  
- Remove or bypass MDM profiles  
- Block DEP (Device Enrollment Program) endpoints  
- Restore systems to stock compliance  
- View shadow logs of actions  
- Securely wipe traces  

The utility is designed to appear and operate like a standard macOS configuration manager.  

**Features**
1. **Run Evasion**  
   - Disables SIP (System Integrity Protection) and authenticated root.  
   - Mounts root volume writable.  
   - Blocks Apple DEP endpoints.  
   - Removes detected MDM profiles.  
   - Terminates and removes Jamf or similar MDM daemons.  
   - Clears unified logs, enables firewall stealth mode, resets NVRAM.  
   - Installs a bypass enrollment profile.  
   - Creates a new sealed snapshot for persistence.  

2. **Run Reversion**  
   - Removes any installed bypass profiles.  
   - Restores original `/etc/hosts` from backup.  
   - Re-enables SIP and authenticated root.  
   - Creates a fresh sealed snapshot to lock in restored state.  

3. **Shadow Log Info**  
   - Displays location of encrypted shadow log:  
     /var/db/.shadow/mdm.log.enc  
   - Provides command to decrypt using OpenSSL and the session key.  

4. **Self-Destruct / Wipe Traces**  
   - Deletes shadow logs.  
   - Removes all `/etc/hosts` backups.  
   - Clears shell history.  

5. **About This Utility**  
   - Displays name, version, author, and build information in a clean Apple-like “About” panel.  

**Installation**
1. Save the script as:  
   enrollment_manager.sh  

2. Make executable and install:  
   sudo cp enrollment_manager.sh /usr/local/bin/enrollment  
   sudo chmod +x /usr/local/bin/enrollment  

3. Launch with:  
   enrollment  

**Usage**
On launch, the utility will display a numbered menu:  

=================================================  
        MAC MDM Evasion Utility  
        Version 1.7  
        Author: Darknessownsu  
-------------------------------------------------  
 Manage enrollment and configuration profiles  
 on your Mac with a secure, menu-driven utility.  
-------------------------------------------------  

Choose an option:  
  1. Run Evasion  
  2. Run Reversion  
  3. Shadow Log Info  
  4. Self-Destruct / Wipe Traces  
  5. Exit  
  6. About This Utility  

Select the desired operation by entering its number.  

**Shadow Logging**
- All actions are echoed both to screen and into an encrypted shadow log.  
- Log location: `/var/db/.shadow/mdm.log.enc`  
- Decrypt command:  
  openssl enc -aes-256-cbc -d -a -in /var/db/.shadow/mdm.log.enc -pass pass:<SESSION_KEY>  

**Author**
This utility is developed and maintained by:  
**Darknessownsu**  

Version 1.7 introduces:  
- About panel option  
- Streamlined Apple-style branding  
- Expanded daemon detection  
