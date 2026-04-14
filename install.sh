#!/bin/bash

echo "========================================="
echo "      Timelapse Creator Installer"
echo "========================================="
echo ""

INSTALL_DIR="$HOME/Scripts"
DESKTOP_FILE="$HOME/Desktop/Timelapse Creator.desktop"

mkdir -p "$INSTALL_DIR"

cp timelapse.sh "$INSTALL_DIR/timelapse.sh"
chmod +x "$INSTALL_DIR/timelapse.sh"
echo "Installed timelapse.sh to $INSTALL_DIR"

cat > "$DESKTOP_FILE" << DESKTOP
[Desktop Entry]
Version=1.0
Type=Application
Name=Timelapse Creator
Comment=Create a timelapse video from a folder of images
Exec=konsole --noclose -e bash "$INSTALL_DIR/timelapse.sh"
Icon=camera-video
Terminal=false
Categories=AudioVideo;Video;
DESKTOP

chmod +x "$DESKTOP_FILE"
echo "Created desktop launcher at $DESKTOP_FILE"

echo ""
echo "========================================="
echo "  Installation complete!"
echo "  Double-click 'Timelapse Creator' on"
echo "  your desktop to get started."
echo "========================================="
echo ""
echo "Press Enter to close."
read
