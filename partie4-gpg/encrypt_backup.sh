#!/bin/bash
#===============================================================================
# Script de chiffrement GPG des sauvegardes
# Controle 5 - Annexe 9
#===============================================================================

# Configuration
BACKUP_DIR="/home/osboxes/backups"
GPG_RECIPIENT="backup@local.test"
GPG_PASSPHRASE="BackupGPG2026!"
LOG_FILE="/home/osboxes/backups/encrypt.log"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_message() {
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log_message "${YELLOW}[START]${NC} Demarrage du chiffrement GPG..."

# Trouver le dernier backup non chiffre
LATEST_BACKUP=$(ls -t ${BACKUP_DIR}/auth_backup_*.tar.gz 2>/dev/null | grep -v ".gpg" | head -1)

if [ -z "$LATEST_BACKUP" ]; then
    log_message "${RED}[ERREUR]${NC} Aucun backup trouve a chiffrer"
    exit 1
fi

BACKUP_NAME=$(basename "$LATEST_BACKUP")
log_message "${YELLOW}[INFO]${NC} Chiffrement de: $BACKUP_NAME"

# Chiffrement avec GPG
echo "$GPG_PASSPHRASE" | gpg --batch --yes --passphrase-fd 0 \
    --pinentry-mode loopback \
    -c --cipher-algo AES256 \
    -o "${LATEST_BACKUP}.gpg" \
    "$LATEST_BACKUP" 2>/dev/null

if [ $? -eq 0 ]; then
    log_message "${GREEN}[OK]${NC} Fichier chiffre: ${BACKUP_NAME}.gpg"

    # Verifier l'integrite
    ORIGINAL_SIZE=$(stat -c%s "$LATEST_BACKUP")
    ENCRYPTED_SIZE=$(stat -c%s "${LATEST_BACKUP}.gpg")

    log_message "${GREEN}[INFO]${NC} Taille originale: $(numfmt --to=iec $ORIGINAL_SIZE)"
    log_message "${GREEN}[INFO]${NC} Taille chiffree: $(numfmt --to=iec $ENCRYPTED_SIZE)"

    # Optionnel: supprimer le backup non chiffre
    # rm -f "$LATEST_BACKUP"
    # log_message "${YELLOW}[INFO]${NC} Backup original supprime"
else
    log_message "${RED}[ERREUR]${NC} Echec du chiffrement"
    exit 1
fi

log_message "${GREEN}[DONE]${NC} Chiffrement termine!"
log_message "=============================================="

echo ""
echo -e "${GREEN}Chiffrement termine avec succes!${NC}"
echo -e "Fichier chiffre: ${LATEST_BACKUP}.gpg"
echo ""
echo -e "${YELLOW}Pour dechiffrer:${NC}"
echo "gpg -d ${LATEST_BACKUP}.gpg > backup_decrypted.tar.gz"
echo "Passphrase: BackupGPG2026!"
