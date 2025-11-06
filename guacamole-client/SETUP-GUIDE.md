# Complete Setup Guide - Guacamole-Client-WiFi Add-on

This guide walks you through setting up the repository, building the Docker images, and installing the add-on in Home Assistant.

## Table of Contents

1. [GitHub Repository Setup](#github-repository-setup)
2. [Build the Docker Images](#build-the-docker-images)
3. [Install the Add-on in Home Assistant](#install-the-add-on-in-home-assistant)
4. [Configure the Add-on](#configure-the-add-on)
5. [Troubleshooting](#troubleshooting)

---

## GitHub Repository Setup

### Step 1: Fork or Clone the Repository

If you haven't already:

```bash
git clone https://github.com/d-two/hassio-addons.git
cd hassio-addons
```

### Step 2: Enable GitHub Container Registry (GHCR)

The workflow publishes Docker images to GHCR. No special setup needed - GHCR is automatically available for your repository.

**Required Permissions:**
- The workflow uses `GITHUB_TOKEN` which is automatically provided
- The workflow has `packages: write` permission to publish images

### Step 3: Enable GitHub Actions

1. Go to your repository on GitHub
2. Click **Settings** → **Actions** → **General**
3. Under "Actions permissions", select:
   - ✅ **Allow all actions and reusable workflows**
4. Under "Workflow permissions", select:
   - ✅ **Read and write permissions**
   - ✅ **Allow GitHub Actions to create and approve pull requests**
5. Click **Save**

### Step 4: Verify Repository Secrets

No custom secrets needed! The workflow uses the built-in `GITHUB_TOKEN`.

---

## Build the Docker Images

### Option 1: Automatic Build via GitHub Actions (Recommended)

The easiest way is to trigger the workflow:

**Method A: Push to main branch**
```bash
git add .
git commit -m "Add Guacamole-Client-WiFi addon"
git push origin main
```

**Method B: Manual trigger**
1. Go to **Actions** tab in your GitHub repository
2. Click **Build Guacamole Client** workflow
3. Click **Run workflow** → **Run workflow**

The build will:
- Build 4 architectures in parallel (aarch64, amd64, armhf, armv7)
- Take approximately **15-20 minutes** per architecture
- Push images to `ghcr.io/d-two/hassio-guacamole-client-wifi:latest-{arch}`
- Create a multi-arch manifest at `ghcr.io/d-two/hassio-guacamole-client-wifi:latest`

**Monitor the Build:**
1. Go to **Actions** tab
2. Click on the running workflow
3. Watch the progress of each architecture build

### Option 2: Local Build (For Testing)

Build locally on your machine:

```bash
cd guacamole-client

# For your current architecture
docker build -t guacamole-client-wifi:test \
  --build-arg BUILD_FROM=ghcr.io/hassio-addons/base:15.0.1 \
  --build-arg BUILD_ARCH=$(uname -m) \
  .

# Test run locally
docker run -p 8080:8080 guacamole-client-wifi:test
```

**Note:** Local builds are faster (5-10 min on x86_64) but only for one architecture.

### Step 5: Verify Images Published

After the workflow completes:

1. Go to your repository **home page**
2. Look for **Packages** section on the right sidebar
3. You should see: `hassio-guacamole-client-wifi`
4. Click on it to see all tags:
   - `latest` (multi-arch manifest)
   - `latest-aarch64`
   - `latest-amd64`
   - `latest-armhf`
   - `latest-armv7`

### Step 6: Make Package Public (Important!)

By default, GHCR packages are private. Make it public so Home Assistant can pull it:

1. Go to the package: `https://github.com/users/d-two/packages/container/hassio-guacamole-client-wifi`
2. Click **Package settings** (gear icon)
3. Scroll down to **Danger Zone**
4. Click **Change visibility**
5. Select **Public**
6. Type the repository name to confirm
7. Click **I understand, change package visibility**

---

## Install the Add-on in Home Assistant

### Method 1: Install from Local Repository (Development)

If you're developing/testing:

1. Open **Home Assistant**
2. Go to **Settings** → **Add-ons** → **Add-on Store**
3. Click the **⋮** (three dots) in the top right
4. Select **Repositories**
5. Add: `https://github.com/d-two/hassio-addons`
6. Click **Add** → **Close**
7. Refresh the page
8. Scroll down to find **Guacamole-Client-WiFi**
9. Click on it → **Install**

### Method 2: Install from GitHub (Published Repository)

For production use:

1. Push your repository to GitHub
2. In Home Assistant:
   - Go to **Settings** → **Add-ons** → **Add-on Store**
   - Click **⋮** → **Repositories**
   - Add: `https://github.com/d-two/hassio-addons`
3. The add-on will appear in the store
4. Click **Guacamole-Client-WiFi** → **Install**

**Installation Time:**
- **Raspberry Pi 4**: 2-5 minutes (image download)
- **x86_64**: 1-3 minutes

### Step 7: Repository Configuration File

Your repository needs a `repository.json` at the root. Update it:

```json
{
  "name": "d-two Home Assistant Add-ons",
  "url": "https://github.com/d-two/hassio-addons",
  "maintainer": "d-two <the.dtwo@gmail.com>"
}
```

This file tells Home Assistant about your add-on repository.

---

## Configure the Add-on

### Step 1: Open Add-on Configuration

1. Go to **Settings** → **Add-ons**
2. Click **Guacamole-Client-WiFi**
3. Go to **Configuration** tab

### Step 2: Choose Your Configuration Profile

#### For Raspberry Pi 4 or WiFi Users (Default - Already Optimized)

The default settings are perfect:

```yaml
vnc_compression_level: 5
vnc_image_quality: 6
color_depth: 16
enable_wifi_optimization: true
enable_low_latency_mode: false
java_opts: "-Xms256m -Xmx384m -XX:+UseG1GC -XX:MaxGCPauseMillis=100"
connection_retry_count: 5
connection_retry_wait: 2000
```

Just click **Save** and **Start**!

#### For Gigabit LAN Users (Optional Ultra-Low Latency)

If you have wired gigabit connection on the same network:

```yaml
vnc_compression_level: 0
vnc_image_quality: 9
color_depth: 24
enable_wifi_optimization: false
enable_low_latency_mode: true
java_opts: "-Xms384m -Xmx768m -XX:+UseG1GC -XX:MaxGCPauseMillis=20"
rdp_disable_compression: true
rdp_bitmap_cache: true
rdp_offscreen_cache: true
rdp_glyph_cache: true
```

### Step 3: Start the Add-on

1. Click **Start**
2. Wait for logs to show:
   ```
   [INFO] PostgreSQL initialized
   [INFO] Guacamole configured
   [INFO] Tomcat started successfully
   ```
3. Go to **Info** tab
4. Click **Open Web UI** or use **Ingress**

### Step 4: Initial Login

**Default Credentials:**
- **Username:** `guacadmin`
- **Password:** `guacadmin`

**⚠️ IMPORTANT:** Change the password immediately!

1. Click **guacadmin** (top right)
2. Click **Settings**
3. Click **Preferences**
4. Enter new password
5. **Save**

### Step 5: Create a Connection

1. Click **Settings** (top right)
2. Click **Connections** → **New Connection**

**For VNC (WiFi Optimized - Recommended):**

```
Name: My Mac Mini
Protocol: VNC
Hostname: 192.168.1.100
Port: 5900
Password: [your VNC password]

Parameters:
  Enable audio: Yes (if needed)
  Color depth: 16-bit (default)
  Swap red/blue: No
  Cursor: Remote
  Read-only: No
  
Compression:
  Enable compression: Yes
  Compression level: 5
  Image quality: 6
```

**For RDP (WiFi Optimized):**

```
Name: Windows Desktop
Protocol: RDP
Hostname: 192.168.1.101
Port: 3389
Username: your-username
Password: your-password

Parameters:
  Security mode: Any
  Ignore server certificate: Yes (for self-signed)
  
Performance:
  Enable wallpaper: No
  Enable theming: No
  Enable font smoothing: No (WiFi)
  Enable full window drag: No (WiFi)
  Enable desktop composition: No (WiFi)
  Disable bitmap caching: No
  Disable offscreen caching: No
  Disable glyph caching: No
```

### Step 6: Connect

1. Go back to **Home**
2. Click your connection
3. You should see your remote desktop!

---

## Troubleshooting

### Build Issues

**Problem: Workflow fails with "permission denied"**

Solution:
- Check **Settings** → **Actions** → **General**
- Ensure "Read and write permissions" is enabled
- Re-run the workflow

**Problem: Package not found when installing**

Solution:
- Make the GHCR package **public** (see Step 6 above)
- Verify the image name in `config.json` matches your package

**Problem: Build times out on ARM**

Solution:
- The workflow uses QEMU which is slower
- ARM builds can take 20-30 minutes
- Wait patiently or build locally on a Pi 4

### Installation Issues

**Problem: Add-on not showing in store**

Solution:
- Verify `repository.json` exists at repo root
- Check repository URL is correct
- Refresh the Add-on Store page
- Check Home Assistant logs for errors

**Problem: Add-on fails to start on Pi 4**

Solution:
- Check available RAM: `free -h`
- Reduce memory in config:
  ```yaml
  java_opts: "-Xms128m -Xmx256m -XX:+UseG1GC -XX:MaxGCPauseMillis=100"
  ```
- Disable other resource-intensive add-ons

**Problem: "Out of memory" during build on Pi 4**

Solution:
- Don't build locally on Pi 4 with <4GB RAM
- Use GitHub Actions instead (builds on x86_64 with QEMU)
- Or increase swap space (see [RASPBERRY-PI.md](RASPBERRY-PI.md))

### Connection Issues

**Problem: Can't connect to VNC/RDP server**

Solution:
- Verify the target machine's IP address
- Check firewall allows VNC (5900) or RDP (3389)
- Test with another VNC/RDP client first
- Check Guacamole logs for connection errors

**Problem: Laggy performance over WiFi**

Solution:
- Verify WiFi optimization is enabled
- Lower quality settings:
  ```yaml
  vnc_compression_level: 7
  vnc_image_quality: 4
  color_depth: 16
  ```
- Check WiFi signal strength (-60 dBm or better)
- Use 5GHz WiFi if possible

**Problem: Connection drops frequently**

Solution:
- Increase retry settings:
  ```yaml
  connection_retry_count: 10
  connection_retry_wait: 3000
  ```
- Check network stability with `ping -c 100 [target-ip]`
- Consider powerline adapters if WiFi is unstable

### Performance Issues

**Problem: High CPU usage on Pi 4**

Solution:
- Ensure WiFi optimization is enabled
- Limit concurrent connections to 1-2
- Close other applications
- Monitor with `top` command

**Problem: Memory warnings in logs**

Solution:
- Reduce Java heap:
  ```yaml
  java_opts: "-Xms128m -Xmx256m -XX:+UseG1GC -XX:MaxGCPauseMillis=100"
  ```
- Close unused connections in Guacamole
- Restart the add-on periodically

---

## Quick Reference Commands

### View Add-on Logs
```bash
# From Home Assistant SSH/Terminal
docker logs addon_[slug]

# Or from Settings → Add-ons → Guacamole-Client-WiFi → Logs
```

### Check Resource Usage
```bash
# On Home Assistant host
docker stats addon_[slug]

# Memory check
free -h
```

### Force Rebuild Images
```bash
# Push a change to trigger workflow
git commit --allow-empty -m "Trigger rebuild"
git push origin main
```

### Test Network Performance
```bash
# Test latency to target
ping -c 100 192.168.1.100

# Test bandwidth
iperf3 -c 192.168.1.100
```

---

## Additional Resources

- **[RASPBERRY-PI.md](RASPBERRY-PI.md)** - Pi 4 specific guide
- **[WIFI-OPTIMIZATION.md](WIFI-OPTIMIZATION.md)** - WiFi tuning guide
- **[DOCS.md](DOCS.md)** - Configuration reference
- **[PERFORMANCE.md](PERFORMANCE.md)** - Performance benchmarks
- **[BUILD.md](BUILD.md)** - Build details

---

## Support

If you encounter issues:

1. Check the [Troubleshooting](#troubleshooting) section above
2. Review add-on logs for errors
3. Check GitHub Actions workflow logs for build issues
4. Verify GHCR package is public
5. Open an issue on GitHub with:
   - Home Assistant version
   - Hardware (Pi 4, x86_64, etc.)
   - Add-on logs
   - Network setup (WiFi, LAN, cross-network)

---

## Summary Checklist

- [ ] Enable GitHub Actions in repository settings
- [ ] Set workflow permissions to "Read and write"
- [ ] Trigger workflow build (push or manual)
- [ ] Wait for all 4 architectures to build (~20 min each)
- [ ] Make GHCR package public
- [ ] Add repository to Home Assistant
- [ ] Install Guacamole-Client-WiFi add-on
- [ ] Configure based on your setup (WiFi or LAN)
- [ ] Start add-on and check logs
- [ ] Change default password
- [ ] Create VNC/RDP connections
- [ ] Test and enjoy!

**Estimated Total Time:**
- GitHub setup: 5 minutes
- Image build: 60-90 minutes (parallel builds)
- Add-on install: 5 minutes
- Configuration: 10 minutes
- **Total: ~2 hours** (mostly automated)
