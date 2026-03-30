# Android

## **How to Enable Custom DNS on Android or Google TV to Block Ads**

To enable a custom DNS via ADB, you need to run two distinct commands. Press **Enter** after each one:

**Command 1:** (This turns on the custom DNS mode)
```bash
adb shell settings put global private_dns_mode hostname
```

**Command 2:** (This tells it to use AdGuard)
```bash
adb shell settings put global private_dns_specifier dns.adguard-dns.com
```

Alternatively, if you want to run them on a single line, you can separate them with `&&` like this:
```bash
adb shell settings put global private_dns_mode hostname && adb shell settings put global private_dns_specifier dns.adguard-dns.com
```

### **How to check if it actually worked**
Once you run the commands, you can verify that your device saved the settings by running these two "get" commands. They should output `hostname` and `dns.adguard-dns.com` respectively:

```bash
adb shell settings get global private_dns_mode
adb shell settings get global private_dns_specifier
```

### **How to Revert to Default Settings**
If you ever want to disable the custom DNS and go back to the standard behavior, run this command to set it back to "Automatic" (the Android default):

```bash
adb shell settings put global private_dns_mode opportunistic
```

*(Note: If you want to turn Private DNS completely off instead of automatic, replace `opportunistic` with `off` in the command above).*

Source: [Reddit: [Guide] How to Enable Custom DNS on Android or Google TV to Block Ads](https://www.reddit.com/r/AndroidTV/comments/1lao1x1/guide_how_to_enable_custom_dns_on_android_or/)