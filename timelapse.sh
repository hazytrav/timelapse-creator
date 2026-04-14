#!/bin/bash

# =========================================
#        Timelapse Creator
#        github.com/hazytrav/timelapse-creator
# =========================================

echo "========================================="
echo "          Timelapse Creator"
echo "========================================="
echo ""

# Show progress option
kdialog --yesno "Do you want to see the rendering progress in the terminal?" --title "Rendering Mode"
SHOW_PROGRESS=$?

# Pick photo folder
PHOTO_DIR=$(kdialog --getexistingdirectory "$HOME" --title "Select your photo folder")
if [ -z "$PHOTO_DIR" ]; then
    echo "No folder selected. Exiting."
    sleep 2; exit 1
fi
echo "Folder selected: $PHOTO_DIR"
echo ""

# Count JPGs (support both .JPG and .jpg)
JPG_COUNT=$(ls -1 "$PHOTO_DIR"/*.JPG "$PHOTO_DIR"/*.jpg 2>/dev/null | wc -l)
if [ "$JPG_COUNT" -eq 0 ]; then
    echo "No JPG files found in that folder. Exiting."
    kdialog --error "No JPG files found in:\n$PHOTO_DIR\n\nMake sure your images are .JPG or .jpg files."
    sleep 2; exit 1
fi
echo "Found $JPG_COUNT images."
echo ""

# Resolution
RESOLUTION=$(kdialog --combobox "Select output resolution:" "1080p" "1080p" "2K" "4K" --title "Resolution")
case "$RESOLUTION" in
    "2K") SCALE="2560:1440" ;;
    "4K") SCALE="3840:2160" ;;
    *)    SCALE="1920:1080" ;;
esac

# Speed
SPEED=$(kdialog --combobox "Select timelapse speed:" "10x" "2x" "5x" "10x" "20x" "30x" "50x" --title "Speed")
case "$SPEED" in
    "2x")  SETPTS="0.5" ;;
    "5x")  SETPTS="0.2" ;;
    "20x") SETPTS="0.05" ;;
    "30x") SETPTS="0.033" ;;
    "50x") SETPTS="0.02" ;;
    *)     SETPTS="0.1" ;;
esac

# Framerate
FPS=$(kdialog --combobox "Select output framerate:" "30fps" "24fps" "30fps" "60fps" --title "Framerate")
case "$FPS" in
    "24fps") FRAMERATE="24" ;;
    "60fps") FRAMERATE="60" ;;
    *)       FRAMERATE="30" ;;
esac

# Quality
QUALITY=$(kdialog --combobox "Select output quality:" "High" "Best (slow, large file)" "High" "Medium" "Low (fast, small file)" --title "Quality")
case "$QUALITY" in
    "Best (slow, large file)") CQ="14" ;;
    "Medium")                  CQ="23" ;;
    "Low (fast, small file)")  CQ="32" ;;
    *)                         CQ="18" ;;
esac

# Pick save location
OUTPUT_DIR=$(kdialog --getexistingdirectory "$HOME" --title "Where do you want to save the timelapse?")
if [ -z "$OUTPUT_DIR" ]; then
    echo "No save location selected. Exiting."
    sleep 2; exit 1
fi

# Enter filename -- loop until valid name chosen
while true; do
    FILENAME=$(kdialog --inputbox "Enter a name for the timelapse file (no extension needed):" "timelapse" --title "File Name")
    if [ -z "$FILENAME" ]; then
        echo "No filename entered. Exiting."
        sleep 2; exit 1
    fi

    OUTPUT_FILE="$OUTPUT_DIR/${FILENAME}.mp4"

    if [ -f "$OUTPUT_FILE" ]; then
        kdialog --yesnocancel "A file named '${FILENAME}.mp4' already exists in that location.\n\nDo you want to overwrite it?" --title "File Already Exists"
        OVERWRITE=$?
        if [ $OVERWRITE -eq 0 ]; then
            break
        elif [ $OVERWRITE -eq 1 ]; then
            continue
        else
            echo "Cancelled. Exiting."
            sleep 2; exit 0
        fi
    else
        break
    fi
done

echo ""
echo "Settings:"
echo "  Resolution : $RESOLUTION ($SCALE)"
echo "  Speed      : $SPEED"
echo "  Framerate  : $FRAMERATE fps"
echo "  Quality    : $QUALITY (cq $CQ)"
echo "  Output     : $OUTPUT_FILE"
echo ""

# Build filelist
FILELIST=$(mktemp /tmp/timelapse_XXXXXX.txt)
ls -1 "$PHOTO_DIR"/*.JPG "$PHOTO_DIR"/*.jpg 2>/dev/null | sort | while read f; do
    echo "file '$f'"
    echo "duration 1"
done > "$FILELIST"

echo "Building timelapse..."
echo ""

if [ $SHOW_PROGRESS -eq 0 ]; then
    ffmpeg -f concat -safe 0 -i "$FILELIST" \
      -r "$FRAMERATE" \
      -vf "scale=$SCALE,setpts=${SETPTS}*PTS" \
      -c:v h264_nvenc \
      -preset p7 -cq "$CQ" \
      -pix_fmt yuv420p \
      -color_range pc \
      -y \
      "$OUTPUT_FILE"
else
    echo "Rendering in background, please wait..."
    kdialog --title "Timelapse Creator" --passivepopup "Rendering timelapse, please wait..." 99999 &
    POPUP_PID=$!

    ffmpeg -f concat -safe 0 -i "$FILELIST" \
      -r "$FRAMERATE" \
      -vf "scale=$SCALE,setpts=${SETPTS}*PTS" \
      -c:v h264_nvenc \
      -preset p7 -cq "$CQ" \
      -pix_fmt yuv420p \
      -color_range pc \
      -y \
      "$OUTPUT_FILE" > /dev/null 2>&1

    kill $POPUP_PID 2>/dev/null
fi

rm "$FILELIST"

echo ""
if [ -f "$OUTPUT_FILE" ]; then
    echo "Done! Timelapse saved to:"
    echo "$OUTPUT_FILE"
    kdialog --yesno "Timelapse created!\n\nResolution: $RESOLUTION  |  Speed: $SPEED  |  Quality: $QUALITY\nSaved to: $OUTPUT_FILE\n\nPlay the video now?" --title "Done!"
    if [ $? -eq 0 ]; then
        xdg-open "$OUTPUT_FILE"
    fi
    dolphin "$OUTPUT_DIR" &
else
    echo "Something went wrong -- output file not found."
    kdialog --error "Something went wrong. Output file was not created.\n\nMake sure ffmpeg and h264_nvenc are available on your system."
fi

echo ""
echo "Press Enter to close."
read
