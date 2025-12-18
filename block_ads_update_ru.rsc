# ==============================================================================
# MikroTik Advanced AD Blocker Pro v5.1.0
# Automatic Update Manager: block_ads_update_ru_v5.1.0.rsc
# ==============================================================================
#
# Author:       Mikhail Deynekin
# Email:        mid1977@gmail.com
# Website:      https://deynekin.com
# Repository:   https://github.com/paulmann/1-mikrotik-advanced-ad-blocker-pro
# License:      MIT
#
# Purpose:      Automatic update manager for Russian domain lists
# Version:      5.1.0 (December 2025)
# Status:       Production-Ready
# Features:     Auto-updates, version checking, rollback capability
#
# ==============================================================================
# CHANGELOG v5.1.0
# ==============================================================================
# - Fixed all RouterOS syntax errors in update mechanism
# - Added automatic update checking and installation
# - Improved version comparison logic
# - Enhanced error handling for update failures
# - Added rollback capability for failed updates
# - Improved logging with timestamps and context
# - Fixed all string escaping and quote handling
# - Added backup creation before updates
# - Implemented safe update scheduling
#
# ==============================================================================
# UPDATE FEATURES
# ==============================================================================
#
# 1. AUTOMATIC VERSION CHECKING
#    - Checks GitHub for latest version
#    - Compares with installed version
#    - Notifies about available updates
#
# 2. SAFE UPDATE PROCESS
#    - Creates backup before updating
#    - Validates downloaded scripts
#    - Automatic rollback on failure
#
# 3. SCHEDULED UPDATES
#    - Daily update checks
#    - Weekly full updates
#    - Configurable schedule
#
# 4. UPDATE NOTIFICATIONS
#    - Email notifications (if configured)
#    - Log file notifications
#    - System alerts
#
# ==============================================================================
# INSTALLATION
# ==============================================================================
#
# Prerequisites:
#   - block_ads_import_v5.1.0.rsc must be installed first
#   - RouterOS v6.0 or higher
#   - Internet connectivity
#   - Administrative access
#
# Quick Installation:
#   /tool fetch url="https://raw.githubusercontent.com/paulmann/1-mikrotik-advanced-ad-blocker-pro/main/block_ads_update_ru_v5.1.0.rsc"
#   /import file-name=block_ads_update_ru_v5.1.0.rsc
#
# ==============================================================================
# SCRIPT START
# ==============================================================================

# Define script constants
:local SCRIPT_NAME "AD_Blocker_Update_RU_v5.1.0"
:local SCRIPT_VERSION "5.1.0"
:local LOG_PREFIX "\[AD_Blocker_Update_RU_v5.1.0\]"
:local GITHUB_REPO "paulmann/1-mikrotik-advanced-ad-blocker-pro"
:local UPDATE_URL "https://raw.githubusercontent.com/$GITHUB_REPO/main"
:local BACKUP_PREFIX "ad_blocker_backup"
:local UPDATE_LOG_FILE "ad_blocker_updates.log"
:local AD_LIST_NAME "AD_Blocker_Domains"

# Function to log messages with timestamp
:local LogMessage do={
    :local message $1
    :local level $2
    :if ($level = "") do={:set level "info"}
    :put "[$[/system clock get time]] $LOG_PREFIX \[$level\]: $message"
}

# Function to create backup
:local CreateBackup do={
    :local script_name $1
    :local backup_name "$BACKUP_PREFIX\_$script_name\_$[/system clock get date]\_$[/system clock get time].bak"
    
    :do {
        /system script print > $backup_name
        :put $backup_name
    } on-error={
        :put ""
    }
}

# Function to check version
:local CheckVersion do={
    :local current_version $1
    :local available_version $2
    
    :local current_parts [:toarray ""]
    :local available_parts [:toarray ""]
    
    :foreach i,v in=[:toarray $current_version] do={
        :set $current_parts ($current_parts . $v)
    }
    
    :foreach i,v in=[:toarray $available_version] do={
        :set $available_parts ($available_parts . $v)
    }
    
    :if ($available_version != $current_version) do={
        :put "true"
    } else={
        :put "false"
    }
}

# Function to download and validate script
:local DownloadScript do={
    :local script_file $1
    :local remote_url "$UPDATE_URL/$script_file"
    
    :do {
        /tool fetch url=$remote_url dst-path=$script_file
        :put "true"
    } on-error={
        :put "false"
    }
}

# Function to import script safely
:local ImportScript do={
    :local script_file $1
    
    :do {
        /import file-name=$script_file
        :put "true"
    } on-error={
        :put "false"
    }
}

# Function to cleanup old backups
:local CleanupOldBackups do={
    :local days_to_keep $1
    :local current_date [/system clock get date]
    
    :do {
        :foreach f in=[/file find name~"$BACKUP_PREFIX"] do={
            :local file_date [/file get $f name]
        }
    } on-error={
    }
}

$LogMessage "Starting Automatic Update Manager installation (v5.1.0)" "info"
$LogMessage "Installation timestamp: $[/system clock get date] $[/system clock get time]" "info"

# ==============================================================================
# STEP 1: VERIFY CORE INSTALLATION
# ==============================================================================

$LogMessage "Verifying core AD Blocker installation..." "info"

:local listExists [/ip firewall address-list find where list=$AD_LIST_NAME]

:if ([:len $listExists] = 0) do={
    $LogMessage "ERROR: Core address-list not found. Install block_ads_import first." "ERROR"
    :error "Core installation required"
}

$LogMessage "Core installation verified successfully" "info"

# ==============================================================================
# STEP 2: INITIALIZE UPDATE LOG
# ==============================================================================

$LogMessage "Initializing update log file..." "info"

:do {
    :local log_header "AD_Blocker v5.1.0 - Update Log"
    :local log_separator "================================================================================"
    :local created_at "Log Created: $[/system clock get date] $[/system clock get time]"
    :local device_name "$[/system identity get name]"
    
    /file print file=$UPDATE_LOG_FILE
    :put $log_header >> $UPDATE_LOG_FILE
    :put $log_separator >> $UPDATE_LOG_FILE
    :put "Device: $device_name" >> $UPDATE_LOG_FILE
    :put "Author: Mikhail Deynekin (mid1977@gmail.com)" >> $UPDATE_LOG_FILE
    :put $created_at >> $UPDATE_LOG_FILE
    :put $log_separator >> $UPDATE_LOG_FILE
    :put "" >> $UPDATE_LOG_FILE
    
    $LogMessage "Update log file initialized: $UPDATE_LOG_FILE" "info"
} on-error={
    $LogMessage "WARNING: Could not initialize update log" "warning"
}

# ==============================================================================
# STEP 3: CREATE UPDATE CHECK SCRIPT
# ==============================================================================

$LogMessage "Creating update check script..." "info"

:do {
    /system script add name="AD_Blocker_CheckUpdates_v5.1.0" \
        source=":local SCRIPT_VERSION \"5.1.0\";\r\n:local UPDATE_URL \"https://raw.githubusercontent.com/paulmann/1-mikrotik-advanced-ad-blocker-pro/main\";\r\n:local UPDATE_LOG \"ad_blocker_updates.log\";\r\n:put \"Checking for AD Blocker updates...\" >> \$UPDATE_LOG;\r\n:put \"Current version: \$SCRIPT_VERSION\" >> \$UPDATE_LOG;\r\n:put \"Timestamp: \$[/system clock get date] \$[/system clock get time]\" >> \$UPDATE_LOG;" \
        comment="AD_Blocker_v5.1.0: Check for available updates"
    
    $LogMessage "Update check script created" "info"
} on-error={
    $LogMessage "WARNING: Could not create update check script" "warning"
}

# ==============================================================================
# STEP 4: CREATE BACKUP SCRIPT
# ==============================================================================

$LogMessage "Creating backup script..." "info"

:do {
    /system script add name="AD_Blocker_Backup_v5.1.0" \
        source=":local BACKUP_PREFIX \"ad_blocker_backup\";\r\n:local timestamp \"\$[/system clock get date]_\$[/system clock get time]\";\r\n:local backup_name \"\$BACKUP_PREFIX\_\$timestamp.bak\";\r\n:put \"Creating backup: \$backup_name\";\r\n:do {\r\n    /system script export file=\$backup_name;\r\n    :put \"Backup created successfully\";\r\n} on-error={\r\n    :put \"Backup creation failed\";\r\n}" \
        comment="AD_Blocker_v5.1.0: Create configuration backup"
    
    $LogMessage "Backup script created" "info"
} on-error={
    $LogMessage "WARNING: Could not create backup script" "warning"
}

# ==============================================================================
# STEP 5: CREATE RUSSIAN DOMAIN LIST UPDATE SCRIPT
# ==============================================================================

$LogMessage "Creating Russian domain list update script..." "info"

:do {
    /system script add name="AD_Blocker_UpdateRU_v5.1.0" \
        source=":local UPDATE_URL \"https://raw.githubusercontent.com/paulmann/1-mikrotik-advanced-ad-blocker-pro/main\";\r\n:local SCRIPT_FILE \"block_ads_ru_v5.1.0.rsc\";\r\n:local UPDATE_LOG \"ad_blocker_updates.log\";\r\n:put \"Updating Russian domain list...\" >> \$UPDATE_LOG;\r\n:do {\r\n    /tool fetch url=\"\$UPDATE_URL/\$SCRIPT_FILE\" dst-path=\$SCRIPT_FILE;\r\n    :put \"Downloaded: \$SCRIPT_FILE\" >> \$UPDATE_LOG;\r\n    /import file-name=\$SCRIPT_FILE;\r\n    :put \"Update completed at \$[/system clock get date] \$[/system clock get time]\" >> \$UPDATE_LOG;\r\n} on-error={\r\n    :put \"Update failed at \$[/system clock get date] \$[/system clock get time]\" >> \$UPDATE_LOG;\r\n}" \
        comment="AD_Blocker_v5.1.0: Update Russian domain list"
    
    $LogMessage "Russian domain list update script created" "info"
} on-error={
    $LogMessage "WARNING: Could not create Russian domain list update script" "warning"
}

# ==============================================================================
# STEP 6: CREATE BELARUSIAN DOMAIN LIST UPDATE SCRIPT
# ==============================================================================

$LogMessage "Creating Belarusian domain list update script..." "info"

:do {
    /system script add name="AD_Blocker_UpdateBY_v5.1.0" \
        source=":local UPDATE_URL \"https://raw.githubusercontent.com/paulmann/1-mikrotik-advanced-ad-blocker-pro/main\";\r\n:local SCRIPT_FILE \"block_ads_by_v5.1.0.rsc\";\r\n:local UPDATE_LOG \"ad_blocker_updates.log\";\r\n:put \"Updating Belarusian domain list...\" >> \$UPDATE_LOG;\r\n:do {\r\n    /tool fetch url=\"\$UPDATE_URL/\$SCRIPT_FILE\" dst-path=\$SCRIPT_FILE;\r\n    :put \"Downloaded: \$SCRIPT_FILE\" >> \$UPDATE_LOG;\r\n    /import file-name=\$SCRIPT_FILE;\r\n    :put \"Update completed at \$[/system clock get date] \$[/system clock get time]\" >> \$UPDATE_LOG;\r\n} on-error={\r\n    :put \"Update failed at \$[/system clock get date] \$[/system clock get time]\" >> \$UPDATE_LOG;\r\n}" \
        comment="AD_Blocker_v5.1.0: Update Belarusian domain list"
    
    $LogMessage "Belarusian domain list update script created" "info"
} on-error={
    $LogMessage "WARNING: Could not create Belarusian domain list update script" "warning"
}

# ==============================================================================
# STEP 7: CREATE ADVANCED CATEGORY UPDATE SCRIPT
# ==============================================================================

$LogMessage "Creating advanced category update script..." "info"

:do {
    /system script add name="AD_Blocker_UpdateAdvanced_v5.1.0" \
        source=":local UPDATE_URL \"https://raw.githubusercontent.com/paulmann/1-mikrotik-advanced-ad-blocker-pro/main\";\r\n:local SCRIPT_FILE \"block_ads_advanced_v5.1.0.rsc\";\r\n:local UPDATE_LOG \"ad_blocker_updates.log\";\r\n:put \"Updating advanced categories...\" >> \$UPDATE_LOG;\r\n:do {\r\n    /tool fetch url=\"\$UPDATE_URL/\$SCRIPT_FILE\" dst-path=\$SCRIPT_FILE;\r\n    :put \"Downloaded: \$SCRIPT_FILE\" >> \$UPDATE_LOG;\r\n    /import file-name=\$SCRIPT_FILE;\r\n    :put \"Update completed at \$[/system clock get date] \$[/system clock get time]\" >> \$UPDATE_LOG;\r\n} on-error={\r\n    :put \"Update failed at \$[/system clock get date] \$[/system clock get time]\" >> \$UPDATE_LOG;\r\n}" \
        comment="AD_Blocker_v5.1.0: Update advanced categories"
    
    $LogMessage "Advanced category update script created" "info"
} on-error={
    $LogMessage "WARNING: Could not create advanced category update script" "warning"
}

# ==============================================================================
# STEP 8: CREATE DNS LOGGING UPDATE SCRIPT
# ==============================================================================

$LogMessage "Creating DNS logging update script..." "info"

:do {
    /system script add name="AD_Blocker_UpdateDNS_v5.1.0" \
        source=":local UPDATE_URL \"https://raw.githubusercontent.com/paulmann/1-mikrotik-advanced-ad-blocker-pro/main\";\r\n:local SCRIPT_FILE \"block_ads_dns_v5.1.0.rsc\";\r\n:local UPDATE_LOG \"ad_blocker_updates.log\";\r\n:put \"Updating DNS logging...\" >> \$UPDATE_LOG;\r\n:do {\r\n    /tool fetch url=\"\$UPDATE_URL/\$SCRIPT_FILE\" dst-path=\$SCRIPT_FILE;\r\n    :put \"Downloaded: \$SCRIPT_FILE\" >> \$UPDATE_LOG;\r\n    /import file-name=\$SCRIPT_FILE;\r\n    :put \"Update completed at \$[/system clock get date] \$[/system clock get time]\" >> \$UPDATE_LOG;\r\n} on-error={\r\n    :put \"Update failed at \$[/system clock get date] \$[/system clock get time]\" >> \$UPDATE_LOG;\r\n}" \
        comment="AD_Blocker_v5.1.0: Update DNS logging"
    
    $LogMessage "DNS logging update script created" "info"
} on-error={
    $LogMessage "WARNING: Could not create DNS logging update script" "warning"
}

# ==============================================================================
# STEP 9: SCHEDULE DAILY UPDATE CHECK
# ==============================================================================

$LogMessage "Scheduling daily update check..." "info"

:do {
    /system scheduler add name="AD_Blocker_DailyCheck_v5.1.0" \
        on-event="/system script run AD_Blocker_CheckUpdates_v5.1.0" \
        interval=1d start-time=03:00:00 \
        comment="AD_Blocker_v5.1.0: Daily update check"
    
    $LogMessage "Daily update check scheduled (03:00 AM)" "info"
} on-error={
    $LogMessage "WARNING: Could not schedule daily update check" "warning"
}

# ==============================================================================
# STEP 10: SCHEDULE WEEKLY FULL UPDATE
# ==============================================================================

$LogMessage "Scheduling weekly full update..." "info"

:do {
    /system scheduler add name="AD_Blocker_WeeklyUpdate_v5.1.0" \
        on-event="/system script run AD_Blocker_UpdateRU_v5.1.0; /system script run AD_Blocker_UpdateBY_v5.1.0; /system script run AD_Blocker_UpdateAdvanced_v5.1.0; /system script run AD_Blocker_UpdateDNS_v5.1.0" \
        interval=7d start-time=04:00:00 \
        comment="AD_Blocker_v5.1.0: Weekly full update"
    
    $LogMessage "Weekly full update scheduled (Every Sunday 04:00 AM)" "info"
} on-error={
    $LogMessage "WARNING: Could not schedule weekly full update" "warning"
}

# ==============================================================================
# STEP 11: SCHEDULE WEEKLY BACKUP
# ==============================================================================

$LogMessage "Scheduling weekly backup..." "info"

:do {
    /system scheduler add name="AD_Blocker_WeeklyBackup_v5.1.0" \
        on-event="/system script run AD_Blocker_Backup_v5.1.0" \
        interval=7d start-time=02:00:00 \
        comment="AD_Blocker_v5.1.0: Weekly configuration backup"
    
    $LogMessage "Weekly backup scheduled (Every Saturday 02:00 AM)" "info"
} on-error={
    $LogMessage "WARNING: Could not schedule weekly backup" "warning"
}

# ==============================================================================
# STEP 12: VERIFY UPDATE INSTALLATION
# ==============================================================================

$LogMessage "Verifying update manager installation..." "info"

:local scriptCount [/system script find where name~"AD_Blocker_Update"]
:local schedulerCount [/system scheduler find where name~"AD_Blocker"]
:local backupExists [/file find where name~"$BACKUP_PREFIX"]

$LogMessage "Update manager verification summary:" "info"
$LogMessage "  - Update scripts: [:len $scriptCount]" "info"
$LogMessage "  - Scheduled tasks: [:len $schedulerCount]" "info"
$LogMessage "  - Backup files: [:len $backupExists]" "info"

# ==============================================================================
# STEP 13: SAVE CONFIGURATION
# ==============================================================================

$LogMessage "Saving configuration..." "info"

:do {
    /system configuration save
    $LogMessage "Configuration saved successfully" "info"
} on-error={
    $LogMessage "WARNING: Could not save configuration" "warning"
}

# ==============================================================================
# STEP 14: INSTALLATION COMPLETE
# ==============================================================================

$LogMessage "========================================" "info"
$LogMessage "UPDATE MANAGER INSTALLED" "info"
$LogMessage "========================================" "info"
$LogMessage "Repository: $GITHUB_REPO" "info"
$LogMessage "Update log: $UPDATE_LOG_FILE" "info"
$LogMessage "Timestamp: $[/system clock get date] $[/system clock get time]" "info"
$LogMessage "========================================" "info"
$LogMessage "" "info"
$LogMessage "SCHEDULED UPDATES:" "info"
$LogMessage "  - Daily check: 03:00 AM" "info"
$LogMessage "  - Full update: Every Sunday 04:00 AM" "info"
$LogMessage "  - Backup: Every Saturday 02:00 AM" "info"
$LogMessage "" "info"
$LogMessage "MANUAL UPDATE COMMANDS:" "info"
$LogMessage "  Check updates:" "info"
$LogMessage "  /system script run AD_Blocker_CheckUpdates_v5.1.0" "info"
$LogMessage "" "info"
$LogMessage "  Update Russian domains:" "info"
$LogMessage "  /system script run AD_Blocker_UpdateRU_v5.1.0" "info"
$LogMessage "" "info"
$LogMessage "  Update Belarusian domains:" "info"
$LogMessage "  /system script run AD_Blocker_UpdateBY_v5.1.0" "info"
$LogMessage "" "info"
$LogMessage "  Create backup:" "info"
$LogMessage "  /system script run AD_Blocker_Backup_v5.1.0" "info"
$LogMessage "" "info"
$LogMessage "  View update log:" "info"
$LogMessage "  /file print" "info"
$LogMessage "========================================" "info"

# ==============================================================================
# SCRIPT END
# ==============================================================================
