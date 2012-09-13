#!/bin/bash
 
# =========== BACKUP SCRIPT ============
# Author: Constantinos Xanthopoulos
#         <conx@xathopoulos.info>
# Version: 1.0.1
# ======================================
 
# ========== CONFIGURATIONS ============
BACKUP_NAME="";
BACKUP_DIR="";
BACKUP_LIST="";
BACKUP_LIST_REMOTE_DIR=""
USER="";
DOMAIN="";
RSYNC_OPTIONS="-ahog --delete";
TAR_FILES_NUM="3";
MIN_DAYS="2";
# ======================================
 
 
# Convert a UNIX timestamp to
# date format.
function stamp_to_date
{
	date +%Y%m%d -d "$(($(date +%s) - $1)) seconds ago";
}
 
# Return the days passed
# since a timestamp.
function days_since
{
	echo $(($(($(date +%s) - $1)) / 86400));
}
 
# Parse args
for arg in "$*"
do
	case $arg in
		--force|-f)
			force="yes";
	esac
done;

# Exit if the script isn't configured properly or
# the directory file doesn' t exist
if [ -z "${BACKUP_NAME}" -o -z "${BACKUP_DIR}" -o -z "${BACKUP_LIST}" -o -z "${BACKUP_LIST_REMOTE_DIR}" -o -z "${USER}" -o -z "${DOMAIN}" -o -z "${TAR_FILES_NUM}" -o -z "${MIN_DAYS}" ];
then
	echo "Error: Set the configuration options and try again";
	exit;
elif [ ! -d "${BACKUP_DIR}" ];
then
	echo "Error: Backup directory doesn't exist";
	exit;
fi

exit;

cd ${BACKUP_DIR}
 
echo "Fetching $BACKUP_LIST..." | tee -a ../logfile.log;
rsync ${RSYNC_OPTIONS} ${USER}@${DOMAIN}:${BACKUP_LIST_REMOTE_DIR}/${BACKUP_LIST} ./;
echo "$BACKUP_LIST fetched" | tee -a ../logfile.log;
 
# Init logfile
echo "$(date):" >> logfile.log;
 
#Delete old files
FILES_COUNT=`ls *.tar.gz -1 | wc -l`;
if [ ${FILES_COUNT} -gt ${TAR_FILES_NUM} ];
then
	FILES_TO_DEL=$[${FILES_COUNT} - ${TAR_FILES_NUM}]
	ls *.tar.gz -1 | head -n ${FILES_TO_DEL} | xargs rm;
	echo "Deleted ${FILES_TO_DEL} files" | tee -a logfile.log;
fi
 
# Exit if the backup list file doesn't exist
if [ ! -f "${BACKUP_LIST}" ];
then
	echo "Backup list file doesn't exist" | tee -a logfile.log;
	exit;
fi
 
# Check if this is the first run
if [ -d cur ];
then	
	DATE=$(stamp_to_date $(cat cur/date.txt));
 
	# Check if we are running in a always online machine or
	# the MIN_DAYS have passed or the --force arg is set.
	if [ "$MIN_DAYS" = "0" -o $(days_since $(cat cur/date.txt)) -ge ${MIN_DAYS} -o "${force}" = "yes" ];
	then
		# Check if a backup was taken today
		if [ ! -f "${BACKUP_NAME}-${DATE}.tar.gz" ];
		then
			echo "Creating Tar File..." | tee -a logfile.log;
			tar -czf "${BACKUP_NAME}-${DATE}.tar.gz" cur/*;
			echo "Tar File Creation Finished" | tee -a logfile.log;
		else
			echo "Skiping Tar File Creation" | tee -a logfile.log;
		fi
	else
		echo "${MIN_DAYS} days didn't pass since the last backup" | tee -a logfile.log;
		exit;
	fi
else
	mkdir cur;
fi
 
cd cur;
 
echo `date +%s` > date.txt;
 
echo "Backup Started..." | tee -a ../logfile.log;
rsync ${RSYNC_OPTIONS} --stats --include-from=${BACKUP_DIR}/${BACKUP_LIST} ${USER}@${DOMAIN}:/ ./ | tee -a ../logfile.log;
echo "Backup Finished" | tee -a ../logfile.log;
 
mv ../logfile.log ./;
