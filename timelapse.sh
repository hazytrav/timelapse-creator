#!/bin/bash

# GoPro Timelapse Creator
# Double-click via timelapse.desktop to run

echo "========================================="
echo "       GoPro Timelapse Creator"
echo "========================================="
echo ""

# Pick the folder with kdialog
PHOTO_DIR=$(kdialog --getexistingdirectory "$HOME" --title "Select your GoPro photo folder")

if [ -z "$PHOTO_DIR" ]; then
    echo "No folder selected. Exiting."
    sleep 2
    exit 1
fi

echo "Folder selected: $PHOTO_DIR"
echo ""

# Count JPGs
JPG_COUNT=$(ls -1 "$PHOTO_DIR"/*.JPG 2>/dev/null | wc -l)

if [ "$JPG_COUNT" -eq 0 ]; then
    echo "No JPG files found in that folder. Exiting."
    kdialog --error "No JPG files found in:\n$PHOTO_DIR"
    sleep 2
    exit 1
fi

echo "Found $JPG_COUNT images."
echo ""

# Ask where to save the output
FOLDER_NAME=$(basename "$PHOTO_DIR")
OUTPUT_DIR=$(kdialog --getexistingdirectory "$HOME" --title "Where do you want to save the timelapse?")

if [ -z "$OUTPUT_DIR" ]; then
    echo "No save location selected. Exiting."
    sleep 2
    exit 1
fi

# Ask for a filename
FILENAME=$(kdialog --inputbox "Enter a name for the timelapse file (no extension needed):" "timelapse" --title "File Name")

if [ -z "$FILENAME" ]; then
    echo "No filename entered. Exiting."
    sleep 2
    exit 1
fi

OUTPUT_FILE="$OUTPUT_DIR/${FILENAME}.mp4"

echo "Output will be saved to:"
echo "$OUTPUT_FILE"
echo ""

# Build filelist
FILELIST=$(mktemp /tmp/timelapse_XXXXXX.txt)
ls -1 "$PHOTO_DIR"/*.JPG | sort | while read f; do
    echo "file '$f'"
    echo "duration 1"
done > "$FILELIST"

echo "Building timelapse..."
echo ""

# Run ffmpeg
ffmpeg -f concat -safe 0 -i "$FILELIST" \
  -r 30 \
  -vf "scale=1920:1080,setpts=0.1*PTS" \
  -c:v h264_nvenc \
  -preset p7 -cq 23 \
  -pix_fmt yuv420p \
  -color_range pc \
  "$OUTPUT_FILE"

rm "$FILELIST"

echo ""
if [ -f "$OUTPUT_FILE" ]; then
    echo "Done! Timelapse saved to:"
    echo "$OUTPUT_FILE"

    # Ask if they want to play the video
    kdialog --yesno "Timelapse created!\n\nSaved to:\n$OUTPUT_FILE\n\nPlay the video now?" --title "Done!"
    if [ $? -eq 0 ]; then
        xdg-open "$OUTPUT_FILE"
    fi

    # Open save location in Dolphin
    dolphin "$OUTPUT_DIR" &
else
    echo "Something went wrong -- output file not found."
    kdialog --error "Something went wrong. Output file was not created."
fi

echo ""
echo "Press Enter to close."
read
