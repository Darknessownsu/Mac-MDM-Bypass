MDM & DEP Bypass Guide for macOS

How to Use This Script

Step 1: Boot into macOS Recovery Mode
	
 1.	Power off the Mac.
	
 2.	Press and hold the power button until you see “Loading startup options.”
	
 3.	Select Options > Continue to enter macOS Recovery Mode.


Step 2: Open Safari and Copy the Script
	
 1.	Open Safari in Recovery Mode by selecting Utilities > Safari.
	
 2.	Navigate to the GitHub repository where the script is hosted.
	
 3.	Click on the script file and then select “Raw” to view the plain text version.
	
 4.	Copy the entire script.


Step 3: Open Terminal and Run the Script
	
 1.	Click Utilities > Terminal in macOS Recovery Mode.
	
 2.	Paste the script into Terminal by pressing Command + V.
	
 3.	Press Enter to execute the script.

What This Script Does
	
 •	Removes MDM profiles
	
 •	Prevents DEP re-enrollment by blocking Apple’s DEP server
	
 •	Disables MDM daemons
	
 •	Removes Jamf and other MDM frameworks
	
 •	Flushes system cache
	
 •	Enables stealth firewall mode
	
 •	Resets NVRAM to clear persistent settings
	
 •	Restarts the Mac automatically


Final Steps After Restart
	
 1.	Set up macOS normally, but do not connect to Wi-Fi until setup is complete.
	
 2.	Open Terminal and verify MDM removal by running: profiles -P.
	
 3.	If no MDM profiles appear, the device is free.
	
 4.	If MDM is still present, repeat the process from Recovery Mode.

Important Notes
	
 •	Running this script before connecting to Wi-Fi prevents DEP from re-enrolling the device.
	
 •	If the Mac still forces MDM enrollment, reset NVRAM using sudo nvram -c.
	
 •	You can also block Apple’s DEP servers manually by adding 127.0.0.1 mdmenrollment.apple.com to the /etc/hosts file.


License

This script is provided for educational purposes only. Use it responsibly.
