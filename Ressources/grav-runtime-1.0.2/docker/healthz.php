<?php
// Minimal liveness endpoint for /healthz. Deliberately outside of Grav's own
// front controller and routing: it only proves that Nginx can reach
// PHP-FPM and that PHP-FPM can execute a script, regardless of what Grav
// site (if any) is configured. It must stay generic — no site content, no
// Grav bootstrap.

http_response_code(200);
header('Content-Type: text/plain');
echo "ok\n";
