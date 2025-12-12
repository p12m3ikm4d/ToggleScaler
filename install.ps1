if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "[-] administrator permissions are required. please run again as an administrator." -ForegroundColor Red
    Start-Sleep -Seconds 3
    Exit
}

$BasePath = "C:\ToggleScaler"
$OptiScalerPath = "$BasePath\OptiScaler"
$ConfigPath = "$BasePath\config.yml"
$ExePath = "$BasePath\ToggleScaler.exe"
$RepoOwner = "optiscaler"
$RepoName = "OptiScaler"
$FallbackUrl = "https://github.com/optiscaler/OptiScaler/releases/download/v0.7.9/OptiScaler_0.7.9.7z"
$SevenZipUrl = "https://www.7-zip.org/a/7zr.exe" 
$SourceExe = Join-Path -Path $PSScriptRoot -ChildPath "ToggleScaler.exe"

Write-Host "[1] make directory for togglescaler: $BasePath" -ForegroundColor Cyan
if (!(Test-Path $BasePath)) { New-Item -ItemType Directory -Force -Path $BasePath | Out-Null }
if (Test-Path $OptiScalerPath) { 
    Write-Host "    remove existing OptiScaler folder..." -ForegroundColor Yellow
    Remove-Item -Path $OptiScalerPath -Recurse -Force 
}

Write-Host "[2] copying ToggleScaler.exe to installation folder..." -ForegroundColor Cyan
if (Test-Path $SourceExe) {
    Copy-Item -Path $SourceExe -Destination $ExePath -Force
    Write-Host "    successfully copied ToggleScaler.exe" -ForegroundColor Green
} else {
    Write-Host "    [!] ToggleScaler.exe not found in current directory. Please copy it manually to $BasePath" -ForegroundColor Red
}

Write-Host "[3] start downloading OptiScaler..." -ForegroundColor Cyan

$DownloadUrl = $null
$FileName = $null

try {
    Write-Host "    searching for the latest release via github api..."
    $LatestRelease = Invoke-RestMethod -Uri "https://api.github.com/repos/$RepoOwner/$RepoName/releases/latest" -ErrorAction Stop
    $Asset = $LatestRelease.assets | Where-Object { $_.name -match "\.7z$|\.zip$" } | Select-Object -First 1
    
    if ($Asset) {
        $DownloadUrl = $Asset.browser_download_url
        $FileName = $Asset.name
        Write-Host "    latest version found: $($LatestRelease.tag_name) ($FileName)" -ForegroundColor Green
    } else {
        throw "could not find a compressed file in the latest release."
    }
}
catch {
    Write-Host "    [!] failed to fetch the latest version or api rate limit reached. using fallback url." -ForegroundColor Yellow
    $DownloadUrl = $FallbackUrl
    $FileName = "OptiScaler_fallback.7z"
}

$DownloadPath = "$BasePath\$FileName"
Write-Host "    downloading: $DownloadUrl"
Invoke-WebRequest -Uri $DownloadUrl -OutFile $DownloadPath

Write-Host "[4] extracting archive..." -ForegroundColor Cyan

if ($DownloadPath -match "\.7z$") {
    $7zExe = "$BasePath\7zr.exe"
    Write-Host "    downloading 7zr.exe for .7z file handling..."
    Invoke-WebRequest -Uri $SevenZipUrl -OutFile $7zExe
    
    Write-Host "    extracting with 7zr.exe..."
    Start-Process -FilePath $7zExe -ArgumentList "x `"$DownloadPath`" -o`"$OptiScalerPath`" -y" -Wait -NoNewWindow
    
    Remove-Item $7zExe -Force
} 
elseif ($DownloadPath -match "\.zip$") {
    Write-Host "    extracting with Expand-Archive..."
    Expand-Archive -Path $DownloadPath -DestinationPath $OptiScalerPath -Force
}

Remove-Item $DownloadPath -Force

Write-Host "[5] creating config.yml..." -ForegroundColor Cyan
$ConfigContent = "source_path: `"$OptiScalerPath`"".Replace("\", "/")
Set-Content -Path $ConfigPath -Value $ConfigContent -Encoding UTF8
Write-Host "    config saved: $ConfigContent"

Write-Host "[6] registering context menu (Registry)..." -ForegroundColor Cyan
$MenuName = "Run ToggleScaler"
$Command = "`"$ExePath`" `"%V`""

$RegPathBg = "Registry::HKEY_CLASSES_ROOT\Directory\Background\shell\ToggleScaler"
New-Item -Path $RegPathBg -Force | Out-Null
New-ItemProperty -Path $RegPathBg -Name "(Default)" -Value $MenuName -PropertyType String -Force | Out-Null
New-ItemProperty -Path $RegPathBg -Name "Icon" -Value "SystemPropertiesComputer.exe" -PropertyType String -Force | Out-Null

$RegPathBgCmd = "$RegPathBg\command"
New-Item -Path $RegPathBgCmd -Force | Out-Null
New-ItemProperty -Path $RegPathBgCmd -Name "(Default)" -Value $Command -PropertyType String -Force | Out-Null

$RegPathDir = "Registry::HKEY_CLASSES_ROOT\Directory\shell\ToggleScaler"
New-Item -Path $RegPathDir -Force | Out-Null
New-ItemProperty -Path $RegPathDir -Name "(Default)" -Value $MenuName -PropertyType String -Force | Out-Null
New-ItemProperty -Path $RegPathDir -Name "Icon" -Value "SystemPropertiesComputer.exe" -PropertyType String -Force | Out-Null

$RegPathDirCmd = "$RegPathDir\command"
New-Item -Path $RegPathDirCmd -Force | Out-Null
New-ItemProperty -Path $RegPathDirCmd -Name "(Default)" -Value $Command -PropertyType String -Force | Out-Null

Write-Host "[7] applying windows 11 classic context menu fix..." -ForegroundColor Cyan
$Win11ClassicMenuPath = "Registry::HKEY_CURRENT_USER\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"
if (!(Test-Path $Win11ClassicMenuPath)) { New-Item -Path $Win11ClassicMenuPath -Force | Out-Null }
New-ItemProperty -Path $Win11ClassicMenuPath -Name "(Default)" -Value "" -PropertyType String -Force | Out-Null

Write-Host "all installation tasks completed!" -ForegroundColor Green
Start-Sleep -Seconds 5