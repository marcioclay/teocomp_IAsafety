#!/bin/bash

# Interrompe o script se houver algum erro
set -e

echo "=================================================="
echo "1. CONFIGURANDO O GATEWAY (Broker MQTT Mosquitto & iptables)"
echo "=================================================="
docker exec clab-lab-ebpf-gateway apt-get update
# Instala o mosquitto e o iptables em simultâneo
docker exec clab-lab-ebpf-gateway apt-get install -y mosquitto iptables
# Inicia o broker em segundo plano apontando para o ficheiro de configuração partilhado
docker exec clab-lab-ebpf-gateway mosquitto -d -c /lab/mosquitto.conf

echo "=================================================="
echo "2. CONFIGURANDO O ATACANTE (Python & Paho-MQTT)"
echo "=================================================="
docker exec clab-lab-ebpf-atacante apt-get update
# Garante a instalação do iproute2 para o comando tc
docker exec clab-lab-ebpf-atacante apt-get install -y python3 python3-pip iproute2
docker exec clab-lab-ebpf-atacante pip3 install paho-mqtt

echo "=================================================="
echo "3. CONFIGURANDO O SENSOR LEGÍTIMO (Python & Paho-MQTT)"
echo "=================================================="
docker exec clab-lab-ebpf-sensor apt-get update
# Garante a instalação do iproute2 para o comando tc
docker exec clab-lab-ebpf-sensor apt-get install -y python3 python3-pip iproute2
docker exec clab-lab-ebpf-sensor pip3 install paho-mqtt

echo "=================================================="
echo "4. EMULANDO CONEXÃO WI-FI REAL (Latência e Perda)"
echo "=================================================="
# Limpa regras antigas caso o script seja rodado mais de uma vez (evita erro de arquivo duplicado)
docker exec clab-lab-ebpf-sensor tc qdisc del dev eth1 root 2>/dev/null || true
docker exec clab-lab-ebpf-atacante tc qdisc del dev eth1 root 2>/dev/null || true

# Sensor: Simula uma rede Wi-Fi estável (Latência 30ms, Jitter 5ms, Perda 1%)
echo "Aplicando perfil Wi-Fi ao Sensor..."
docker exec clab-lab-ebpf-sensor tc qdisc add dev eth1 root netem delay 30ms 5ms loss 1%

# Atacante: Simula uma rede Wi-Fi mais distante/instável (Latência 50ms, Jitter 15ms, Perda 5%)
#echo "Aplicando perfil Wi-Fi ao Atacante..."
#docker exec clab-lab-ebpf-atacante tc qdisc add dev eth1 root netem delay 50ms 15ms loss 5%

echo "=================================================="
echo "🎉 INFRAESTRUTURA COMPLETA E PRONTA PARA USO!"
echo "=================================================="
