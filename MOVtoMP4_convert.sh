#!/bin/zsh

###############################################################
# convertMOVtoMP4.sh                                          #
# Author: Yevgeniy Lukomskiy                                  #
# Version: 1.3                                                #
# Updated: 12/04/2026                                         #
#                                                             #
# About: This script converts .MOV files into .MP4 format     #
# using macOS hardware acceleration (h264_videotoolbox).      #
# It recursively searches the directory where it's executed   #
# for .mov files, encodes them to .mp4, and uniquely renames  #
# the originals to .mov.original to prevent reconversions.    #
#                                                             #
# Usage: Navigate to the folder containing your videos        #
# and execute the script from there. For example:             #
#      /path/to/MOVtoMP4_convert.sh                           #
#                                                             #
# Requirements: 'ffmpeg' must be installed system-wide.       #
# If missing, the script will provide installation steps.     #
###############################################################


# Determine current working directory to place logs where the script is run from
WORKING_DIR=$(pwd)

#Create a log file
START_DATE=$(date +"%Y-%m-%d_%H-%M-%S")
mkdir -p "${WORKING_DIR}/logs"
LOG_FILE="${WORKING_DIR}/logs/convertMOVtoMP4_${START_DATE}.log"
touch "${LOG_FILE}"

# Logging function to dynamically inject current time and output to terminal
log_message() {
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "${timestamp}  $1" | tee -a "${LOG_FILE}"
}

# Check if ffmpeg is installed system-wide
if ! command -v ffmpeg &> /dev/null; then
    echo "==========================================================="
    echo "ERROR: ffmpeg could not be found on the system."
    echo "Please install it using Homebrew:"
    echo "  1. Install Homebrew (if not already installed):"
    echo "     /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    echo "  2. Install ffmpeg:"
    echo "     brew install ffmpeg"
    echo "==========================================================="
    
    log_message "ERROR: ffmpeg could not be found on the system. Exiting."
    exit 1
fi

#find mov files and add them to files array
files=()
while IFS= read -r -d '' filepath; do
    if [[ -n "$filepath" ]]; then
        files+=("$filepath")
    fi
done < <(find . -name "*.mov" -type f -print0)

#print all found files function on new line
function listFiles(){
    log_message "Found files to be converted:"
    for f in "${files[@]}"; do
        log_message "${f}"
        echo | tee -a "${LOG_FILE}"
        echo | tee -a "${LOG_FILE}"
    done
}

function convertFiles() {
    #cycle through each file and convert to mp4
    for file in "${files[@]}"; do
        echo | tee -a "${LOG_FILE}"
        log_message "Converting: ${file}"

        #generate new name without mov extension
        newfile=${file%.mov}

        # Encode with Hardware acceleration
        # AC3 is highly compatible and often more robust for MOV files from recording equipment.
        # -y: Overwrite output file if it exists.
        # -af "aresample=async=1": Helps with sync and ensures consistent audio processing.
        # -ar 48000: Forces standard 48kHz sample rate.
        # -movflags +faststart: Moves the moov atom to the beginning for faster playback start.
        # -loglevel info: Show info level logs.
        
        if ffmpeg -y -hide_banner -loglevel info -stats -i "${file}" \
            -c:v h264_videotoolbox -b:v 10000k -vf yadif -pix_fmt yuv420p \
            -c:a ac3 -b:a 320k -ac 2 -ar 48000 \
            -af "aresample=async=1" \
            -movflags +faststart \
            "${newfile}.mp4"; then
            
            # Change original file's extension so it doesn't get converted again.
            mv "${file}" "${file}.original"
            log_message "SUCCESS! ${newfile}.mp4 Converted!"
        else
            log_message "ERROR: Conversion failed for ${file}. Check the output above for details."
            # Optionally remove partial file if conversion failed
            [ -f "${newfile}.mp4" ] && rm "${newfile}.mp4"
        fi
    done
}


if [ ${#files[@]} -ne 0 ]
    then
        #list found MOV files
       listFiles
        #Convert Files

        convertFiles
    else
        log_message "No files found. Exiting"
fi
