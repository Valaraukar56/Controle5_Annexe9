#!/bin/bash
#===============================================================================
# Script de capture du trafic reseau vers le systeme d'authentification
# Controle 5 - Annexe 9
#===============================================================================

# Configuration
SERVER_IP="192.168.56.111"
CAPTURE_DIR="/home/osboxes/captures"
DATE=$(date +%Y%m%d_%H%M%S)
CAPTURE_FILE="${CAPTURE_DIR}/auth_capture_${DATE}.pcap"
DURATION=${1:-30}  # Duree par defaut: 30 secondes

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Creation du repertoire
mkdir -p "$CAPTURE_DIR"

echo -e "${YELLOW}============================================${NC}"
echo -e "${YELLOW}  Capture du trafic vers auth_system${NC}"
echo -e "${YELLOW}============================================${NC}"
echo ""
echo -e "Serveur cible: ${GREEN}$SERVER_IP${NC}"
echo -e "Duree: ${GREEN}${DURATION} secondes${NC}"
echo -e "Fichier: ${GREEN}$CAPTURE_FILE${NC}"
echo ""

# Trouver l'interface reseau
INTERFACE=$(ip route get $SERVER_IP 2>/dev/null | grep -oP 'dev \K\S+' | head -1)

if [ -z "$INTERFACE" ]; then
    echo -e "${RED}[ERREUR]${NC} Impossible de determiner l'interface reseau"
    INTERFACE="enp0s8"  # Interface par defaut pour VirtualBox Host-Only
fi

echo -e "Interface: ${GREEN}$INTERFACE${NC}"
echo ""
echo -e "${YELLOW}[INFO]${NC} Demarrage de la capture..."
echo -e "${YELLOW}[INFO]${NC} Effectuez des connexions sur http://${SERVER_IP}/auth_system/public/login.php"
echo ""

# Capture avec tcpdump
# Filtre: trafic HTTP vers/depuis le serveur
sudo timeout ${DURATION}s tcpdump -i $INTERFACE -w "$CAPTURE_FILE" \
    "host $SERVER_IP and port 80" 2>/dev/null &

TCPDUMP_PID=$!

# Barre de progression
for ((i=0; i<$DURATION; i++)); do
    printf "\r${YELLOW}[CAPTURE]${NC} Progression: [%-50s] %d/%ds" \
        "$(printf '#%.0s' $(seq 1 $((i*50/DURATION))))" $i $DURATION
    sleep 1
done
printf "\r${GREEN}[CAPTURE]${NC} Progression: [%-50s] %d/%ds\n" \
    "$(printf '#%.0s' $(seq 1 50))" $DURATION $DURATION

wait $TCPDUMP_PID 2>/dev/null

echo ""
echo -e "${GREEN}[DONE]${NC} Capture terminee!"

# Statistiques
if [ -f "$CAPTURE_FILE" ]; then
    PACKETS=$(sudo tcpdump -r "$CAPTURE_FILE" 2>/dev/null | wc -l)
    SIZE=$(du -h "$CAPTURE_FILE" | cut -f1)

    echo ""
    echo -e "${GREEN}Statistiques:${NC}"
    echo -e "  Paquets captures: $PACKETS"
    echo -e "  Taille du fichier: $SIZE"
    echo ""
    echo -e "${YELLOW}Pour analyser avec Wireshark:${NC}"
    echo "  wireshark $CAPTURE_FILE"
    echo ""
    echo -e "${YELLOW}Pour filtrer les POST (connexions):${NC}"
    echo "  Dans Wireshark: http.request.method == POST"
    echo ""
    echo -e "${YELLOW}Analyse rapide avec tcpdump:${NC}"
    echo "  sudo tcpdump -r $CAPTURE_FILE -A | grep -i 'username\|password'"
else
    echo -e "${RED}[ERREUR]${NC} Fichier de capture non cree"
fi
