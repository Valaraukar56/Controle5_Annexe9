<?php
require_once 'init.php';

Auth::logout();

header('Location: login.php?logout=1');
exit;
