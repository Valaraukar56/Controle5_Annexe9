# Partie 6 : Fail2ban avec 3 Jails

## Installation des fichiers

```bash
# Copier la configuration principale
sudo cp jail.local /etc/fail2ban/jail.local

# Copier les filtres personnalises
sudo cp auth-login.conf /etc/fail2ban/filter.d/
sudo cp auth-scan.conf /etc/fail2ban/filter.d/

# Redemarrer Fail2ban
sudo systemctl restart fail2ban
```

## Les 3 Jails

### Jail 1 : Protection SSH (sshd)
- **Port :** SSH (22)
- **maxretry :** 3
- **bantime :** 30 minutes
- **Log :** /var/log/auth.log

### Jail 2 : Protection tentatives de connexion (auth-login)
- **Port :** HTTP/HTTPS
- **maxretry :** 3
- **findtime :** 1 minute
- **bantime :** 1 minute
- **Log :** /var/log/apache2/auth_access.log

### Jail 3 : Protection scans vulnerabilites (auth-scan)
- **Port :** HTTP/HTTPS
- **maxretry :** 5
- **bantime :** 1 heure
- **Log :** /var/log/apache2/auth_access.log

## Commandes utiles

```bash
# Verifier le statut
sudo fail2ban-client status
sudo fail2ban-client status sshd
sudo fail2ban-client status auth-login
sudo fail2ban-client status auth-scan

# Debannir une IP
sudo fail2ban-client set <jail> unbanip <IP>

# Voir les IPs bannies
sudo fail2ban-client status auth-login
```

## Test de bannissement

```bash
# Simuler une attaque brute-force
for i in {1..5}; do
    curl -X POST -d "username=hacker&password=wrong$i" \
        http://192.168.56.111/auth_system/public/login.php
done

# Verifier le bannissement
sudo fail2ban-client status auth-login
```
