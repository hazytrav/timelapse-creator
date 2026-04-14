# Timelapse Creator

A simple, user-friendly timelapse video creator for Linux with a fully guided graphical interface. No command line knowledge required -- just double-click and follow the prompts.

Designed for KDE Plasma on Linux (tested on Bazzite/Fedora), but compatible with any Linux desktop that has KDialog and Konsole available.

![License](https://img.shields.io/badge/license-GPL--3.0-blue)
![Platform](https://img.shields.io/badge/platform-Linux-lightgrey)
![Shell](https://img.shields.io/badge/shell-bash-green)

---

## What it does

Point it at a folder of JPG images and it will produce a smooth, high quality timelapse video. Every setting is chosen through a graphical dialog -- no typing commands required.

**Settings you can choose each time:**
- Output resolution -- 1080p, 2K, or 4K
- Speed -- 2x, 5x, 10x, 20x, 30x, or 50x
- Framerate -- 24, 30, or 60fps
- Quality -- Best, High, Medium, or Low
- Save location and filename
- Whether to watch the rendering progress or run it quietly in the background

**Also handles:**
- Detects duplicate filenames and asks whether to overwrite
- Opens the save location in Dolphin when done
- Offers to play the video immediately on completion

---

## Requirements

### System
- Linux with KDE Plasma (Wayland or X11)
- Konsole terminal
- Dolphin file manager

### Software
- `ffmpeg` (with `h264_nvenc` for GPU rendering -- requires an Nvidia GPU)
- `kdialog` (included with KDE Plasma)

### Installing ffmpeg

**Fedora / Bazzite / rpm-ostree based:**
```bash
sudo rpm-ostree install ffmpeg
```

**Ubuntu / Debian:**
```bash
sudo apt install ffmpeg
```

**Arch Linux:**
```bash
sudo pacman -S ffmpeg
```

### GPU rendering note

This tool uses `h264_nvenc` for fast GPU-accelerated rendering via Nvidia. If you do not have an Nvidia GPU, open `timelapse.sh` and replace `-c:v h264_nvenc` with `-c:v libx264` for CPU rendering. CPU rendering is slower but works on any hardware.

For AMD GPU acceleration, replace with `-c:v h264_amf`.

---

## Installation

```bash
git clone https://github.com/hazytrav/timelapse-creator.git
cd timelapse-creator
bash install.sh
```

The installer will:
1. Copy `timelapse.sh` to `~/Scripts/`
2. Create a clickable launcher on your desktop

---

## Usage

1. Put your JPG images into a folder
2. Double-click **Timelapse Creator** on your desktop
3. Follow the prompts
4. Your timelapse video will be saved wherever you choose

### Supported image formats
- `.JPG` / `.jpg`

### Recommended image sources
- Any camera shooting in timelapse or interval mode
- GoPro timelapse/interval photos
- DSLR/mirrorless interval shooting
- Smartphone timelapse exports
- Any sequence of JPG images captured at regular intervals

---

## Tips

- **How fast should I go?** For a 5-minute interval shoot over 90 days (~25,000 frames), 30x speed at 30fps gives roughly a 28-minute video. 50x gives about 17 minutes.
- **Quality vs file size:** "Best" produces large files but maximum detail. "High" is a good everyday balance. Use "Low" for a quick preview.
- **4K and GPU:** 4K at Best quality will take longer even with GPU acceleration. Make sure you have enough disk space.
- **Duplicate names:** The tool will warn you before overwriting any existing file.

---

## Folder structure
---

## License

GPL-3.0 -- see [LICENSE](LICENSE) for details.

---

## Contributing

Pull requests welcome. If you add support for additional image formats, CPU fallback detection, or other desktop environments, please open a PR.
