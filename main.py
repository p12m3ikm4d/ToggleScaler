import os
import shutil
import yaml
import sys
from pathenger import *
from pathlib import Path
from plyer import notification
import subprocess

icon_path = Path(get_temp_path() + "/icon.ico")

if not icon_path.exists():
    icon_path = None

def show_notification(title, message):
    try:
        notification.notify(
            title=title,
            message=message,
            app_name='ToggleScaler',
            timeout=3,
            app_icon=str(icon_path) if icon_path else None
        )
    except Exception:
        print(f"failed to show notification / {title}: {message}")

class ToggleScaler:
    def __init__(self, target_path):
        self.script_dir = Path(get_executable_path()).resolve()
        self.config_file = self.script_dir / "config.yml"
        self.config = self.load_config()
        self.source_path = Path(self.config['source_path']).resolve()
        self.target_path = Path(target_path).resolve()
        
        self.toggle_dir = self.target_path / ".toggle_scaler"
        self.origin_dir = self.toggle_dir / "origin"
        self.state_file = self.toggle_dir / "state.yml"

    def load_config(self):
        if not self.config_file.exists():
            show_notification("Error", "config.yml not found.")
            sys.exit(1)
            
        with open(self.config_file, 'r', encoding='utf-8') as f:
            return yaml.safe_load(f)

    def load_state(self):
        if not self.state_file.exists():
            return {"enabled": False, "added": []}
        
        with open(self.state_file, 'r', encoding='utf-8') as f:
            return yaml.safe_load(f) or {"enabled": False, "added": []}

    def save_state(self, enabled, added_files):
        state = {
            "enabled": enabled,
            "added": [str(p) for p in added_files]
        }
        
        self.toggle_dir.mkdir(parents=True, exist_ok=True)
        
        with open(self.state_file, 'w', encoding='utf-8') as f:
            yaml.dump(state, f, default_flow_style=False, allow_unicode=True)

    def enable_scaling(self):
        added_files = []
        
        if not self.source_path.exists():
            show_notification("Error", f"source path does not exist")
            return

        for src_file in self.source_path.rglob('*'):
            if not src_file.is_file():
                continue
                
            rel_path = src_file.relative_to(self.source_path)
            tgt_file = self.target_path / rel_path
            
            tgt_file.parent.mkdir(parents=True, exist_ok=True)

            if tgt_file.exists():
                origin_backup_path = self.origin_dir / rel_path
                origin_backup_path.parent.mkdir(parents=True, exist_ok=True)
                shutil.move(str(tgt_file), str(origin_backup_path))
            else:
                added_files.append(str(rel_path))

            shutil.copy2(src_file, tgt_file)
        
        setup_bat = self.target_path / "setup_windows.bat"
        if setup_bat.exists():
            try:
                subprocess.run([str(setup_bat)], cwd=str(self.target_path), check=True)
                added_files = [f for f in added_files if (self.target_path / f).exists()]
            except subprocess.CalledProcessError:
                # show_notification("Warning", "setup_windows.bat execution failed")
                pass

        self.save_state(True, added_files)
        show_notification("Success", f"OptiScaler enabled")

    def disable_scaling(self, state):
        remove_bat = self.target_path / "Remove OptiScaler.bat"
        if remove_bat.exists():
            try:
                subprocess.run([str(remove_bat)], cwd=str(self.target_path), check=True)
            except subprocess.CalledProcessError:
                # show_notification("Warning", "Remove OptiScaler.bat execution failed")
                pass

        added_files = state.get('added', [])

        for rel_path in added_files:
            file_to_remove = self.target_path / rel_path
            if file_to_remove.exists():
                os.remove(file_to_remove)
            
            try:
                if not any(file_to_remove.parent.iterdir()):
                    file_to_remove.parent.rmdir()
            except:
                pass

        if self.origin_dir.exists():
            for backup_file in self.origin_dir.rglob('*'):
                if not backup_file.is_file():
                    continue

                rel_path = backup_file.relative_to(self.origin_dir)
                tgt_file = self.target_path / rel_path
                
                tgt_file.parent.mkdir(parents=True, exist_ok=True)
                
                if tgt_file.exists():
                    os.remove(tgt_file)
                
                shutil.move(str(backup_file), str(tgt_file))
            
            shutil.rmtree(self.origin_dir)

        self.save_state(False, [])
        show_notification("Success", f"OptiScaler disabled")

    def run(self):
        current_state = self.load_state()

        if current_state.get('enabled'):
            self.disable_scaling(current_state)
        else:
            self.enable_scaling()

if __name__ == "__main__":
    if len(sys.argv) < 2:
        show_notification("Error", "target path argument is missing")
        sys.exit(0)
    
    target_path_arg = sys.argv[1]
    
    scaler = ToggleScaler(target_path_arg)
    scaler.run()