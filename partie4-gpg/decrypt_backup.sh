#!/bin/bash
#===============================================================================
# Script de dechiffrement GPG des sauvegardes
# Controle 5 - Annexe 9
#===============================================================================

# Configuration
BACKUP_DIR="/home/osboxes/backups"
GPG_PASSPHRASE="BackupGPG2026!"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Verification des arguments
if [ -z "$1" ]; then
    echo -e "${YELLOW}Usage:${NC} $0 <fichier.tar.gz.gpg>"
    echo ""
    echo "Fichiers chiffres disponibles:"
    ls -la ${BACKUP_DIR}/*.gpg 2>/dev/null || echo "Aucun fichier chiffre trouve"
    exit 1
fi

INPUT_FILE="$1"
OUTPUT_FILE="${INPUT_FILE%.gpg}"

if [ ! -f "$INPUT_FILE" ]; then
    echo -e "${RED}[ERREUR]${NC} Fichier non trouve: $INPUT_FILE"
    exit 1
fi

echo -e "${YELLOW}[INFO]${NC} Dechiffrement de: $(basename $INPUT_FILE)"

# Dechiffrement
echo "$GPG_PASSPHRASE" | gpg --batch --yes --passphrase-fd 0 \
    --pinentry-mode loopback \
    -d -o "$OUTPUT_FILE" \
    "$INPUT_FILE" 2>/dev/null

if [ $? -eq 0 ]; then
    echo -e "${GREEN}[OK]${NC} Fichier dechiffre: $(basename $OUTPUT_FILE)"
    echo ""
    echo -e "${YELLOW}Pour extraire:${NC}"
    echo "tar -xzf $OUTPUT_FILE -C /destination/"
else
    echo -e "${RED}[ERREUR]${NC} Echec du dechiffrement"
    exit 1
fi
