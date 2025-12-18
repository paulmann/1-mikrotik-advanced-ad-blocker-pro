# MikroTik Advanced AD Blocker Pro

**Version:** 5.0.0  
**Author:** Mikhail Deynekin ([Deynekin.RU](https://deynekin.com))  
**License:** MIT  
**Repository:** [github.com/paulmann/1-mikrotik-advanced-ad-blocker-pro](https://github.com/paulmann/1-mikrotik-advanced-ad-blocker-pro)

---

## 📋 Overview

**MikroTik Advanced AD Blocker Pro** is an enterprise-grade advertisement and unwanted content blocking solution engineered specifically for MikroTik RouterOS devices. This sophisticated system provides comprehensive DNS-based, HTTPS SNI-based, and firewall-level blocking with granular category-based controls, automatic update mechanisms, and multi-regional domain list support.

The system is architected to deliver production-ready protection with minimal performance overhead while maintaining complete transparency and control over blocked content. It combines advanced firewall rules, address-list based domain management, and intelligent pattern matching to effectively neutralize advertisement networks, tracking services, malware distribution points, and other unwanted traffic.

---

## 🎯 Problem Statement

Modern internet users face increasingly aggressive and sophisticated advertising delivery mechanisms:

### The Problem
- **Intrusive Advertisement Networks**: Yandex, Mail.ru, VK Ad platforms, and global networks (Google, Facebook) aggressively track user behavior
- **Privacy Invasion**: Analytics services continuously monitor user activities without meaningful consent
- **Performance Degradation**: Multiple advertisement delivery endpoints cause network latency and bandwidth waste
- **Security Threats**: Advertisement networks serve as distribution vectors for malware, phishing attempts, and exploit kits
- **Regional-Specific Issues**: Russian and Belarusian advertisers employ aggressive tactics with large domain portfolios
- **System Resource Consumption**: Each blocked advertisement connection frees CPU cycles and memory on network endpoints

### Current Solution Limitations
Standard approaches (browser extensions, DNS-based filtering services) have significant drawbacks:
- **Network-wide inefficiency**: Individual device protection leaves network vulnerable
- **Incomplete coverage**: Many tracking services operate via CDNs requiring deep packet inspection
- **Administrative overhead**: Centralized DNS filtering services provide limited control
- **Regional blocklists**: Generic global lists miss region-specific advertisers

---

## ✨ Solution: Core Features

### 🔥 Advanced Blocking Architecture

#### 1. **Multi-Layer Firewall Rules**
The system implements several blocking mechanisms at different OSI layers:

- **Layer 3 (RAW Chain)**: High-performance prerouting rules
- **Layer 4 (Filter Chain)**: DNS (UDP/TCP port 53) and HTTPS (TCP port 443) blocking
- **Intelligent Pattern Matching**: Content-based patterns for advertisement domain prefixes

#### 2. **Address-List Based Management**
- Centralized domain repository (`AD_Blocker_Domains`)
- Category-specific lists for granular control
- Automatic duplicate detection and prevention
- Hot-reload capability without router restart

#### 3. **Regional Domain Lists**

**Russian Domains:** 100+ networks (Yandex, Mail.ru, VK, analytics, e-commerce)  
**Belarusian Domains:** 50+ networks (regional media, mobile operators, e-commerce)

#### 4. **Category-Based Filtering**

Eight independent categories:
- Social Media Tracking
- Analytics & User Tracking
- Malware & Threats
- Phishing & Fraud
- Cryptomining
- Adult Content
- Gambling Platforms
- Aggressive/Intrusive Ads

#### 5. **Automatic Update System**

- Weekly regional updates
- Bi-weekly system updates
- Automatic scheduler integration
- No manual intervention required

#### 6. **Comprehensive Logging & Statistics**

- Real-time DNS query logging
- Daily blocking statistics
- Client IP tracking
- Performance metrics

---

## 📦 Installation Components

| Script | Purpose |
|--------|---------|
| `block_ads_import.rsc` | Core installer (main entry point) |
| `block_ads_ru.rsc` | Russian domain list |
| `block_ads_by.rsc` | Belarusian domain list |
| `block_ads_advanced.rsc` | Category-based blocking system |
| `block_ads_dns.rsc` | Statistics and logging module |
| `block_ads_update_import_rules.rsc` | System auto-updater (bi-weekly) |
| `block_ads_update_ru.rsc` | Russian list auto-updater (weekly) |
| `block_ads_update_by.rsc` | Belarusian list auto-updater (weekly) |
| `block_ads_cleanup.rsc` | Complete removal tool |

---

## 🚀 Quick Start Installation

### Prerequisites
- MikroTik RouterOS v6.45+ (recommended v7.0+)
- Internet connectivity
- Admin access to RouterOS CLI
- Minimum 2MB free disk space

### Standard Installation (5 minutes)

#### Step 1: Download Core Installer
```bash
/tool fetch url="https://raw.githubusercontent.com/paulmann/1-mikrotik-advanced-ad-blocker-pro/main/block_ads_import.rsc" dst-path="block_ads_import.rsc"
```

#### Step 2: Execute Core Installer
```bash
/import file-name=block_ads_import.rsc
```

#### Step 3: Import Regional Domain Lists

**For Russian regions:**
```bash
/tool fetch url="https://raw.githubusercontent.com/paulmann/1-mikrotik-advanced-ad-blocker-pro/main/block_ads_ru.rsc" dst-path="block_ads_ru.rsc"
/import file-name=block_ads_ru.rsc
```

**For Belarusian regions:**
```bash
/tool fetch url="https://raw.githubusercontent.com/paulmann/1-mikrotik-advanced-ad-blocker-pro/main/block_ads_by.rsc" dst-path="block_ads_by.rsc"
/import file-name=block_ads_by.rsc
```

#### Step 4: (Optional) Install Advanced Features

**Category-based filtering:**
```bash
/tool fetch url="https://raw.githubusercontent.com/paulmann/1-mikrotik-advanced-ad-blocker-pro/main/block_ads_advanced.rsc" dst-path="block_ads_advanced.rsc"
/import file-name=block_ads_advanced.rsc
```

**Logging and statistics:**
```bash
/tool fetch url="https://raw.githubusercontent.com/paulmann/1-mikrotik-advanced-ad-blocker-pro/main/block_ads_dns.rsc" dst-path="block_ads_dns.rsc"
/import file-name=block_ads_dns.rsc
```

#### Step 5: Enable Automatic Updates
```bash
/tool fetch url="https://raw.githubusercontent.com/paulmann/1-mikrotik-advanced-ad-blocker-pro/main/block_ads_update_import_rules.rsc" dst-path="block_ads_update_import_rules.rsc"
/import file-name=block_ads_update_import_rules.rsc
```

---

## 🔧 Advanced Configuration

### Viewing Active Rules
```bash
# List all blocking rules
/ip firewall filter print where comment~"AD_Blocker"

# Show rule count
/ip firewall filter print count-only where comment~"AD_Blocker"

# Display active domains
/ip firewall address-list print count-only where list="AD_Blocker_Domains"
```

### Category Management

**Disable specific category (e.g., social tracking):**
```bash
/ip firewall filter set [find comment~"Category social"] disabled=yes
```

**Re-enable category:**
```bash
/ip firewall filter set [find comment~"Category social"] disabled=no
```

### Manual Update Execution

**Update Russian domains immediately:**
```bash
/import block_ads_update_ru.rsc
```

**Update system rules immediately:**
```bash
/import block_ads_update_import_rules.rsc
```

### Monitoring Statistics

**View daily blocked request count:**
```bash
/ip firewall address-list print count-only where list="AD_Blocker_Stats"
```

**View latest log entries:**
```bash
/log print where message~"AD_Blocker" tail=20
```

---

## 📊 Performance Impact

| Metric | Impact |
|--------|--------|
| **CPU Usage** | +2-5% |
| **Memory** | +5-8MB |
| **Latency** | 0-1ms |
| **Throughput** | No degradation |
| **Boot Time** | +3-5s |

---

## 🛡️ Security Considerations

### Safety Mechanisms

- **Automatic backups** before major operations
- **Version validation** and compatibility checking
- **Error handling** with automatic rollback
- **Transaction-based** operations (all-or-nothing)

### Recommended Practices

1. **Regular Backups**
   ```bash
   /system backup save name="adblocker_backup_[date]" dont-encrypt=yes
   ```

2. **Monitor for Update Failures**
   ```bash
   /log print where message~"ERROR" tail=50
   ```

3. **Test Before Deployment** in lab environment

---

## 🐛 Troubleshooting

### Issue: Rules Not Working

**Check if rules are enabled:**
```bash
/ip firewall filter print where comment~"AD_Blocker" disabled=yes
/ip firewall address-list print count-only where list="AD_Blocker_Domains"
```

### Issue: Performance Degradation

**Check CPU usage:**
```bash
/system resource print
```

### Issue: Legitimate Sites Being Blocked

**Search for domain in address lists:**
```bash
/ip firewall address-list print where address~"example.com"
```

### Issue: Automatic Updates Not Running

**Check if schedulers exist:**
```bash
/system scheduler print where name~"adblocker"
```

---

## 📈 Extension & Customization

### Adding Custom Domains

**Add single domain:**
```bash
/ip firewall address-list add list="AD_Blocker_Domains" \
    address="customad.example.com" \
    comment="Custom AD block"
```

### Creating Custom Category

```bash
# Create new category list
/ip firewall address-list add list="AD_Blocker_Cat_Custom" \
    address="127.0.0.1" \
    comment="Custom Category - Your Description"

# Add blocking rule
/ip firewall filter add chain=forward protocol=udp dst-port=53 \
    src-address-list="AD_Blocker_Cat_Custom" \
    action=drop comment="AD_Blocker: Category custom - DNS" disabled=no
```

### Modifying Update Intervals

**Change weekly update to daily:**
```bash
/system scheduler set adblocker_update_ru interval=1d start-time=02:00:00
```

---

## 🗑️ Uninstallation

### Complete Removal (Recommended)

```bash
/import block_ads_cleanup.rsc
```

This will safely remove all components and create a backup before cleanup.

### Manual Removal (Advanced)

```bash
# Remove all rules
/ip firewall filter remove [find comment~"AD_Blocker"]
/ip firewall address-list remove [find list="AD_Blocker_Domains"]
/ip firewall raw remove [find comment~"AD_Blocker"]
/system scheduler remove [find name~"adblocker"]
/system script remove [find name~"adblocker"]
/system configuration save
```

---

## 📝 Changelog

### Version 5.0.0 (December 18, 2025)
- Enterprise-grade multi-layer blocking architecture
- 150+ Russian advertisement domains with wildcards
- 50+ Belarusian advertisement domains
- Advanced category-based filtering
- Automatic update system
- Comprehensive logging and statistics
- Complete removal toolkit
- Production-ready with backup and rollback

---

## 🤝 Contributing

To contribute improvements or domain lists:

1. Fork the repository
2. Create feature branch
3. Update domain lists with proper documentation
4. Submit pull request

---

## 📄 License

MIT License - Copyright © 2025 Mikhail Deynekin (Deynekin.RU)

---

## 📞 Support & Contact

**Author:** Mikhail Deynekin  
**Website:** [https://deynekin.com](https://deynekin.com)  
**Email:** mid1977@gmail.com  
**Repository:** [github.com/paulmann/1-mikrotik-advanced-ad-blocker-pro](https://github.com/paulmann/1-mikrotik-advanced-ad-blocker-pro)

---

**Last Updated:** December 18, 2025  
**Status:** Production Ready  
**Stability:** Stable