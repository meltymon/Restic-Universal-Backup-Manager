# restore.sh

# Funktion für Option 5: Logs anzeigen
view_logs() {
    clear
    echo "--- LOGS ANZEIGEN ---"
    
    # 1. Restic Log
    echo "1. Neuestes Restic Log (Detailansicht)"
    LATEST_LOG=$(find "$LOG_DIR" -name 'backup_*.log' -type f -printf '%T@ %p\n' 2>/dev/null | sort -n | tail -1 | cut -d' ' -f2)
    if [ -n "$LATEST_LOG" ]; then
        echo "Gefunden: $LATEST_LOG"
        read -p "Anzeigen? (j/n): " show_log
        if [[ "$show_log" =~ ^[jJ]$ ]]; then
            less "$LATEST_LOG"
        fi
    else
        echo "Keine Logfiles gefunden in $LOG_DIR."
    fi

    # 2. Systemd Journal
    echo "2. Systemd Journal des Backup-Services"
    if command -v systemctl &> /dev/null; then
        read -p "Systemd Journal anzeigen (sudo erforderlich)? (j/n): " show_journal
        if [[ "$show_journal" =~ ^[jJ]$ ]]; then
            sudo journalctl -eu "$SYSTEMD_SERVICE" | less
        fi
    else
        echo "Systemd nicht gefunden."
    fi
    read -p "Weiter mit Enter..."
}

# Funktion für Option 4: Restore Menü
do_restore() {
    clear
    echo "--- RESTORE WIEDERHERSTELLUNG ---"
    if ! check_tools_and_env; then return; fi
    
    echo "1. Restore einer Einzeldatei/Verzeichnis (Im laufenden System)"
    echo "2. Notfall-Systemwiederherstellung (NUR von Live-System ausführen!)"
    echo "3. Snapshots anzeigen"
    echo "4. Zurück"
    
    read -p "Wahl: " restore_choice
    
    case $restore_choice in
        1)
            restic snapshots
            read -p "Wiederherzustellende Snapshot-ID (z.B. latest oder ID): " snap_id
            read -p "Pfad IM BACKUP (z.B. /home/user/Dokumente/Datei.txt): " file_to_restore
            read -p "Zielpfad auf Workstation (z.B. /tmp/restore_out): " target_path

            mkdir -p "$target_path"
            echo "Starte Restore von $file_to_restore aus Snapshot $snap_id nach $target_path..."
            restic restore "$snap_id" --target "$target_path" --include "$file_to_restore"
            
            if [ $? -eq 0 ]; then
                echo "Restore erfolgreich unter $target_path gespeichert."
            else
                echo "FEHLER beim Restore."
            fi
            ;;
        2)
            echo "WARNUNG: Dies wird das gesamte System überschreiben. NUR von einem LIVE-LINUX-SYSTEM ausführen!"
            read -p "Möchten Sie den interaktiven Notfall-Restore-Prozess starten? (j/n): " confirm_emergency
            if [[ "$confirm_emergency" =~ ^[jJ]$ ]]; then
                emergency_system_restore
            fi
            ;;
        3)
            restic snapshots
            ;;
    esac
}

# Funktion für Notfall-Restore
emergency_system_restore() {
    clear
    echo "--- NOTFALL-SYSTEMWIEDERHERSTELLUNG (LIVE-SYSTEM) ---"
    echo "Wird das Repository mit $REPO_URL verwenden."
    
    # 1. Manuelle Abfrage der kritischen Partition
    echo "---------------------------------------------------------"
    lsblk
    echo "---------------------------------------------------------"
    read -p "Partition zur Wiederherstellung (z.B. /dev/sda2): " TARGET_PARTITION
    
    RESTORE_MOUNT_POINT="/mnt/restic_restore"
    mkdir -p "$RESTORE_MOUNT_POINT"
    
    # 2. Mounten
    echo "Partition $TARGET_PARTITION wird nach $RESTORE_MOUNT_POINT gemountet."
    sudo mount "$TARGET_PARTITION" "$RESTORE_MOUNT_POINT"

    if [ $? -ne 0 ]; then
        echo "FEHLER: Konnte Partition nicht mounten."
        return 1
    fi
    
    # 3. Snapshot-Wahl
    restic snapshots
    read -p "Snapshot-ID zur Wiederherstellung (latest oder ID): " SNAPSHOT_ID
    SNAPSHOT_ID=${SNAPSHOT_ID:-latest}

    # 4. Bestätigung und Restore
    echo "WARNUNG: Alle Daten auf $TARGET_PARTITION werden überschrieben!"
    read -p "Sind Sie SICHER, dass Sie $TARGET_PARTITION überschreiben möchten? (ja/nein): " CONFIRM_RESTORE

    if [[ "$CONFIRM_RESTORE" != "ja" ]]; then
        echo "Wiederherstellung abgebrochen."
        sudo umount "$RESTORE_MOUNT_POINT"
        return 0
    fi
    
    echo "Starte Voll-Restore von $SNAPSHOT_ID nach $RESTORE_MOUNT_POINT..."
    sudo restic restore "$SNAPSHOT_ID" --target "$RESTORE_MOUNT_POINT"
    
    if [ $? -eq 0 ]; then
        echo "✅ RESTORE ERFOLGREICH. WICHTIG: Boot-Konfiguration (GRUB/fstab) prüfen."
    else
        echo "❌ FEHLER BEI DER WIEDERHERSTELLUNG."
    fi
    sudo umount "$RESTORE_MOUNT_POINT"
}
