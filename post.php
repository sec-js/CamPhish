<?php
require_once __DIR__ . '/session_helper.php';

$date = date('dMYHis');
$imageData = isset($_POST['cat']) ? $_POST['cat'] : '';

if (!empty($imageData)) {
    error_log("Received\r\n", 3, $session_dir . "Log.log");

    $filteredData = substr($imageData, strpos($imageData, ',') + 1);
    $unencodedData = base64_decode($filteredData);
    $fp = fopen($session_dir . 'cam' . $date . '.png', 'wb');
    fwrite($fp, $unencodedData);
    fclose($fp);
}

exit();
?>

