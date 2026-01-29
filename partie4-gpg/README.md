# Partie 4 : Chiffrement GPG

## Generation de la cle GPG

```bash
gpg --batch --generate-key << EOF
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: Backup Auth System
Name-Email: backup@local.test
Expire-Date: 0
Passphrase: BackupGPG2026!
%commit
EOF
```

## Verification de la cle

```bash
gpg --list-keys backup@local.test
```

## Scripts

### encrypt_backup.sh
Chiffre automatiquement le dernier backup avec AES-256.

```bash
/home/osboxes/scripts/encrypt_backup.sh
```

### decrypt_backup.sh
Dechiffre un backup chiffre.

```bash
/home/osboxes/scripts/decrypt_backup.sh /path/to/backup.tar.gz.gpg
```

## Informations de dechiffrement

| Parametre | Valeur |
|-----------|--------|
| Algorithme | AES-256 |
| Passphrase | BackupGPG2026! |
| Email cle | backup@local.test |

## Commande manuelle

```bash
# Chiffrer
gpg -c --cipher-algo AES256 fichier.tar.gz

# Dechiffrer
gpg -d fichier.tar.gz.gpg > fichier.tar.gz
```
