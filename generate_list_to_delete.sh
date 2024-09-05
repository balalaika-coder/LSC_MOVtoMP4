# Navigate to the NAS folder where archive is located 
# cd /Volumes/Media\ Archive-1/LSCMedia/Live/LSC\ Video\ Raid/LSCJAX_Videos\ 2023
# execute the script from the above folder by running ~/Documents/MOVtoMP4ConvertionScript_DO_NOT_DELETE/generate_list_to_delete.sh
# output file will be put in the same folder as the script

# cd /Volumes/Media\ Archive-1/LSCMedia/Live/LSC\ Video\ Raid/LSCJAX_Videos\ 2023

echo "Please wait...searching..."
find . -type f -name "*.original" > ~/Documents/MOVtoMP4ConvertionScript_DO_NOT_DELETE/toDelete.txt

echo "Completed"
echo "See results in ~/Documents/MOVtoMP4ConvertionScript_DO_NOT_DELETE/toDelete.txt"