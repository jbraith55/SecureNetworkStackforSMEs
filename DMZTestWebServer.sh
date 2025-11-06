#!/bin/bash
sudo apt install -y apache2
sudo systemctl enable apache2
sudo systemctl start apache2

echo "<!DOCTYPE html>
<html>
<head>
    <title>DMZ-hosted website</title>
</head>
<body>
    <h1>Welcome to the DMZ Server</h1>
    <p>Accessible from other machines within the LAN</p>
</body>
</html>" | sudo tee /var/www/html/index.html
echo "For access curl the DMZ IP"

