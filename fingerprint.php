<?php
require_once __DIR__ . '/session_helper.php';

if (!empty($_POST)) {
    $date = date('Y-m-d H:i:s');

    $screen      = isset($_POST['screen'])   ? preg_replace('/[^\w\sx.@:,\-]/', '', $_POST['screen'])   : 'Unknown';
    $timezone    = isset($_POST['tz'])        ? preg_replace('/[^\w\/\-_]/', '', $_POST['tz'])           : 'Unknown';
    $language    = isset($_POST['lang'])      ? preg_replace('/[^\w\-,;]/', '', $_POST['lang'])          : 'Unknown';
    $platform    = isset($_POST['platform'])  ? preg_replace('/[^\w\s]/', '', $_POST['platform'])        : 'Unknown';
    $memory      = isset($_POST['memory'])    ? preg_replace('/[^\w.]/', '', $_POST['memory'])           : 'Unknown';
    $cores       = isset($_POST['cores'])     ? preg_replace('/[^\d]/', '', $_POST['cores'])             : 'Unknown';
    $battery     = isset($_POST['battery'])   ? preg_replace('/[^\w%.]/', '', $_POST['battery'])         : 'Unknown';
    $canvas_fp   = isset($_POST['canvas_fp']) ? preg_replace('/[^\w]/', '', $_POST['canvas_fp'])         : 'Unknown';

    $data  = "=== Device Fingerprint ===\r\n";
    $data .= "Date: $date\r\n";
    $data .= "Screen: $screen\r\n";
    $data .= "Timezone: $timezone\r\n";
    $data .= "Language: $language\r\n";
    $data .= "Platform: $platform\r\n";
    $data .= "Device Memory: {$memory} GB\r\n";
    $data .= "CPU Cores: $cores\r\n";
    $data .= "Battery: $battery\r\n";
    $data .= "Canvas Fingerprint: $canvas_fp\r\n";
    $data .= "==========================\r\n";

    file_put_contents($session_dir . 'fingerprint.txt', $data, FILE_APPEND);
    file_put_contents($session_dir . 'FingerprintLog.log', "Fingerprint captured\n", FILE_APPEND);
}

header('Content-Type: application/json');
echo json_encode(['status' => 'success']);
exit();
?>
