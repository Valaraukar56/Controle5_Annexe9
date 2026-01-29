#!/bin/bash
#===============================================================================
# Script de sauvegarde du systeme d'authentification
# Controle 5 - Annexe 9
# Sauvegarde : Base de donnees + Fichiers PHP depuis le serveur
#===============================================================================

# Configuration
SERVER_IP="192.168.56.111"
SERVER_USER="osboxes"
SERVER_PASS="osboxes.org"
BACKUP_DIR="/home/osboxes/backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="auth_backup_${DATE}"
LOG_FILE="/home/osboxes/backups/backup.log"

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Fonction de logging
log_message() {
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Verification du repertoire de backup
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
    log_message "${GREEN}[INFO]${NC} Repertoire de backup cree: $BACKUP_DIR"
fi

log_message "${YELLOW}[START]${NC} Demarrage de la sauvegarde..."

# Creer le repertoire temporaire pour cette sauvegarde
TEMP_DIR="${BACKUP_DIR}/${BACKUP_NAME}"
mkdir -p "$TEMP_DIR"

#===============================================================================
# 1. Sauvegarde de la base de donnees MySQL
#===============================================================================
log_message "${YELLOW}[DB]${NC} Sauvegarde de la base de donnees auth_db..."

sshpass -p "$SERVER_PASS" ssh -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_IP} \
    "echo '$SERVER_PASS' | sudo -S mysqldump -u root auth_db" > "${TEMP_DIR}/auth_db.sql" 2>/dev/null

if [ $? -eq 0 ] && [ -s "${TEMP_DIR}/auth_db.sql" ]; then
    log_message "${GREEN}[OK]${NC} Base de donnees sauvegardee: auth_db.sql"
else
    log_message "${RED}[ERREUR]${NC} Echec de la sauvegarde de la base de donnees"
fi

#===============================================================================
# 2. Sauvegarde des fichiers PHP
#===============================================================================
log_message "${YELLOW}[FILES]${NC} Sauvegarde des fichiers auth_system..."

sshpass -p "$SERVER_PASS" scp -o StrictHostKeyChecking=no -r \
    ${SERVER_USER}@${SERVER_IP}:/var/www/html/auth_system "${TEMP_DIR}/" 2>/dev/null

if [ $? -eq 0 ]; then
    log_message "${GREEN}[OK]${NC} Fichiers PHP sauvegardes"
else
    log_message "${RED}[ERREUR]${NC} Echec de la sauvegarde des fichiers"
fi

#===============================================================================
# 3. Sauvegarde de la configuration Fail2ban
#===============================================================================
log_message "${YELLOW}[FAIL2BAN]${NC} Sauvegarde de la configuration Fail2ban..."

mkdir -p "${TEMP_DIR}/fail2ban"

sshpass -p "$SERVER_PASS" ssh -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_IP} \
    "echo '$SERVER_PASS' | sudo -S cat /etc/fail2ban/jail.local" > "${TEMP_DIR}/fail2ban/jail.local" 2>/dev/null

sshpass -p "$SERVER_PASS" ssh -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_IP} \
    "echo '$SERVER_PASS' | sudo -S cat /etc/fail2ban/filter.d/auth-login.conf" > "${TEMP_DIR}/fail2ban/auth-login.conf" 2>/dev/null

sshpass -p "$SERVER_PASS" ssh -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_IP} \
    "echo '$SERVER_PASS' | sudo -S cat /etc/fail2ban/filter.d/auth-scan.conf" > "${TEMP_DIR}/fail2ban/auth-scan.conf" 2>/dev/null

log_message "${GREEN}[OK]${NC} Configuration Fail2ban sauvegardee"

#===============================================================================
# 4. Sauvegarde de la configuration Apache
#===============================================================================
log_message "${YELLOW}[APACHE]${NC} Sauvegarde de la configuration Apache..."

mkdir -p "${TEMP_DIR}/apache"

sshpass -p "$SERVER_PASS" ssh -o StrictHostKeyChecking=no ${SERVER_USER}@${SERVER_IP} \
    "echo '$SERVER_PASS' | sudo -S cat /etc/apache2/sites-available/auth_system.conf" > "${TEMP_DIR}/apache/auth_system.conf" 2>/dev/null

log_message "${GREEN}[OK]${NC} Configuration Apache sauvegardee"

#===============================================================================
# 5. Creation de l'archive compressee
#===============================================================================
log_message "${YELLOW}[ARCHIVE]${NC} Creation de l'archive compressee..."

cd "$BACKUP_DIR"
tar -czf "${BACKUP_NAME}.tar.gz" "$BACKUP_NAME"

if [ $? -eq 0 ]; then
    log_message "${GREEN}[OK]${NC} Archive creee: ${BACKUP_NAME}.tar.gz"
    # Supprimer le repertoire temporaire
    rm -rf "$TEMP_DIR"
else
    log_message "${RED}[ERREUR]${NC} Echec de la creation de l'archive"
fi

#===============================================================================
# 6. Nettoyage des anciennes sauvegardes (garder les 7 dernieres)
#===============================================================================
log_message "${YELLOW}[CLEANUP]${NC} Nettoyage des anciennes sauvegardes..."

cd "$BACKUP_DIR"
ls -t auth_backup_*.tar.gz 2>/dev/null | tail -n +8 | xargs -r rm -f

log_message "${GREEN}[OK]${NC} Nettoyage termine"

#===============================================================================
# Resume
#===============================================================================
BACKUP_SIZE=$(du -h "${BACKUP_DIR}/${BACKUP_NAME}.tar.gz" 2>/dev/null | cut -f1)
log_message "${GREEN}[DONE]${NC} Sauvegarde terminee!"
log_message "${GREEN}[INFO]${NC} Fichier: ${BACKUP_NAME}.tar.gz (${BACKUP_SIZE})"
log_message "=============================================="

echo ""
echo -e "${GREEN}Sauvegarde terminee avec succes!${NC}"
echo -e "Fichier: ${BACKUP_DIR}/${BACKUP_NAME}.tar.gz"
