#!/bin/zsh

###############################################################
# convertMOVtoMP4.sh                                          #
# Author: Yevgeniy Lukomskiy                                  #
# Version: 1.3                                          #
# Updated: 03/24/2025                                         #
#                                                             #
# About: This script scans folder and all subfolders,         #
# searches for all MOV files and converts them to MP4 files   #
# and rename original MOV files to .original                  #
###############################################################

#Create a log file
currentDate=$(date +"%Y-%m-%d_%H-%M-%S")
# touch "/Users/lsc_stream/Documents/MOVtoMP4ConvertionScript_DO_NOT_DELETE/LSC_MOVtoMP4/logs/convertMOVtoMP4_${currentDate}.log"
log="/Users/lsc_stream/Documents/MOVtoMP4ConvertionScript_DO_NOT_DELETE/LSC_MOVtoMP4/logs/convertMOVtoMP4_${currentDate}.log"
touch ${log}

#find mov files and add them to files array
files=()
while IFS=  read -r -d $'\0'; do
    files+=("$REPLY")
done < <(find . -iname "*.mov" -print0)

#print all found files function on new line. This is needed for logging.
function listFiles(){
    a=1
    echo "${currentDate}  Found files to be converted:" | tee -a ${log}
    while [ $a -le ${#files[@]} ]
    do
        echo -e "${currentDate}  ${files[a]}\n\n" | tee -a ${log}
        ((a++))
    done
}

function convertFiles() {
    #cycle through each file and convert to mp4
    i=1
    while [ $i -le ${#files[@]} ]
        do
            #get name for each file in array
            file=${files[i]}
            echo >>${log}
            echo "${currentDate}  Converting: ${files[i]}" | tee -a ${log}

            #generate new name without mov extension
            newfile=${file%.mov}

            #convert file
            #Endode with Hardware acceleration (larger file, faster encode, most compatible)
            /opt/homebrew/bin/ffmpeg -i ${file} -c:v h264_videotoolbox -b:v 10000k -vf yadif -pix_fmt yuv420p -c:a ac3 -b:a 1024k "${newfile}.mp4" 

            #change original file's extension so it doesn't get converted again, later, if not deleted.
            mv ${file} "${file}.original"
            ((i++))
            echo -e "\n\n${currentDate}  SUCCESS! ${newfile}.mp4 Converted!" | tee -a ${log}
    done
    cat ${log}
}


if [ ${#files[@]} -ne 0 ]
    then
        #list found MOV files
        listFiles
        #Convert Files
        convertFiles
    else
        echo "${currentDate}  No files found. Exiting" | tee -a ${log}
fi
