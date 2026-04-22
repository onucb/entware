#!/bin/sh

BASE_URL="https://raw.githubusercontent.com/onucb/entware/refs/heads/main"
SELF_URL="${BASE_URL}/install-pegakmop-banner.sh"
SELF="/opt/tmp/install-pegakmop-banner.sh"
BANNER_DEST="/opt/etc/pegakmop-banner.sh"
PROFILE="$HOME/.profile"

# ===== Цвета =====
red="\033[1;31m"
grn="\033[1;32m"
ylw="\033[1;33m"
blu="\033[1;34m"
cyn="\033[1;36m"
clr="\033[0m"

# ===== Самообновление =====
SELF_TMP="/opt/tmp/install-banner-new.sh"
wget -q -O "$SELF_TMP" "$SELF_URL" 2>/dev/null
if [ -f "$SELF_TMP" ]; then
  OLD_MD5="$(md5sum "$SELF" 2>/dev/null | awk '{print $1}')"
  NEW_MD5="$(md5sum "$SELF_TMP" 2>/dev/null | awk '{print $1}')"
  if [ -n "$NEW_MD5" ] && [ "$OLD_MD5" != "$NEW_MD5" ]; then
    cp "$SELF_TMP" "$SELF"
    chmod +x "$SELF"
    rm -f "$SELF_TMP"
    printf "${grn}✔ Скрипт обновлён, перезапускаю...${clr}\n"
    sleep 1
    exec sh "$SELF"
    exit 0
  fi
  rm -f "$SELF_TMP"
fi

show_menu() {
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
  printf "${ylw}=== Установщик баннера для Keenetic Entware ===${clr}\n\n"
  printf "  ${grn}1${clr}) Установить ${cyn}lite${clr}  — модель, температура, сервисы, диск\n"
  printf "  ${grn}2${clr}) Установить ${cyn}mid${clr}   — lite + сеть, память, uptime\n"
  printf "  ${grn}3${clr}) Установить ${cyn}pro${clr}   — всё + CPU, пакеты, обновления\n\n"
  printf "  ${red}00${clr}) Удалить баннер\n"
  printf "  ${red}0${clr})  Выход\n\n"
  printf "Ваш выбор: "
}

install_banner() {
  VARIANT="$1"
  URL="${BASE_URL}/${VARIANT}-banner.sh"

  printf "\n${ylw}Скачиваю ${VARIANT}-banner.sh...${clr}\n"
  if wget -q -O "$BANNER_DEST" "$URL"; then
    chmod +x "$BANNER_DEST"
    printf "${grn}✔ Баннер '${VARIANT}' установлен! Перезайди по SSH чтобы увидеть.${clr}\n"
  else
    printf "${red}✘ Ошибка загрузки. Проверь интернет или наличие файла на GitHub.${clr}\n"
    rm -f "$BANNER_DEST"
    return 1
  fi

  # Убрать старый custom-banner если есть
  if [ -f /opt/etc/custom-banner.sh ]; then
    rm -f /opt/etc/custom-banner.sh
    printf "${ylw}→ Старый custom-banner.sh удалён${clr}\n"
  fi
  if grep -q "custom-banner.sh" "$PROFILE" 2>/dev/null; then
    sed -i '/custom-banner\.sh/d' "$PROFILE"
    printf "${ylw}→ Старая запись custom-banner удалена из $PROFILE${clr}\n"
  fi

  # Добавить в .profile если ещё нет
  if ! grep -q "pegakmop-banner.sh" "$PROFILE" 2>/dev/null; then
    printf "\n. /opt/etc/profile\n/opt/etc/pegakmop-banner.sh\n" >> "$PROFILE"
    printf "${grn}✔ Добавлено в $PROFILE${clr}\n"
  fi
}

remove_banner() {
  if [ -f "$BANNER_DEST" ]; then
    rm -f "$BANNER_DEST"
    printf "${grn}✔ Файл $BANNER_DEST удалён${clr}\n"
  else
    printf "${ylw}→ Файл баннера не найден${clr}\n"
  fi

  if grep -q "pegakmop-banner.sh" "$PROFILE" 2>/dev/null; then
    sed -i '/pegakmop-banner\.sh/d' "$PROFILE"
    printf "${grn}✔ Запись удалена из $PROFILE${clr}\n"
  else
    printf "${ylw}→ В $PROFILE ничего не найдено${clr}\n"
  fi

  printf "${grn}✔ Баннер удалён.${clr}\n"
}

# ===== Главный цикл =====
while true; do
  show_menu
  read -r choice

  case "$choice" in
    1) install_banner "lite" ;;
    2) install_banner "mid" ;;
    3) install_banner "pro" ;;
    00) remove_banner ;;
    0) printf "\n${ylw}Выход.${clr}\n"; exit 0 ;;
    *) printf "\n${red}Неверный выбор, попробуй снова.${clr}\n" ;;
  esac

  printf "\nНажми Enter для продолжения..."
  read -r _
done
