# ToggleScaler for OptiScaler

**ToggleScaler** is an unofficial helper tool designed to enhance the usability of [OptiScaler](https://github.com/optiscaler/OptiScaler).

Instead of manually copying DLL files and editing configurations for every game, **ToggleScaler** integrates directly into the Windows Context Menu (Right-Click Menu). You can enable or disable OptiScaler for any game directory with a single click.

## Features

* **One-Click Toggle:** Easily enable or disable OptiScaler via the right-click context menu on any folder or folder background.
* **Automatic Installation:** The installer automatically downloads the latest version of OptiScaler from the official repository during setup.
* **Safe Backups:** When enabled, it automatically backs up original game files (e.g., `nvngx.dll`, `dxgi.dll`) to a hidden `.toggle_scaler` folder. Disabling it restores the original files perfectly.
* **Windows 11 Classic Menu:** Automatically applies the "Classic Context Menu" fix for Windows 11 users for easier access.

## Installation

The release package includes the compiled executable and PowerShell scripts required for installation.

1.  Download the latest release archive (`.zip` or `.7z`) from the Releases page.
2.  Extract the archive to a temporary location.
3.  Right-click on **`install.ps1`** and select **Run with PowerShell**.
    * *Note: Administrator privileges are required.*
4.  The script will:
    * Create the installation directory at `C:\ToggleScaler`.
    * Copy `ToggleScaler.exe`.
    * **Download the latest OptiScaler** release automatically.
    * Register the context menu registry keys.

> **Note for Windows 11 Users:** The installer will enable the "Classic Context Menu" (Windows 10 style) to make the "Run ToggleScaler" option immediately visible without clicking "Show more options".

## How to Use

1.  Navigate to your Game Folder (where the main executable is located).
2.  **Right-click** on the folder background (or right-click the folder itself in Explorer).
3.  Click **"Run ToggleScaler"**.
4.  A notification will appear:
    * **Enabled:** OptiScaler files are copied, and `setup_windows.bat` is executed.
    * **Disabled:** OptiScaler files are removed, `Remove OptiScaler.bat` is executed, and original files are restored.

## Uninstallation

To remove ToggleScaler and revert changes:

1.  Locate the downloaded release files (or the folder where you ran the install script).
2.  Right-click on **`uninstall.ps1`** and select **Run with PowerShell**.
3.  The script will:
    * Remove the "Run ToggleScaler" context menu.
    * **Revert** the Windows 11 Classic Context Menu change (if applicable).
    * Delete the `C:\ToggleScaler` directory.

## Configuration

The tool uses a global configuration file located at:
`C:\ToggleScaler\config.yml`

By default, it points to the auto-downloaded OptiScaler folder. If you wish to use a custom version of OptiScaler, you can modify the `source_path` in this file.

## Disclaimer

This is an unofficial tool and is not directly affiliated with the OptiScaler project.
* Please ensure you back up important game data before using.
* For issues related to upscaling quality or game compatibility, please refer to the [OptiScaler Repository](https://github.com/optiscaler/OptiScaler).

---
*Powered by [OptiScaler](https://github.com/optiscaler/OptiScaler)*