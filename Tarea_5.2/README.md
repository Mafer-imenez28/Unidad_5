# Tarea 5.2: Despliegue de Entorno Virtualizado y Gestión de Redes Virtuales

**Materia:** Administración de Servidores  
**Alumna:** María Fernanda Jiménez Zamora  
**Hipervisor:** Oracle VirtualBox sobre Windows 11  
**Sistema Operativo Huésped:** Ubuntu Server 26.04.1 LTS (64-bit)  

---

## Descripción de la Arquitectura

Este directorio contiene la infraestructura como código (`Vagrantfile`), el script de aprovisionamiento (`provision_redes.sh`) y la documentación técnica correspondiente al despliegue de dos servidores virtualizados con segmentación de red y compartición controlada de recursos físicos.

```text
                       [ INTERNET / RED EXTERNA ]
                                   ▲
                                   │ (Salida vía NAT: 10.0.2.15)
                                   │
+----------------------------------+----------------------------------+
|  EQUIPO ANFITRIÓN (Windows 11 - Host)                               |
|  - Red Física LAN (Wi-Fi/Ethernet): 192.168.1.x/24                  |
|  - Adaptador Virtual Host-Only:     192.168.56.1/24 (DHCP Activo)   |
+-----------------+---------------------------------+-----------------+
                  │                                 │
   [ Red Física / Modo Puente ]      [ Red Privada / Modo Host-Only ]
        (192.168.1.0/24)                     (192.168.56.0/24)
                  │                                 │
                  ▼                                 ▼
+---------------------------------+ +---------------------------------+
| VM 1: Servidor_1_Redes          | | VM 2: Servidor_2_Backendddd     |
| - enp0s3 (NAT): 10.0.2.15/24    | | - enp0s3 (Host-Only):           |
| - enp0s8 (Bridged):             | |   IP: 192.168.56.103/24         |
|   IP: 192.168.1.75/24           | | - Aislamiento: Sin salida a     |
| - vCPU: 1 | RAM: 1024 MB        | |   Internet (Network unreachable)|
+---------------------------------+ +---------------------------------+