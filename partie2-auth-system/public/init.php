<?php
// Load config
require_once '../config/config.php';

// Autoload classes
spl_autoload_register(function ($className) {
    require_once '../app/' . $className . '.php';
});

// Start session
Auth::startSession();

// Check session timeout
if (Auth::check()) {
    Auth::checkSessionTimeout();
}
