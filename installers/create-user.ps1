# Windows 11 VR Machine - User Account Creation Script
# HydraHardware - https://win11setup.hydrahardware.io
# This script helps create a custom user account before exiting Audit Mode

# Ensure we're running as admin (which is default in Audit Mode)
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "This script requires administrative privileges. Please run PowerShell as administrator and try again."
    exit
}

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
Write-ColorOutput Green "=================================================="
Write-ColorOutput Green "  Windows 11 VR Machine - User Account Creation"
Write-ColorOutput Green "=================================================="
Write-Output "This script will help you create a local administrator account before exiting Audit Mode."
Write-Output "This allows you to bypass Microsoft Account requirements during OOBE."
Write-Output ""

# Get user account details
$username = Read-Host "Enter the desired username"
$fullname = Read-Host "Enter the full name (optional, press Enter to skip)"
if ([string]::IsNullOrEmpty($fullname)) {
    $fullname = $username
}

# Get password securely
$password = Read-Host "Enter the password" -AsSecureString
$passwordConfirm = Read-Host "Confirm the password" -AsSecureString

# Convert secure strings to plain text for comparison
$bstr1 = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
$plainPassword1 = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr1)
$bstr2 = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($passwordConfirm)
$plainPassword2 = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr2)

# Check if passwords match
if ($plainPassword1 -ne $plainPassword2) {
    Write-ColorOutput Red "Passwords do not match. Please run the script again."
    exit
}

# Clear the plain text passwords from memory for security
[System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr1)
[System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr2)
$plainPassword1 = $null
$plainPassword2 = $null

# Check if user already exists
$userExists = Get-LocalUser -Name $username -ErrorAction SilentlyContinue

if ($userExists) {
    Write-ColorOutput Yellow "A user with the name '$username' already exists."
    $overwrite = Read-Host "Do you want to reset the password for this account? (y/n)"
    
    if ($overwrite -eq 'y') {
        # Set new password for existing user
        Set-LocalUser -Name $username -Password $password -FullName $fullname
        Write-ColorOutput Green "Password updated for user '$username'."
    } else {
        Write-ColorOutput Yellow "Operation cancelled. No changes were made."
        exit
    }
} else {
    # Create new local user account
    try {
        New-LocalUser -Name $username -Password $password -FullName $fullname -Description "Created during VR setup" -AccountNeverExpires
        Write-ColorOutput Green "User account '$username' created successfully."
        
        # Add user to administrators group
        Add-LocalGroupMember -Group "Administrators" -Member $username
        Write-ColorOutput Green "User '$username' added to Administrators group."
    } catch {
        Write-ColorOutput Red "Error creating user account: $_"
        exit
    }
}

# Create registry entries for auto-login (optional)
$enableAutoLogin = Read-Host "Enable automatic login for this user? (y/n)"
if ($enableAutoLogin -eq 'y') {
    # Convert secure string password to plain text for auto-login registry key
    $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
    $plainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
    
    # Set registry keys for automatic login
    $RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
    Set-ItemProperty -Path $RegPath -Name "AutoAdminLogon" -Value "1" -Force
    Set-ItemProperty -Path $RegPath -Name "DefaultUsername" -Value "$username" -Force
    Set-ItemProperty -Path $RegPath -Name "DefaultPassword" -Value "$plainPassword" -Force
    Set-ItemProperty -Path $RegPath -Name "DefaultDomainName" -Value "$env:COMPUTERNAME" -Force
    
    # Clear the plain text password from memory for security
    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
    $plainPassword = $null
    
    Write-ColorOutput Green "Automatic login configured for user '$username'."
}

# Final instructions
Write-ColorOutput Green "=========================================================="
Write-ColorOutput Green "User account setup complete!"
Write-ColorOutput Green "=========================================================="
Write-Output ""
Write-Output "You can now exit Audit Mode using Sysprep:"
Write-Output "1. Open Sysprep (C:\Windows\System32\Sysprep\sysprep.exe)"
Write-Output "2. Select 'Enter System Out-of-Box Experience (OOBE)'"
Write-Output "3. Check 'Generalize' only if you want to reset unique identifiers"
Write-Output "4. Set 'Shutdown Options' to 'Reboot'"
Write-Output "5. Click 'OK'"
Write-Output ""
Write-Output "After reboot, your account will be available for login."
Write-Output "If you enabled auto-login, you'll be logged in automatically."
Write-Output ""

# Ask to open Sysprep
$openSysprep = Read-Host "Would you like to open Sysprep now? (y/n)"
if ($openSysprep -eq 'y') {
    Start-Process "C:\Windows\System32\Sysprep\sysprep.exe"
}
