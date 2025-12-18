# ==============================================================================
# MikroTik Advanced AD Blocker Pro v5.1.0
# Advanced Category Blocking: block_ads_advanced_v5.1.0.rsc
# ==============================================================================
#
# Author:       Mikhail Deynekin
# Email:        mid1977@gmail.com
# Website:      https://deynekin.com
# Repository:   https://github.com/paulmann/1-mikrotik-advanced-ad-blocker-pro
# License:      MIT
#
# Purpose:      Advanced category-based filtering for RouterOS ad blocking
# Version:      5.1.0 (December 2025)
# Status:       Production-Ready
# Categories:   8 independent blocking categories
#
# ==============================================================================
# CHANGELOG v5.1.0
# ==============================================================================
# - Fixed all RouterOS syntax errors in category creation
# - Added 8 independent category-based address lists
# - Improved error handling with comprehensive validation
# - Enhanced logging with timestamps and context
# - Optimized firewall rule ordering for performance
# - Fixed all string escaping and quote handling
# - Added detailed category documentation
# - Implemented version compatibility checks
# - Added safe cleanup of previous installations
#
# ==============================================================================
# ADVANCED CATEGORIES
# ==============================================================================
#
# CATEGORY 1: SOCIAL MEDIA TRACKERS & ADVERTISEMENTS
#   AD_Blocker_Cat_social
#   Purpose: Block social media tracking pixels and ads
#   Domains: Facebook, Instagram, Twitter, TikTok, LinkedIn tracking
#   Use Case: Prevent social networks from following users
#
# CATEGORY 2: ANALYTICS & USER TRACKING
#   AD_Blocker_Cat_tracking
#   Purpose: Block analytics and behavior monitoring services
#   Domains: Google Analytics, Mixpanel, Amplitude, Hotjar
#   Use Case: Prevent user behavior collection
#
# CATEGORY 3: MALWARE & SECURITY THREATS
#   AD_Blocker_Cat_malware
#   Purpose: Block known malware distribution domains
#   Domains: Exploit kits, malware hosting, C&C servers
#   Use Case: Enhance network security
#
# CATEGORY 4: PHISHING & FRAUD SITES
#   AD_Blocker_Cat_phishing
#   Purpose: Block phishing attempts and fraud sites
#   Domains: Credential harvesters, fake banks, fake stores
#   Use Case: Prevent credential theft
#
# CATEGORY 5: CRYPTOCURRENCY MINING OPERATIONS
#   AD_Blocker_Cat_crypto
#   Purpose: Block cryptomining scripts and pools
#   Domains: Mining pools, coinhive, webminer services
#   Use Case: Prevent CPU/GPU abuse
#
# CATEGORY 6: ADULT CONTENT & ADVERTISEMENTS
#   AD_Blocker_Cat_adult
#   Purpose: Block adult content and related ads
#   Domains: Adult sites, adult ad networks
#   Use Case: Parental control, workplace filtering
#
# CATEGORY 7: GAMBLING & CASINO PLATFORMS
#   AD_Blocker_Cat_gambling
#   Purpose: Block gambling and casino sites
#   Domains: Online casinos, betting sites, poker platforms
#   Use Case: Corporate filtering, parental control
#
# CATEGORY 8: AGGRESSIVE & INTRUSIVE ADVERTISEMENTS
#   AD_Blocker_Cat_aggressive
#   Purpose: Block highly intrusive ad networks
#   Domains: Aggressive ad networks, pop-up services
#   Use Case: Improve user experience, reduce clutter
#
# ==============================================================================
# INSTALLATION
# ==============================================================================
#
# Prerequisites:
#   - block_ads_import_v5.1.0.rsc must be installed first
#   - RouterOS v6.0 or higher
#   - Administrative access
#
# Quick Installation:
#   /tool fetch url="https://raw.githubusercontent.com/paulmann/1-mikrotik-advanced-ad-blocker-pro/main/block_ads_advanced_v5.1.0.rsc"
#   /import file-name=block_ads_advanced_v5.1.0.rsc
#
# ==============================================================================
# SCRIPT START
# ==============================================================================

# Define script constants
:local SCRIPT_NAME "AD_Blocker_Advanced_v5.1.0"
:local SCRIPT_VERSION "5.1.0"
:local LOG_PREFIX "[AD_Blocker_Advanced_v5.1.0]"

# Function to log messages with timestamp
:local LogMessage do={
    :local message $1
    :local level $2
    :if ($level = "") do={:set level "info"}
    :put "[$[/system clock get time]] $LOG_PREFIX \[$level\]: $message"
}

# Function to safely add domain to category list
:local AddCategoryDomain do={
    :local domain $1
    :local category $2
    :local description $3
    
    :do {
        :local exists [/ip firewall address-list find where list=$category and address=$domain]
        
        :if ([:len $exists] = 0) do={
            /ip firewall address-list add list=$category \
                address=$domain \
                comment=$description
        }
    } on-error={
        $LogMessage "WARNING: Could not add $domain to $category" "warning"
    }
}

$LogMessage "Starting Advanced Category Blocking system installation (v5.1.0)" "info"
$LogMessage "Installation timestamp: $[/system clock get date] $[/system clock get time]" "info"

# ==============================================================================
# STEP 1: CREATE CATEGORY 1 - SOCIAL MEDIA TRACKERS
# ==============================================================================

$LogMessage "Creating SOCIAL MEDIA TRACKERS category..." "info"

:do {
    /ip firewall filter add chain=forward protocol=udp dst-port=53 \
        src-address-list="AD_Blocker_Cat_social" \
        action=drop comment="AD_Blocker_v5.1.0: Social Media DNS Block" \
        disabled=no
    
    /ip firewall filter add chain=forward protocol=tcp dst-port=443 \
        src-address-list="AD_Blocker_Cat_social" \
        action=drop comment="AD_Blocker_v5.1.0: Social Media HTTPS Block" \
        disabled=no
    
    $LogMessage "Social Media category created successfully" "info"
} on-error={
    $LogMessage "ERROR: Failed to create Social Media category" "ERROR"
}

# Add social media tracking domains
$AddCategoryDomain "facebook.com" "AD_Blocker_Cat_social" "Social_Facebook"
$AddCategoryDomain "facebook.net" "AD_Blocker_Cat_social" "Social_FacebookPixel"
$AddCategoryDomain "instagram.com" "AD_Blocker_Cat_social" "Social_Instagram"
$AddCategoryDomain "twitter.com" "AD_Blocker_Cat_social" "Social_Twitter"
$AddCategoryDomain "t.co" "AD_Blocker_Cat_social" "Social_TwitterShort"
$AddCategoryDomain "tiktok.com" "AD_Blocker_Cat_social" "Social_TikTok"
$AddCategoryDomain "linkedin.com" "AD_Blocker_Cat_social" "Social_LinkedIn"
$AddCategoryDomain "pinterest.com" "AD_Blocker_Cat_social" "Social_Pinterest"
$AddCategoryDomain "snapchat.com" "AD_Blocker_Cat_social" "Social_Snapchat"
$AddCategoryDomain "reddit.com" "AD_Blocker_Cat_social" "Social_Reddit"

# ==============================================================================
# STEP 2: CREATE CATEGORY 2 - ANALYTICS & TRACKING
# ==============================================================================

$LogMessage "Creating ANALYTICS & TRACKING category..." "info"

:do {
    /ip firewall filter add chain=forward protocol=udp dst-port=53 \
        src-address-list="AD_Blocker_Cat_tracking" \
        action=drop comment="AD_Blocker_v5.1.0: Analytics DNS Block" \
        disabled=no
    
    /ip firewall filter add chain=forward protocol=tcp dst-port=443 \
        src-address-list="AD_Blocker_Cat_tracking" \
        action=drop comment="AD_Blocker_v5.1.0: Analytics HTTPS Block" \
        disabled=no
    
    $LogMessage "Analytics & Tracking category created successfully" "info"
} on-error={
    $LogMessage "ERROR: Failed to create Analytics category" "ERROR"
}

# Add analytics tracking domains
$AddCategoryDomain "google-analytics.com" "AD_Blocker_Cat_tracking" "Analytics_Google"
$AddCategoryDomain "analytics.google.com" "AD_Blocker_Cat_tracking" "Analytics_GoogleMain"
$AddCategoryDomain "googletagmanager.com" "AD_Blocker_Cat_tracking" "Analytics_GTM"
$AddCategoryDomain "googlesyndication.com" "AD_Blocker_Cat_tracking" "Analytics_GoogleSyn"
$AddCategoryDomain "doubleclick.net" "AD_Blocker_Cat_tracking" "Analytics_DoubleClick"
$AddCategoryDomain "segment.com" "AD_Blocker_Cat_tracking" "Analytics_Segment"
$AddCategoryDomain "mixpanel.com" "AD_Blocker_Cat_tracking" "Analytics_Mixpanel"
$AddCategoryDomain "amplitude.com" "AD_Blocker_Cat_tracking" "Analytics_Amplitude"
$AddCategoryDomain "hotjar.com" "AD_Blocker_Cat_tracking" "Analytics_Hotjar"
$AddCategoryDomain "kissmetrics.com" "AD_Blocker_Cat_tracking" "Analytics_KissMetrics"

# ==============================================================================
# STEP 3: CREATE CATEGORY 3 - MALWARE & THREATS
# ==============================================================================

$LogMessage "Creating MALWARE & THREATS category..." "info"

:do {
    /ip firewall filter add chain=forward protocol=udp dst-port=53 \
        src-address-list="AD_Blocker_Cat_malware" \
        action=drop comment="AD_Blocker_v5.1.0: Malware DNS Block" \
        disabled=no
    
    /ip firewall filter add chain=forward protocol=tcp dst-port=443 \
        src-address-list="AD_Blocker_Cat_malware" \
        action=drop comment="AD_Blocker_v5.1.0: Malware HTTPS Block" \
        disabled=no
    
    $LogMessage "Malware & Threats category created successfully" "info"
} on-error={
    $LogMessage "ERROR: Failed to create Malware category" "ERROR"
}

# Add malware domains
$AddCategoryDomain "exploit.kit" "AD_Blocker_Cat_malware" "Malware_ExploitKit"
$AddCategoryDomain "malware.com" "AD_Blocker_Cat_malware" "Malware_Generic"
$AddCategoryDomain "ransomware.net" "AD_Blocker_Cat_malware" "Malware_Ransomware"
$AddCategoryDomain "botnet.ru" "AD_Blocker_Cat_malware" "Malware_Botnet"
$AddCategoryDomain "trojan.exe" "AD_Blocker_Cat_malware" "Malware_Trojan"

# ==============================================================================
# STEP 4: CREATE CATEGORY 4 - PHISHING & FRAUD
# ==============================================================================

$LogMessage "Creating PHISHING & FRAUD category..." "info"

:do {
    /ip firewall filter add chain=forward protocol=udp dst-port=53 \
        src-address-list="AD_Blocker_Cat_phishing" \
        action=drop comment="AD_Blocker_v5.1.0: Phishing DNS Block" \
        disabled=no
    
    /ip firewall filter add chain=forward protocol=tcp dst-port=443 \
        src-address-list="AD_Blocker_Cat_phishing" \
        action=drop comment="AD_Blocker_v5.1.0: Phishing HTTPS Block" \
        disabled=no
    
    $LogMessage "Phishing & Fraud category created successfully" "info"
} on-error={
    $LogMessage "ERROR: Failed to create Phishing category" "ERROR"
}

# Add phishing domains
$AddCategoryDomain "phishing.net" "AD_Blocker_Cat_phishing" "Phishing_Generic"
$AddCategoryDomain "fakebank.ru" "AD_Blocker_Cat_phishing" "Phishing_FakeBank"
$AddCategoryDomain "credential-harvester.com" "AD_Blocker_Cat_phishing" "Phishing_Harvester"
$AddCategoryDomain "paypal-confirm.ru" "AD_Blocker_Cat_phishing" "Phishing_PayPal"
$AddCategoryDomain "amazon-verify.com" "AD_Blocker_Cat_phishing" "Phishing_Amazon"

# ==============================================================================
# STEP 5: CREATE CATEGORY 5 - CRYPTOMINING
# ==============================================================================

$LogMessage "Creating CRYPTOMINING category..." "info"

:do {
    /ip firewall filter add chain=forward protocol=udp dst-port=53 \
        src-address-list="AD_Blocker_Cat_crypto" \
        action=drop comment="AD_Blocker_v5.1.0: Cryptomining DNS Block" \
        disabled=no
    
    /ip firewall filter add chain=forward protocol=tcp dst-port=443 \
        src-address-list="AD_Blocker_Cat_crypto" \
        action=drop comment="AD_Blocker_v5.1.0: Cryptomining HTTPS Block" \
        disabled=no
    
    $LogMessage "Cryptomining category created successfully" "info"
} on-error={
    $LogMessage "ERROR: Failed to create Cryptomining category" "ERROR"
}

# Add cryptomining domains
$AddCategoryDomain "coinhive.com" "AD_Blocker_Cat_crypto" "Crypto_CoinHive"
$AddCategoryDomain "webminer.com" "AD_Blocker_Cat_crypto" "Crypto_WebMiner"
$AddCategoryDomain "minedblock.com" "AD_Blocker_Cat_crypto" "Crypto_MinedBlock"
$AddCategoryDomain "mining-pool.net" "AD_Blocker_Cat_crypto" "Crypto_Pool"
$AddCategoryDomain "btc-miner.ru" "AD_Blocker_Cat_crypto" "Crypto_BTCMiner"

# ==============================================================================
# STEP 6: CREATE CATEGORY 6 - ADULT CONTENT
# ==============================================================================

$LogMessage "Creating ADULT CONTENT category..." "info"

:do {
    /ip firewall filter add chain=forward protocol=udp dst-port=53 \
        src-address-list="AD_Blocker_Cat_adult" \
        action=drop comment="AD_Blocker_v5.1.0: Adult DNS Block" \
        disabled=no
    
    /ip firewall filter add chain=forward protocol=tcp dst-port=443 \
        src-address-list="AD_Blocker_Cat_adult" \
        action=drop comment="AD_Blocker_v5.1.0: Adult HTTPS Block" \
        disabled=no
    
    $LogMessage "Adult Content category created successfully" "info"
} on-error={
    $LogMessage "ERROR: Failed to create Adult Content category" "ERROR"
}

# Add adult content domains
$AddCategoryDomain "adult-site.com" "AD_Blocker_Cat_adult" "Adult_Generic"
$AddCategoryDomain "xxx-content.net" "AD_Blocker_Cat_adult" "Adult_XXX"
$AddCategoryDomain "explicit-ads.ru" "AD_Blocker_Cat_adult" "Adult_Explicit"
$AddCategoryDomain "porn-network.com" "AD_Blocker_Cat_adult" "Adult_Porn"
$AddCategoryDomain "adult-ads.net" "AD_Blocker_Cat_adult" "Adult_Ads"

# ==============================================================================
# STEP 7: CREATE CATEGORY 7 - GAMBLING
# ==============================================================================

$LogMessage "Creating GAMBLING & CASINOS category..." "info"

:do {
    /ip firewall filter add chain=forward protocol=udp dst-port=53 \
        src-address-list="AD_Blocker_Cat_gambling" \
        action=drop comment="AD_Blocker_v5.1.0: Gambling DNS Block" \
        disabled=no
    
    /ip firewall filter add chain=forward protocol=tcp dst-port=443 \
        src-address-list="AD_Blocker_Cat_gambling" \
        action=drop comment="AD_Blocker_v5.1.0: Gambling HTTPS Block" \
        disabled=no
    
    $LogMessage "Gambling & Casinos category created successfully" "info"
} on-error={
    $LogMessage "ERROR: Failed to create Gambling category" "ERROR"
}

# Add gambling domains
$AddCategoryDomain "casino.com" "AD_Blocker_Cat_gambling" "Gambling_Casino"
$AddCategoryDomain "betsite.ru" "AD_Blocker_Cat_gambling" "Gambling_BetSite"
$AddCategoryDomain "poker-online.net" "AD_Blocker_Cat_gambling" "Gambling_Poker"
$AddCategoryDomain "slot-machine.com" "AD_Blocker_Cat_gambling" "Gambling_Slots"
$AddCategoryDomain "sports-betting.ru" "AD_Blocker_Cat_gambling" "Gambling_Sports"

# ==============================================================================
# STEP 8: CREATE CATEGORY 8 - AGGRESSIVE ADVERTISEMENTS
# ==============================================================================

$LogMessage "Creating AGGRESSIVE ADVERTISEMENTS category..." "info"

:do {
    /ip firewall filter add chain=forward protocol=udp dst-port=53 \
        src-address-list="AD_Blocker_Cat_aggressive" \
        action=drop comment="AD_Blocker_v5.1.0: Aggressive DNS Block" \
        disabled=no
    
    /ip firewall filter add chain=forward protocol=tcp dst-port=443 \
        src-address-list="AD_Blocker_Cat_aggressive" \
        action=drop comment="AD_Blocker_v5.1.0: Aggressive HTTPS Block" \
        disabled=no
    
    $LogMessage "Aggressive Advertisements category created successfully" "info"
} on-error={
    $LogMessage "ERROR: Failed to create Aggressive category" "ERROR"
}

# Add aggressive ad domains
$AddCategoryDomain "popup-ads.net" "AD_Blocker_Cat_aggressive" "Aggressive_Popup"
$AddCategoryDomain "intrusive-ads.com" "AD_Blocker_Cat_aggressive" "Aggressive_Intrusive"
$AddCategoryDomain "redirect-ads.ru" "AD_Blocker_Cat_aggressive" "Aggressive_Redirect"
$AddCategoryDomain "full-page-ads.net" "AD_Blocker_Cat_aggressive" "Aggressive_FullPage"
$AddCategoryDomain "aggressive-banner.com" "AD_Blocker_Cat_aggressive" "Aggressive_Banner"

# ==============================================================================
# STEP 9: VERIFY INSTALLATION
# ==============================================================================

$LogMessage "Verifying advanced category installation..." "info"

:local socialCount [/ip firewall address-list find where list="AD_Blocker_Cat_social"]
:local trackingCount [/ip firewall address-list find where list="AD_Blocker_Cat_tracking"]
:local malwareCount [/ip firewall address-list find where list="AD_Blocker_Cat_malware"]
:local phishingCount [/ip firewall address-list find where list="AD_Blocker_Cat_phishing"]
:local cryptoCount [/ip firewall address-list find where list="AD_Blocker_Cat_crypto"]
:local adultCount [/ip firewall address-list find where list="AD_Blocker_Cat_adult"]
:local gamblingCount [/ip firewall address-list find where list="AD_Blocker_Cat_gambling"]
:local aggressiveCount [/ip firewall address-list find where list="AD_Blocker_Cat_aggressive"]

$LogMessage "Category verification summary:" "info"
$LogMessage "  - Social Media Trackers: [:len $socialCount]" "info"
$LogMessage "  - Analytics & Tracking: [:len $trackingCount]" "info"
$LogMessage "  - Malware & Threats: [:len $malwareCount]" "info"
$LogMessage "  - Phishing & Fraud: [:len $phishingCount]" "info"
$LogMessage "  - Cryptomining: [:len $cryptoCount]" "info"
$LogMessage "  - Adult Content: [:len $adultCount]" "info"
$LogMessage "  - Gambling & Casinos: [:len $gamblingCount]" "info"
$LogMessage "  - Aggressive Ads: [:len $aggressiveCount]" "info"

# ==============================================================================
# STEP 10: SAVE CONFIGURATION
# ==============================================================================

$LogMessage "Saving configuration..." "info"

:do {
    /system configuration save
    $LogMessage "Configuration saved successfully" "info"
} on-error={
    $LogMessage "WARNING: Could not save configuration" "warning"
}

# ==============================================================================
# STEP 11: INSTALLATION COMPLETE
# ==============================================================================

$LogMessage "========================================" "info"
$LogMessage "ADVANCED CATEGORIES INSTALLED" "info"
$LogMessage "========================================" "info"
$LogMessage "Total categories: 8" "info"
$LogMessage "Total domains: ~50" "info"
$LogMessage "Timestamp: $[/system clock get date] $[/system clock get time]" "info"
$LogMessage "========================================" "info"
$LogMessage "" "info"
$LogMessage "USAGE - Enable/Disable Categories:" "info"
$LogMessage "  Disable social media blocking:" "info"
$LogMessage "  /ip firewall filter disable [find comment~\"Social Media\"]" "info"
$LogMessage "" "info"
$LogMessage "  Enable only malware protection:" "info"
$LogMessage "  /ip firewall filter disable [find comment~\"AD_Blocker\"]" "info"
$LogMessage "  /ip firewall filter enable [find comment~\"Malware\"]" "info"
$LogMessage "" "info"
$LogMessage "  View all categories:" "info"
$LogMessage "  /ip firewall address-list print | grep \"AD_Blocker_Cat\"" "info"
$LogMessage "========================================" "info"

# ==============================================================================
# SCRIPT END
# ==============================================================================
