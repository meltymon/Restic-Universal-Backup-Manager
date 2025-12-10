# config.sh
# Enthält Standardwerte und Konstanten. Benutzerkonfiguration wird aus $CONFIG_FILE geladen.

# Default-Pfade
DEFAULT_BACKUP_SOURCE="/home/$(whoami)"
DEFAULT_LOG_DIR="/home/$(whoami)/restic_logs"
DEFAULT_TARGET_NC_REPO="/home/$(whoami)/Nextcloud/Restic_Backups" 

# Systemd/Docker Konfiguration
SYSTEMD_SERVICE="restic-backup.service"
NEXTCLOUD_CONTAINER="nextcloud_app"
NEXTCLOUD_USER="$(whoami)"

# Absolute Pfade zu externen Tools (Für systemd PATH-Probleme)
# Diese werden später dynamisch über 'which' ermittelt, aber hier als Fallback definiert.
ZIP_BIN="/usr/bin/zip" 
RSYNC_BIN="/usr/bin/rsync"

# Ort der dynamischen Konfigurationsdatei (muss in $HOME liegen)
CONFIG_FILE="$HOME/.restic_universal_manager_config"
