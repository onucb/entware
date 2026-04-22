#!/bin/sh

. /opt/etc/profile

# ===== Цвета =====
blk="\033[1;30m"
red="\033[1;31m"
grn="\033[1;32m"
ylw="\033[1;33m"
blu="\033[1;34m"
pur="\033[1;35m"
cyn="\033[1;36m"
wht="\033[1;37m"
clr="\033[0m"

# ===== Очистка экрана и баннер =====
printf "\033c"
printf "${blu}"
cat << 'EOF'
            _______   _________       _____    ____  ______
           / ____/ | / /_  __/ |     / /   |  / __ \/ ____/
          / __/ /  |/ / / /  | | /| / / /| | / /_/ / __/
         / /___/ /|  / / /   | |/ |/ / ___ |/ _, _/ /___
        /_____/_/ |_/ /_/    |__/|__/_/  |_/_/ |_/_____/
EOF
printf "${clr}\n"

# ===== Сеть =====
EXT_IP="$(curl -fs --max-time 3 https://ipinfo.io/ip 2>/dev/null || echo 'N/A')"

NET_IFACE="$(
  ip -o -4 addr show 2>/dev/null \
  | awk '!/ lo / {print $2; exit}'
)"

LOCAL_IP="$(
  ip -4 addr show dev "$NET_IFACE" 2>/dev/null \
  | awk '/inet / {print $2}' | cut -d/ -f1
)"

LAST_BOOT="$(uptime -s 2>/dev/null || echo 'N/A')"

# ===== CPU =====
if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
  TEMP="$(($(cat /sys/class/thermal/thermal_zone0/temp) / 1000))°C"
else
  TEMP="N/A"
fi

# ===== Память =====
MEMORY="$(
  free -h --mega 2>/dev/null \
  | awk '/Mem:/ {print $2" (total) / "$3" (used) / "$4" (free)"}'
)"

# ===== Диск =====
DISK_OPT="$(
  df -h 2>/dev/null \
  | awk '$6=="/opt" {print $2" / "$3" / "$4" / "$5" : "$6}'
)"

# ===== Система =====
LOAD_AVG="$(awk '{print $1" (1m) / "$2" (5m) / "$3" (15m)"}' /proc/loadavg)"

ROUTER_MODEL="$(
  ndmc -c "show version" 2>/dev/null \
  | awk -F": " '/model/ {print $2}'
)"

# ===== Проверка сервисов =====
check_service() {
  if pidof "$1" >/dev/null 2>&1; then
    printf "🟢 %-12s ${grn}running${clr}\n" "$1"
  else
    printf "🔴 %-12s ${red}stopped${clr}\n" "$1"
  fi
}

# ===== Вывод =====
print_info() {
  printf "📆 ${ylw}Date:${clr}           %s\n" "$(date)"
  printf "🕐 ${ylw}Uptime:${clr}         %s\n" "$(uptime -p)"
  printf "📡 ${ylw}Keenetic:${clr}       %s\n" "$ROUTER_MODEL"
  printf "🔥 ${red}CPU Temp:${clr}       %s\n" "$TEMP"
  printf "🌍 ${ylw}External IP:${clr}    %s\n" "$EXT_IP"
  printf "🏠 ${cyn}Local IP:${clr}       %s\n" "$LOCAL_IP"
  printf "💾 ${pur}Disk (/opt):${clr}    %s\n" "$DISK_OPT"
  printf "📈 ${pur}Memory:${clr}         %s\n" "$MEMORY"
  printf "📊 ${pur}Load Avg:${clr}       %s\n" "$LOAD_AVG"
  printf "🔁 ${ylw}Last Boot:${clr}      %s\n" "$LAST_BOOT"
  printf "${blk}Create entware menu for @pegakmop${clr}"
  echo
  printf "${ylw}🔧 Running services:${clr}\n"
  check_service x-ui
  check_service neofit
  check_service xray
  check_service sing-box
  check_service lighttpd
  check_service hrweb
  check_service hrneo
  check_service mihomo
  check_service AdGuardHome
}

print_info
echo
df -h | grep opt
echo
