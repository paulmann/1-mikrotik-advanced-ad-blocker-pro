# ================================================
# 1: MikroTik Advanced AD Blocker Pro - DNS Logger
# ================================================
# Repository: https://github.com/paulmann/1-mikrotik-advanced-ad-blocker-pro
# Author: Mikhail Deynekin [Deynekin.RU]
# Version: 5.0.0
# Date: 2025-12-18
# License: MIT
#
# DESCRIPTION:
# Advanced DNS logging module that tracks blocked advertisement requests.
# ================================================

:local markerComment "AD_Blocker_DNS_Logger_v5"
:local addressListName "AD_Blocker_Domains"
:local statsListName "AD_Blocker_Stats"

:log info "Installing DNS logging module..."

# Create statistics list if it doesn't exist
:if ([/ip firewall address-list find list="$statsListName"] = "") do={
    /ip firewall address-list add list="$statsListName" address="0.0.0.0" comment="Statistics placeholder"
    :log info "Created statistics list: $statsListName"
}

# DNS logging rules
/ip firewall filter add chain=forward protocol=udp dst-port=53 \
    src-address-list="$addressListName" \
    action=add-src-to-address-list address-list="$statsListName" \
    address-list-timeout=1d comment="$markerComment: Log DNS UDP" disabled=no

/ip firewall filter add chain=forward protocol=tcp dst-port=53 \
    src-address-list="$addressListName" \
    action=add-src-to-address-list address-list="$statsListName" \
    address-list-timeout=1d comment="$markerComment: Log DNS TCP" disabled=no

# Remove placeholder
/ip firewall address-list remove [find list="$statsListName" address="0.0.0.0"]

/system configuration save
:log info "DNS logging module installation completed"

:put "======================================================"
:put "DNS LOGGING MODULE INSTALLED"
:put "======================================================"
:put "✓ Real-time DNS logging enabled"
:put "✓ Statistics list: $statsListName"
:put "======================================================"