# ================================================
# 1: MikroTik Advanced AD Blocker Pro - Cleanup Tool
# ================================================
# Repository: https://github.com/paulmann/1-mikrotik-advanced-ad-blocker-pro
# Author: Mikhail Deynekin [Deynekin.RU]
# Version: 5.0.0
# Date: 2025-12-18
# License: MIT
#
# DESCRIPTION:
# Complete removal tool for AD Blocker system.
# WARNING: This operation cannot be undone. Backup created first.
# ================================================

:log warning "=== STARTING COMPLETE AD BLOCKER SYSTEM REMOVAL ==="
:log warning "WARNING: This will remove all AD Blocker configuration"
:log warning "Backup will be created before proceeding"

:local totalRemoved 0

# 1. Create backup
:local backupName "pre_cleanup_backup_$[/system clock get date]"
/system backup save name="$backupName" dont-encrypt=yes
:log warning "Created pre-cleanup backup: $backupName"

# 2. Remove firewall filter rules
:local filterPatterns {"AD_Blocker_Pro_v5"; "AD_Blocker_DNS_Logger"; "AD_Blocker: Category"; "BlockAD_System"}

:foreach pattern in=$filterPatterns do={
    :local rules [/ip firewall filter find comment~"$pattern"]
    :if ([:len $rules] > 0) do={
        /ip firewall filter remove numbers=$rules
        :set totalRemoved ($totalRemoved + [:len $rules])
        :log info "Removed filter rules with pattern '$pattern': $[:len $rules]"
    }
}

# 3. Remove address lists
:local addressLists {"AD_Blocker_Domains"; "AD_Blocker_Stats"; "AD_Blocker_Cat_social"; "AD_Blocker_Cat_tracking"; "AD_Blocker_Cat_malware"; "AD_Blocker_Cat_phishing"; "AD_Blocker_Cat_crypto"; "AD_Blocker_Cat_adult"; "AD_Blocker_Cat_gambling"; "AD_Blocker_Cat_aggressive"}

:foreach list in=$addressLists do={
    :local items [/ip firewall address-list find list="$list"]
    :if ([:len $items] > 0) do={
        /ip firewall address-list remove numbers=$items
        :set totalRemoved ($totalRemoved + [:len $items])
        :log info "Removed address list '$list': $[:len $items] entries"
    }
}

# 4. Remove RAW rules
:local rawRules [/ip firewall raw find comment~"AD_Blocker"]
:if ([:len $rawRules] > 0) do={
    /ip firewall raw remove numbers=$rawRules
    :set totalRemoved ($totalRemoved + [:len $rawRules])
    :log info "Removed RAW rules: $[:len $rawRules]"
}

# 5. Remove schedulers
:local schedulers [/system scheduler find comment~"AD Blocker"]
:if ([:len $schedulers] > 0) do={
    /system scheduler remove numbers=$schedulers
    :log info "Removed schedulers: $[:len $schedulers]"
}

# 6. Remove scripts
:local scripts [/system script find name~"adblocker"]
:if ([:len $scripts] > 0) do={
    /system script remove numbers=$scripts
    :log info "Removed scripts: $[:len $scripts]"
}

# Final configuration save
/system configuration save

:log warning "=== AD BLOCKER SYSTEM REMOVAL COMPLETED ==="
:log warning "Total items removed: $totalRemoved"

:put "======================================================"
:put "AD BLOCKER SYSTEM - COMPLETE REMOVAL REPORT"
:put "======================================================"
:put "✓ Total configuration items removed: $totalRemoved"
:put "✓ Backup created: $backupName"
:put ""
:put "System has been completely cleaned."
:put "To reinstall, import block_ads_import.rsc again."
:put "======================================================"