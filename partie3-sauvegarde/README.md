# Partie 3 : Sauvegarde et Planification

## Script de sauvegarde

Le script `backup_auth_system.sh` effectue les operations suivantes :

1. Sauvegarde de la base de donnees MySQL (mysqldump)
2. Sauvegarde des fichiers PHP du projet
3. Sauvegarde de la configuration Fail2ban
4. Sauvegarde de la configuration Apache
5. Compression en archive tar.gz
6. Rotation automatique (conservation des 7 dernieres sauvegardes)

## Installation

```bash
# Copier le script
cp backup_auth_system.sh /home/osboxes/scripts/
chmod +x /home/osboxes/scripts/backup_auth_system.sh

# Creer le repertoire de backup
mkdir -p /home/osboxes/backups
```

## Execution manuelle

```bash
/home/osboxes/scripts/backup_auth_system.sh
```

## Planification avec Cron

Ajouter au crontab pour une execution quotidienne a 2h du matin :

```bash
crontab -e
```

Ajouter la ligne :
```
0 2 * * * /home/osboxes/scripts/backup_auth_system.sh >> /home/osboxes/backups/cron.log 2>&1
```

## Emplacement des sauvegardes

```
/home/osboxes/backups/
├── auth_backup_YYYYMMDD_HHMMSS.tar.gz
├── backup.log
└── cron.log
```
