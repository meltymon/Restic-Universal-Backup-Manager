# menu.sh

# Funktion zur Anzeige des Menüs
show_menu() {
    local repo_status="FEHLT"
    
    if load_user_config; then
        repo_status="$REPO_URL"
    fi

    clear
    echo "================================================="
    echo "💡 RESTIC UNIVERSAL MANAGER v2.0 | Status: $(check_tools && echo "OK" || echo "FEHLER")"
    echo "================================================="
    echo "Ziel-Repo: $repo_status"
    echo "-------------------------------------------------"
    echo "1. ⚙️ SETUP: Interaktive Konfiguration & Installation"
    echo "---"
    echo "2. 🔄 BACKUP: Backup Job manuell starten (Inkl. Prune & rsync)"
    echo "3. ✅ CHECK: Repository Integrität prüfen (--check-data)"
    echo "---"
    echo "4. 🛡️ RESTORE: Einzelne Dateien oder Verzeichnis wiederherstellen"
    echo "5. 🔍 LOGS: Restic & Systemd Logs anzeigen"
    echo "6. 📝 CONFIG: Konfigurationsdateien im Editor öffnen"
    echo "0. ❌ Beenden"
    echo "-------------------------------------------------"
}

# Hauptmenü-Schleife (ruft die Funktionen in den anderen Modulen auf)
run_menu_loop() {
    while true; do
        show_menu
        if ! load_user_config; then
            echo "INFO: Konfiguration fehlt. Bitte Option 1 wählen, um zu starten."
        fi

        read -p "Wahl eingeben [0-6]: " choice

        case $choice in
            1) do_setup ;;
            2)
                if check_tools_and_env; then
                    run_automated_backup
                fi
                read -p "Job abgeschlossen. Weiter mit Enter..."
                ;;
            3)
                if check_tools_and_env; then
                    echo "Prüfe Repository Integrität..."
                    restic check --check-data
                fi
                read -p "Prüfung abgeschlossen. Weiter mit Enter..."
                ;;
            4) 
                if check_tools_and_env; then
                    do_restore
                fi
                read -p "Weiter mit Enter..."
                ;;
            5) view_logs ;;
            6)
                EDITOR=${EDITOR:-nano}
                echo "Öffne $CONFIG_FILE..."
                "$EDITOR" "$CONFIG_FILE"
                read -p "Konfiguration gespeichert. Weiter mit Enter..."
                ;;
            0)
                echo "Manager wird beendet."
                break
                ;;
            *)
                echo "Ungültige Wahl."
                read -p "Weiter mit Enter..."
                ;;
        esac
    done
}
