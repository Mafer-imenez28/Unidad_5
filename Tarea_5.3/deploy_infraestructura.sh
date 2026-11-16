#!/bin/bash
# ==============================================================================
# Proyecto Integrador - Tarea 5.3: Despliegue Automatizado de Infraestructura
# Sistema Operativo: Ubuntu Server 24.04 LTS
# Servicios: DNS (BIND9), DHCP (ISC-DHCP), Web HTTPS (Apache2), DB (MariaDB), Storage (Samba)
# ==============================================================================

set -e

echo "[1/7] Actualizando repositorios e instalando paquetes..."
sudo apt update && sudo apt install -y bind9 isc-dhcp-server apache2 mariadb-server samba openssl ufw

echo "[2/7] Configurando red estatica en enp0s8 (192.168.56.10/24)..."
cat << 'EOF' | sudo tee /etc/netplan/50-cloud-init.yaml
network:
  version: 2
  ethernets:
    enp0s3:
      dhcp4: true
    enp0s8:
      dhcp4: false
      addresses:
        - 192.168.56.10/24
EOF
sudo chmod 600 /etc/netplan/50-cloud-init.yaml
sudo netplan apply

echo "[3/7] Configurando Servidor DHCP..."
sudo sed -i 's/INTERFACESv4=""/INTERFACESv4="enp0s8"/' /etc/default/isc-dhcp-server
cat << 'EOF' | sudo tee -a /etc/dhcp/dhcpd.conf
subnet 192.168.56.0 netmask 255.255.255.0 {
  range 192.168.56.50 192.168.56.100;
  option domain-name-servers 192.168.56.10;
  option domain-name "proyecto.local";
  option routers 192.168.56.10;
}
EOF
sudo systemctl restart isc-dhcp-server

echo "[4/7] Configurando Servidor DNS (proyecto.local)..."
cat << 'EOF' | sudo tee -a /etc/bind/named.conf.local
zone "proyecto.local" {
    type master;
    file "/etc/bind/db.proyecto.local";
};
EOF

cat << 'EOF' | sudo tee /etc/bind/db.proyecto.local
$TTL    604800
@       IN      SOA     ns1.proyecto.local. admin.proyecto.local. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      ns1.proyecto.local.
ns1     IN      A       192.168.56.10
www     IN      A       192.168.56.10
db      IN      A       192.168.56.10
files   IN      A       192.168.56.10
EOF
sudo systemctl restart bind9

echo "[5/7] Configurando Servidor Web HTTPS (Apache + SSL Autofirmado)..."
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/apache-selfsigned.key \
  -out /etc/ssl/certs/apache-selfsigned.crt \
  -subj "/C=MX/ST=Coahuila/L=Monclova/O=TecNM/CN=www.proyecto.local"

sudo sed -i 's|/etc/ssl/certs/ssl-cert-snakeoil.pem|/etc/ssl/certs/apache-selfsigned.crt|' /etc/apache2/sites-available/default-ssl.conf
sudo sed -i 's|/etc/ssl/private/ssl-cert-snakeoil.key|/etc/ssl/private/apache-selfsigned.key|' /etc/apache2/sites-available/default-ssl.conf
sudo a2enmod ssl
sudo a2ensite default-ssl

cat << 'EOF' | sudo tee /var/www/html/index.html
<!DOCTYPE html>
<html lang="es">
<head><meta charset="UTF-8"><title>Tarea 5.3 - Infraestructura</title></head>
<body style="font-family: sans-serif; text-align: center; margin-top: 50px;">
  <h1>Proyecto Integrador - Tarea 5.3</h1>
  <p>Servidor Ubuntu Server 24.04 operando sobre <strong>HTTPS</strong></p>
  <p>Servicios activos: DNS | DHCP | HTTPS | MariaDB | Samba</p>
</body>
</html>
EOF
sudo systemctl restart apache2

echo "[6/7] Configurando Base de Datos MariaDB..."
sudo mysql -e 'CREATE DATABASE IF NOT EXISTS infraestructura_db;'
sudo mysql -e 'CREATE USER IF NOT EXISTS "admin_remoto"@"%" IDENTIFIED BY "Pass1234";'
sudo mysql -e 'GRANT ALL PRIVILEGES ON infraestructura_db.* TO "admin_remoto"@"%";'
sudo mysql -e 'FLUSH PRIVILEGES;'
sudo sed -i 's/127.0.0.1/0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf
sudo systemctl restart mariadb

echo "[7/7] Configurando Almacenamiento Samba y Firewall UFW..."
sudo mkdir -p /srv/almacenamiento
sudo chown -R fernanda:fernanda /srv/almacenamiento
echo "Almacenamiento compartido operativo - Tarea 5.3" > /srv/almacenamiento/bienvenida.txt
printf "Pass1234\nPass1234\n" | sudo smbpasswd -a -s fernanda

cat << 'EOF' | sudo tee -a /etc/samba/smb.conf
[Compartido]
   path = /srv/almacenamiento
   browseable = yes
   read only = no
   guest ok = no
   valid users = fernanda
EOF
sudo systemctl restart smbd

sudo ufw allow OpenSSH
sudo ufw allow 53
sudo ufw allow 67/udp
sudo ufw allow 'Apache Full'
sudo ufw allow 3306/tcp
sudo ufw allow Samba
sudo ufw --force enable

echo "Despliegue completado exitosamente."
