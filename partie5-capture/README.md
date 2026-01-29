# Partie 5 : Analyse Reseau avec Wireshark/tcpdump

## Script de capture

Le script `capture_auth_traffic.sh` capture le trafic HTTP vers le systeme d'authentification.

### Usage

```bash
# Capture de 30 secondes (defaut)
./capture_auth_traffic.sh

# Capture de 60 secondes
./capture_auth_traffic.sh 60
```

## Commandes tcpdump manuelles

### Capture basique
```bash
sudo tcpdump -i enp0s8 -w capture.pcap "host 192.168.56.111 and port 80"
```

### Capture avec affichage
```bash
sudo tcpdump -i enp0s8 -A "host 192.168.56.111 and port 80"
```

### Analyse d'une capture
```bash
sudo tcpdump -r capture.pcap -A | grep -E "(POST|username|password)"
```

## Filtres Wireshark recommandes

| Filtre | Description |
|--------|-------------|
| `http.request.method == POST` | Requetes POST (connexions) |
| `http.request.uri contains "login"` | Pages de login |
| `http.request.uri contains "auth_system"` | Trafic auth_system |
| `ip.addr == 192.168.56.111` | Trafic vers/depuis serveur |

## Observations de securite

L'analyse revele que les credentials sont transmis en clair sur HTTP.

**Recommandations :**
1. Activer HTTPS avec certificat SSL/TLS
2. Utiliser HSTS pour forcer HTTPS
3. Implementer des tokens CSRF
4. Ajouter un rate-limiting cote serveur

## Emplacement des captures

```
/home/osboxes/captures/
├── auth_capture_*.pcap
└── auth_traffic.pcap
```
