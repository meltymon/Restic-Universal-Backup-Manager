# backup_logic.sh

run_automated_backup() {
    # Tools prüfen und Umgebung laden
    if ! check_tools_and_env; then return 1; fi
    
    # Stellt sicher, dass das Logging-Verzeichnis existiert
    mkdir -p "$LOG_DIR"
    mkdir -p "$TARGET_NC_REPO"
    
    LOG_FILE="$LOG_DIR/backup_$(date +%Y-%m-%d_%H%M).log"
    RESTIC_BIN=$(which restic) # Erneut bestimmen für den Aufruf

    echo "Starting Restic Backup at $(date)" | tee "$LOG_FILE"
    echo "--- Restic Verbose Log Start ---" | tee -a "$LOG_FILE"
    
    # Dynamische Exclude-Liste aus CUSTOM_EXCLUDES erstellen
    EXCLUDE_ARGS=""
    for item in $CUSTOM_EXCLUDES; do
        EXCLUDE_ARGS+=" --exclude '$BACKUP_SOURCE/$item'"
    done
    
    # Feste Ausschlüsse (müssen immer am Ende stehen)
    EXCLUDE_ARGS+=" --exclude '$BACKUP_SOURCE/restic_repos' --exclude '$TMP_DIR' --exclude '$BACKUP_SOURCE/winboat/windows_secure.tpm'"

    # --- 1. Backup-Befehl ---
    eval "$RESTIC_BIN --verbose backup $BACKUP_SOURCE --repo \"$REPO_URL\" $EXCLUDE_ARGS \
        --tag \"daily\" --host \"\$(hostname)\" --cleanup-cache --exclude-caches \
        --option \"temp_dir:$TMP_DIR\"" 2>&1 | tee -a "$LOG_FILE"

    if [ ${PIPESTATUS[0]} -ne 0 ]; then
        echo "Restic Backup failed at $(date)" | tee -a "$LOG_FILE"
        BACKUP_SUCCESS=false
    else
        BACKUP_SUCCESS=true
    fi

    echo "Backup complete. Running forget policy..." | tee -a "$LOG_FILE"
    
    # --- 2. Aufräum-Befehl ---
    "$RESTIC_BIN" forget --prune --repo "$REPO_URL" \
        --keep-daily 7 --keep-weekly 4 --keep-monthly 12 --keep-yearly 1 2>&1 | tee -a "$LOG_FILE"

    echo "Forget/Prune complete. Starting file transfer..." | tee -a "$LOG_FILE"

    # --- 3. Komprimierung und Transfer (Absolute Pfade nutzen) ---
    local ZIP_BIN_PATH=$(which zip)
    local RSYNC_BIN_PATH=$(which rsync)

    COMPRESSED_LOG="${LOG_FILE}.zip"
    "$ZIP_BIN_PATH" -j "$COMPRESSED_LOG" "$LOG_FILE" 2>&1 | tee -a "$LOG_FILE"
    
    "$RSYNC_BIN_PATH" -avz --delete "$REPO_URL/" "$TARGET_NC_REPO/" 2>&1 | tee -a "$LOG_FILE"
    "$RSYNC_BIN_PATH" -avz "$COMPRESSED_LOG" "$TARGET_NC_REPO/" 2>&1 | tee -a "$LOG_FILE"
    
    # --- 4. OCC Files:Scan (Nur wenn Nextcloud-Zweck benötigt) ---
    if command -v docker &> /dev/null; then
        echo "Starting Nextcloud scan..." | tee -a "$LOG_FILE"
        docker exec -u www-data "$NEXTCLOUD_CONTAINER" php occ files:scan "$NEXTCLOUD_USER" 2>&1 | tee -a "$LOG_FILE"
    else
        echo "Docker/Nextcloud-Scan übersprungen (Docker nicht gefunden)." | tee -a "$LOG_FILE"
    fi

    echo "Job finished at $(date)" | tee -a "$LOG_FILE"
    
    if [ "$BACKUP_SUCCESS" = false ]; then
        return 1
    else
        return 0
    fi
}
