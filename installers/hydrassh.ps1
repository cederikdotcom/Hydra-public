# Windows Audit Mode SSH Setup Script
# Run as Administrator in PowerShell

Write-Host "Starting SSH setup and user creation..." -ForegroundColor Green

# Check if running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "This script must be run as Administrator!"
    exit 1
}

# Install OpenSSH Server
Write-Host "Installing OpenSSH Server..." -ForegroundColor Yellow
try {
    Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
    Write-Host "OpenSSH Server installed successfully" -ForegroundColor Green
} catch {
    Write-Error "Failed to install OpenSSH Server: $($_.Exception.Message)"
    exit 1
}

# Start and enable SSH service
Write-Host "Starting and enabling SSH service..." -ForegroundColor Yellow
try {
    Start-Service sshd
    Set-Service -Name sshd -StartupType 'Automatic'
    Write-Host "SSH service started and enabled" -ForegroundColor Green
} catch {
    Write-Error "Failed to start SSH service: $($_.Exception.Message)"
    exit 1
}

# Configure Windows Firewall for SSH
Write-Host "Configuring Windows Firewall for SSH..." -ForegroundColor Yellow
try {
    New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
    Write-Host "Firewall rule created for SSH" -ForegroundColor Green
} catch {
    Write-Warning "Firewall rule may already exist or failed to create: $($_.Exception.Message)"
}

# Create Hydra user account
Write-Host "Creating Hydra user account..." -ForegroundColor Yellow
try {
    $Password = ConvertTo-SecureString "Hydra" -AsPlainText -Force
    New-LocalUser -Name "Hydra" -Password $Password -FullName "Hydra User" -Description "SSH Access User" -PasswordNeverExpires
    Write-Host "Hydra user account created successfully" -ForegroundColor Green
} catch {
    Write-Error "Failed to create Hydra user: $($_.Exception.Message)"
    exit 1
}

# Add Hydra to Administrators group (optional - remove if you don't want admin access)
Write-Host "Adding Hydra to Administrators group..." -ForegroundColor Yellow
try {
    Add-LocalGroupMember -Group "Administrators" -Member "Hydra"
    Write-Host "Hydra added to Administrators group" -ForegroundColor Green
} catch {
    Write-Warning "Failed to add Hydra to Administrators group: $($_.Exception.Message)"
}

# Display system information
Write-Host "`nSetup Complete!" -ForegroundColor Green
Write-Host "SSH Server Status:" -ForegroundColor Cyan
Get-Service sshd | Select-Object Name, Status, StartType

Write-Host "`nUser Account Created:" -ForegroundColor Cyan
Get-LocalUser -Name "Hydra" | Select-Object Name, Enabled, LastLogon

Write-Host "`nNetwork Information:" -ForegroundColor Cyan
$IpAddresses = Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -ne "127.0.0.1"} | Select-Object -ExpandProperty IPAddress
Write-Host "IP Addresses: $($IpAddresses -join ', ')"

Write-Host "`nSSH Connection Information:" -ForegroundColor Yellow
Write-Host "Username: Hydra"
Write-Host "Password: Hydra"
Write-Host "Port: 22"
Write-Host "Example connection: ssh Hydra@$($IpAddresses[0])" -ForegroundColor White

Write-Host "`nSecurity Recommendations:" -ForegroundColor Red
Write-Host "- Change the default password immediately"
Write-Host "- Consider using SSH key authentication instead of passwords"
Write-Host "- Consider changing the default SSH port from 22"
Write-Host "- Remove admin privileges if not needed"