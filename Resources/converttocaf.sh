##
## Shell script to batch convert all files in a directory to caf sound format for iPhone
## Place this shell script a directory with sound files and run it: 'sh converttocaf.sh'
## Change -c 1 to -c 2 to create stereo files
## @22050 is sample rate
##
 
for f in *.wav; do
	if  [ "$f" != "converttocaf.sh" ]
	then
		/usr/bin/afconvert -f caff -d ima4@44100 -c 2 $f
		echo "$f converted"
	fi
done