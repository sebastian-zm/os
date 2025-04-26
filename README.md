# Custom Fedora Kinoite OS Build

This repository contains configuration files to build a customized version of Fedora Kinoite with additional software pre-installed. The custom image includes gaming tools, development utilities, privacy-focused applications, and networking tools.

## Getting Cisco Packet Tracer

Due to licensing restrictions, Cisco Packet Tracer isn't included in this repository. To obtain it:

1. Visit [Cisco Networking Academy](https://www.netacad.com/)
2. Create a free account or log in to your existing account
3. Navigate to the "Resources" section
4. Download "Packet Tracer 8.2.2" or the latest available version
5. Save the `.deb` file in the root directory of this repository

## Using the OS Image

To use the custom OS image:

```bash
# Build using the Containerfile
podman build -t localhost/os .

# Switch to this image
bootc switch --transport containers-storage localhost/os
```

## Included Software

The custom image includes:

### Gaming
- Steam (with Gamescope session)
- MangoHud (performance overlay)

### Development
- Visual Studio Code
- VirtualBox
- Vim (set as default editor)
- FZF (fuzzy finder)
- Bat (enhanced cat)

### Others
- Cisco Packet Tracer (requires separate download)
- Tailscale
- LibreWolf Browser
- ProtonMail
- ProtonPass
- DNIe support (Spanish electronic ID)

## Using Steam in Gamescope Session

The build includes a dedicated Gamescope session for Steam that provides an optimized gaming experience:

1. Log out of your normal desktop session
2. At the login screen, click on the session type selector
3. Choose "Steam (Gamescope)"
4. Log in to start directly into the Steam interface running through Gamescope
