How to Use This Script
	1.	Boot into macOS Recovery Mode on an M1 Mac:
	•	Power off the Mac.
	•	Press and hold the power button until you see “Loading startup options.”
	•	Select Options > Continue to enter macOS Recovery Mode.
	2.	Open Safari and Copy This Script
	•	Open Safari in Recovery Mode (Utilities > Safari).
	•	Copy the entire script from your GitHub or this page.
	3.	Open Terminal in Recovery Mode
	•	Click Utilities > Terminal.
	•	Paste the script into Terminal (Command + V).
	•	Press Enter to execute.

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
	2.	Open Terminal and verify MDM is gone:

profiles -P

	•	If no MDM profiles appear, the device is free.
	•	If anything remains, repeat the process from Recovery Mode.

This ensures MDM and DEP are fully bypassed on a freshly wiped macOS device. Let me know if you need any modifications.
