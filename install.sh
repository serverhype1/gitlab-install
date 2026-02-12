#!/usr/bin/bash
set -e

mkdir -p /root/gitlab &> /dev/null

# Passwort-Eingabe mit Sternchen
read_password() {
    local prompt="$1"
    local password=""
    local char=""
    printf "%s" "$prompt" > /dev/tty
    while IFS= read -r -s -n1 char < /dev/tty; do
        if [[ -z "$char" ]]; then
            break
        elif [[ "$char" == $'\x7f' || "$char" == $'\b' ]]; then
            if [[ -n "$password" ]]; then
                password="${password%?}"
                printf "\b \b" > /dev/tty
            fi
        else
            password+="$char"
            printf "*" > /dev/tty
        fi
    done
    echo "" > /dev/tty
    echo "$password"
}

# Prüfe ob sudo installiert ist
if command -v sudo &> /dev/null; then
    echo "sudo ist bereits installiert."
else
    echo "sudo wird installiert..."
    apt-get install sudo -y &> /dev/null
    echo "sudo wurde installiert."
fi

# Systemaktualisierung
echo "Systemaktualisierung wird durchgeführt..."
sudo apt-get update &> /dev/null && sudo apt-get upgrade -y &> /dev/null && sudo apt-get autoremove -y &> /dev/null
sudo apt-get install curl nano htop wget openssl -y &> /dev/null
echo "Systemaktualisierung abgeschlossen."

# Prüfe ob Docker installiert ist
if command -v docker &> /dev/null; then
    echo "Docker ist bereits installiert: $(docker --version)"
else
    echo "Docker wird installiert..."
    curl -sSL https://get.docker.com | sh &> /dev/null
    sudo usermod -aG docker "$USER" &> /dev/null
    echo "Docker wurde installiert."
fi

# Prüfe ob Docker Compose installiert ist
if docker compose version &> /dev/null; then
    echo "Docker Compose ist bereits installiert: $(docker compose version)"
else
    echo "Docker Compose wird installiert..."
    sudo apt-get install docker-compose-plugin -y &> /dev/null
    echo "Docker Compose wurde installiert."
fi

echo ""
echo "=============================================="
echo "GitLab Konfiguration"
echo "=============================================="
echo ""

# Domain abfragen
read -p "Hauptdomain eingeben (z.B. example.com): " MAIN_DOMAIN < /dev/tty
GITLAB_URL="https://gitlab.${MAIN_DOMAIN}"
GITLAB_HOSTNAME="gitlab.${MAIN_DOMAIN}"


# SMTP Konfiguration abfragen (Strato Standardwerte)
echo "--- SMTP Konfiguration (Strato Standardwerte) ---"
read -p "SMTP Server [smtp.strato.de]: " SMTP_ADDRESS < /dev/tty
SMTP_ADDRESS=${SMTP_ADDRESS:-smtp.strato.de}
read -p "SMTP Port [465]: " SMTP_PORT < /dev/tty
SMTP_PORT=${SMTP_PORT:-465}
read -p "SMTP Benutzername (z.B. mail@example.com): " SMTP_USERNAME < /dev/tty
SMTP_PASSWORD=$(read_password "SMTP Passwort: ")
read -p "SMTP Domain (z.B. example.com): " SMTP_DOMAIN < /dev/tty
read -p "GitLab E-Mail Absender (z.B. gitlab@example.com): " GITLAB_EMAIL_FROM < /dev/tty
read -p "GitLab E-Mail Reply-To (z.B. gitlab@example.com): " GITLAB_EMAIL_REPLY_TO < /dev/tty
echo ""

# SMTP TLS Einstellungen basierend auf Port setzen
# Port 465 = TLS (direktes SSL)
# Port 587 = STARTTLS
# Port 25 = kein TLS (unsicher)
if [ "$SMTP_PORT" = "465" ]; then
    SMTP_TLS="true"
    SMTP_STARTTLS="false"
    echo "Port 465 erkannt: Verwende TLS (direktes SSL)"
elif [ "$SMTP_PORT" = "587" ]; then
    SMTP_TLS="false"
    SMTP_STARTTLS="true"
    echo "Port 587 erkannt: Verwende STARTTLS"
else
    SMTP_TLS="false"
    SMTP_STARTTLS="false"
    echo "Port $SMTP_PORT: Kein TLS konfiguriert (unsicher)"
fi
echo ""

#reverse proxy abfragen
echo "Welchen Reverse Proxy möchtest du verwenden?"
echo "1) Caddy installieren"
echo "2) Nginx installieren"
echo "3) Bereits installiert (Caddy)"
echo "4) Bereits installiert (Nginx)"
echo "5) Keinen"
read -p "Auswahl (1/2/3/4/5): " REVERSE_PROXY < /dev/tty
case "$REVERSE_PROXY" in
    1)
        echo "Caddy wird installiert..."
        curl -sSL https://gitlab.pascalheim.de/root/gitlab/-/raw/main/Caddy/install.sh?ref_type=heads | bash -s personal > /dev/null
        echo "Caddy wurde installiert."
        ;;
    2)
        echo "Nginx wird installiert..."
        curl -sSL https://gitlab.pascalheim.de/root/gitlab/-/raw/main/NGNIX/install.sh?ref_type=heads | bash -s personal > /dev/null
        echo "Nginx wurde installiert."
        ;;
    3)
        echo "Vorhandener Caddy wird verwendet."
        ;;
    4)
        echo "Vorhandener Nginx wird verwendet."
        ;;
    *)
        echo "Kein Reverse Proxy wird installiert. Bitte stelle sicher, dass Port 80 und 443 auf diesen Server weitergeleitet werden, damit GitLab erreichbar ist."
        ;;
esac

# OpenID Connect abfragen
echo "--- OpenID Connect Konfiguration ---"
read -p "OpenID Connect aktivieren? (j/n): " ENABLE_OIDC < /dev/tty

if [[ "$ENABLE_OIDC" == "j" || "$ENABLE_OIDC" == "J" ]]; then
    OIDC_ENABLED="true"
    read -p "OIDC Name (z.B. Libre-Workspace): " OIDC_NAME < /dev/tty
    read -p "OIDC Issuer URL (z.B. https://auth.example.com/application/o/gitlab/): " OIDC_ISSUER < /dev/tty
    read -p "OIDC Client ID: " OIDC_CLIENT_ID < /dev/tty
    read -p "OIDC Client Secret: " OIDC_CLIENT_SECRET < /dev/tty
    OIDC_COMMENT=""
else
    OIDC_ENABLED="false"
    OIDC_NAME="Libre-Workspace"
    OIDC_ISSUER="https://auth.example.com/application/o/gitlab/"
    OIDC_CLIENT_ID="your-client-id"
    OIDC_CLIENT_SECRET="your-client-secret"
    OIDC_COMMENT="# "
fi

mkdir -p /root/gitlab &> /dev/null

#port fragen
read -p "Port für GitLab HTTP (Standard 80): " port < /dev/tty
port=${port:-80}

read -p "Soll auch SSH Zugriff auf GitLab ermöglicht werden? (j/n): " ssh_gitlab < /dev/tty
if [[ "$ssh_gitlab" == "j" || "$ssh_gitlab" == "J" ]]; then
    read -p "Port für GitLab SSH (Standard 2222): " ssh_port < /dev/tty
    ssh_port=${ssh_port:-2222}
    SSH_COMMENT=""
else
    ssh_port=2222
    SSH_COMMENT="# "
fi


cat > /root/docker-compose.yml <<EOF
services:
  gitlab:
    image: gitlab/gitlab-ce:latest
    container_name: gitlab
    restart: always
    hostname: ${GITLAB_HOSTNAME}
    environment:
      GITLAB_OMNIBUS_CONFIG: |
        external_url '${GITLAB_URL}'
        nginx['listen_port'] = 80
        nginx['listen_https'] = false
        nginx['proxy_set_headers'] = {
          "X-Forwarded-Proto" => "https",
          "X-Forwarded-Ssl" => "on"
        }
        ${SSH_COMMENT}gitlab_rails['gitlab_shell_ssh_port'] = ${ssh_port}
        gitlab_rails['smtp_enable'] = true
        gitlab_rails['smtp_address'] = ENV['SMTP_ADDRESS']
        gitlab_rails['smtp_port'] = ENV['SMTP_PORT'].to_i
        gitlab_rails['smtp_user_name'] = ENV['SMTP_USERNAME']
        gitlab_rails['smtp_password'] = ENV['SMTP_PASSWORD']
        gitlab_rails['smtp_domain'] = ENV['SMTP_DOMAIN']
        gitlab_rails['smtp_authentication'] = 'login'
        gitlab_rails['smtp_enable_starttls_auto'] = ${SMTP_STARTTLS}
        gitlab_rails['smtp_tls'] = ${SMTP_TLS}
        gitlab_rails['gitlab_email_from'] = ENV['GITLAB_EMAIL_FROM']
        gitlab_rails['gitlab_email_reply_to'] = ENV['GITLAB_EMAIL_REPLY_TO']
        ${OIDC_COMMENT}gitlab_rails['omniauth_providers'] = [
        ${OIDC_COMMENT}  {
        ${OIDC_COMMENT}    name: 'openid_connect',
        ${OIDC_COMMENT}    label: ENV['OIDC_NAME'],
        ${OIDC_COMMENT}    args: {
        ${OIDC_COMMENT}      name: 'openid_connect',
        ${OIDC_COMMENT}      scope: ['openid', 'profile', 'email'],
        ${OIDC_COMMENT}      response_type: 'code',
        ${OIDC_COMMENT}      issuer: ENV['OIDC_ISSUER'],
        ${OIDC_COMMENT}      client_auth_method: 'query',
        ${OIDC_COMMENT}      discovery: true,
        ${OIDC_COMMENT}      uid_field: 'preferred_username',
        ${OIDC_COMMENT}      client_options: {
        ${OIDC_COMMENT}        identifier: ENV['OIDC_CLIENT_ID'],
        ${OIDC_COMMENT}        secret: ENV['OIDC_CLIENT_SECRET'],
        ${OIDC_COMMENT}        redirect_uri: '${GITLAB_URL}/users/auth/openid_connect/callback'
        ${OIDC_COMMENT}      }
        ${OIDC_COMMENT}    }
        ${OIDC_COMMENT}  }
        ${OIDC_COMMENT}]
        ${OIDC_COMMENT}gitlab_rails['omniauth_allow_single_sign_on'] = ['openid_connect']
        ${OIDC_COMMENT}gitlab_rails['omniauth_block_auto_created_users'] = false
    env_file:
      - .env
    ports:
      - "${port}:80"
      ${SSH_COMMENT}- "${ssh_port}:22"
    volumes:
      - ./daten/config:/etc/gitlab
      - ./daten/logs:/var/log/gitlab
      - ./daten/data:/var/opt/gitlab
EOF

# .env Datei erstellen
cat > /root/.env <<EOF
# GitLab Domain
GITLAB_DOMAIN=${GITLAB_HOSTNAME}
GITLAB_URL=${GITLAB_URL}

# SMTP Konfiguration
SMTP_ADDRESS=${SMTP_ADDRESS}
SMTP_PORT=${SMTP_PORT}
SMTP_USERNAME=${SMTP_USERNAME}
SMTP_PASSWORD=${SMTP_PASSWORD}
SMTP_DOMAIN=${SMTP_DOMAIN}

# GitLab E-Mail Adressen
GITLAB_EMAIL_FROM=${GITLAB_EMAIL_FROM}
GITLAB_EMAIL_REPLY_TO=${GITLAB_EMAIL_REPLY_TO}

# OpenID Connect Konfiguration
${OIDC_COMMENT}OIDC_ENABLED=${OIDC_ENABLED}
${OIDC_COMMENT}OIDC_NAME=${OIDC_NAME}
${OIDC_COMMENT}OIDC_ISSUER=${OIDC_ISSUER}
${OIDC_COMMENT}OIDC_CLIENT_ID=${OIDC_CLIENT_ID}
${OIDC_COMMENT}OIDC_CLIENT_SECRET=${OIDC_CLIENT_SECRET}
EOF
echo "gitlab datei erstellt."

# Caddyfile Eintrag erstellen wenn Caddy ausgewählt wurde
if [ "$REVERSE_PROXY" = "1" ] || [ "$REVERSE_PROXY" = "3" ]; then
    echo "GitLab Reverse Proxy wird in Caddyfile eingetragen..."
    sudo sed -i "\$a\\\\n${GITLAB_HOSTNAME} {\n    reverse_proxy localhost:${port}\n}" /etc/caddy/Caddyfile
    sudo systemctl reload caddy
    echo "Caddyfile wurde aktualisiert und Caddy neu geladen."
fi

echo "GitLab wird gestartet und herungergeladen. Dies kann einige Minuten dauern.. nicht wundern wenn es länger dauert es hängt an der internetverbindung ab:)"
docker compose up -d &> /dev/null

# Server IP ermitteln
SERVER_IP=$(hostname -I | awk '{print $1}')


# Update Script fragen
read -rp "Update Script erstellen? (y/n): " CREATE_UPDATE_SCRIPT < /dev/tty
if [ "$CREATE_UPDATE_SCRIPT" = "y" ]; then
    SCRIPT_PATH="/root/.scripts/update.sh"
    CRON_JOB="0 3 * * 0 /root/.scripts/update.sh &> /dev/null"

    UPDATE_LINES='apt update && apt upgrade -y && apt autoremove -y
apt dist-upgrade -y && apt autoremove -y

# Alle docker-compose Projekte finden und updaten
find /root -maxdepth 3 -name "docker-compose.yml" -o -name "compose.yml" | while read -r file; do
    dir=$(dirname "$file")
    echo "Updating Docker Compose project in: $dir"
    cd "$dir"
    docker compose pull
    docker compose down
    docker compose up -d
done'

    if [ -f "$SCRIPT_PATH" ]; then
        echo "Update Script existiert bereits."
        if grep -qF "apt dist-upgrade -y && apt autoremove -y" "$SCRIPT_PATH"; then
            echo "Inhalt ist bereits vorhanden, keine Änderung nötig."
        else
            echo "Füge Update-Befehle in bestehendes Script ein..."
            echo "$UPDATE_LINES" >> "$SCRIPT_PATH"
            echo "Update-Befehle wurden eingefügt."
        fi
    else
        echo "Update Script wird erstellt..."
        mkdir -p /root/.scripts
        cat << 'UPDATEEOF' > "$SCRIPT_PATH"
#!/usr/bin/bash
apt update && apt upgrade -y && apt autoremove -y
apt dist-upgrade -y && apt autoremove -y

# Alle docker-compose Projekte finden und updaten
find /root -maxdepth 3 -name "docker-compose.yml" -o -name "compose.yml" | while read -r file; do
    dir=$(dirname "$file")
    echo "Updating Docker Compose project in: $dir"
    cd "$dir"
    docker compose pull
    docker compose down
    docker compose up -d
done
UPDATEEOF
        chmod +x "$SCRIPT_PATH"
        echo "Update Script wurde erstellt."
    fi

    # cronjob prüfen und ggf. erstellen
    if crontab -l 2>/dev/null | grep -qF "$SCRIPT_PATH"; then
        echo "Cronjob existiert bereits, keine Änderung nötig."
    else
        (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
        echo "Update Cronjob wurde erstellt (sonntags um 3 Uhr)."
    fi
    echo ""
fi

# Warten bis GitLab bereit ist
while ! docker exec gitlab cat /etc/gitlab/initial_root_password &> /dev/null; do
    echo "GitLab initialisiert noch... warte 30 Sekunden"
    sleep 30
done
PASSWORD=$(docker exec gitlab grep 'Password:' /etc/gitlab/initial_root_password)

echo "=============================================="
echo "GitLab Initial Root Passwort"
echo "=============================================="
echo ""
echo "=============================================="
echo "URL: ${GITLAB_URL}"
echo "Benutzername: root"
echo "$PASSWORD"
echo "=============================================="
echo ""
echo "WICHTIG: Das Passwort wird nach 24 Stunden automatisch geloescht!"
echo "Bitte aendere das Passwort nach dem ersten Login."
echo ""
echo ""