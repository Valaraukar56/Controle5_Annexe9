<?php
class Auth {
    public static function startSession() {
        if (session_status() == PHP_SESSION_NONE) {
            session_start();
        }
    }

    public static function check() {
        self::startSession();
        if (isset($_SESSION['user_id'])) {
            return true;
        } else {
            return false;
        }
    }

    public static function user() {
        self::startSession();
        if (isset($_SESSION['user_id'])) {
            $user = new User();
            return $user->getUserById($_SESSION['user_id']);
        }
        return null;
    }

    public static function attempt($username, $password) {
        $user = new User();
        $loggedInUser = $user->login($username, $password);

        if ($loggedInUser) {
            self::startSession();
            $_SESSION['user_id'] = $loggedInUser->id;
            $_SESSION['username'] = $loggedInUser->username;
            $_SESSION['role'] = $loggedInUser->role;
            $_SESSION['last_activity'] = time();

            $db = new Database();
            $db->logAction($loggedInUser->id, 'login', $_SERVER['REMOTE_ADDR']);

            return true;
        }
        return false;
    }

    public static function logout() {
        self::startSession();
        
        if (isset($_SESSION['user_id'])) {
            $db = new Database();
            $db->logAction($_SESSION['user_id'], 'logout', $_SERVER['REMOTE_ADDR']);
        }

        $_SESSION = array();
        session_destroy();
    }

    public static function checkSessionTimeout() {
        self::startSession();
        if (isset($_SESSION['last_activity'])) {
            $inactive = time() - $_SESSION['last_activity'];
            if ($inactive > SESSION_TIMEOUT) {
                self::logout();
                return true;
            }
        }
        $_SESSION['last_activity'] = time();
        return false;
    }

    public static function isAdmin() {
        self::startSession();
        return isset($_SESSION['role']) && $_SESSION['role'] === 'admin';
    }
}
