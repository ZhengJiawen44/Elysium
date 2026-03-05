#!/usr/bin/env bash

# =========================
# CONFIG
# =========================
ICON_DIR="$HOME/.config/hypr/icons"
SINK="@DEFAULT_AUDIO_SINK@"
SOURCE="@DEFAULT_AUDIO_SOURCE@"

# =========================
# HELPERS
# =========================
require() {
  command -v "$1" >/dev/null 2>&1 || {
    notify-send -u critical "Missing dependency" "$1 not found"
    exit 1
  }
}

require wpctl
require notify-send
require awk
require grep

# =========================
# VOLUME (SPEAKER)
# =========================
get_volume() {
  wpctl get-volume "$SINK" | awk '{printf "%d\n", $2 * 100}'
}

is_muted() {
  wpctl get-volume "$SINK" | grep -q MUTED
}

get_icon() {
  local vol
  vol=$(get_volume)

  if is_muted || [ "$vol" -eq 0 ]; then
    echo "$ICON_DIR/volume-mute.png"
  elif [ "$vol" -le 30 ]; then
    echo "$ICON_DIR/volume-low.png"
  elif [ "$vol" -le 60 ]; then
    echo "$ICON_DIR/volume-high.png"
  else
    echo "$ICON_DIR/volume-high.png"
  fi
}

notify_volume() {
  notify-send \
    -h string:x-canonical-private-synchronous:volume \
    -u low \
    -i "$(get_icon)" \
    "Volume: $(get_volume)%"
}

inc_volume() {
  wpctl set-volume -l 1 "$SINK" 5%+ && notify_volume
}

dec_volume() {
  wpctl set-volume "$SINK" 5%- && notify_volume
}

toggle_mute() {
  wpctl set-mute "$SINK" toggle

  if is_muted; then
    notify-send \
      -h string:x-canonical-private-synchronous:volume \
      -u low \
      -i "$ICON_DIR/volume-mute.png" \
      "Volume muted"
  else
    notify_volume
  fi
}

# =========================
# MICROPHONE
# =========================
get_mic_volume() {
  wpctl get-volume "$SOURCE" | awk '{printf "%d\n", $2 * 100}'
}

mic_is_muted() {
  wpctl get-volume "$SOURCE" | grep -q MUTED
}

notify_mic() {
  if mic_is_muted; then
    notify-send \
      -h string:x-canonical-private-synchronous:mic \
      -u low \
      -i "$ICON_DIR/microphone-mute.png" \
      "Mic: muted"
  else
    notify-send \
      -h string:x-canonical-private-synchronous:mic \
      -u low \
      -i "$ICON_DIR/microphone.png" \
      "Mic: $(get_mic_volume)%"
  fi
}

toggle_mic() {
  wpctl set-mute "$SOURCE" toggle && notify_mic
}

inc_mic() {
  wpctl set-volume "$SOURCE" 5%+ && notify_mic
}

dec_mic() {
  wpctl set-volume "$SOURCE" 5%- && notify_mic
}

# =========================
# ARGUMENT DISPATCH
# =========================
case "$1" in
--get) get_volume ;;
--inc) inc_volume ;;
--dec) dec_volume ;;
--toggle) toggle_mute ;;
--toggle-mic) toggle_mic ;;
--mic-inc) inc_mic ;;
--mic-dec) dec_mic ;;
*) get_volume ;;
esac
