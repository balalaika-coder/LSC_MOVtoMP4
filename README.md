# LSC_MOVtoMP4

This project provides a suite of Zsh/Bash scripts designed for automated video conversion from `.mov` to `.mp4` format, specifically tailored for the LSC environment. 

The core workflow involves scanning directories for MOV files, converting them using FFmpeg (with macOS hardware acceleration support), and managing the lifecycle of original files by renaming and eventually deleting them.

## Key Features
- **Automated Directory Scanning**: Recursively searches the current directory for `.mov` files.
- **Hardware Acceleration**: Utilizes macOS `h264_videotoolbox` for lightning-fast, highly efficient video encoding.
- **Real-Time Progress**: Parses execution telemetry to output real-time percentage progress of conversions in the terminal.
- **Detailed Logging**: Automatically generates and saves conversion logs in a `logs/` folder within the execution directory.
- **Original File Protection**: Safely renames original files to `.mov.original` to ensure fallback safety and prevent redundant processing.
- **Batch Cleanup Utilities**: Includes included scripts to safely list and batch-delete `.original` files after conversions are verified, ideal for managing storage space. 

## Requirements
- **macOS** (Required for the Apple `h264_videotoolbox` encoder)
- **ffprobe & ffmpeg**: Must be installed system-wide.
  - Easily installable via Homebrew: 
    ```bash
    brew install ffmpeg
    ```

## Usage

### 1. Conversion Workflow
You can convert files by either navigating to the folder containing your videos and executing the full path, or by using the global alias. 

To convert using the script path:
```bash
/path/to/MOVtoMP4_convert.sh
```
*Tip: The included `.zshrc` provides an alias to map this operation to a `convert` command, allowing you to simply type `convert` from any working directory containing `.mov` files.*

The conversion script will:
1. Locate all nested `.mov` files.
2. Convert each file to `.mp4`.
3. Rename each original file with the `.original` suffix (e.g., `video.mov` -> `video.mov.original`).

### 2. Cleanup Workflow
After your conversions are verified, use the cleanup utilities to permanently remove the legacy `.mov.original` files:

1. **Generate the Deletion List**:
   Navigate to your archive or NAS directory and run the list generation script:
   ```bash
   /path/to/generate_list_to_delete.sh
   ```
   This will scan the network map and populate a `toDelete.txt` file listing all files scheduled for deletion.

2. **Review the Target List**:
   It is highly recommended to quickly check `toDelete.txt` to ensure the correct files will be removed.

3. **Execute Deletion**:
   Once verified, run the deletion script to permanently clear the space:
   ```bash
   /path/to/deleteOriginals.sh
   ```

## Included Files overview
- `MOVtoMP4_convert.sh`: The primary conversion and renaming script.
- `generate_list_to_delete.sh`: Scans for `.original` legacy files and adds them to `toDelete.txt`.
- `deleteOriginals.sh`: Permanently removes the exact files read from `toDelete.txt`.
- `commands.md`: A reference sheet of useful shell one-liners for broader media management.
- `.zshrc`: Alias integration mapping the script execution to an easy command.
