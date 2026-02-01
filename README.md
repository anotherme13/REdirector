# App Redirector - Magisk Module

> ⚠️ **DISCLAIMER: FOR EDUCATIONAL PURPOSES ONLY**
>
> This project is created **strictly for educational and research purposes**. It demonstrates Android internals, Magisk module development, and system-level app management techniques. Therefore, aware the importance of detecting rooted device or abnormal environment when developing some sensitive apps.
>
> **I am NOT responsible for any misuse of this software.** By using this module, you agree that:
> - You will only use it for learning and legitimate testing on your own devices
> - You understand the implications of modifying system behavior
> - Any consequences resulting from misuse are solely your responsibility
>
> **Use at your own risk.**

---

## 🛡️ Security Research Justification
#### How This Module Helps Security Research:

1. **Detection Testing**: By redirecting app launches, security researchers can test whether their apps properly detect when another process is interfering with the foreground activity, or running in a abnormal environment?

2. **Defense Validation**: Apps handling sensitive data (banking, authentication) should detect and prevent overlay attacks. This module helps validate those defenses.

3. **Attack Surface Analysis**: Understanding how foreground activity can be monitored and manipulated helps developers build more secure apps.



#### Real-World Impact:
- **Banking apps must detect root detection**, overlay attack, ... -> refuse to run in an abnormal environment.
- Payment apps need protection against clickjacking
- Authentication flows require secure UI rendering

**This module provides a controlled environment to test and improve app security against these attacks.**

---

## 📚 What You'll Learn

This module demonstrates:
- How Magisk modules work (service.sh, module.prop, late_start)
- Android Activity lifecycle and foreground detection
- Shell scripting on Android (dumpsys, pm, am commands)
- App interception and redirection techniques
- Logging mechanisms (logcat integration)
- Security implications of foreground monitoring

## 🎯 What it does

When user opens App A → Module detects → Launches App B instead!

This simulates how malicious software could interfere with app launches, helping security researchers test their defenses.

## 📝 Configuration

Edit `/data/adb/app_redirect_list.txt`:

```bash
# Format: source_package=target_package
# Example: com.example.source=com.example.target
```

## 📦 Installation

```bash
# Flash via Magisk Manager
adb push Redirector.zip /sdcard/Download/
# Then install from Magisk Manager → Modules → Install from storage
```

## 🎮 Usage

### Set up redirect rules:
```bash
# Add a redirect rule (replace with your test packages)
adb shell su -c "echo 'com.example.app=com.example.target' >> /data/adb/app_redirect_list.txt"
```

### Check logs:
```bash
adb logcat -s MagiskAppWatcher
```


## 📂 Files

| File | Purpose |
|------|---------|
| `service.sh` | Main script (runs on boot) |
| `module.prop` | Module metadata |
| `uninstall.sh` | Cleanup on removal |
| `/data/adb/app_redirect_list.txt` | Your redirect rules |

## 🗑️ Uninstallation

Simply remove from Magisk Manager. All redirects stop immediately.

## Author
**🔥 _Hi1uTr3n_**  

---

## ⚖️ License & Legal

```
MIT License - Educational Use Only

This software is provided "AS IS" without warranty of any kind.
The author disclaims all liability for any damages or misuse.
Only use on devices you own and have permission to modify.
```

---
