# ================================================
# 1: MikroTik Advanced AD Blocker Pro - Russian Domains
# ================================================
# Repository: https://github.com/paulmann/1-mikrotik-advanced-ad-blocker-pro
# Author: Mikhail Deynekin [Deynekin.RU]
# Version: 5.0.0
# Date: 2025-12-18
# License: MIT
#
# DESCRIPTION:
# Comprehensive list of Russian advertisement domains for blocking.
# Includes major ad networks, tracking services, and regional advertisers.
# Updated regularly with new Russian ad domains.
#
# FEATURES:
# - Major Russian ad networks (Yandex, Mail.ru, VK)
# - Regional advertisers and trackers
# - E-commerce advertisement domains
# - Mobile advertisement services
#
# USAGE:
# /tool fetch url="https://raw.githubusercontent.com/paulmann/1-mikrotik-advanced-ad-blocker-pro/main/block_ads_ru.rsc"
# /import file-name=block_ads_ru.rsc
#
# Update automatically:
# /import block_ads_update_ru.rsc
# ================================================

:local addressListName "AD_Blocker_Domains"
:local markerComment "RU_Ad_Domain_v5"

:log info "Loading Russian advertisement domains..."

# Russian Advertisement Domains (2025 Edition)
:local ruAdDomains {
    # Yandex Advertisement Network
    "an.yandex.ru"; "mc.yandex.ru"; "bs.yandex.ru"; "direct.yandex.ru"; "ad.yandex.ru";
    "mobile.yandex.ru"; "metrika.yandex.ru"; "webmaster.yandex.ru"; "adv.yandex.ru";
    "promo.yandex.ru"; "ads.yandex.ru"; "adfox.yandex.ru";
    
    # Mail.ru / VK Networks
    "ad.mail.ru"; "ads.adfox.ru"; "ads.vk.com"; "ads.vkontakte.ru"; "ads.my.com";
    "rtb.mail.ru"; "pub.mail.ru"; "partner.mail.ru"; "top-fwz1.mail.ru";
    "advertising.mail.ru"; "promo.mail.ru"; "banner.mail.ru";
    
    # Rambler Media Network
    "ad.rambler.ru"; "ads.rambler.ru"; "counter.rambler.ru"; "top.rambler.ru";
    "banner.rambler.ru"; "media.rambler.ru";
    
    # AdRiver Ecosystem
    "ad.adriver.ru"; "www.adriver.ru"; "servedby.adriver.ru"; "track.adriver.ru";
    "st.adriver.ru"; "cdn.adriver.ru";
    
    # MyTarget
    "ad.mytarget.ru"; "target.my.com"; "mytarget.ru"; "cdn.myarget.ru"; "api.myarget.ru";
    
    # Russian Platforms
    "ad.sbermegamarket.ru"; "ads.ozon.ru"; "ad.wildberries.ru"; "ads.dns-shop.ru";
    "ad.citilink.ru"; "ad.avito.ru"; "ad.yandex.market"; "ad.youla.ru";
    
    # Video Advertisement
    "video.adfox.ru"; "videoads.yandex.ru"; "adv.video.yandex.ru"; "video.rambler.ru";
    "video.mail.ru"; "ads.video.ru";
    
    # Analytics and Tracking
    "stat.tns-counter.ru"; "stat.rambler.ru"; "top.mail.ru"; "counter.yadro.ru";
    "log.mail.ru"; "track.mail.ru"; "metric.yandex.ru"; "analytics.yandex.ru"; "stats.vk.com"
}

# Add domains to address list
:local addedCount 0
:local skippedCount 0

:foreach domain in=$ruAdDomains do={
    :if ([/ip firewall address-list find list="$addressListName" address="$domain"] = "") do={
        /ip firewall address-list add list="$addressListName" address="$domain" comment="$markerComment"
        :set addedCount ($addedCount + 1)
    } else={
        :set skippedCount ($skippedCount + 1)
    }
}

/system configuration save
:log info "Russian domains added: $addedCount (skipped: $skippedCount)"

:put "======================================================"
:put "RUSSIAN ADVERTISEMENT DOMAINS LOADED"
:put "======================================================"
:put "Total domains added: $addedCount"
:put "Duplicate domains skipped: $skippedCount"
:put "✓ Yandex Advertisement Network"
:put "✓ Mail.ru / VK Networks"
:put "✓ Rambler Media"
:put "✓ Major Russian E-commerce"
:put "✓ Analytics and Tracking"
:put "======================================================"