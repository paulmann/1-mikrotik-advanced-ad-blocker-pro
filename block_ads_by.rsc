# ================================================
# 1: MikroTik Advanced AD Blocker Pro - Belarusian Domains
# ================================================
# Repository: https://github.com/paulmann/1-mikrotik-advanced-ad-blocker-pro
# Author: Mikhail Deynekin [Deynekin.RU]
# Version: 5.0.0
# Date: 2025-12-18
# License: MIT
#
# DESCRIPTION:
# Comprehensive list of Belarusian advertisement domains for blocking.
# Includes regional ad networks and local media advertisers.
#
# USAGE:
# /tool fetch url="https://raw.githubusercontent.com/paulmann/1-mikrotik-advanced-ad-blocker-pro/main/block_ads_by.rsc"
# /import file-name=block_ads_by.rsc
# ================================================

:local addressListName "AD_Blocker_Domains"
:local markerComment "BY_Ad_Domain_v5"

:log info "Loading Belarusian advertisement domains..."

# Belarusian Advertisement Domains (2025 Edition)
:local byAdDomains {
    # Major Belarusian Media Portals
    "ad.tut.by"; "ads.tut.by"; "reklama.tut.by"; "banner.tut.by"; "promo.tut.by";
    "media.tut.by"; "ad.onliner.by"; "ads.onliner.by"; "promo.onliner.by";
    "banner.onliner.by"; "media.onliner.by"; "track.onliner.by";
    
    # Belarusian Media Networks
    "ad.media.by"; "ads.media.by"; "banner.media.by"; "ad.belarus.by";
    "ads.belarus.by"; "reklama.belarus.by"; "ad.belta.by"; "ads.belta.by";
    "promo.belta.by";
    
    # Contextual Advertisement Services
    "ad.ctr.by"; "ads.ctr.by"; "context.by"; "ad.context.by"; "ads.context.by";
    "cdn.context.by";
    
    # Social Media and Platforms
    "ad.vk.by"; "ads.vk.by"; "promo.vk.by"; "ad.ok.by"; "ads.ok.by"; "banner.ok.by";
    
    # E-commerce and Marketplaces
    "ad.kufar.by"; "ads.kufar.by"; "promo.kufar.by"; "ad.deal.by"; "ads.deal.by";
    "banner.deal.by"; "ad.av.by"; "ads.av.by"; "reklama.av.by";
    
    # Mobile Operators Advertisement
    "ad.mts.by"; "ads.mts.by"; "promo.mts.by"; "ad.velcom.by"; "ads.velcom.by";
    "banner.velcom.by"; "ad.life.by"; "ads.life.by"; "reklama.life.by";
    
    # Banner Networks
    "banner.by"; "bannery.by"; "reklama.by"; "areklama.by"; "breklama.by";
    "adnetwork.by"; "adsnetwork.by"; "byadvert.by";
    
    # New 2025 Networks
    "ad.vkplay.by"; "ads.vkplay.by"; "ad.ivi.by"; "ads.ivi.by"; "ad.megogo.by";
    "ads.megogo.by"; "ad.zala.by"; "ads.zala.by"
}

# Add domains to address list
:local addedCount 0
:local skippedCount 0

:foreach domain in=$byAdDomains do={
    :if ([/ip firewall address-list find list="$addressListName" address="$domain"] = "") do={
        /ip firewall address-list add list="$addressListName" address="$domain" comment="$markerComment"
        :set addedCount ($addedCount + 1)
    } else={
        :set skippedCount ($skippedCount + 1)
    }
}

/system configuration save
:log info "Belarusian domains added: $addedCount (skipped: $skippedCount)"

:put "======================================================"
:put "BELARUSIAN ADVERTISEMENT DOMAINS LOADED"
:put "======================================================"
:put "Total domains added: $addedCount"
:put "Duplicate domains skipped: $skippedCount"
:put "✓ Belarusian Media Portals (TUT.by, Onliner)"
:put "✓ Local E-commerce (Kufar, Deal.by, AV.by)"
:put "✓ Mobile Operators"
:put "✓ Regional and Local Advertisers"
:put "======================================================"