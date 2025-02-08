#!/bin/bash
sudo yum update -y
sudo yum install -y httpd.x86_64
sudo systemctl enable httpd --now

cat << 'EOF2' > /var/www/html/index.html
<html>
  <head>
    <meta charset="UTF-8">
    <title>Laboratorio de Terraform</title>
    <style>
      body {
        background-color: #f4f4f4;
        font-family: Arial, sans-serif;
        text-align: center;
        padding: 50px;
      }
      h1 {
        color: #333;
      }
      p {
        font-size: 20px;
        color: #666;
      }
    </style>
  </head>
  <body>
    <h1>Bienvenidos al Laboratorio de Terraform</h1>
    <p>Esta es una página web desplegada automáticamente.</p>
  </body>
</html>
EOF2
