# Script Start
# This script will check if the device is a RouterBOARD and if the firmware is up to date.
# If the firmware is not up to date, it will upgrade the firmware and reboot the device.
# If the firmware is up to date, it will check if there are any critical package updates available.
# If there are critical package updates available, it will download the updates and reboot the device.
# If there are no critical package updates available, it will log an info message.

:global version2arr do={
    :local ver [:tostr $1]
    :local pos 0
    :local major "" ; :local minor ""; :local patch ""
    :set pos   [:find $ver "." -1]
    :set major [:pick $ver 0 $pos]
    :set ver   [:pick $ver ($pos + 1) [:len $ver]]
    :if ([:typeof [:find $ver "." -1]] != "nil") do={
        :set pos   [:find $ver "." -1]
        :set minor [:pick $ver 0 $pos]
        :set ver   [:pick $ver ($pos + 1) [:len $ver]]
    }
    :if ([:typeof [:find $ver " " -1]] != "nil") do={
        :set pos [:find $ver " " -1]
        :if ($minor = "") do={
            :set minor [:pick $ver 0 $pos]
        } else={
            :set patch [:pick $ver 0 $pos]
        }
        :set ver [:pick $ver ($pos + 1) [:len $ver]]
    }
    :if ($ver ~ "^ ") do={
        :set patch [:pick $ver 1 [:len $ver]]
    } else={
        :set patch $ver
    }
    :return ($major,$minor,$patch)
}

:local minimumPatch 2

/log info "AutoUpdate: Starting AutoUpgradeFirmware script..."

# Boot-up Delay
:delay 30

:local architectureName [/system resource get architecture-name]

:if ($architectureName != "x86_64") do={
    :local currentFirmware [/system routerboard get current-firmware]
    :local upgradeFirmware [/system routerboard get upgrade-firmware]
    
    :if ($currentFirmware != $upgradeFirmware) do={
        /log info "AutoUpdate: Firmware upgrade available. Upgrading firmware..."
        /system routerboard upgrade
        :delay 30
        /log info "AutoUpdate: Rebooting device to apply firmware upgrade..."
        /system reboot
    } else={
        /log info "AutoUpdate: Firmware is up to date."
    }
} else={
    /log info "AutoUpdate: This device is not a RouterBOARD. Skipping firmware check."
}

/log info "AutoUpdate: Checking for update..."
/system package update check-for-updates
:delay 15
:local installedVersion [/system package get value-name=version [find where name="routeros"]]
:local latestVersion [/system package update get value-name=latest-version]

:if ([:len $installedVersion] > 0 && [:len $latestVersion] > 0) do={ 

    :if ($installedVersion != $latestVersion) do={
        :local installedVerParts [$version2arr $installedVersion]
        :local latestVerParts [$version2arr $latestVersion]

        :if ([:len $installedVerParts] >= 3 && [:len $latestVerParts] >= 3) do={
            :local installedMajor [:pick $installedVerParts 0]
            :local installedMinor [:pick $installedVerParts 1]
            :local installedPatch [:pick $installedVerParts 2]

            :local latestMajor [:pick $latestVerParts 0]
            :local latestMinor [:pick $latestVerParts 1]
            :local latestPatch [:pick $latestVerParts 2]
            
            :if ($latestPatch >= $minimumPatch && $latestMinor >= $installedMinor) do={
                /log info "AutoUpdate: Critical package updates available. Downloading updates..."
                /system package update install
                :delay 3
                /log info "AutoUpdate: Installing and Rebooting device to apply updates..."
            } else={
                /log info "AutoUpdate: No critical package updates available. Patch number is less than $minimumPatch."
            }
        } else={
            /log info "AutoUpdate: Failed to check for updates. Cannot parse version information."
        }
    } else={
        /log info "AutoUpdate: No updates available."

    }
} else={
    /log info "AutoUpdate: Failed to check for updates. Cannot read version information."
}
