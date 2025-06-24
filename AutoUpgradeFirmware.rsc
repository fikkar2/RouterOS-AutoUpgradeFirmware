# Script Start
# This script will check if the device is a RouterBOARD and if the firmware is up to date.
# If the firmware is not up to date, it will upgrade the firmware and reboot the device.
# If the firmware is up to date, it will check if there are any critical package updates available.
# If there are critical package updates available, it will download the updates and reboot the device.
# If there are no critical package updates available, it will log an info message.

:global version2arr do={
    :local ver [:tostr $1]
    :local parts [:toarray ""]
    :local pos 0

    :if ([:len $ver] = 0) do={
        :log warning "version2arr: empty input string"
        :return [:toarray ""]
    }

    :while ([:len $ver] > 0) do={
        :set pos [:find $ver "."]
        :if ($pos = nil) do={
            :set parts ($parts, $ver)
            :set ver ""
        } else={
            :set parts ($parts, [:pick $ver 0 $pos])
            :set ver [:pick $ver ($pos + 1) [:len $ver]]
        }
    }

    :while ([:len $parts] < 3) do={
        :set parts ($parts, "0")
    }

    :return $parts
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
        :delay 15
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

        :if ([:len $installedVerParts] < 3 || [:len $latestVerParts] < 3) do={
        /log warning "AutoUpdate: version2arr returned invalid result"
        :return
        }

        :if ([:len $installedVerParts] >= 3 && [:len $latestVerParts] >= 3) do={
            :local installedMajor [:tonum [:pick $installedVerParts 0]]
            :local installedMinor [:tonum [:pick $installedVerParts 1]]
            :local installedPatch [:tonum [:pick $installedVerParts 2]]

            :local latestMajor [:tonum [:pick $latestVerParts 0]]
            :local latestMinor [:tonum [:pick $latestVerParts 1]]
            :local latestPatch [:tonum [:pick $latestVerParts 2]]
            
            :if ($latestPatch >= $minimumPatch && $latestMinor >= $installedMinor) do={
                /log info "AutoUpdate: Critical package updates available. Downloading updates..."
                /system package update install
                :delay 3
                /log info "AutoUpdate: Installing and Rebooting device to apply updates..."
            } else={
                /log info "AutoUpdate: Latest version has patch number less than $minimumPatch. Skipping update."
            }
        } else={
            /log info "AutoUpdate: Failed to check for updates. Cannot parse version information."
        }
    } else={
        /log info "AutoUpdate: No updates available."

    }
} else={
    /log info "AutoUpdate: Failed to check for updates. Cannot read version information..."
}
