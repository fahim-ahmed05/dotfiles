# Android

## How to Enable Private DNS on Android or Google TV (Ad Blocking)

To enable Private DNS and use AdGuard as your DNS provider via ADB, run:

```bash
adb shell settings put global private_dns_mode hostname
adb shell settings put global private_dns_specifier dns.adguard-dns.com
```

## How to Verify It Worked

After running the commands, confirm the settings were applied:

```bash
adb shell settings get global private_dns_mode
adb shell settings get global private_dns_specifier
```

Expected output:

```bash
hostname
dns.adguard-dns.com
```

## How to Revert to Default Settings

To restore the default behavior (Automatic mode):

```bash
adb shell settings put global private_dns_mode opportunistic
```

To completely disable Private DNS:

```bash

adb shell settings put global private_dns_mode off
```

Source: [Reddit: [Guide] How to Enable Custom DNS on Android or Google TV to Block Ads](https://www.reddit.com/r/AndroidTV/comments/1lao1x1/guide_how_to_enable_custom_dns_on_android_or/)