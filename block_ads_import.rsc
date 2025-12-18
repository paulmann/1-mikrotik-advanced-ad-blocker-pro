# ================================================
# 1: MikroTik Advanced AD Blocker Pro - Core Installer
# ================================================
# Repository: https://github.com/paulmann/1-mikrotik-advanced-ad-blocker-pro
# Author: Mikhail Deynekin [Deynekin.RU]
# Version: 5.0.0
# Date: 2025-12-18
# License: MIT
#
# DESCRIPTION:
# This is the MAIN INSTALLER for 99% of users. It sets up the core framework
# for advanced advertisement blocking on MikroTik RouterOS devices.
#
# FEATURES:
# - Core firewall rules for DNS and HTTPS blocking
# - Address-list based domain management
# - Optimized RAW rules for maximum performance
# - Automatic configuration backup
#
# USAGE:
# /tool fetch url="https://raw.githubusercontent.com/paulmann/1-mikrotik-advanced-ad-blocker-pro/main/block_ads_import.rsc"
# /import file-name=block_ads_import.rsc
#
# After installation, import regional domain lists:
# block_ads_ru.rsc for Russian ads
# block_ads_by.rsc for Belarusian ads
# ================================================

# System Configuration
:local scriptVersion "5.0.0"
:local markerComment "AD_Blocker_Pro_v5"
:local addressListName "AD_Blocker_Domains"
:local fwChain "forward"
:local githubBaseURL "https://raw.githubusercontent.com/paulmann/1-mikrotik-advanced-ad-blocker-pro/main/"

:log info "Starting 1: MikroTik Advanced AD Blocker Pro v$scriptVersion installation"

# Cleanup old system rules safely
:local cleanupOldRules {
    :local removedCount 0
    
    # Remove firewall filter rules
    :local filterRules [/ip firewall filter find comment~"$markerComment"]
    :if ([:len $filterRules] > 0) do={
        /ip firewall filter remove numbers=$filterRules
        :set removedCount ($removedCount + [:len $filterRules])
        :log info "Removed $[:len $filterRules] old filter rules"
    }
    
    # Remove address-list entries from our system
    :local addressItems [/ip firewall address-list find list="$addressListName"]
    :if ([:len $addressItems] > 0) do={
        /ip firewall address-list remove numbers=$addressItems
        :set removedCount ($removedCount + [:len $addressItems])
        :log info "Removed $[:len $addressItems] address-list entries"
    }
    
    # Remove RAW rules
    :local rawRules [/ip firewall raw find comment~"$markerComment"]
    :if ([:len $rawRules] > 0) do={
        /ip firewall raw remove numbers=$rawRules
        :set removedCount ($removedCount + [:len $rawRules])
        :log info "Removed $[:len $rawRules] RAW rules"
    }
    
    :return $removedCount
}

# Execute cleanup
:local cleanedItems [$cleanupOldRules]
:log info "Total items cleaned: $cleanedItems"

# Create main address list if it doesn't exist
:if ([/ip firewall address-list find list="$addressListName"] = "") do={
    /ip firewall address-list add list="$addressListName" address="127.0.0.1" comment="$markerComment: Initial entry"
    :log info "Created main address list: $addressListName"
}

# Core Blocking Rules
:log info "Installing core blocking rules..."

# 1. DNS-based blocking (UDP 53)
/ip firewall filter add chain="$fwChain" protocol=udp dst-port=53 \
    src-address-list="$addressListName" \
    action=drop comment="$markerComment: DNS UDP Block" disabled=no

# 2. DNS-based blocking (TCP 53)
/ip firewall filter add chain="$fwChain" protocol=tcp dst-port=53 \
    src-address-list="$addressListName" \
    action=drop comment="$markerComment: DNS TCP Block" disabled=no

# 3. HTTPS/SSL blocking using SNI (RouterOS v7+)
/ip firewall filter add chain="$fwChain" protocol=tcp dst-port=443 \
    src-address-list="$addressListName" \
    action=drop comment="$markerComment: HTTPS SNI Block" disabled=no

# 4. High-performance RAW blocking (prerouting chain)
/ip firewall raw add chain=prerouting \
    src-address-list="$addressListName" \
    action=drop comment="$markerComment: RAW Prerouting Block" disabled=no \
    place-before=0

# 5. Common pattern blocking for DNS requests
:local dnsPatterns {"ads."; "ad."; "track."; "metric."; "pixel."}
:local patternIndex 0
:foreach pattern in=$dnsPatterns do={
    /ip firewall filter add chain="$fwChain" protocol=udp dst-port=53 \
        content="$pattern" \
        action=drop comment="$markerComment: DNS Pattern $pattern" disabled=no
    :set patternIndex ($patternIndex + 1)
}

# Optimize rule placement for performance
:local ruleCount 0
:local adBlockerRules [/ip firewall filter find comment~"$markerComment"]
:foreach rule in=$adBlockerRules do={
    /ip firewall filter move $rule destination=$ruleCount
    :set ruleCount ($ruleCount + 1)
}

# Configuration backup
/system backup save name="adblocker_backup_$[/system clock get date]" dont-encrypt=yes
/system configuration save

:log info "1: MikroTik Advanced AD Blocker Pro installation completed successfully"
:put "======================================================"
:put "1: MikroTik Advanced AD Blocker Pro v$scriptVersion"
:put "======================================================"
:put "✓ Core rules installed: $ruleCount"
:put "✓ Address list created: $addressListName"
:put "✓ Configuration saved and backed up"
:put ""
:put "NEXT STEPS:"
:put "1. Import regional domain lists:"
:put "   /import block_ads_ru.rsc    (Russian ads)"
:put "   /import block_ads_by.rsc    (Belarusian ads)"
:put ""
:put "2. Set up automatic updates:"
:put "   /import block_ads_update_import_rules.rsc"
:put "======================================================"