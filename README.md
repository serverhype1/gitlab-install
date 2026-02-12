# Docker-install — GitLab Install Script

An interactive installation script that automatically sets up a self-hosted **GitLab CE** instance via Docker on Debian-based systems.

## Features

- **Fully automated** — installs Docker, Docker Compose, and all dependencies if not already present
- **SMTP configuration** — set up email delivery with automatic TLS detection based on port (465 = TLS, 587 = STARTTLS)
- **OpenID Connect** — optional SSO login integration (e.g. with Authentik, Keycloak, etc.)
- **Reverse proxy** — optional installation of:
  - **Caddy** — automatic HTTPS, zero configuration needed
  - **NGINX** — requires manual configuration after installation
  - Or use an already installed proxy, or none at all
- **SSH access** — optional Git-over-SSH on a custom port
- **Automatic updates** — optional cronjob every **Sunday at 03:00 AM** that updates the system and all Docker Compose projects
- **Secure password input** — SMTP password is masked with asterisks during entry

## Prerequisites

- A Debian-based Linux server (Debian, Ubuntu, etc.)
- Root access
- A domain pointing to your server (e.g. `gitlab.example.com`)

## Quick Start (One-Liner)

Download and run the script directly:

**Via GitLab:**
```bash
curl -sSL https://gitlab.pascalheim.de/serverhype/docker-yt/-/raw/main/install.sh?ref_type=heads | bash
```

**Via GitHub:**
```bash
curl -sSL https://raw.githubusercontent.com/serverhype1/docker-yt/refs/heads/main/gitlab/install.sh | bash
```

## Installation via Git Clone

Alternatively, clone the repository and run it locally:

**Via GitLab:**
```bash
git clone https://gitlab.pascalheim.de/serverhype/docker-yt.git
cd docker-yt
chmod +x install.sh
./install.sh
```

**Via GitHub:**
```bash
git clone https://github.com/serverhype1/docker-yt.git
cd docker-yt
chmod +x install.sh
./install.sh
```

## What the Script Does

1. **System preparation** — installs `sudo`, `curl`, `nano`, `htop`, `wget`, `openssl` and performs a system update
2. **Docker setup** — installs Docker and Docker Compose if not already present
3. **GitLab configuration** — interactively asks for:
   - Domain name (e.g. `example.com` → GitLab will be available at `gitlab.example.com`)
   - SMTP settings (defaults to Strato, but any provider works)
   - Reverse proxy choice (Caddy / NGINX / existing / none)
   - OpenID Connect settings (optional)
   - HTTP port and optional SSH port
4. **File generation** — creates `docker-compose.yml` and `.env` in `/root/`
5. **Caddy integration** — if Caddy is selected, automatically adds the reverse proxy entry to the Caddyfile
6. **GitLab startup** — pulls the image and starts the container
7. **Update script** (optional) — creates `/root/.scripts/update.sh` with a weekly cronjob that:
   - Runs `apt update`, `apt upgrade`, `apt dist-upgrade`, `apt autoremove`
   - Finds and updates all Docker Compose projects under `/root/`
8. **Shows credentials** — waits for GitLab to finish initializing and displays the initial root password

## Default Ports

| Service | Default Port | Configurable |
|---------|-------------|--------------|
| GitLab HTTP | 80 | Yes |
| GitLab SSH | 2222 | Yes (optional) |

## Notes

- This repository is maintained on both [GitLab](https://gitlab.pascalheim.de/serverhype/docker-yt) and [GitHub](https://github.com/serverhype1/docker-yt) — both are always in sync.
- The initial root password is displayed after installation and **expires after 24 hours** — change it immediately after your first login.
- GitLab data is stored in `/root/daten/` (config, logs, data).
- The update script avoids duplicates — if it already exists, only missing entries are appended.

---

# Docker-YT — GitLab Install Script (Deutsch)

Ein interaktives Installationsskript, das eine selbstgehostete **GitLab CE**-Instanz vollautomatisch per Docker auf Debian-basierten Systemen aufsetzt.

## Features

- **Vollautomatisch** — installiert Docker, Docker Compose und alle Abhängigkeiten, falls noch nicht vorhanden
- **SMTP-Konfiguration** — E-Mail-Versand einrichten mit automatischer TLS-Erkennung basierend auf dem Port (465 = TLS, 587 = STARTTLS)
- **OpenID Connect** — optionale SSO-Login-Anbindung (z.B. mit Authentik, Keycloak, etc.)
- **Reverse Proxy** — optionale Installation von:
  - **Caddy** — automatisches HTTPS, keine weitere Konfiguration nötig
  - **NGINX** — erfordert manuelle Konfiguration nach der Installation
  - Oder einen bereits installierten Proxy verwenden, oder gar keinen
- **SSH-Zugriff** — optionaler Git-over-SSH auf einem eigenen Port
- **Automatische Updates** — optionaler Cronjob jeden **Sonntag um 03:00 Uhr**, der das System und alle Docker-Compose-Projekte aktualisiert
- **Sichere Passworteingabe** — SMTP-Passwort wird bei der Eingabe mit Sternchen maskiert

## Voraussetzungen

- Ein Debian-basierter Linux-Server (Debian, Ubuntu, etc.)
- Root-Zugriff
- Eine Domain, die auf den Server zeigt (z.B. `gitlab.example.com`)

## Schnellstart (One-Liner)

Das Skript direkt herunterladen und ausführen:

**Über GitLab:**
```bash
curl -sSL https://gitlab.pascalheim.de/serverhype/docker-yt/-/raw/main/install.sh?ref_type=heads | bash
```

**Über GitHub:**
```bash
curl -sSL https://raw.githubusercontent.com/serverhype1/docker-yt/refs/heads/main/gitlab/install.sh | bash
```

## Installation via Git Clone

Alternativ das Repository klonen und lokal ausführen:

**Über GitLab:**
```bash
git clone https://gitlab.pascalheim.de/serverhype/docker-yt.git
cd docker-yt
chmod +x install.sh
./install.sh
```

**Über GitHub:**
```bash
git clone https://github.com/serverhype1/docker-yt.git
cd docker-yt
chmod +x install.sh
./install.sh
```

## Was das Skript macht

1. **Systemvorbereitung** — installiert `sudo`, `curl`, `nano`, `htop`, `wget`, `openssl` und führt ein System-Update durch
2. **Docker-Setup** — installiert Docker und Docker Compose, falls noch nicht vorhanden
3. **GitLab-Konfiguration** — fragt interaktiv ab:
   - Domain-Name (z.B. `example.com` → GitLab wird unter `gitlab.example.com` erreichbar)
   - SMTP-Einstellungen (Standardwerte für Strato, aber jeder Anbieter funktioniert)
   - Reverse-Proxy-Auswahl (Caddy / NGINX / vorhanden / keiner)
   - OpenID-Connect-Einstellungen (optional)
   - HTTP-Port und optionaler SSH-Port
4. **Dateierstellung** — erstellt `docker-compose.yml` und `.env` unter `/root/`
5. **Caddy-Integration** — wenn Caddy gewählt wurde, wird der Reverse-Proxy-Eintrag automatisch in die Caddyfile geschrieben
6. **GitLab-Start** — lädt das Image herunter und startet den Container
7. **Update-Skript** (optional) — erstellt `/root/.scripts/update.sh` mit einem wöchentlichen Cronjob, der:
   - `apt update`, `apt upgrade`, `apt dist-upgrade`, `apt autoremove` ausführt
   - Alle Docker-Compose-Projekte unter `/root/` findet und aktualisiert
8. **Zugangsdaten anzeigen** — wartet bis GitLab fertig initialisiert ist und zeigt das initiale Root-Passwort an

## Standard-Ports

| Dienst | Standard-Port | Konfigurierbar |
|--------|--------------|----------------|
| GitLab HTTP | 80 | Ja |
| GitLab SSH | 2222 | Ja (optional) |

## Hinweise

- Das Repository wird sowohl auf [GitLab](https://gitlab.pascalheim.de/serverhype/docker-yt) als auch auf [GitHub](https://github.com/serverhype1/docker-yt) gepflegt — beide sind immer auf dem gleichen Stand.
- Das initiale Root-Passwort wird nach der Installation angezeigt und **läuft nach 24 Stunden ab** — ändere es sofort nach dem ersten Login.
- GitLab-Daten werden unter `/root/daten/` gespeichert (Config, Logs, Daten).
- Das Update-Skript vermeidet Duplikate — falls es bereits existiert, werden nur fehlende Einträge ergänzt.
