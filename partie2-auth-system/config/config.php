<?php
// Configuration de la base de données
define('DB_HOST', 'localhost');
define('DB_USER', 'auth-user');
define('DB_PASS', 'AuthP@ss2026!');
define('DB_NAME', 'auth_db');

// Chemins
define('APP_ROOT', dirname(__DIR__));
define('URL_ROOT', 'http://192.168.56.111/auth_system/public');

// Clé de chiffrement (pour les tokens)
define('APP_KEY', 'a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6');

// Paramètres de sécurité
define('SESSION_TIMEOUT', 1800); // 30 minutes
