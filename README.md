bash-mysql-backup
=================

A simple backup-script for MySQL

# Usage
Edit the config-section of the script. You might also want to have a look at the
"Delete files/folders" just below, in case you want to edit it. By default
it deletes everything older than a week.

Make sure that the BASE_FOLDER you specify in the config contains a writable directory called
"data". Also, if you want to use the mail functions, make sure to configure mail on your server.
Eg. install and configure postfix. If mail is not important for you, simply comment the lines
containing "mail" out.

# Requirements
7z
