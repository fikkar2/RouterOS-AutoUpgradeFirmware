# MikroTik AutoUpgrade Script

This MikroTik RouterOS script automates the firmware and RouterOS update process for compatible devices. It checks whether the device is a RouterBOARD, evaluates firmware and package versions, and upgrades/reboots as needed. This helps keep your MikroTik devices updated with minimal manual intervention.

---

## 🧩 Features

- ✅ Detects if the device is a RouterBOARD (e.g., not x86 or CHR)
- 🔄 Upgrades RouterBOARD firmware if outdated
- 📦 Checks for RouterOS package updates
- ⬆️ Installs critical RouterOS patch updates if minimum patch level is met
- 🔁 Automatically reboots when needed
- 🧪 Includes version parsing with safe fallback

---

## ⚙️ Requirements

- MikroTik RouterOS v6.40+
- Scripting and system package access
- Internet access for checking and downloading updates

---

## 📝 How It Works

1. **Firmware Check**
   - Skips if device is not a RouterBOARD (e.g., x86/CHR)
   - Upgrades firmware and reboots if outdated

2. **RouterOS Version Check**
   - Compares current installed version with the latest available version
   - Parses major, minor, and patch numbers using a custom `version2arr` function

3. **Patch Update Logic**
   - Updates are installed only if:
     - Latest patch ≥ defined minimum patch (default: `2`)
     - Latest minor version ≥ installed minor version

4. **Logging**
   - Logs every step to the MikroTik system log for audit and debugging

---

## 🛡️ Safety Features

- Adds default values when parsing incomplete version strings
- Avoids crashes due to invalid or missing version data
- Uses delay between critical steps to ensure system stability

---

## 🔄 How to Schedule It

I recommend you to have 2 scheduler running this script, especially if your RouterOS hardware is not x86_64 or CHR.
One scheduler runs on boot/start and the second one runs periodically (I recommend every 7 days).
This is so that your firmware is also updated after the RouterOS updated (It will reboot twice, one for updating the RouterOS, and the second reboot is for updating the firmware if it is RouterBOARD).

To run this script at boot/start and periodically:

1. Save it as a named script (e.g., `AutoUpgrade`)
2. Add a scheduler entry like this:

```shell
/system scheduler add name=AutoUpgradeOnBoot on-event="/system script run AutoUpgrade" start-time=startup
/system scheduler add name=AutoUpgradeWeekly interval=7d on-event="/system script run AutoUpgrade" start-time=00:00:00
```

---

## 🛠 Configuration

You can tweak the patch update threshold:

```mikrotik
:local minimumPatch 2
```
Based on experience, mikrotik early minor/major version updates (i.e. Patch number 0-1) were historicly sometimes have major/minor bugs.
I recommend to set and wait at least 2 patch before doing minor/major update.
You can increase the value if you want be more sure the latest version is more stable. However, if it is too high and your script might never update your RouterOS especially if mikrotik decides to up their minor/major version before your minimumPatch number is reached.

---

## 📂 Files

- `RouterOS-AutoUpgradeFirmware.rsc`: The script you can import via Winbox, WebFig, or terminal
- `README.md`: This file

---

## 🧪 Disclaimer

Use at your own risk. Always test scripts in a staging or non-critical environment before deploying to production routers.
I am not responsible for any damage causes by this script and I am not representing Mikrotik by any means.

---

## 👨‍💻 Author

Created by: **Muhammad Fikkar Faruqi**  
Date: **September 2025**

Feel free to improve or modify based on your network's needs!
