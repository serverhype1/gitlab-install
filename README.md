# Docker-YT Install Script

An interactive installation script that automatically sets up **GitLab** via Docker — including optional configuration of **SMTP** (email delivery), **OpenID Connect** (SSO login) and a **reverse proxy**.

## Features

- Automatic GitLab installation via Docker
- Optional SMTP configuration for email notifications
- Optional OpenID Connect integration for Single Sign-On
- Optional reverse proxy:
  - **Caddy** — works out of the box, no additional configuration needed
  - **NGINX** — requires manual configuration after installation
- **Automatic updates** — the script sets up a cronjob that automatically runs an update every **Sunday at 03:00 AM**

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
```

**Via GitHub:**
```bash
git clone https://github.com/serverhype1/docker-yt.git
cd docker-yt
```

## Notes

- This repository is maintained on both [GitLab](https://gitlab.pascalheim.de/serverhype/docker-yt) and [GitHub](https://github.com/serverhype1/docker-yt) — both are always in sync.
- When choosing **Caddy** as the reverse proxy, no further configuration is needed.
- When choosing **NGINX**, the configuration must be adjusted manually after installation.

---

# Docker-YT Install Script (Deutsch)

Ein interaktives Installationsskript, das **GitLab** vollautomatisch per Docker aufsetzt — inklusive optionaler Konfiguration von **SMTP** (E-Mail-Versand) und **OpenID Connect** (SSO-Login).

## Features

- Automatische GitLab-Installation via Docker
- Optionale SMTP-Konfiguration für E-Mail-Benachrichtigungen
- Optionale OpenID Connect-Anbindung für Single Sign-On
- Optionaler Reverse Proxy:
  - **Caddy** — funktioniert direkt ohne weitere Konfiguration
  - **NGINX** — erfordert manuelle Anpassung der Konfiguration nach der Installation
- **Automatische Updates** — das Skript richtet einen Cronjob ein, der jeden **Sonntag um 03:00 Uhr** automatisch ein Update durchführt

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
```

**Über GitHub:**
```bash
git clone https://github.com/serverhype1/docker-yt.git
cd docker-yt
```

## Hinweise

- Das Repository wird sowohl auf [GitLab](https://gitlab.pascalheim.de/serverhype/docker-yt) als auch auf [GitHub](https://github.com/serverhype1/docker-yt) gepflegt — beide sind immer auf dem gleichen Stand.
- Bei der Wahl von **Caddy** als Reverse Proxy ist keine weitere Konfiguration nötig.
- Bei **NGINX** muss die Konfiguration nach der Installation manuell angepasst werden.