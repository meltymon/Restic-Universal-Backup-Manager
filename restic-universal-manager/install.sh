# install.sh

# Interaktiver Installations- und Konfigurationsassistent
do_setup() {
    clear
    echo "--- RESTIC SETUP ASSISTENT (Option 1) ---"
    
    # --- 1. Grundkonfiguration interaktiv abfragen ---
    read -p "Restic Repository URL (Lokal/sftp/s3/...): " REPO_URL
    read -s -p "Restic Passwort: " RESTIC_PW
    echo
    read -p "Temporäres Verzeichnis (Für Restic-Packs, z.B. /home/user/restic_tmp): " TMP_DIR
    
    # --- 2. Pfade und Ausschlüsse ---
    read -p "Quellverzeichnis (zu sicherndes Verzeichnis, Standard: $DEFAULT_BACKUP_SOURCE): " BACKUP_SOURCE
    BACKUP_SOURCE=${BACKUP_SOURCE:-$DEFAULT_BACKUP_SOURCE}
    
    read -p "Weitere auszuschließende Ordner (z.B. DatenPool Games): " CUSTOM_EXCLUDES
    
    # 3. Konfigurationsdatei speichern
    cat << CFG_EOF > "$CONFIG_FILE"
# Restic Konfiguration (Automatisch generiert)
REPO_URL="$REPO_URL"
RESTIC_PW="$RESTIC_PW"
BACKUP_SOURCE="$BACKUP_SOURCE"
TMP_DIR="$TMP_DIR"
CUSTOM_EXCLUDES="$CUSTOM_EXCLUDES"
CFG_EOF
    
    echo "✅ Konfiguration erfolgreich in $CONFIG_FILE gespeichert."
    
    # 4. Installation und Initialisierung
    do_install_requirements
    
    read -p "Setup abgeschlossen. Weiter mit Enter..."
}


# Funktion zur Installation der Anforderungen mit dynamischem Paketmanager
do_install_requirements() {
    local pkg_mgr required_packages="restic zip rsync"
    local yay_bin=$(command -v yay 2>/dev/null) # Prüft, ob Yay installiert ist

    # Paketmanager-Erkennung
    if command -v pacman &> /dev/null; then pkg_mgr="pacman"; 
    elif command -v apt &> /dev/null; then pkg_mgr="apt"; 
    elif command -v dnf &> /dev/null; then pkg_mgr="dnf"; 
    else pkg_mgr="unbekannt";
    fi

    echo "Erkannter Paketmanager: $pkg_mgr"
    
    # --- 1. Installation ---
    read -p "Sollen restic, zip und rsync über $pkg_mgr installiert werden (sudo erforderlich)? (j/n): " confirm_install

    if [[ "$confirm_install" =~ ^[jJ]$ ]]; then
        if [ "$pkg_mgr" == "pacman" ]; then
            sudo pacman -Syu --noconfirm $required_packages
        elif [ "$pkg_mgr" == "apt" ]; then
            sudo apt update
            sudo apt install -y $required_packages
        elif [ "$pkg_mgr" == "dnf" ]; then
            sudo dnf install -y $required_packages
        fi
        
        # --- 2. Alternativquellen (AUR/Yay) ---
        if [ "$pkg_mgr" == "pacman" ] && ! command -v restic &> /dev/null; then
            echo "WARNUNG: Restic nicht über Pacman gefunden."
            if [ -n "$yay_bin" ]; then
                read -p "Soll Restic über Yay (AUR) installiert werden? (j/n): " confirm_aur
                if [[ "$confirm_aur" =~ ^[jJ]$ ]]; then
                    "$yay_bin" -S restic --noconfirm
                fi
            else
                echo "Empfehlung: AUR Helper (yay) installieren und dann Restic installieren."
            fi
        fi
    fi
    
    # --- 3. Initialisierung ---
    if check_tools_and_env; then # Lädt Konfiguration und setzt Umgebungsvariablen
        read -p "Möchten Sie das Repository jetzt initialisieren (restic init)? (j/n): " init_choice
        if [[ "$init_choice" =~ ^[jJ]$ ]]; then
            restic init
            if [ $? -eq 0 ]; then
                echo "Repository erfolgreich initialisiert."
            else
                echo "FEHLER beim Initialisieren des Repositorys."
            fi
        fi
    fi
}
