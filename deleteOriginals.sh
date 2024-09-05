# Delete .original files on the NAS

# To execute, manually cd into the archive directory on the NAS and execute this script from that folder
# I have yet to figure out how Apple structures permissionf for afp shares


cat /Users/lsc_admin/Documents/MOVtoMP4ConvertionScript_DO_NOT_DELETE/toDelete.txt | while read line;
do
	echo "Please wait..."
	echo
	rm -f "$line"
	echo "Deleted $line"
done

echo "Finished"
