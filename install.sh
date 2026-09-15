#!/usr/bin/env bash
# Установка clip: скрипт в ~/.local/bin, ярлыки в меню приложений,
# хоткеи для GNOME (Ctrl+Alt+C — выбрать, Ctrl+Alt+A — всё).
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
BIN="$HOME/.local/bin"
APPS="$HOME/.local/share/applications"
mkdir -p "$BIN" "$APPS"
install -m 755 "$HERE/clip" "$BIN/clip"
echo "ок: $BIN/clip"

write_desktop() { # $1=файл $2=имя $3=комментарий $4=аргумент $5=иконка
  cat > "$APPS/$1" <<EOF
[Desktop Entry]
Type=Application
Name=$2
Comment=$3
Exec=$BIN/clip $4
Icon=$5
Terminal=false
Categories=Utility;
EOF
}
write_desktop "clip.desktop" "clip — буфер (Ctrl+Alt+C)" "Выбрать файл из ~/clip и скопировать в буфер обмена" "" "edit-copy"
write_desktop "clip-all.desktop" "clip — всё в буфер (Ctrl+Alt+A)" "Склеить всё содержимое ~/clip в буфер обмена" "all" "edit-paste"
command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database "$APPS" || true
echo "ок: ярлыки в меню приложений"

if command -v gsettings >/dev/null 2>&1 && [ "${XDG_CURRENT_DESKTOP:-}" = "GNOME" ]; then
  SCHEMA="org.gnome.settings-daemon.plugins.media-keys"
  BASE="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"
  cur="$(gsettings get $SCHEMA custom-keybindings)"
  if [[ "$cur" != *clip* ]]; then
    gsettings set $SCHEMA custom-keybindings "['$BASE/clip/', '$BASE/clip-all/']"
    k="org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$BASE/clip/"
    gsettings set "$k" name 'clip → буфер'
    gsettings set "$k" command "$BIN/clip"
    gsettings set "$k" binding '<Control><Alt>c'
    k="org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$BASE/clip-all/"
    gsettings set "$k" name 'clip: всё'
    gsettings set "$k" command "$BIN/clip all"
    gsettings set "$k" binding '<Control><Alt>a'
    echo "ок: хоткеи GNOME (Ctrl+Alt+C / Ctrl+Alt+A)"
  else
    echo "хоткеи clip уже настроены — не трогаю"
  fi
fi

echo "готово. файлы кидай в ~/clip"
