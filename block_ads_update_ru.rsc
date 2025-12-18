# ================================================
# 1: MikroTik Advanced AD Blocker Pro - RU List Updater
# ================================================
# Repository: https://github.com/paulmann/1-mikrotik-advanced-ad-blocker-pro
# Author: Mikhail Deynekin [Deynekin.RU]
# Version: 5.0.0
# Date: 2025-12-18
# License: MIT
#
# DESCRIPTION:
# Automatic updater for Russian advertisement domain lists.
# ================================================

:local remoteURL "https://raw.githubusercontent.com/paulmann/1-mikrotik-advanced-ad-blocker-pro/main/block_ads_ru.rsc"
:local tempFile "block_ads_ru_temp.rsc"
:local currentVersion "5.0.0"
:local markerComment "RU_Ad_Domain_v5"
:local addressListName "AD_Blocker_Domains"

:log info "Starting Russian domain list update check..."

# Create backup
:local backupName "ru_list_backup_$[/system clock get date]"
/system backup save name="$backupName" dont-encrypt=yes
:log info "Created backup: $backupName"

# Download latest list
:log info "Downloading latest Russian domain list..."
/tool fetch url="$remoteURL" dst-path="$tempFile" as-value

:if ([:len [/file find name="$tempFile"]] > 0) do={
    # Extract version
    :local fileContent [/file get $tempFile contents]
    :local newVersion ""
    :local versionMatch [:find $fileContent "Version: "]
    
    :if ($versionMatch >= 0) do={
        :local startPos ($versionMatch + 9)
        :local endPos [:find $fileContent "\n" start=$startPos]
        :if ($endPos = -1) do={ :set endPos [:len $fileContent] }
        :set newVersion [:pick $fileContent $startPos $endPos]
    }
    
    :if ($newVersion != "" && $newVersion != $currentVersion) do={
        :log info "New version detected: $newVersion (current: $currentVersion)"
        
        :local currentCount [/ip firewall address-list find list="$addressListName" comment~"$markerComment"]
        /import file-name=$tempFile
        :local newCount [/ip firewall address-list find list="$addressListName" comment~"$markerComment"]
        :local addedDomains ($[:len $newCount] - $[:len $currentCount])
        
        /file remove $tempFile
        /system configuration save
        
        :log info "Russian list updated: v$currentVersion -> v$newVersion (+$addedDomains)"
        
        :put "======================================================"
        :put "RUSSIAN DOMAIN LIST UPDATE SUCCESSFUL"
        :put "======================================================"
        :put "Previous version: $currentVersion"
        :put "New version: $newVersion"
        :put "Domains added: $addedDomains"
        :put "======================================================"
        
    } else={
        :log info "Russian domain list is already up-to-date (v$currentVersion)"
        /file remove $tempFile
        
        :put "======================================================"
        :put "RUSSIAN DOMAIN LIST STATUS"
        :put "======================================================"
        :put "Current version: $currentVersion"
        :put "Status: Already up-to-date"
        :put "======================================================"
    }
} else={
    :log error "Failed to download updated Russian domain list"
    :put "ERROR: Unable to download list from GitHub"
}

# Create scheduler
:if ([/system scheduler find name="adblocker_update_ru"] = "") do={
    /system scheduler add name="adblocker_update_ru" interval=7d start-time="04:30:00" \
        on-event=":delay 30s; /import file-name=block_ads_update_ru.rsc" \
        comment="Weekly update for Russian AD Blocker domains"
    :log info "Created automatic update scheduler"
}