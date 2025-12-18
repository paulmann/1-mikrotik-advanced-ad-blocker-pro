# ================================================
# 1: MikroTik Advanced AD Blocker Pro - System Updater
# ================================================
# Repository: https://github.com/paulmann/1-mikrotik-advanced-ad-blocker-pro
# Author: Mikhail Deynekin [Deynekin.RU]
# Version: 5.0.0
# Date: 2025-12-18
# License: MIT
#
# DESCRIPTION:
# Complete system updater with version checking and safe updates.
# ================================================

:local mainURL "https://raw.githubusercontent.com/paulmann/1-mikrotik-advanced-ad-blocker-pro/main/block_ads_import.rsc"
:local tempFile "block_ads_import_temp.rsc"
:local currentVersion "5.0.0"
:local backupFile "system_backup_$[/system clock get date]"
:local githubBaseURL "https://github.com/paulmann/1-mikrotik-advanced-ad-blocker-pro"

:log warning "=== STARTING COMPLETE AD BLOCKER SYSTEM UPDATE ==="
:log info "Current system version: $currentVersion"

# 1. Create system backup
:log info "Creating system backup: $backupFile"
/system backup save name="$backupFile" dont-encrypt=yes

# 2. Download latest system
:log info "Downloading latest system from GitHub..."
/tool fetch url="$mainURL" dst-path="$tempFile" as-value

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
        :log info "New system version detected: $newVersion"
        
        # Import new system
        /import file-name=$tempFile
        /file remove $tempFile
        /system configuration save
        
        :log warning "=== SYSTEM UPDATE COMPLETED ==="
        :put "======================================================"
        :put "AD BLOCKER PRO - SYSTEM UPDATE REPORT"
        :put "======================================================"
        :put "Previous version: $currentVersion"
        :put "New version: $newVersion"
        :put "✓ Backup created: $backupFile"
        :put "======================================================"
        
    } else={
        :log info "System is already up-to-date (v$currentVersion)"
        /file remove $tempFile
        
        :put "======================================================"
        :put "AD BLOCKER PRO - SYSTEM STATUS"
        :put "======================================================"
        :put "Current version: $currentVersion"
        :put "Status: Already up-to-date"
        :put "======================================================"
    }
} else={
    :log error "Failed to download system update"
    :put "ERROR: Unable to download update from GitHub"
}

# Create update scheduler if missing
:if ([/system scheduler find name="adblocker_system_update"] = "") do={
    /system scheduler add name="adblocker_system_update" interval=14d \
        start-time="05:00:00" on-event=":delay 60s; :log info \"Starting scheduled update\"; /import file-name=block_ads_update_import_rules.rsc" \
        comment="Bi-weekly AD Blocker system update"
    :log info "Created automatic system update scheduler"
}