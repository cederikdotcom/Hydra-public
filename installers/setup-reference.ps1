# Reference Machine Setup Script
# Run as Administrator on your reference Windows 11 machine
# This prepares the machine for imaging with Sysprep

param(
    [string]$DaemonPath = "C:\HydraBodyDaemon\daemon.exe",  # Path to your Go daemon executable
    [string]$UnattendPath = "C:\Windows\System32\Sysprep\unattend.xml"  # Where to place unattend.xml
)

Write-Host "=== Hydra Reference Machine Setup ===" -ForegroundColor Green
Write-Host "This script prepares the reference machine for imaging" -ForegroundColor Yellow

# Check if running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "This script must be run as Administrator!"
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "`n1. Installing OpenSSH Server..." -ForegroundColor Cyan
try {
    Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
    Write-Host "   ✓ OpenSSH Server installed" -ForegroundColor Green
} catch {
    Write-Warning "   ⚠ OpenSSH Server installation failed or already installed: $($_.Exception.Message)"
}

Write-Host "`n2. Configuring SSH Service..." -ForegroundColor Cyan
try {
    Set-Service -Name sshd -StartupType Manual  # Don't auto-start on reference machine
    Write-Host "   ✓ SSH service configured for manual startup" -ForegroundColor Green
} catch {
    Write-Warning "   ⚠ SSH service configuration failed: $($_.Exception.Message)"
}

Write-Host "`n3. Creating Hydra user account..." -ForegroundColor Cyan
try {
    $Password = ConvertTo-SecureString "Hydra" -AsPlainText -Force
    New-LocalUser -Name "Hydra" -Password $Password -FullName "Hydra Admin" -Description "Hydra Administrator Account" -PasswordNeverExpires -ErrorAction Stop
    Add-LocalGroupMember -Group "Administrators" -Member "Hydra" -ErrorAction Stop
    Write-Host "   ✓ Hydra user created with admin privileges" -ForegroundColor Green
} catch {
    if ($_.Exception.Message -like "*already exists*") {
        Write-Host "   ✓ Hydra user already exists" -ForegroundColor Green
    } else {
        Write-Warning "   ⚠ Hydra user creation failed: $($_.Exception.Message)"
    }
}

Write-Host "`n4. Setting up HydraBodyDaemon directory..." -ForegroundColor Cyan
try {
    New-Item -Path "C:\HydraBodyDaemon" -ItemType Directory -Force | Out-Null
    Write-Host "   ✓ HydraBodyDaemon directory created" -ForegroundColor Green
    
    # Check if daemon executable exists
    if (Test-Path $DaemonPath) {
        Write-Host "   ✓ Daemon executable found at $DaemonPath" -ForegroundColor Green
        
        # Install as Windows Service
        Write-Host "   Installing daemon as Windows service..." -ForegroundColor Yellow
        try {
            New-Service -Name "HydraBodyDaemon" -BinaryPathName $DaemonPath -DisplayName "Hydra Body Daemon" -StartupType Automatic -Description "Hydra VM Management Daemon" -ErrorAction Stop
            Write-Host "   ✓ HydraBodyDaemon service installed" -ForegroundColor Green
        } catch {
            if ($_.Exception.Message -like "*already exists*") {
                Write-Host "   ✓ HydraBodyDaemon service already exists" -ForegroundColor Green
            } else {
                Write-Warning "   ⚠ Service installation failed: $($_.Exception.Message)"
            }
        }
    } else {
        Write-Warning "   ⚠ Daemon executable not found at $DaemonPath"
        Write-Host "   Please copy your daemon.exe to C:\HydraBodyDaemon\ before running sysprep" -ForegroundColor Yellow
    }
} catch {
    Write-Warning "   ⚠ Directory creation failed: $($_.Exception.Message)"
}

Write-Host "`n5. Copying unattend.xml to Sysprep folder..." -ForegroundColor Cyan
try {
    # You'll need to copy your unattend.xml file here
    Write-Host "   Please ensure unattend.xml is placed at: $UnattendPath" -ForegroundColor Yellow
    Write-Host "   This should be done manually or via your deployment process" -ForegroundColor Yellow
} catch {
    Write-Warning "   ⚠ Failed to copy unattend.xml: $($_.Exception.Message)"
}

Write-Host "`n6. Performing system optimizations..." -ForegroundColor Cyan

# Disable unnecessary services for VMs
$servicesToDisable = @(
    "Fax",
    "Spooler",  # Only if you don't need printing
    "Themes"    # Only if you want minimal UI
)

foreach ($service in $servicesToDisable) {
    try {
        if (Get-Service -Name $service -ErrorAction SilentlyContinue) {
            Set-Service -Name $service -StartupType Disabled
            Write-Host "   ✓ Disabled $service service" -ForegroundColor Green
        }
    } catch {
        Write-Warning "   ⚠ Could not disable $service service"
    }
}

# Clear temporary files
Write-Host "   Cleaning temporary files..." -ForegroundColor Yellow
try {
    Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "   ✓ Temporary files cleaned" -ForegroundColor Green
} catch {
    Write-Warning "   ⚠ Some temporary files could not be cleaned"
}

Write-Host "`n7. Final system status check..." -ForegroundColor Cyan

# Check SSH
$sshStatus = Get-Service -Name sshd -ErrorAction SilentlyContinue
if ($sshStatus) {
    Write-Host "   ✓ SSH Service Status: $($sshStatus.Status)" -ForegroundColor Green
} else {
    Write-Warning "   ⚠ SSH service not found"
}

# Check Hydra user
$hydraUser = Get-LocalUser -Name "Hydra" -ErrorAction SilentlyContinue
if ($hydraUser) {
    Write-Host "   ✓ Hydra user exists and is $($hydraUser.Enabled)" -ForegroundColor Green
} else {
    Write-Warning "   ⚠ Hydra user not found"
}

# Check daemon service
$daemonService = Get-Service -Name "HydraBodyDaemon" -ErrorAction SilentlyContinue
if ($daemonService) {
    Write-Host "   ✓ HydraBodyDaemon service exists, StartType: $($daemonService.StartType)" -ForegroundColor Green
} else {
    Write-Warning "   ⚠ HydraBodyDaemon service not found"
}

Write-Host "`n=== Setup Complete ===" -ForegroundColor Green
Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "1. Ensure your daemon.exe is in C:\HydraBodyDaemon\" -ForegroundColor White
Write-Host "2. Copy unattend.xml to C:\Windows\System32\Sysprep\" -ForegroundColor White
Write-Host "3. Run sysprep command:" -ForegroundColor White
Write-Host "   cd C:\Windows\System32\Sysprep" -ForegroundColor Gray
Write-Host "   sysprep.exe /generalize /oobe /shutdown /unattend:unattend.xml" -ForegroundColor Gray
Write-Host "4. After shutdown, capture the C: drive as your image" -ForegroundColor White

Write-Host "`nPress Enter to continue..."
Read-Host