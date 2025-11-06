# Repository Restructure Instructions

## Overview
This repository is being converted from a multi-addon repository to a single-addon repository focused solely on **Guacamole-Client-WiFi**.

## New Repository Structure

The new structure will be:
```
hassio-guacamole-client/  (NEW repo name)
├── .github/
│   └── workflows/
│       └── build.yml
├── rootfs/
│   ├── etc/
│   │   ├── cont-init.d/
│   │   └── services.d/
│   └── usr/
├── Dockerfile
├── config.json
├── build.yaml
├── apparmor.txt
├── README.md
├── DOCS.md
├── SETUP-GUIDE.md
├── (all other .md files)
└── repository.json
```

## Migration Steps

### Step 1: Create New Repository on GitHub
```bash
# On GitHub: Create new repository
# Name: hassio-guacamole-client
# Owner: GraysonCAdams
# Description: Apache Guacamole 1.5.5 WiFi-optimized Home Assistant Add-on
```

### Step 2: Restructure Local Repository

#### Option A: Clean Start (Recommended)
```powershell
# In a new directory
cd ~
git clone https://github.com/GraysonCAdams/hassio-guacamole-client.git
cd hassio-guacamole-client

# Copy files from old repo
$OLD_REPO = "c:\Users\gca\Repos\hassio-addons\guacamole-client"

# Copy all addon files to root
Copy-Item "$OLD_REPO\*" -Recurse -Force -Exclude ".git"

# Copy workflow from old repo root
Copy-Item "c:\Users\gca\Repos\hassio-addons\.github" -Recurse -Force

# Copy repository.json from old repo root  
Copy-Item "c:\Users\gca\Repos\hassio-addons\repository.json" -Force
```

#### Option B: In-Place Restructure
```powershell
cd c:\Users\gca\Repos\hassio-addons

# Move guacamole-client contents to root
Get-ChildItem guacamole-client | Move-Item -Destination . -Force

# Remove old addon folders
Remove-Item -Recurse -Force baikal, guacamole, guacamole-server, hpessa, jdownloader2, mediaelch, oscam, ps3netsrv, tvheadend, guacamole-client

# Update git remote
git remote set-url origin https://github.com/GraysonCAdams/hassio-guacamole-client.git
```

### Step 3: Update Documentation References

Files already updated with new repository path:
- ✅ `repository.json` → `GraysonCAdams/hassio-guacamole-client`
- ✅ `config.json` → `ghcr.io/graysoncadams/hassio-guacamole-client-wifi`
- ✅ `.github/workflows/build-guacamole-client.yml` → Uses `github.repository_owner` (auto-updates)

Files that need manual updates:
- `README.md` - Update all GitHub links
- `DOCS.md` - Update repository references
- `SETUP-GUIDE.md` - Update clone/install instructions
- `BUILD.md` - Update repository paths
- `CHANGELOG.md` - Update image references
- All other .md files - Search for `d-two` and replace with `GraysonCAdams`

### Step 4: Update Workflow Path

Rename workflow file:
```powershell
# Rename for clarity since it's the only workflow now
Rename-Item ".github\workflows\build-guacamole-client.yml" "build.yml"
```

Update workflow to reference root instead of subdirectory:
```yaml
# Change from:
- 'guacamole-client/**'
context: ./guacamole-client
file: ./guacamole-client/Dockerfile

# To:
- '**'  # Or specific paths
context: .
file: ./Dockerfile
```

## Folders to Remove

These folders are no longer needed and should be deleted:

```powershell
# Old addon folders (if doing in-place restructure)
Remove-Item -Recurse -Force baikal
Remove-Item -Recurse -Force guacamole
Remove-Item -Recurse -Force guacamole-server
Remove-Item -Recurse -Force hpessa
Remove-Item -Recurse -Force jdownloader2
Remove-Item -Recurse -Force mediaelch
Remove-Item -Recurse -Force oscam
Remove-Item -Recurse -Force ps3netsrv
Remove-Item -Recurse -Force tvheadend
Remove-Item -Recurse -Force guacamole-client  # After moving contents out
```

## New Repository URL

**Old**: `https://github.com/d-two/hassio-addons`
**New**: `https://github.com/GraysonCAdams/hassio-guacamole-client`

## Home Assistant Installation

Users will add the repository:
```
https://github.com/GraysonCAdams/hassio-guacamole-client
```

The `repository.json` file at the root tells Home Assistant:
- Repository name
- Where to find addon config (in root `config.json`)
- Maintainer information

## Benefits of Single-Addon Repo

✅ **Cleaner structure** - All files at root level
✅ **Simpler workflow** - No subdirectory paths
✅ **Focused purpose** - Clear single-addon repo
✅ **Easier maintenance** - Less complexity
✅ **Better CI/CD** - Simpler build paths

## Post-Migration Checklist

- [ ] New GitHub repository created
- [ ] Files moved/copied to new structure
- [ ] All documentation updated with new paths
- [ ] Workflow file updated for root-level builds
- [ ] Test local build works
- [ ] Push to new repository
- [ ] Verify GitHub Actions build succeeds
- [ ] Make GHCR package public
- [ ] Test installation in Home Assistant
- [ ] Update any external links/references

## Quick Migration Command (Clean Start)

```powershell
# Create and setup new repo
cd ~\repos
git clone https://github.com/GraysonCAdams/hassio-guacamole-client.git
cd hassio-guacamole-client

# Copy everything from old repo's guacamole-client folder
Copy-Item "c:\Users\gca\Repos\hassio-addons\guacamole-client\*" -Recurse -Destination . -Force

# Copy workflow and repository.json
New-Item -ItemType Directory -Force -Path .github\workflows
Copy-Item "c:\Users\gca\Repos\hassio-addons\.github\workflows\build-guacamole-client.yml" .github\workflows\build.yml
Copy-Item "c:\Users\gca\Repos\hassio-addons\repository.json" .

# Commit and push
git add .
git commit -m "Initial commit: Guacamole-Client-WiFi addon"
git push origin main
```
