#!/usr/bin/env bash

# =========================
# CONFIG
# =========================
ICON_DIR="$HOME/.config/hypr/icons"
STEP="5%"

# =========================
# DEP CHECK
# =========================
command -v brightnessctl >/dev/null 2>&1 || exit 1
command -v notify-send >/dev/null 2>&1 || exit 1
command -v awk >/dev/null 2>&1 || exit 1

# =========================
# HELPERS
# =========================
get_brightness() {
  brightnessctl -m | awk -F',' '{print $4}' | tr -d '%'
}

get_icon() {
  local b
  b=$(get_brightness)

  if [ "$b" -le 20 ]; then
    echo "$ICON_DIR/brightness.png"
  elif [ "$b" -le 50 ]; then
    echo "$ICON_DIR/brightness.png"
  else
    echo "$ICON_DIR/brightness.png"
  fi
}

notify_brightness() {
  notify-send \
    -h string:x-canonical-private-synchronous:brightness \
    -u low \
    -i "$(get_icon)" \
    "Brightness: $(get_brightness)%"
}

# =========================
# ACTIONS
# =========================
inc() {
  brightnessctl set "$STEP"+ && notify_brightness
}

dec() {
  brightnessctl set "$STEP"- && notify_brightness
}

# =========================
# DISPATCH
# =========================
case "$1" in
--get) get_brightness ;;
--inc) inc ;;
--dec) dec ;;
*) get_brightness ;;
esac
