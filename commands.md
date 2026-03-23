# Ad-hoc commands to run to manage the archive

## Searches for all .original files and creates a list to delete
cd /Volumes/Media\ Archive-1/LSCMedia/Live/LSC\ Video\ Raid/LSCJAX_Videos\ 2023
find . -type f -name "*.original"

## Find mov files in current directory that are larger than 10GB in size and save output to file
find . -type f -size +10G -iname "*.mov" -exec ls -alh {} + > ~/Documents/MOVtoMP4ConvertionScript_DO_NOT_DELETE/large.txt