#!/usr/bin/env bash

set -euo pipefail

#######################################
# Root / sudo Check
#######################################

if [[ "$EUID" -ne 0 ]]; then
  echo "Dieses Skript benötigt Root-Rechte!"
  echo "Bitte mit sudo ausführen:"
  echo "    sudo ./deploy.sh"
  exit 1
fi

#######################################
# Deploy production or dev?
#######################################

# Ins Verzeichnis des Skripts wechseln, egal von wo es aufgerufen wird
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

read -rp "Welche Umgebung soll deployed werden? [prod/dev] (Default: prod): " DEPLOY_ENV
DEPLOY_ENV="${DEPLOY_ENV:-prod}"

case "$DEPLOY_ENV" in
  prod|production)
    DEPLOY_ENV="prod"
    ;;
  dev|development)
    DEPLOY_ENV="dev"
    ;;
  *)
    echo "Ungültige Auswahl. Bitte 'prod' oder 'dev' angeben."
    exit 1
    ;;
esac

echo "Deploy-Umgebung: $DEPLOY_ENV"

#######################################
# Write PWD into .env
#######################################

ENV_FILE="$SCRIPT_DIR/.env"

# .env neu schreiben
echo "PROJECT_ROOT=$SCRIPT_DIR" > "$ENV_FILE"
echo "ENVIRONMENT=$DEPLOY_ENV" >> "$ENV_FILE"

echo ".env geschrieben:"
cat "$ENV_FILE"
echo

#######################################
# rsync grav-admin into grav
# - bei prod ohne Admin- und Login-Plugin
# - bei dev mit allen Plugins
#######################################

SOURCE_DIR="$SCRIPT_DIR/grav-admin"
TARGET_DIR="$SCRIPT_DIR/grav"

if [[ ! -d "$SOURCE_DIR" ]]; then
  echo "Fehler: Quellverzeichnis '$SOURCE_DIR' existiert nicht."
  exit 1
fi

mkdir -p "$TARGET_DIR"

if [[ "$DEPLOY_ENV" == "prod" ]]; then
  echo "Synchronisiere PROD (ohne Admin- und Login-Plugin)..."
  rsync -a --delete \
    --exclude 'user/plugins/admin' \
    --exclude 'user/plugins/login' \
    "$SOURCE_DIR"/ "$TARGET_DIR"/
fi

echo "rsync abgeschlossen."
echo

#######################################
# Set ownership of folder grav to www-data/httpd (id=33)
#######################################
echo "Setze Besitzrechte auf www-data:www-data (id=33)..."
if [[ "$DEPLOY_ENV" == "prod" ]]; then
    chown -R 33:33 "$TARGET_DIR"
else
    chown -R 33:33 grav-admin
fi

echo "Fertig. Deployment für '$DEPLOY_ENV' abgeschlossen."
