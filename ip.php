<?php
require_once __DIR__ . '/session_helper.php';

if (!empty($_SERVER['HTTP_CLIENT_IP'])) {
    $ipaddress = $_SERVER['HTTP_CLIENT_IP'] . "\r\n";
} elseif (!empty($_SERVER['HTTP_X_FORWARDED_FOR'])) {
    $ipaddress = $_SERVER['HTTP_X_FORWARDED_FOR'] . "\r\n";
} else {
    $ipaddress = $_SERVER['REMOTE_ADDR'] . "\r\n";
}

$browser = isset($_SERVER['HTTP_USER_AGENT']) ? $_SERVER['HTTP_USER_AGENT'] : 'Unknown';

$file = $session_dir . 'ip.txt';
$fp = fopen($file, 'a');
fwrite($fp, "IP: " . $ipaddress);
fwrite($fp, "User-Agent: " . $browser . "\r\n");
fclose($fp);
