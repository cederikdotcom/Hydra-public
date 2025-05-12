# Windows 11 VR Setup Automation

This repository contains scripts and resources for automatically setting up and optimizing Windows 11 machines for VR gaming. The automation is designed to be run during Windows Audit Mode for optimal results.

## Project Website

Visit our project website at [win11setup.hydrahardware.io](https://win11setup.hydrahardware.io) for easy-to-follow instructions.

## Quick Start

1. During Windows setup, press **Ctrl+Shift+F3** at the OOBE screen to enter Audit Mode
2. Open Command Prompt and run:
   ```
   powershell -ExecutionPolicy Bypass -Command "iwr -useb https://win11setup.hydrahardware.io/setup.ps1 | iex"
   ```
3. After the script completes, use Sysprep to exit Audit Mode and create your user account

## Scripts Included

### setup.ps1

The main setup script that:
- Installs package managers (Chocolatey and WinGet)
- Installs latest GPU drivers
- Installs VR software and gaming platforms
- Optimizes Windows settings for VR performance
- Configures Wake-on-LAN
- Sets up PCIe performance (if supported)

### create-user.ps1

A helper script to create a local administrator account before exiting Audit Mode, which:
- Creates a custom local administrator account
- Optionally enables automatic login
- Helps bypass Microsoft Account requirements during OOBE

## Features

- **Driver Installation**: Automatically detects and installs the latest GPU drivers
- **VR Software**: Installs Steam, Oculus software, and other VR platforms
- **Performance Optimization**: Tweaks Windows settings for optimal VR performance
- **Wake-on-LAN**: Configures network adapters for remote wake capabilities
- **PCIe Gen4**: Attempts to enable PCIe Gen4 mode for compatible hardware

## What it installs

### Drivers
- nvidiadisplaydrivers for gpu through choco
- amd-ryzen-chipset for cpu through choco
- [x870 drivers for motherboard](https://rog.asus.com/motherboards/rog-strix/rog-strix-x870-f-gaming-wifi/helpdesk_download/)

### VR Software
- Steam
- [todo] steam vr
- [todo meta quest link to support tethered quest 3 as backup]

## Requirements

- Windows 11 installation (fresh install recommended)
- Internet connection during setup
- VR headset (Oculus/Meta Quest, Valve Index, HTC Vive, or Windows Mixed Reality)

## Security

All scripts are open source and can be reviewed before running. The scripts do not collect any personal data and make only the necessary changes for VR optimization.

## Contributing

We welcome contributions to improve these scripts! Please submit pull requests or open issues to suggest enhancements.

## License

This project is released under the MIT License. See the LICENSE file for details.

---

© 2025 HydraHardware. All rights reserved.
