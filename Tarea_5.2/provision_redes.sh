#!/usr/bin/env bash
# Script de aprovisionamiento y auditoría de interfaces de red
# Tarea 5.2 - Administración de Servidores

ROL=$1

echo "===================================================="
echo " Iniciando aprovisionamiento para nodo: $ROL"
echo "===================================================="

if [ "$ROL" == "frontera" ]; then
    echo "[INFO] Verificando conectividad externa (NAT/Puente)..."
    if ping -c 2 8.8.8.8 &> /dev/null; then
        echo "[OK] Salida a Internet verificada."
        sudo apt-get update -y && sudo apt-get install -y net-tools iputils-ping
    else
        echo "[WARN] Sin acceso externo detectado."
    fi
elif [ "$ROL" == "backend" ]; then
    echo "[INFO] Validando aislamiento de red en modo Host-Only..."
    if ping -c 2 8.8.8.8 &> /dev/null; then
        echo "[ALERTA] El servidor backend tiene salida a Internet. Revisar aislamiento."
    else
        echo "[OK] Aislamiento verificado: Network is unreachable hacia Internet."
    fi
fi

echo "--- Resumen de Interfaces Asignadas ---"
ip -brief addr show
echo "===================================================="
