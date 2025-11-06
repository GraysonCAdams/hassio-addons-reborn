# Quick Reference - Guacamole-Client-WiFi

## Add-on Name Changed ✅
- **Old name:** `Guacamole-Client`
- **New name:** `Guacamole-Client-WiFi`
- **New slug:** `guacamole-client-wifi`
- **Image:** `ghcr.io/d-two/hassio-guacamole-client-wifi`

This allows it to install alongside your existing Guacamole Client installation without conflicts.

---

## GitHub Setup (One-Time)

### 1. Enable GitHub Actions
```
Repository → Settings → Actions → General
✅ Allow all actions and reusable workflows
✅ Read and write permissions
✅ Allow GitHub Actions to create and approve pull requests
Save
```

### 2. Trigger Build
```bash
# Option A: Push changes
git add .
git commit -m "Add Guacamole-Client-WiFi"
git push origin main

# Option B: Manual trigger
GitHub → Actions → Build Guacamole Client → Run workflow
```

### 3. Wait for Build
- Takes ~15-20 minutes per architecture (4 total)
- Builds run in parallel
- Monitor in Actions tab

### 4. Make Package Public
```
GitHub → Your profile → Packages → hassio-guacamole-client-wifi
→ Package settings → Change visibility → Public
```

---

## Home Assistant Installation

### 1. Add Repository
```
Settings → Add-ons → Add-on Store → ⋮ → Repositories
Add: https://github.com/d-two/hassio-addons
```

### 2. Install Add-on
```
Find "Guacamole-Client-WiFi" in store
Click → Install (takes 2-5 min)
```

### 3. Configure
**Default WiFi/Pi4 config (Already optimal):**
```yaml
vnc_compression_level: 5
vnc_image_quality: 6
color_depth: 16
enable_wifi_optimization: true
enable_low_latency_mode: false
```

**Or for Gigabit LAN:**
```yaml
vnc_compression_level: 0
vnc_image_quality: 9
color_depth: 24
enable_wifi_optimization: false
enable_low_latency_mode: true
```

### 4. Start & Access
```
Click Start → Wait for logs
Open Web UI (or use Ingress)
Login: guacadmin / guacadmin
CHANGE PASSWORD IMMEDIATELY!
```

---

## Key Files Modified

| File | Change |
|------|--------|
| `config.json` | Name, slug, image updated |
| `.github/workflows/build-guacamole-client.yml` | Image name updated |
| `Dockerfile` | `-j2` for ARM, `su-exec` added |
| `repository.json` | Already correct |
| `README.md` (root) | New addon mentioned |

---

## Workflow Location

✅ **CORRECT:** `.github/workflows/build-guacamole-client.yml` (at repo root)
❌ **REMOVED:** `guacamole-client/.github/` (duplicate deleted)

Workflows must be at repository root, not inside subdirectories.

---

## Default Credentials

```
Username: guacadmin
Password: guacadmin
```

**⚠️ Change immediately after first login!**

---

## Build Time Expectations

| Platform | Time |
|----------|------|
| GitHub Actions (all 4 arch) | 60-90 min total |
| Local x86_64 | 5-10 min |
| Local Pi 4 | 30-45 min |

---

## Common Issues & Fixes

**Add-on not in store:**
- Verify repository URL is correct
- Refresh store page
- Check `repository.json` exists at root

**Can't pull image:**
- Make GHCR package public
- Check image name in `config.json` matches package

**Out of memory on Pi 4:**
```yaml
java_opts: "-Xms128m -Xmx256m -XX:+UseG1GC -XX:MaxGCPauseMillis=100"
```

**Laggy over WiFi:**
```yaml
vnc_compression_level: 7
vnc_image_quality: 4
color_depth: 16
```

---

## Architecture Support

| Arch | Platform | Example |
|------|----------|---------|
| aarch64 | ARM 64-bit | Pi 4 64-bit, Apple Silicon |
| amd64 | x86 64-bit | Intel NUC, Desktop PC |
| armv7 | ARM 32-bit v7 | Pi 4 32-bit, Pi 3 |
| armhf | ARM 32-bit v6 | Pi Zero, Pi 1 |

---

## Documentation

- **[SETUP-GUIDE.md](SETUP-GUIDE.md)** - Complete walkthrough (you are here in summary)
- **[RASPBERRY-PI.md](RASPBERRY-PI.md)** - Pi 4 optimization guide
- **[WIFI-OPTIMIZATION.md](WIFI-OPTIMIZATION.md)** - WiFi tuning
- **[DOCS.md](DOCS.md)** - Configuration reference
- **[BUILD.md](BUILD.md)** - Build details
- **[QUICKSTART.md](QUICKSTART.md)** - 5-minute setup

---

## Complete Step-by-Step

1. ✅ Enable GitHub Actions (Settings)
2. ✅ Push code or trigger workflow manually
3. ⏳ Wait ~90 minutes for all builds
4. ✅ Make package public on GHCR
5. ✅ Add repository to Home Assistant
6. ✅ Install Guacamole-Client-WiFi
7. ✅ Use default config (WiFi mode)
8. ✅ Start addon
9. ✅ Change password
10. ✅ Create connections and enjoy!

**Total time: ~2 hours (mostly automated)**
