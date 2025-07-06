# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Fedora bootc-based container image that creates a custom Linux desktop environment primarily focused on gaming and development. The project uses bootc (bootable container) technology to create an immutable OS image that can be deployed on bare metal systems or virtual machines.

## Architecture

The repository follows this structure:
- `Containerfile` - Main container definition with package installation and system configuration
- `usr/` - Directory containing custom files to be copied into the container:
  - `usr/bin/` - Custom scripts (steam-session, steamos-session-select, etc.)
  - `usr/lib/systemd/system/` - Systemd service and timer files
  - `usr/share/wayland-sessions/` - Desktop session definitions
- `.github/workflows/` - GitHub Actions for automated builds and releases

## Key Components

### Container Build
- Based on `quay.io/fedora/fedora-bootc:42`
- Installs desktop environments: COSMIC Desktop and Sway
- Includes gaming tools: Steam, GameScope, MangoHUD
- Adds development tools: Git, GitHub CLI, Tailscale
- Configures DNIe (Spanish digital ID) support

### Gaming Session
- `/usr/bin/steam-session:2` - Launches Steam in GameScope with MangoHUD
- `/usr/share/wayland-sessions/steam.desktop:5` - Desktop entry for Steam session
- `/usr/bin/steamos-session-select:2` - Utility to shutdown Steam

### System Services
- `bootc-fetch-updates.service` - Fetches bootc updates using `bootc update --quiet`
- `bootc-fetch-updates.timer` - Schedules updates (1h after boot, then every 8h with 2h random delay)
- The update timer is disabled by default in the container build

## Development Commands

### Container Build
```bash
# Build the container image
docker build -f Containerfile -t custom-os .

# Or using podman
podman build -f Containerfile -t custom-os .
```

### Testing
```bash
# Run container for testing
docker run -it --rm custom-os /bin/bash

# Test bootc functionality
bootc container lint
```

### Deployment
```bash
# Deploy to system (requires bootc-compatible system)
bootc switch ghcr.io/OWNER/REPO:latest
```

## CI/CD Pipeline

The project uses two GitHub Actions workflows:

1. **docker-publish.yml** - Builds and publishes container images:
   - Triggered on pushes to main, PRs, releases, and daily schedule
   - Uses GitHub Container Registry (ghcr.io)
   - Signs images with Cosign
   - For PRs: builds but doesn't push
   - For main/releases: builds, pushes, and signs

2. **create-release.yml** - Automated daily releases:
   - Runs daily at 5 AM UTC
   - Manages version bumping in VERSION file
   - Creates timestamped releases (v0.1.X.YYYYMMDDHHMM)
   - Generates release notes with commit history

## File Modifications

When modifying files:
- Container changes go in `Containerfile`
- Custom scripts and configs go in `usr/` directory structure
- System services belong in `usr/lib/systemd/system/`
- Desktop entries go in `usr/share/wayland-sessions/`

## Version Management

The project uses semantic versioning with automated daily builds:
- Base version stored in `VERSION` file
- Release versions include timestamp: `v{base_version}.{timestamp}`
- Version bumping happens automatically on code changes to release branches