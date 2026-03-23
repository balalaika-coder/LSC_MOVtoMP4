#!/bin/zsh

###############################################################
# generate_list_to_delete.sh                                  #
#                                                             #
# About: This script searches for all successfully converted  #
# .mov.original files within the current directory and its    #
# subdirectories, recording their paths into a text file.     #
# This file is used later for safely deleting old originals.  #
#                                                             #
# Usage: Navigate to your network or local storage directory  #
# where the archived media files are stored, and execute:     #
#      /path/to/generate_list_to_delete.sh                    #
#                                                             #
# Output: A 'toDelete.txt' file is generated, which serves as #
# the target list for the deletion script.                    #
###############################################################

echo "Please wait...searching..."
find . -type f -name "*.original" > ~/Documents/MOVtoMP4ConvertionScript_DO_NOT_DELETE/toDelete.txt

echo "Completed"
echo "See results in ~/Documents/MOVtoMP4ConvertionScript_DO_NOT_DELETE/toDelete.txt"