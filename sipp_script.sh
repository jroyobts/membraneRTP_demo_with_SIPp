#!/bin/bash

# Iniciar SIPp como UAS con eco RTP en 127.0.0.1:5070
echo "Iniciando SIPp como UAS..."
sudo sipp -sf uas_mod.xml -p 5070 -i 127.0.0.1 -mp 6003 &

# Esperar unos segundos para asegurar que el UAS está listo
sleep 2

# Iniciar SIPp como UAC (modo pcap) hacia el UAS
echo "Iniciando SIPp como UAC hacia 127.0.0.1:5070..."
sudo sipp -sn uac_pcap 127.0.0.1:5070
