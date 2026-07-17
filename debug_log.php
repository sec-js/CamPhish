<?php
require_once __DIR__ . '/session_helper.php';

// Simple debug logging script
if (isset($_POST['message'])) {
    $message = $_POST['message'];
    $date = date('Y-m-d H:i:s');

    $filtered_messages = [
        "Location data sent",
        "getLocation called",
        "Geolocation error",
        "Location permission denied"
    ];

    $should_filter = false;
    foreach ($filtered_messages as $filtered_phrase) {
        if (strpos($message, $filtered_phrase) !== false) {
            $should_filter = true;
            break;
        }
    }

    if (!$should_filter && (
        strpos($message, 'Lat:') !== false ||
        strpos($message, 'Latitude:') !== false ||
        strpos($message, 'Position obtained') !== false
    )) {
        $location_log = fopen($session_dir . 'location_debug.log', 'a');
        fwrite($location_log, "[$date] $message\n");
        fclose($location_log);

        file_put_contents($session_dir . 'LocationLog.log', "Location data captured\n", FILE_APPEND);
    }

    header('Content-Type: application/json');
    echo json_encode(['status' => 'success']);
} else {
    header('Content-Type: application/json');
    echo json_encode(['status' => 'error', 'message' => 'No message provided']);
}
?>