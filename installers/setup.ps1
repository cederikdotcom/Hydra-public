# Windows 11 VR Machine Setup Script
# HydraHardware - https://win11setup.hydrahardware.io
# This script automates the setup of a Windows 11 machine for VR gaming during Audit Mode

# Set error action preference
$ErrorActionPreference = "Stop"

# Initialize
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    else {
        $input | Write-Output
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

# Display welcome message
Clear-Host
Write-ColorOutput Green "=================================="
Write-ColorOutput Green "  Windows 11 VR Machine Setup"
Write-ColorOutput Green "=================================="
Write-Output "This script will configure your Windows 11 machine for optimal VR performance."
Write-Output ""
Write-Output "The script will:"
Write-Output "  1. Install package managers (Chocolatey and WinGet)"
Write-Output "  2. Install latest drivers"
Write-Output "  3. Install VR software and gaming platforms"
Write-Output "  4. Optimize Windows settings for VR performance"
Write-Output "  5. Remove Windows bloatware"
Write-Output ""
Write-Output "Press Enter to continue or Ctrl+C to cancel..."
Read-Host

# Step 1: Install Package Managers
Write-ColorOutput Cyan "STEP 1: Installing Package Managers..."

# Check if Chocolatey is installed
if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Output "Installing Chocolatey..."
    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        Write-ColorOutput Green "Chocolatey installed successfully."
    } 
    catch {
        Write-ColorOutput Red "Failed to install Chocolatey: $_"
        exit
    }
} 
else {
    Write-Output "Chocolatey is already installed."
}

# Check if WinGet is installed
if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Output "Installing WinGet..."
    try {
        # Install via Chocolatey
        choco install winget -y
        Write-ColorOutput Green "WinGet installed successfully."
    } 
    catch {
        Write-ColorOutput Red "Failed to install WinGet: $_"
        Write-Output "This could be due to an older Windows version. Continuing with Chocolatey only."
    }
} 
else {
    Write-Output "WinGet is already installed."
}

# Step 2: Install Latest Drivers
Write-ColorOutput Cyan "STEP 2: Installing Latest Drivers..."
Write-Output "NVIDIA GPU RTX 5070ti and AMD CPU Ryzen 7 9800X3D assumed. Installing latest drivers..."
# Install NVIDIA GPU drivers
choco install nvidia-display-driver -y
# Install AMD CPU chipset drivers
choco install amd-ryzen-chipset -y

# Step 3: Install VR Software and Gaming Platforms
Write-ColorOutput Cyan "STEP 3: Installing VR Software and Gaming Platforms..."

# Install essential software
$software = @(
    "steam",
"steamcmd"
)

foreach ($app in $software) {
    Write-Output "Installing $app..."
    choco install $app -y
}

# Ensure Steam is fully updated during installation
Write-Output "Forcing Steam update during installation..."
Start-Process -FilePath "C:\Program Files (x86)\Steam\Steam.exe" -ArgumentList "-silent", "-login", "anonymous" -NoNewWindow -Wait
Start-Sleep -Seconds 5
$steamProcess = Get-Process -Name "Steam" -ErrorAction SilentlyContinue
if ($steamProcess) {
    $steamProcess | Stop-Process -Force
    Start-Sleep -Seconds 2
}
Write-Output "Steam update completed."

# Install additional utilities with WinGet if available
if (Get-Command winget -ErrorAction SilentlyContinue) {
    $wingetApps = @(
        "Microsoft.DotNet.DesktopRuntime.7",
        "Microsoft.VCRedist.2015+.x64"
    )
    
    foreach ($app in $wingetApps) {
        Write-Output "Installing $app..."
        winget install $app --accept-package-agreements --accept-source-agreements --silent
    }
}

# Step 4: Optimize Windows Settings for VR Performance
Write-ColorOutput Cyan "STEP 4: Optimizing Windows Settings for VR Performance..."

# Set power plan to high performance
Write-Output "Setting power plan to high performance..."
powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

# Disable visual effects for performance
Write-Output "Optimizing visual effects for performance..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Type DWORD -Value 2

# Disable Game DVR and Game Bar
Write-Output "Disabling Game Bar and Game DVR..."
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Type DWORD -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "UseNexusForGameBarEnabled" -Type DWORD -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AutoGameModeEnabled" -Type DWORD -Value 1

# Enable Hardware-Accelerated GPU Scheduling
Write-Output "Enabling Hardware-Accelerated GPU Scheduling..."
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Type DWORD -Value 2

# Disable unnecessary services
Write-Output "Disabling unnecessary services..."
$servicesToDisable = @("DiagTrack", "dmwappushservice", "SysMain")
foreach ($service in $servicesToDisable) {
    Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
    Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
}

# Configure registry for VR performance
Write-Output "Applying registry tweaks for VR performance..."
# Disable Full Screen Optimizations
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehaviorMode" -Type DWORD -Value 2
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_HonorUserFSEBehaviorMode" -Type DWORD -Value 1
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehavior" -Type DWORD -Value 2
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_DXGIHonorFSEWindowsCompatible" -Type DWORD -Value 1

# Set up Wake-on-LAN (as requested)
Write-Output "Configuring Wake-on-LAN..."
$nicRegPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002bE10318}"
Get-ChildItem -Path $nicRegPath -ErrorAction SilentlyContinue | 
    ForEach-Object {
        $nicID = $_.PSChildName
        if ($nicID -match "\d{4}") {
            # Enable WOL and disable power saving
            Set-ItemProperty -Path "$nicRegPath\$nicID" -Name "PnPCapabilities" -Type DWORD -Value 24 -ErrorAction SilentlyContinue
            Set-ItemProperty -Path "$nicRegPath\$nicID" -Name "WakeOnMagicPacket" -Type String -Value 1 -ErrorAction SilentlyContinue
            Set-ItemProperty -Path "$nicRegPath\$nicID" -Name "WakeOnPattern" -Type String -Value 1 -ErrorAction SilentlyContinue
        }
    }

# Set PCIe to Gen4 mode (if supported by hardware)
Write-Output "Attempting to set PCIe to Gen4 mode via registry (if supported)..."
# Note: This is hardware-dependent and might not work on all systems
try {
    New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Video\PCIe" -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Video\PCIe" -Name "Generation" -Type DWORD -Value 4 -ErrorAction SilentlyContinue
} catch {
    Write-Output "PCIe mode will need to be set manually in BIOS."
}

# Step 5: Remove Windows Bloatware
Write-ColorOutput Cyan "STEP 5: Removing Windows Bloatware..."

# List of bloatware apps to remove
$bloatwareApps = @(
    "Microsoft.3DBuilder",
    "Microsoft.BingNews",
    "Microsoft.BingWeather",
    "Microsoft.GetHelp",
    "Microsoft.Getstarted",
    "Microsoft.MicrosoftOfficeHub",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.MixedReality.Portal",
    "Microsoft.People",
    "Microsoft.SkypeApp",
    "Microsoft.WindowsAlarms",
    "Microsoft.WindowsFeedbackHub",
    "Microsoft.WindowsMaps",
    "Microsoft.WindowsSoundRecorder",
    "Microsoft.Xbox.TCUI",
    "Microsoft.XboxApp",
    "Microsoft.XboxGameOverlay",
    "Microsoft.XboxGamingOverlay",
    "Microsoft.XboxIdentityProvider",
    "Microsoft.XboxSpeechToTextOverlay",
    "Microsoft.YourPhone",
    "Microsoft.ZuneMusic",
    "Microsoft.ZuneVideo",
    "Microsoft.549981C3F5F10", # Cortana
    "Microsoft.Advertising.Xaml",
    "Microsoft.Wallet",
    "Microsoft.MicrosoftStickyNotes",
    "Microsoft.Windows.Photos",
    "Microsoft.WindowsCamera",
    "Microsoft.WindowsCalculator"
)

# Remove bloatware
foreach ($app in $bloatwareApps) {
    Write-Output "Removing $app..."
    
    # Try with Get-AppxPackage
    Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -ErrorAction SilentlyContinue
    
    # Try with WinGet if available
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget uninstall $app --silent --accept-source-agreements --force -ErrorAction SilentlyContinue
    }
}

# Disable Consumer Features
Write-Output "Disabling Windows consumer features..."
if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent")) {
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Force | Out-Null
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -Type DWORD -Value 1

# Disable Suggestions in Start Menu
Write-Output "Disabling suggestions and ads in Start Menu..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SystemPaneSuggestionsEnabled" -Type DWORD -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338388Enabled" -Type DWORD -Value 0

# Disable Activity History
Write-Output "Disabling Activity History..."
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -Type DWORD -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -Type DWORD -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "UploadUserActivities" -Type DWORD -Value 0

# Disable Customer Experience Improvement Program
Write-Output "Disabling Customer Experience Improvement Program..."
if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows")) {
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows" -Force | Out-Null
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows" -Name "CEIPEnable" -Type DWORD -Value 0

# Final Message
Write-ColorOutput Green "======================================"
Write-ColorOutput Green "Setup Complete!"
Write-ColorOutput Green "======================================"
Write-Output "Your Windows 11 machine has been optimized for VR gaming."
Write-Output ""
Write-Output "To exit Audit Mode and create a user account:"
Write-Output "1. Open Sysprep (C:\Windows\System32\Sysprep\sysprep.exe)"
Write-Output "2. Select 'Enter System Out-of-Box Experience (OOBE)'"
Write-Output "3. Check 'Generalize' only if you want to reset unique identifiers"
Write-Output "4. Set 'Shutdown Options' to 'Reboot'"
Write-Output "5. Click 'OK'"
Write-Output ""
Write-Output "After reboot, you'll be able to create your user account"
Write-Output "with all optimizations already in place."
Write-Output ""

# Create desktop shortcut to sysprep for convenience
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\Exit Audit Mode.lnk")
$Shortcut.TargetPath = "C:\Windows\System32\Sysprep\sysprep.exe"
$Shortcut.Save()
Write-Output "A shortcut to Sysprep has been created on the desktop."
Write-Output ""

$restart = Read-Host "Would you like to restart now? (y/n)"
if ($restart -eq 'y') {
    Restart-Computer
}