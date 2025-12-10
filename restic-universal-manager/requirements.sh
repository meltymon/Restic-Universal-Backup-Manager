# requirements.sh

# Lädt die Benutzerkonfiguration aus der versteckten Datei
load_user_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
        return 0
    else
        return 1
    fi
}

# Prüft, ob Restic und andere notwendige Tools vorhanden sind
check_tools() {
    local missing_tools=()
    
    if ! command -v restic &> /dev/null; then
        missing_tools+=("restic")
    fi

    # Prüft ZIP und RSYNC (über den absoluten Pfad und Fallback)
    if [ ! -x "$ZIP_BIN" ] && ! command -v zip &> /dev/null; then
        missing_tools+=("zip")
    fi
    if [ ! -x "$RSYNC_BIN" ] && ! command -v rsync &> /dev/null; then
        missing_tools+=("rsync")
    fi
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        echo "FEHLER: Folgende Tools fehlen. Bitte Option 1 wählen: ${missing_tools[*]}"
        return 1
    fi
    return 0
}

# Kombinierte Funktion zum Laden und Prüfen
check_tools_and_env() {
    if ! load_user_config; then return 1; fi
    if ! check_tools; then return 1; fi

    # Setzt die Umgebungsvariablen für Restic
    export RESTIC_REPOSITORY="$REPO_URL"
    export RESTIC_PASSWORD="$RESTIC_PW"
    
    return 0
}
