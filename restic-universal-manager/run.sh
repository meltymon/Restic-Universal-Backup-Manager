# run.sh
#!/bin/bash
# RESTIC UNIVERSAL MANAGER (RUNNER)
# Lädt alle Module und startet das Menü.

# Stoppt das Skript bei Fehler, um Datenverlust zu vermeiden
set -e

# Pfad zum aktuellen Verzeichnis, in dem die Skripte liegen
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Lade Module in der korrekten Reihenfolge:
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/requirements.sh"
source "$SCRIPT_DIR/install.sh"
source "$SCRIPT_DIR/backup_logic.sh"
source "$SCRIPT_DIR/restore.sh"
source "$SCRIPT_DIR/menu.sh"

# Starte die Hauptmenü-Schleife
run_menu_loop
