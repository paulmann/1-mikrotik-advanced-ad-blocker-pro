# ================================================
# 1: MikroTik Advanced AD Blocker Pro - Category Module
# ================================================
# Repository: https://github.com/paulmann/1-mikrotik-advanced-ad-blocker-pro
# Author: Mikhail Deynekin [Deynekin.RU]
# Version: 5.0.0
# Date: 2025-12-18
# License: MIT
#
# DESCRIPTION:
# Advanced category-based blocking system for granular control.
# ================================================

:local categoryDefinitions {
    "social"    = "Social Media Trackers and Ads";
    "tracking"  = "Analytics and User Tracking";
    "malware"   = "Malware and Security Threats";
    "phishing"  = "Phishing and Fraud Sites";
    "crypto"    = "Cryptomining and Coin Miners";
    "adult"     = "Adult Content and Ads";
    "gambling"  = "Gambling and Casino Sites";
    "aggressive"= "Aggressive and Intrusive Ads"
}

:log info "Installing category-based blocking system..."

:foreach catName,catDesc in=$categoryDefinitions do={
    :local listName "AD_Blocker_Cat_$catName"
    
    :if ([/ip firewall address-list find list="$listName"] = "") do={
        /ip firewall address-list add list="$listName" address="127.0.0.1" comment="Category: $catDesc"
        :log info "Created category list: $listName"
    }
    
    /ip firewall filter add chain=forward protocol=udp dst-port=53 \
        src-address-list="$listName" action=drop \
        comment="AD_Blocker: Category $catName - DNS" disabled=no
    
    /ip firewall filter add chain=forward protocol=tcp dst-port=443 \
        src-address-list="$listName" action=drop \
        comment="AD_Blocker: Category $catName - HTTPS" disabled=no
}

/system configuration save
:log info "Category module installed successfully"

:put "======================================================"
:put "CATEGORY-BASED BLOCKING SYSTEM INSTALLED"
:put "======================================================"
:put "✓ Created 8 independent categories"
:put "✓ Each with DNS and HTTPS blocking rules"
:put "======================================================"