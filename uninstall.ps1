if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "[-] administrator permissions are required. please run again as an administrator." -ForegroundColor Red
    Start-Sleep -Seconds 3
    Exit
}

Write-Host "[1] removing context menu registry keys..." -ForegroundColor Cyan

$RegPathBg = "Registry::HKEY_CLASSES_ROOT\Directory\Background\shell\ToggleScaler"
if (Test-Path $RegPathBg) {
    Remove-Item -Path $RegPathBg -Recurse -Force
    Write-Host "    removed background context menu."
}

$RegPathDir = "Registry::HKEY_CLASSES_ROOT\Directory\shell\ToggleScaler"
if (Test-Path $RegPathDir) {
    Remove-Item -Path $RegPathDir -Recurse -Force
    Write-Host "    removed directory context menu."
}

Write-Host "[2] removing windows 11 classic context menu fix..." -ForegroundColor Cyan
$Win11ClassicMenuPath = "Registry::HKEY_CURRENT_USER\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}"
if (Test-Path $Win11ClassicMenuPath) {
    Remove-Item -Path $Win11ClassicMenuPath -Recurse -Force
    Write-Host "    removed windows 11 classic menu override."
}

Write-Host "[3] removing togglescaler files..." -ForegroundColor Cyan
$BasePath = "C:\ToggleScaler"
if (Test-Path $BasePath) {
    Remove-Item -Path $BasePath -Recurse -Force
    Write-Host "    removed $BasePath"
}

Write-Host "uninstallation completed!" -ForegroundColor Green
Start-Sleep -Seconds 5