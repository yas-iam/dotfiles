# =============================================================================
#  FILE:        launch.sh
#  DESCRIPTION: Polybar launcher script with multi-monitor support
#  AUTHOR:      emoon
#  REPO:        github.com/yas-iam/dotfiles
# =============================================================================

#!/usr/bin/env bash

# --- 1. MONITOR SETUP ---
# Configure dual-head display: HDMI-1 to the right of the laptop screen (eDP-1)
xrandr --output eDP-1 --auto --primary --output HDMI-1 --mode 1920x1080 --rate 60 --right-of eDP-1

# --- 2. CLEANUP ---
# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down completely
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# --- 3. LAUNCH ---
# MAGIC: Detects all connected monitors and spawns a bar instance for each.
# This ensures your 'matrix' bar appears on both your laptop and HDMI monitor.
if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m polybar --reload matrix 2>&1 | tee -a /tmp/polybar.log & disown
  done
else
  polybar --reload matrix 2>&1 | tee -a /tmp/polybar.log & disown
fi

echo "Polybar launched..."
