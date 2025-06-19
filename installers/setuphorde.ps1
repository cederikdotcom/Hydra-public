# Windows 11 HYDRA Unit Setup Script
# HydraHardware - https://win11setup.hydrahardware.io
# This script automates the setup of a Windows 11 machine as a HYDRA unit during Audit Mode

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
Write-ColorOutput Green "  Windows 11 HYDRA Unit Setup"
Write-ColorOutput Green "=================================="
Write-Output "This script will configure your Windows 11 machine as a HYDRA unit for optimal immersive experiences."
Write-Output ""
Write-Output "The script will:"
Write-Output "  1. Install package managers (Chocolatey and WinGet)"
Write-Output "  2. Install latest drivers"
Write-Output "  3. Install HYDRA software and experience platforms"
Write-Output "  4. Configure HYDRA horde participation"
Write-Output "  5. Optimize Windows settings for immersive experience performance"
Write-Output "  6. Remove Windows bloatware"
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
Write-Output "NVIDIA GPU RTX 5070Ti and Intel Core Ultra 7 265K assumed. Installing latest drivers..."
# Install NVIDIA GPU drivers
choco install nvidia-display-driver -y
# Install Intel CPU chipset drivers
choco install intel-chipset-device-software -y

# Step 3: Install HYDRA Software and Experience Platforms
Write-ColorOutput Cyan "STEP 3: Installing HYDRA Software and Experience Platforms..."

# Install essential software
$software = @(
    "steam",
    "steamcmd",
    "nats-server"  # HYDRA horde communication
)

foreach ($app in $software) {
    Write-Output "Installing $app..."
    choco install $app -y
}

# Add Go runtime for HYDRA services
choco install golang -y

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

# Step 4: Configure HYDRA Horde Participation
Write-ColorOutput Cyan "STEP 4: Configuring HYDRA Horde Participation..."

# Get venue information
$VenueID = Read-Host "Enter Venue ID (e.g., cloud7, visitflanders, home) [Optional - press Enter to skip]"
if ([string]::IsNullOrWhiteSpace($VenueID)) {
    $VenueID = "hydra-unit-" + (Get-Random -Minimum 1000 -Maximum 9999)
    Write-Output "Generated HYDRA unit ID: $VenueID"
}

$Metro = Read-Host "Enter Metro (e.g., brussels, newyork, london) [Optional - press Enter to skip horde setup]"

if (![string]::IsNullOrWhiteSpace($Metro)) {
    Write-Output "Setting up HYDRA horde participation..."
    
    # Create HYDRA/Horde directories
    New-Item -ItemType Directory -Force -Path "C:\Hydra\Horde\config" | Out-Null
    New-Item -ItemType Directory -Force -Path "C:\Hydra\Horde\logs" | Out-Null
    New-Item -ItemType Directory -Force -Path "C:\Hydra\Horde\nats" | Out-Null
    New-Item -ItemType Directory -Force -Path "C:\Hydra\Horde\data" | Out-Null
    
    # Generate unique HYDRA unit ID using Windows computer name
    $WindowsGenerated = $env:COMPUTERNAME.ToLower()
    $HydraUnitID = "hydra-$VenueID-$WindowsGenerated"
    
    # Create HYDRA configuration
    $HydraConfig = @{
        unit_id = $HydraUnitID
        venue_id = $VenueID
        metro = $Metro
        role = "hydra-unit"  # Standard HYDRA unit for immersive experiences
        horde_discovery = "https://horde.hydrahardware.io/discover"
        capabilities = @("experiences", "streaming", "backup-streaming", "weerwolf-light")
        hardware_profile = "rtx5070ti"
        experience_priority = $true  # Immersive experiences take priority over horde tasks
        windows_generated_id = $WindowsGenerated
    } | ConvertTo-Json -Depth 3
    
    $HydraConfig | Set-Content "C:\Hydra\Horde\config\hydra.json"
    
    # Configure NATS for horde participation
    Write-Output "Configuring NATS server for horde participation..."
    $NatsConfig = @"
server_name: "$HydraUnitID"
port: 4222

# Horde cluster participation
cluster {
  name: "$Metro-horde"
  port: 6222
  routes: [
    "nats://$Metro.horde.hydrahardware.io:6222"
  ]
  pool_size: 5  # Limit connections for HYDRA unit
}

# Resource limits for experience priority
max_connections: 100
max_subscriptions: 500
max_payload: 1MB

# Authorization for horde participation
authorization {
  users: [
    {
      user: "horde-hydra"
      password: "$($WindowsGenerated)_horde_$(Get-Random)"
      permissions: {
        subscribe: ["horde.discovery.>", "$Metro.horde.status.>", "weerwolf.light.>", "experiences.>"]
        publish: ["horde.hydra.status", "$Metro.horde.hydra.>", "telemetry.hydra.>", "experiences.telemetry.>"]
      }
    }
  ]
}
"@
    
    $NatsConfig | Set-Content "C:\Hydra\Horde\nats\nats-server.conf"
    
    Write-ColorOutput Green "HYDRA horde configuration completed!"
    Write-Output "Your HYDRA unit will participate in the $Metro horde as: $HydraUnitID"
} else {
    Write-Output "Skipping HYDRA horde setup - standalone experience configuration."
}

# Step 5: Optimize Windows Settings for Immersive Experience Performance
Write-ColorOutput Cyan "STEP 5: Optimizing Windows Settings for Immersive Experience Performance..."

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

# Configure registry for immersive experience performance
Write-Output "Applying registry tweaks for immersive experience performance..."
# Disable Full Screen Optimizations
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehaviorMode" -Type DWORD -Value 2
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_HonorUserFSEBehaviorMode" -Type DWORD -Value 1
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehavior" -Type DWORD -Value 2
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_DXGIHonorFSEWindowsCompatible" -Type DWORD -Value 1

# Set up Wake-on-LAN for remote HYDRA management
Write-Output "Configuring Wake-on-LAN for remote HYDRA management..."
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

# Configure HYDRA horde with experience priority
if (![string]::IsNullOrWhiteSpace($Metro)) {
    Write-Output "Configuring HYDRA horde with experience priority..."

    # Set CPU affinity for experience priority
    Write-Output "Reserving cores for immersive experience performance..."
    # Cores 0-7: Immersive experiences (Performance cores)
    # Cores 8-11: System
    # Cores 12-15: HYDRA horde (Efficiency cores only)

    $HordeResourceConfig = @"
# HYDRA Unit Resource Allocation
experience_priority: true
resource_limits:
  nats_max_cpu: 2%
  horde_max_memory: 500MB
  experience_reserved_cores: [0,1,2,3,4,5,6,7]
  horde_allowed_cores: [12,13,14,15]
  
# Automatic throttling when running experiences
auto_throttle:
  detect_experiences: true
  throttle_horde_when_experiences: true
  emergency_shutdown_horde: false  # Keep minimal horde connection
  
# Experience detection patterns
experience_processes:
  - "steam"
  - "SteamVR" 
  - "vrmonitor"
  - "Unity"
  - "UnrealEngine"
  - "UE4"
  - "UE5"
  - "Experience"
  - "Hydra"
"@

    $HordeResourceConfig | Set-Content "C:\Hydra\Horde\config\resource-limits.yaml"

    # Install HYDRA horde service
    Write-Output "Installing HYDRA horde service..."
    
    # Create service script
    $ServiceScript = @"
@echo off
cd /d C:\Hydra\Horde\nats
C:\ProgramData\chocolatey\bin\nats-server.exe -c nats-server.conf
"@
    $ServiceScript | Set-Content "C:\Hydra\Horde\start-horde.bat"
    
    # Install as Windows service with low priority
    sc create "HYDRA-Horde" binPath= "C:\Hydra\Horde\start-horde.bat" start= auto
    sc config "HYDRA-Horde" depend= "Tcpip"
    
    # Set service to run with low priority (experiences get priority)
    sc config "HYDRA-Horde" type= own start= auto error= ignore
    
    Write-Output "HYDRA horde service installed. Starting service..."
    Start-Service "HYDRA-Horde" -ErrorAction SilentlyContinue

    # Add experience detection script
    $ExperienceMonitorScript = @"
# HYDRA Experience Monitor - Throttles horde when experiences are active
while (`$true) {
    `$experienceProcesses = Get-Process | Where-Object {
        `$_.ProcessName -match "steam|SteamVR|vrmonitor|Unity|UnrealEngine|UE4|UE5|Experience|Hydra"
    }
    
    if (`$experienceProcesses) {
        # Experience detected - throttle horde
        Get-Process "nats-server" -ErrorAction SilentlyContinue | 
            ForEach-Object { `$_.ProcessorAffinity = 0xF000 }  # Cores 12-15 only
    } else {
        # No experiences - allow normal horde operation  
        Get-Process "nats-server" -ErrorAction SilentlyContinue |
            ForEach-Object { `$_.ProcessorAffinity = 0xFF00 }   # Cores 8-15
    }
    
    Start-Sleep -Seconds 30
}
"@

    $ExperienceMonitorScript | Set-Content "C:\Hydra\Horde\experience-monitor.ps1"
    
    # Create scheduled task for experience monitor
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File C:\Hydra\Horde\experience-monitor.ps1"
    $trigger = New-ScheduledTaskTrigger -AtStartup
    Register-ScheduledTask -TaskName "HYDRA-Experience-Monitor" -Action $action -Trigger $trigger -User "SYSTEM"
}

# Step 6: Remove Windows Bloatware
Write-ColorOutput Cyan "STEP 6: Removing Windows Bloatware..."

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
Write-ColorOutput Green "HYDRA Unit Setup Complete!"
Write-ColorOutput Green "======================================"
Write-Output "Your Windows 11 machine has been optimized for immersive experiences"
Write-Output "and configured to participate in the HYDRA horde."
Write-Output ""
if (![string]::IsNullOrWhiteSpace($Metro)) {
    Write-Output "HYDRA Horde Configuration:"
    Write-Output "  Unit ID: $HydraUnitID"
    Write-Output "  Metro: $Metro"
    Write-Output "  Role: HYDRA Unit with horde participation"
    Write-Output "  Windows Generated ID: $WindowsGenerated"
    Write-Output ""
    Write-Output "Your unit will:"
    Write-Output "  - Prioritize immersive experience performance (cores 0-7 reserved)"
    Write-Output "  - Participate in $Metro horde during idle time"
    Write-Output "  - Automatically throttle horde when experiences are running"
    Write-Output "  - Contribute to Project Weerwolf during downtime"
    Write-Output "  - Enable backup streaming capabilities for the horde"
    Write-Output ""
}
Write-Output "Experience Performance:"
Write-Output "  - High performance power plan enabled"
Write-Output "  - Hardware-accelerated GPU scheduling enabled"
Write-Output "  - Immersive experience optimizations applied"
Write-Output "  - Bloatware removed"
Write-Output "  - Wake-on-LAN configured for remote management"
Write-Output ""

# Create desktop shortcut to sysprep for convenience
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\Exit Audit Mode.lnk")
$Shortcut.TargetPath = "C:\Windows\System32\Sysprep\sysprep.exe"
$Shortcut.Save()
Write-Output "A shortcut to Sysprep has been created on the desktop."

# Create desktop shortcut to HYDRA horde configuration
if (![string]::IsNullOrWhiteSpace($Metro)) {
    $HydraShortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\HYDRA Horde Config.lnk")
    $HydraShortcut.TargetPath = "C:\Hydra\Horde\config"
    $HydraShortcut.Save()
    Write-Output "A shortcut to HYDRA Horde configuration has been created on the desktop."
}
Write-Output ""

Write-Output "To exit Audit Mode and create a user account:"
Write-Output "1. Open Sysprep (C:\Windows\System32\Sysprep\sysprep.exe)"
Write-Output "2. Select 'Enter System Out-of-Box Experience (OOBE)'"
Write-Output "3. Check 'Generalize' only if you want to reset unique identifiers"
Write-Output "4. Set 'Shutdown Options' to 'Reboot'"
Write-Output "5. Click 'OK'"
Write-Output ""
Write-Output "After reboot, you'll be able to create your user account"
Write-Output "with all HYDRA optimizations already in place."
Write-Output ""

$restart = Read-Host "Would you like to restart now? (y/n)"
if ($restart -eq 'y') {
    Restart-Computer
}