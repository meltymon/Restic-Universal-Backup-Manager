# 🚀 Restic Universal Backup Manager (RUBM)

## 🛡️ Die Vollautomatisierte, Modulare Backup-Lösung für Linux-Workstations

Der **Restic Universal Backup Manager (RUBM)** ist eine modulare, in Bash geschriebene Lösung, die die leistungsstarke, deduplizierende Backup-Software [Restic](https://restic.net/) in ein **universelles, interaktives und wartungsarmes System** verwandelt.

Entwickelt, um die Komplexität der Kommandozeile zu beseitigen, bietet RUBM ein Menüsystem, das die tägliche Wartung, automatische Synchronisierung (z.B. mit Nextcloud) und die Notfallwiederherstellung des gesamten Systems in einem einfachen Prozess vereint.

## ✨ Hauptfunktionen

| Feature | Beschreibung | Vorteil für den Nutzer |
| :--- | :--- | :--- |
| **Interaktives Setup** | Die gesamte Konfiguration (Repo-URL, Passwort, Ausschlüsse) wird beim ersten Start **interaktiv abgefragt** und in einer separaten Datei gespeichert – **keine manuelle Skriptbearbeitung nötig.**  | Maximaler Komfort, minimales Fehlerpotenzial. |
| **Universelle Portabilität** | Das Skript erkennt automatisch den verwendeten Paketmanager (`pacman`, `apt`, `dnf`) und überprüft, ob alle erforderlichen Tools (`restic`, `zip`, `rsync`) installiert sind. | Funktioniert **zuverlässig** auf fast jeder modernen Linux-Distribution (Arch, Debian, Ubuntu, Fedora etc.).  |
| **Automatische Synchronisation** | Führt nach jedem Backup eine inkrementelle Synchronisation des Repositorys (via `rsync`) zu einem Remote-Ziel (z.B. Nextcloud/SFTP) durch und startet automatisch den `occ files:scan`. | **Einfache Offsite-Sicherung** ohne komplexe Cronjobs. |
| **Modulare Struktur** | Aufgeteilt in logische Dateien (`config.sh`, `backup_logic.sh`, `restore.sh`), was das System extrem **übersichtlich und wartbar** macht.  | Ideal für Community-Beiträge und einfache Erweiterungen. |
| **Management-Menü** | Ein intuitives Menü vereint Backup-Start, Integritätsprüfungen, Log-Analyse und Wiederherstellung an einem Ort.  | Steuern Sie Ihr gesamtes Backup-System mit nur einem Befehl. |

## 🚀 Die Vier Säulen der Sicherung

Das RUBM-System basiert auf vier getrennten, optimierten Modulen, die über ein **Hauptmenü** gesteuert werden:

1.  **⚙️ Setup/Install:** Prüft und installiert alle notwendigen Abhängigkeiten (Restic, Zip, Rsync) und fragt interaktiv die Benutzerkonfiguration ab.
2.  **🔄 Backup-Logik:** Führt die automatische inkrementelle Sicherung, Deduplizierung, `forget/prune` und die Synchronisierung durch.
3.  **🛡️ Restore-Logik:** Ermöglicht die Wiederherstellung **einzelner Dateien** im laufenden Betrieb oder die **Notfallwiederherstellung des gesamten Systems** von einem Live-USB-Stick.
4.  **💡 Manager-Menü:** Das Front-End zur Steuerung der Module.

## 💻 Installation und Start

1.  **Klonen Sie das Repository:**
    ```bash
    git clone [https://github.com/meltymon/restic-universal-manager.git](https://github.com/IhrUsername/restic-universal-manager.git)
    cd restic-universal-manager
    ```
2.  **Starten Sie den Manager:**
    ```bash
    bash ./run.sh
    ```
3.  Wählen Sie **Option 1 (SETUP)** und folgen Sie den interaktiven Anweisungen, um Ihr Repository-Ziel (`REPO_URL`) und das Passwort einzugeben.

## ❓ FAQ & Hilfe

* **Systemd-Automatisierung:** Die mitgelieferte Logik ist darauf ausgelegt, leicht in einen `systemd`-Timer integriert zu werden, um die tägliche Ausführung zu automatisieren.
* **Nextcloud/Docker:** Das Skript ist darauf vorbereitet, Docker-Container (wie `nextcloud_app`) anzusteuern, kann aber auch für einfache lokale oder SSH-Repositories verwendet werden.
* **Passwort:** Das Skript speichert das Restic-Passwort in einer versteckten, lokalen Konfigurationsdatei (`$HOME/.restic_universal_manager_config`), um eine unbeaufsichtigte Ausführung zu ermöglichen.
* **Lizenz:** [Hier die Lizenz angeben, z.B. MIT oder GPL]

## 🤝 Mitwirken (Contributing)

Ihre Ideen sind willkommen! Da das Skript modular aufgebaut ist, sind Beiträge zu Erweiterungen (z.B. Unterstützung für neue Paketmanager, bessere Fehlerbehandlung) einfach zu implementieren.
