#!/bin/zsh

###############################################################
# MOVtoMP4_avconvert_fallback.sh                                #
# Author: Yevgeniy Lukomskiy & AI Assistant                   #
#                                                             #
# About: This script converts .MOV files into .MP4 format.    #
# It serves as a fallback for Blackmagic HyperDeck files      #
# that have corrupted QuickTime indexes which cause ffmpeg    #
# and HandBrake to crash or drop audio.                       #
# It uses macOS's native `avconvert` tool to safely extract   #
# the audio at max speed, then uses FFmpeg to encode video.   #
#                                                             #
# Usage: Navigate to the folder containing your videos        #
# and execute the script from there.                          #
#                                                             #
# Requirements: 'ffmpeg' must be installed system-wide.       #
# 'avconvert' is built into macOS automatically.              #
###############################################################

WORKING_DIR=$(pwd)
START_DATE=$(date +"%Y-%m-%d_%H-%M-%S")
mkdir -p "${WORKING_DIR}/logs"
LOG_FILE="${WORKING_DIR}/logs/convertMOVtoMP4_VLC_${START_DATE}.log"
touch "${LOG_FILE}"

log_message() {
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "${timestamp}  $1" | tee -a "${LOG_FILE}"
}

if ! command -v ffmpeg &> /dev/null; then
    log_message "ERROR: ffmpeg could not be found. Exiting."
    exit 1
fi

# (avconvert is a built-in macOS tool, so no extra check is needed for it)

files=()
while IFS= read -r -d '' filepath; do
    if [[ -n "$filepath" ]]; then
        files+=("$filepath")
    fi
done < <(find . -name "*.mov" -type f -print0)

function listFiles(){
    log_message "Found files to be converted:"
    for f in "${files[@]}"; do
        log_message "${f}"
    done
}

function convertFiles() {
    for file in "${files[@]}"; do
        echo | tee -a "${LOG_FILE}"
        log_message "Converting: ${file}"

        newfile=${file%.mov}
        temp_audio="${newfile}_temp_audio.m4a"

        log_message "Step 1/2: Extracting audio using Apple avconvert (max speed)..."
        
        # -------------------------------------------------------------------------
        # WORKAROUND: Extract audio using macOS native `avconvert` tool.
        # HyperDeck .mov files sometimes have corrupted QuickTime chunk offset
        # tables (stco) which cause ffmpeg to drop the audio entirely.
        # Apple's native AVFoundation handles these files correctly.
        # We extract the audio to an intermediate .m4a file first.
        # -------------------------------------------------------------------------
        avconvert --preset PresetAppleM4A --source "${file}" --output "${temp_audio}" > /dev/null 2>&1
        
        if [ ! -f "${temp_audio}" ]; then
            log_message "ERROR: avconvert failed to extract audio from ${file}. Skipping."
            continue
        fi
        
        log_message "Step 2/2: Encoding video and merging audio using FFmpeg..."

        # Input 0: Original MOV file (for video)
        # Input 1: Extracted M4A file (for audio)
        if ffmpeg -y -hide_banner -loglevel info -stats -i "${file}" -i "${temp_audio}" \
            -map 0:v:0 -map 1:a:0 \
            -c:v h264_videotoolbox -b:v 10000k -vf yadif -pix_fmt yuv420p \
            -c:a ac3 -b:a 320k -ac 2 -ar 48000 \
            -movflags +faststart \
            "${newfile}.mp4"; then
            
            # Cleanup
            mv "${file}" "${file}.original"
            rm "${temp_audio}"
            log_message "SUCCESS! ${newfile}.mp4 Converted!"
        else
            log_message "ERROR: Conversion failed for ${file}. Check the output above for details."
            [ -f "${newfile}.mp4" ] && rm "${newfile}.mp4"
            [ -f "${temp_audio}" ] && rm "${temp_audio}"
        fi
    done
}

if [ ${#files[@]} -ne 0 ]; then
    listFiles
    convertFiles
else
    log_message "No files found. Exiting"
fi
