#!/bin/zsh

###############################################################
# convertMOVtoMP4.sh                                          #
# Author: Yevgeniy Lukomskiy                                  #
# Version: 1.2                                                #
# Updated: 03/04/2026                                         #
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

        #convert file
	        
        #Encode with Hardware acceleration
        #fmpeg -hide_banner -loglevel error -stats -i "${file}" -c:v h264_videotoolbox -b:v 10000k -vf yadif -pix_fmt yuv420p -c:a ac3 -b:a 1024k "${newfile}.mp4" 
        # ^ This is the old command that was not working. There were reports of converted files having no sound.
        
        ffmpeg -i ${file} -c:v h264_videotoolbox -b:v 10000k -vf yadif -pix_fmt yuv420p -c:a ac3 -b:a 1024k "${newfile}.mp4"
        
        #change original file's extension so it doesn't get converted again, later, if not deleted.
        mv "${file}" "${file}.original"
        
        log_message "SUCCESS! ${newfile}.mp4 Converted!"
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
