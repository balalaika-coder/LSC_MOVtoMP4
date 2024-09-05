#!/bin/zsh

###############################################################
# convertMOVtoMP4.sh                                          #
# Author: Yevgeniy Lukomskiy                                  #
# Version: 1.1                                                #
# Updated: 12/01/2021                                         #
#                                                             #
# About: This script scans folder and all subfolders,         #
# searches for all MOV files and converts them to MP4 files   #
# and rename original MOV files to .original                  #
###############################################################

#Navigate to folder with MOV files
#cd /Users/zhenya/Desktop/ConversionScript
# cd /Volumes/Media\ Archive/LSCMedia/Live/LSC\ Video\ Raid/LSCJAX_Videos\ 2022

# For regular conversions, delete line below and uncomment line above
cd /Volumes/Macintosh\ HD/Users/lsc_stream/Movies/Live_2023
ls -alh


#Create a log file
currentDate=`date +"%Y-%m-%d_%H-%M-%S"`
touch "/Users/lsc_stream/Documents/MOVtoMP4ConvertionScript_DO_NOT_DELETE/logs/convertMOVtoMP4_${currentDate}.log"
log="/Users/lsc_stream/Documents/MOVtoMP4ConvertionScript_DO_NOT_DELETE/logs/convertMOVtoMP4_${currentDate}.log"

#find mov files and add them to files array
files=()
while IFS=  read -r -d $'\0'; do
    files+=("$REPLY")
done < <(find . -name "*.mov" -print0)

#print all found files function on new line
function listFiles(){
    a=1
    echo "${currentDate}  Found files to be converted:" >>${log}
    while [ $a -le ${#files[@]} ]
    do
        echo "${currentDate}  ${files[a]}" >>${log}
        echo 
        echo
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
            echo "${currentDate}  Converting: ${files[i]}" >>${log}

            #generate new name without mov extension
            newfile=${file%.mov}

            #convert file
		    
            #Software encode            	
		    #/usr/local/bin/ffmpeg -i ${file} -c:v libx264 -b:v 10000k -vf yadif -pix_fmt yuv420p -c:a ac3 -b:a 1024k "${newfile}.mp4" 
	        
            #Endode with Hardware acceleration
            /Users/lsc_stream/Documents/MOVtoMP4ConvertionScript_DO_NOT_DELETE/ffmpeg -i ${file} -c:v h264_videotoolbox -b:v 10000k -vf yadif -pix_fmt yuv420p -c:a ac3 -b:a 1024k "${newfile}.mp4" 
            
            #change original file's extension so it doesn't get converted again, later, if not deleted.
            mv ${file} "${file}.original"
            ((i++))
            echo "${currentDate}  SUCCESS! ${newfile}.mp4 Converted!" >>${log}
        done
}


if [ ${#files[@]} -ne 0 ]
    then
        #list found MOV files
       listFiles
        #Convert Files

        convertFiles
    else
        echo "${currentDate}  No files found. Exiting" >>${log}
fi