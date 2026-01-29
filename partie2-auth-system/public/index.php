<?php
require_once 'init.php';

if (!Auth::check()) {
    header('Location: login.php');
    exit;
}

header('Location: home.php');
exit;
