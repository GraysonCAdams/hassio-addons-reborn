# Quick Setup Guide - Guacamole Client for macOS

## 🚀 5-Minute Setup

### 1. Install Addon
- Open Home Assistant
- Navigate to Settings → Add-ons → Add-on Store
- Install "Guacamole-Client"
- Click "START"

### 2. Login
- Open Web UI or Ingress
- Username: `guacadmin`
- Password: `guacadmin`
- **⚠️ Change password immediately!**

### 3. Enable macOS Screen Sharing
On your Mac:
- **System Settings** → **General** → **Sharing**
- Turn on **Screen Sharing**
- Click **(i)** next to Screen Sharing
- Enable: "VNC viewers may control screen with password"
- Set a VNC password

### 4. Create Connection in Guacamole

Click **Settings** (⚙️) → **Connections** → **New Connection**

#### Basic Settings
```
Name: My Mac
Protocol: VNC
```

#### Network
```
Hostname: 192.168.1.XXX    (your Mac's IP)
Port: 5900
```

#### Authentication
```
Password: [your VNC password]
```

#### Display (Expand)
```
Color depth: True color (24-bit)
Swap red/blue: Unchecked
Cursor: Local
Read-only: Unchecked
Force lossless: Checked
```

#### Performance (Expand) - **CRITICAL FOR LOW LATENCY**
```
Encodings: raw
Compression level: 0
Image quality: 9

✅ Disable audio
✅ Disable desktop wallpaper  
✅ Disable desktop effects
```

Click **Save** → Click connection to connect!

## ⚡ Optimal Addon Configuration

For lowest latency (LAN) - **ULTRA MODE**:

```yaml
vnc_compression_level: 0
vnc_image_quality: 9
color_depth: 16  # Or 24 for better colors
guacd_log_level: warning
enable_low_latency_mode: true
java_opts: "-Xms384m -Xmx768m -XX:+UseG1GC -XX:MaxGCPauseMillis=20"
```

**What this enables:**
- ✅ Zero compression (raw data transfer)
- ✅ Maximum image quality
- ✅ 16-bit color (lowest latency, or 24-bit for balance)
- ✅ 20ms GC pause limit (vs 50ms default)
- ✅ TCP optimizations (fast open, nodelay)
- ✅ 200 Tomcat threads (vs 150)
- ✅ 10s connection timeout (vs 20s)
- ✅ Optimized network buffers
- ✅ Minimal logging overhead

**Color Depth Guide:**
- **16-bit**: Absolute lowest latency (~30% less data)
- **24-bit**: Best balance (default) - recommended
- **32-bit**: Highest quality (only if quality > speed)

## 🎯 Performance Checklist

✅ Mac and client on same network (LAN)
✅ Both devices on wired Ethernet (not WiFi)
✅ VNC compression set to 0
✅ Encoding set to "raw"
✅ Image quality set to 9
✅ Force lossless enabled
✅ Mac wallpaper and effects disabled
✅ No other heavy apps running on Mac

## 🔧 Common Issues

### Can't connect to Mac
- Check Mac IP address: `System Settings → Network`
- Verify Screen Sharing is ON
- Check firewall: `System Settings → Network → Firewall`
- Ping Mac: `ping 192.168.1.XXX`

### Laggy/Slow
- Change encoding to "raw" (LAN) or "tight" (WAN)
- Set compression to 0 (LAN) or 3-5 (WAN)
- Disable Mac visual effects
- Check network speed
- Reduce color depth to 16-bit

### Poor Quality
- Increase image quality to 9
- Use 32-bit color depth
- Enable "Force lossless"
- Check network bandwidth

### Connection Drops
- Check Mac sleep settings: `System Settings → Lock Screen`
- Disable "Put hard disks to sleep when possible"
- Set display sleep to "Never" (while remote)

## 📊 Performance Modes

### Ultra-Low Latency (Gigabit LAN)
```
Encoding: raw
Compression: 0
Quality: 9
Color: 16-bit (or 24-bit for better colors)
Lossless: Yes
```
**Result**: ~5-10ms latency, 60 FPS, 30-50 Mbps (16-bit) or 45-75 Mbps (24-bit)

### Balanced (Fast WiFi/WAN)
```
Encoding: tight
Compression: 3
Quality: 7
Color: 24-bit
Lossless: No
```
**Result**: ~20-50ms latency, 30 FPS, 5-10 Mbps

### Bandwidth Saver (Slow Connection)
```
Encoding: tight
Compression: 7
Quality: 5
Color: 16-bit
Lossless: No
```
**Result**: ~100ms latency, 15 FPS, 1-3 Mbps

## 🎮 Use Cases

### Gaming/Video Editing
- Ultra-Low Latency mode
- Wired connection mandatory
- Disable all compression
- 32-bit color

### Office Work
- Balanced mode
- WiFi acceptable
- Moderate compression
- 24-bit color

### Emergency Access
- Bandwidth Saver mode
- Any connection works
- High compression
- 16-bit color

## 💡 Pro Tips

1. **Static IP**: Assign static IP to your Mac for reliable connections
2. **Keyboard**: Use local keyboard shortcuts in browser
3. **Clipboard**: Copy/paste works between devices
4. **Fullscreen**: F11 in browser for immersive experience
5. **Multiple Displays**: Create separate connections for each display
6. **SSH Fallback**: Create SSH connection as backup

## 🔐 Security

- **Change default password** immediately
- Use strong passwords for VNC
- Consider VPN for WAN access
- Enable 2FA on Home Assistant
- Don't expose Guacamole directly to internet

## 📱 Mobile Access

Works great on:
- iPad/iPhone (Safari)
- Android tablets (Chrome)
- Any device with browser

Recommended for mobile:
```
Encoding: tight
Compression: 5
Quality: 6
Color: 16-bit
```

## 🆘 Support

- **Logs**: Settings → Add-ons → Guacamole-Client → Log
- **Docs**: See DOCS.md for detailed configuration
- **Issues**: GitHub repository
- **Forum**: Home Assistant Community

---

**Quick Reference Card** | v1.5.5 | Optimized for macOS
