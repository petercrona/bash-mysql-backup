#!/bin/bash

# Script for creating backup of MySQL database. 
# It deletes backup-files older than a week.
# * BASE_FOLDER MUST CONTAIN WRITEABLE DIRECTORY NAMED "data".
# * "mail" SHOULD BE CONFIGURED ON THE COMPUTER

#Config (which you need to specify)
USERNAME="root";
PASSWORD="test";
BASE_FOLDER="/home/peter/Skrivbord/test";
EXPECTED_TABLES=160; # Set really low if you don't care. Else check bottom of script.
EMAIL="petercrona89@gmail.com";
PASSWORD_7Z="test" # Password to encrypt compressed files with

# Delete files/folders older than a week
find $BASE_FOLDER/data -mindepth 1 -mtime +7 | xargs rm -Rf

# Create folder for today
TODAY_FOLDER="$BASE_FOLDER/data/$(date +%Y-%m-%d)";
if [ -f "$TODAY_FOLDER.7z" ]; then
    echo "File for the current day already exist!" | mail -s "DB Backup service" $EMAIL
    exit 1;
else
    mkdir $TODAY_FOLDER;
fi

# Backup individual tables
for DATABASE in $(mysql -u $USERNAME -p$PASSWORD -AN -e "SHOW DATABASES");
do
    mkdir "$TODAY_FOLDER/$DATABASE";
    for TABLE in $(mysql -u $USERNAME -p$PASSWORD -AN -e "SHOW TABLES FROM $DATABASE");
    do
	mysqldump -u $USERNAME -p$PASSWORD $DATABASE $TABLE > "$TODAY_FOLDER/$DATABASE/$TABLE.sql"; 
    done
done

# Did we get the expected number of tables?
NUMBER_OF_TABLES=$(find $TODAY_FOLDER | wc -l | cut -f1 -d" ");
if [[ $EXPECTED_TABLES -gt $NUMBER_OF_TABLES ]]; then
    echo "The expected number of tables were not created!" | mail -s "DB Backup service" $EMAIL
    exit 1;
fi

# Run 7z and remove folders
7z a -p$PASSWORD_7Z $TODAY_FOLDER.7z $TODAY_FOLDER;
rm -rf $TODAY_FOLDER;

# ===================================================================================
# One way to get the number of expected tables is to set it to something really low, comment out the "rm -rf $TODAY_FOLDER"-line
# and then run "find ./data/<SOME_EXISTING_DATE> | wc -l" in the terminal. Set the expected to this value.