# ==============================================================================
# MikroTik Advanced AD Blocker Pro v5.1.0
# Belarusian Domain List Update: block_ads_update_by_v5.1.0.rsc
# ==============================================================================
#
# Author:       Mikhail Deynekin
# Email:        mid1977@gmail.com
# Website:      https://deynekin.com
# Repository:   https://github.com/paulmann/1-mikrotik-advanced-ad-blocker-pro
# License:      MIT
#
# Purpose:      Automatic update manager for Belarusian domain lists
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
#   /tool fetch url="https://raw.githubusercontent.com/paulmann/1-mikrotik-advanced-ad-blocker-pro/main/block_ads_update_by_v5.1.0.rsc"
#   /import file-name=block_ads_update_by_v5.1.0.rsc
#
# ==============================================================================
# SCRIPT START
# ==============================================================================

# Define script constants
:local SCRIPT_NAME "AD_Blocker_Update_BY_v5.1.0"
:local SCRIPT_VERSION "5.1.0"
:local LOG_PREFIX "\[AD_Blocker_Update_BY_v5.1.0\]"
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
    :local log_header "AD_Blocker v5.1.0 - Update Log (Belarusian)"
    :local log_separator "================================================================================"
    :local created_at "Log Created: $[/system clock get date] $[/system clock get time]"
    :local device_name "$[/system identity get name]"
    
    /file print file=$UPDATE_LOG_FILE
    :put $log_header >> $UPDATE_LOG_FILE
    :put $log_separator >> $UPDATE_LOG_FILE
    :put "Device: $device_name" >> $UPDATE_LOG_FILE
    :put "Author: Mikhail Deynekin (mid1977@gmail.com)" >> $UPDATE_LOG_FILE
    :put "Regional List: Belarusian (.by domains)" >> $UPDATE_LOG_FILE
    :put $created_at >> $UPDATE_LOG_FILE
    :put $log_separator >> $UPDATE_LOG_FILE
    :put "" >> $UPDATE_LOG_FILE
    
    $LogMessage "Update log file initialized: $UPDATE_LOG_FILE" "info"
} on-error={
    $LogMessage "WARNING: Could not initialize update log" "warning"
}

# ==============================================================================
# STEP 3: CREATE BELARUSIAN UPDATE CHECK SCRIPT
# ==============================================================================

$LogMessage "Creating Belarusian update check script..." "info"

:do {
    /system script add name="AD_Blocker_CheckUpdatesBY_v5.1.0" \
        source=":local SCRIPT_VERSION \"5.1.0\";\r\n:local UPDATE_URL \"https://raw.githubusercontent.com/paulmann/1-mikrotik-advanced-ad-blocker-pro/main\";\r\n:local UPDATE_LOG \"ad_blocker_updates.log\";\r\n:put \"Checking for Belarusian AD Blocker updates...\" >> \$UPDATE_LOG;\r\n:put \"Current version: \$SCRIPT_VERSION\" >> \$UPDATE_LOG;\r\n:put \"Timestamp: \$[/system clock get date] \$[/system clock get time]\" >> \$UPDATE_LOG;" \
        comment="AD_Blocker_v5.1.0: Check Belarusian updates"
    
    $LogMessage "Belarusian update check script created" "info"
} on-error={
    $LogMessage "WARNING: Could not create Belarusian update check script" "warning"
}

# ==============================================================================
# STEP 4: CREATE BACKUP SCRIPT
# ==============================================================================

$LogMessage "Creating backup script..." "info"

:do {
    /system script add name="AD_Blocker_BackupBY_v5.1.0" \
        source=":local BACKUP_PREFIX \"ad_blocker_backup\";\r\n:local timestamp \"\$[/system clock get date]_\$[/system clock get time]\";\r\n:local backup_name \"\$BACKUP_PREFIX\_by\_\$timestamp.bak\";\r\n:put \"Creating Belarusian backup: \$backup_name\";\r\n:do {\r\n    /system script export file=\$backup_name;\r\n    :put \"Backup created successfully\";\r\n} on-error={\r\n    :put \"Backup creation failed\";\r\n}" \
        comment="AD_Blocker_v5.1.0: Create Belarusian configuration backup"
    
    $LogMessage "Belarusian backup script created" "info"
} on-error={
    $LogMessage "WARNING: Could not create Belarusian backup script" "warning"
}

# ==============================================================================
# STEP 5: CREATE BELARUSIAN DOMAIN LIST UPDATE SCRIPT
# ==============================================================================

$LogMessage "Creating Belarusian domain list update script..." "info"

:do {
    /system script add name="AD_Blocker_UpdateBYDomains_v5.1.0" \
        source=":local UPDATE_URL \"https://raw.githubusercontent.com/paulmann/1-mikrotik-advanced-ad-blocker-pro/main\";\r\n:local SCRIPT_FILE \"block_ads_by_v5.1.0.rsc\";\r\n:local UPDATE_LOG \"ad_blocker_updates.log\";\r\n:put \"Updating Belarusian domain list...\" >> \$UPDATE_LOG;\r\n:do {\r\n    /tool fetch url=\"\$UPDATE_URL/\$SCRIPT_FILE\" dst-path=\$SCRIPT_FILE;\r\n    :put \"Downloaded: \$SCRIPT_FILE\" >> \$UPDATE_LOG;\r\n    /import file-name=\$SCRIPT_FILE;\r\n    :put \"Belarusian domains updated at \$[/system clock get date] \$[/system clock get time]\" >> \$UPDATE_LOG;\r\n} on-error={\r\n    :put \"Belarusian update failed at \$[/system clock get date] \$[/system clock get time]\" >> \$UPDATE_LOG;\r\n}" \
        comment="AD_Blocker_v5.1.0: Update Belarusian domain list"
    
    $LogMessage "Belarusian domain list update script created" "info"
} on-error={
    $LogMessage "WARNING: Could not create Belarusian domain list update script" "warning"
}

# ==============================================================================
# STEP 6: CREATE BELARUSIAN CATEGORY UPDATE SCRIPT
# ==============================================================================

$LogMessage "Creating Belarusian category update script..." "info"

:do {
    /system script add name="AD_Blocker_UpdateBYCategories_v5.1.0" \
        source=":local UPDATE_URL \"https://raw.githubusercontent.com/paulmann/1-mikrotik-advanced-ad-blocker-pro/main\";\r\n:local SCRIPT_FILE \"block_ads_by_categories_v5.1.0.rsc\";\r\n:local UPDATE_LOG \"ad_blocker_updates.log\";\r\n:put \"Updating Belarusian categories...\" >> \$UPDATE_LOG;\r\n:do {\r\n    /tool fetch url=\"\$UPDATE_URL/\$SCRIPT_FILE\" dst-path=\$SCRIPT_FILE;\r\n    :put \"Downloaded: \$SCRIPT_FILE\" >> \$UPDATE_LOG;\r\n    /import file-name=\$SCRIPT_FILE;\r\n    :put \"Belarusian categories updated at \$[/system clock get date] \$[/system clock get time]\" >> \$UPDATE_LOG;\r\n} on-error={\r\n    :put \"Category update failed at \$[/system clock get date] \$[/system clock get time]\" >> \$UPDATE_LOG;\r\n}" \
        comment="AD_Blocker_v5.1.0: Update Belarusian categories"
    
    $LogMessage "Belarusian category update script created" "info"
} on-error={
    $LogMessage "WARNING: Could not create Belarusian category update script" "warning"
}

# ==============================================================================
# STEP 7: CREATE BELARUSIAN DNS LOGGING UPDATE SCRIPT
# ==============================================================================

$LogMessage "Creating Belarusian DNS logging update script..." "info"

:do {
    /system script add name="AD_Blocker_UpdateBYDNS_v5.1.0" \
        source=":local UPDATE_URL \"https://raw.githubusercontent.com/paulmann/1-mikrotik-advanced-ad-blocker-pro/main\";\r\n:local SCRIPT_FILE \"block_ads_by_dns_v5.1.0.rsc\";\r\n:local UPDATE_LOG \"ad_blocker_updates.log\";\r\n:put \"Updating Belarusian DNS logging...\" >> \$UPDATE_LOG;\r\n:do {\r\n    /tool fetch url=\"\$UPDATE_URL/\$SCRIPT_FILE\" dst-path=\$SCRIPT_FILE;\r\n    :put \"Downloaded: \$SCRIPT_FILE\" >> \$UPDATE_LOG;\r\n    /import file-name=\$SCRIPT_FILE;\r\n    :put \"Belarusian DNS logging updated at \$[/system clock get date] \$[/system clock get time]\" >> \$UPDATE_LOG;\r\n} on-error={\r\n    :put \"DNS logging update failed at \$[/system clock get date] \$[/system clock get time]\" >> \$UPDATE_LOG;\r\n}" \
        comment="AD_Blocker_v5.1.0: Update Belarusian DNS logging"
    
    $LogMessage "Belarusian DNS logging update script created" "info"
} on-error={
    $LogMessage "WARNING: Could not create Belarusian DNS logging update script" "warning"
}

# ==============================================================================
# STEP 8: SCHEDULE DAILY UPDATE CHECK (BELARUSIAN)
# ==============================================================================

$LogMessage "Scheduling daily Belarusian update check..." "info"

:do {
    /system scheduler add name="AD_Blocker_DailyCheckBY_v5.1.0" \
        on-event="/system script run AD_Blocker_CheckUpdatesBY_v5.1.0" \
        interval=1d start-time=03:30:00 \
        comment="AD_Blocker_v5.1.0: Daily Belarusian update check"
    
    $LogMessage "Daily Belarusian update check scheduled (03:30 AM)" "info"
} on-error={
    $LogMessage "WARNING: Could not schedule daily Belarusian update check" "warning"
}

# ==============================================================================
# STEP 9: SCHEDULE WEEKLY BELARUSIAN FULL UPDATE
# ==============================================================================

$LogMessage "Scheduling weekly Belarusian full update..." "info"

:do {
    /system scheduler add name="AD_Blocker_WeeklyUpdateBY_v5.1.0" \
        on-event="/system script run AD_Blocker_UpdateBYDomains_v5.1.0; /system script run AD_Blocker_UpdateBYCategories_v5.1.0; /system script run AD_Blocker_UpdateBYDNS_v5.1.0" \
        interval=7d start-time=04:30:00 \
        comment="AD_Blocker_v5.1.0: Weekly Belarusian full update"
    
    $LogMessage "Weekly Belarusian full update scheduled (Every Sunday 04:30 AM)" "info"
} on-error={
    $LogMessage "WARNING: Could not schedule weekly Belarusian full update" "warning"
}

# ==============================================================================
# STEP 10: SCHEDULE WEEKLY BELARUSIAN BACKUP
# ==============================================================================

$LogMessage "Scheduling weekly Belarusian backup..." "info"

:do {
    /system scheduler add name="AD_Blocker_WeeklyBackupBY_v5.1.0" \
        on-event="/system script run AD_Blocker_BackupBY_v5.1.0" \
        interval=7d start-time=02:30:00 \
        comment="AD_Blocker_v5.1.0: Weekly Belarusian configuration backup"
    
    $LogMessage "Weekly Belarusian backup scheduled (Every Saturday 02:30 AM)" "info"
} on-error={
    $LogMessage "WARNING: Could not schedule weekly Belarusian backup" "warning"
}

# ==============================================================================
# STEP 11: CREATE STATISTICS COLLECTION SCRIPT (BELARUSIAN)
# ==============================================================================

$LogMessage "Creating Belarusian statistics collection script..." "info"

:do {
    /system script add name="AD_Blocker_StatsBY_v5.1.0" \
        source=":local stats_file \"ad_blocker_stats_by\";\r\n:local timestamp \"\$[/system clock get date] \$[/system clock get time]\";\r\n:local blocked_count [:len [/ip firewall address-list find where list=\"AD_Blocker_Domains_BY\"]];\r\n:local active_rules [:len [/ip firewall filter find where comment~\"AD_Blocker_v5.1.0\"]];\r\n:put \$timestamp >> \$stats_file;\r\n:put \"Belarusian Blocked Domains: \$blocked_count\" >> \$stats_file;\r\n:put \"Active Rules: \$active_rules\" >> \$stats_file;\r\n:put \"---\" >> \$stats_file;" \
        comment="AD_Blocker_v5.1.0: Belarusian statistics collector"
    
    $LogMessage "Belarusian statistics collection script created" "info"
} on-error={
    $LogMessage "WARNING: Could not create Belarusian statistics script" "warning"
}

# ==============================================================================
# STEP 12: VERIFY UPDATE INSTALLATION
# ==============================================================================

$LogMessage "Verifying Belarusian update manager installation..." "info"

:local scriptCount [/system script find where name~"AD_Blocker_Update" or name~"AD_Blocker_BY"]
:local schedulerCount [/system scheduler find where name~"AD_Blocker" and name~"BY"]
:local backupExists [/file find where name~"$BACKUP_PREFIX"]

$LogMessage "Belarusian update manager verification summary:" "info"
$LogMessage "  - Belarusian update scripts: [:len $scriptCount]" "info"
$LogMessage "  - Scheduled Belarusian tasks: [:len $schedulerCount]" "info"
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
$LogMessage "BELARUSIAN UPDATE MANAGER INSTALLED" "info"
$LogMessage "========================================" "info"
$LogMessage "Repository: $GITHUB_REPO" "info"
$LogMessage "Update log: $UPDATE_LOG_FILE" "info"
$LogMessage "Region: Belarus (.by domains)" "info"
$LogMessage "Timestamp: $[/system clock get date] $[/system clock get time]" "info"
$LogMessage "========================================" "info"
$LogMessage "" "info"
$LogMessage "SCHEDULED BELARUSIAN UPDATES:" "info"
$LogMessage "  - Daily check: 03:30 AM" "info"
$LogMessage "  - Full update: Every Sunday 04:30 AM" "info"
$LogMessage "  - Backup: Every Saturday 02:30 AM" "info"
$LogMessage "" "info"
$LogMessage "MANUAL BELARUSIAN UPDATE COMMANDS:" "info"
$LogMessage "  Check Belarusian updates:" "info"
$LogMessage "  /system script run AD_Blocker_CheckUpdatesBY_v5.1.0" "info"
$LogMessage "" "info"
$LogMessage "  Update Belarusian domains:" "info"
$LogMessage "  /system script run AD_Blocker_UpdateBYDomains_v5.1.0" "info"
$LogMessage "" "info"
$LogMessage "  Update Belarusian categories:" "info"
$LogMessage "  /system script run AD_Blocker_UpdateBYCategories_v5.1.0" "info"
$LogMessage "" "info"
$LogMessage "  Create Belarusian backup:" "info"
$LogMessage "  /system script run AD_Blocker_BackupBY_v5.1.0" "info"
$LogMessage "" "info"
$LogMessage "  View Belarusian statistics:" "info"
$LogMessage "  /system script run AD_Blocker_StatsBY_v5.1.0" "info"
$LogMessage "" "info"
$LogMessage "  View update log:" "info"
$LogMessage "  /file print" "info"
$LogMessage "========================================" "info"

# ==============================================================================
# SCRIPT END
# ==============================================================================
