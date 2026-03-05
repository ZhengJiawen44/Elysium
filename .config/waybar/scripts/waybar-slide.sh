#!/bin/bash
TRIGGER_HEIGHT=1 # How close to the top to trigger opening
BAR_HEIGHT=45    # The actual height of your Waybar
SHOW_DELAY=3
HIDE_DELAY=8
WAYBAR_VISIBLE=true
show_counter=0
hide_counter=0

# Ensure Waybar is running initially to avoid sync issues
if ! pgrep -x "waybar" >/dev/null; then
  waybar &
  sleep 1 # Wait for it to start
fi

while true; do
  # Get the Y position of the cursor
  Y=$(hyprctl cursorpos | awk '{print $2}' | tr -d ',')

  # SCENARIO 1: Show Waybar (with 1 second delay)
  if [[ "$Y" -le "$TRIGGER_HEIGHT" && "$WAYBAR_VISIBLE" = false ]]; then
    hide_counter=0 # Reset hide counter
    ((show_counter++))
    if [[ "$show_counter" -ge "$SHOW_DELAY" ]]; then
      # Send signal to unhide
      killall -SIGUSR1 waybar
      WAYBAR_VISIBLE=true
      show_counter=0
    fi
  # SCENARIO 2: Hide Waybar (with 2 second delay)
  elif [[ "$Y" -gt "$BAR_HEIGHT" && "$WAYBAR_VISIBLE" = true ]]; then
    show_counter=0 # Reset show counter
    ((hide_counter++))
    if [[ "$hide_counter" -ge "$HIDE_DELAY" ]]; then
      # Send signal to hide
      killall -SIGUSR1 waybar
      WAYBAR_VISIBLE=false
      hide_counter=0
    fi
  # Reset both counters if conditions aren't met
  else
    show_counter=0
    hide_counter=0
  fi

  sleep 0.1
done
