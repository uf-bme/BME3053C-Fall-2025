#!/usr/bin/env bash
set -euo pipefail

# Make sure supervisor starts on login shells
if ! grep -q "supervisord" /home/vscode/.bashrc; then
  cat >> /home/vscode/.bashrc <<'EOF'
# Start Supervisor (noVNC/Xvfb) on login if not running
if ! pgrep -x supervisord >/dev/null; then
  sudo /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf >/dev/null 2>&1 &
fi
EOF
fi

echo "Setup complete. Use: DISPLAY=:0 love ."