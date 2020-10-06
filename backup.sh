#!/bin/bash
BACKUP_PATH="/media/Passport"
BACKUP_LOG_FOLDER="backuplog"
BACKUP_LOG_PATH="$BACKUP_PATH/$BACKUP_LOG_FOLDER"

MAX_LOGS=14
MAX_DAILY_BACKUPS=14

[ ! -d "$BACKUP_LOG_PATH" ] && mkdir $BACKUP_LOG_PATH
[ ! -d "$BACKUP_PATH" ] && mkdir $BACKUP_PATH

thislog="$BACKUP_LOG_PATH/backup.0.log"

i=$((MAX_LOGS));
while (( $i >= 0 ))
do
#	echo $i
	next=$((i+1));
	[ -f "$BACKUP_LOG_PATH/backup.$i.log" ] && mv $BACKUP_LOG_PATH/backup.$i.log $BACKUP_LOG_PATH/backup.$next.log
	((i--))
done

overmaxlogs=$((MAX_LOGS+1));
[ -f "$BACKUP_LOG_PATH/backup.$overmaxlogs.log" ] && rm $BACKUP_LOG_PATH/backup.$overmaxlogs.log

i=$((MAX_DAILY_BACKUPS));
while (( $i >= 0 ))
do
	next=$((i+1));
	[ -d "$BACKUP_PATH/daily.$i" ] && echo "Rotating $BACKUP_PATH/daily.$i" >> $thislog && mv $BACKUP_PATH/daily.$i $BACKUP_PATH/daily.$next
	((i--))
done


[ ! -d "$BACKUP_PATH/daily.0" ] && mkdir $BACKUP_PATH/daily.0


echo "Beginning backup at $(date)" >> $thislog
echo "Creating backup $BACKUP_PATH/daily.0" >> $thislog

nohup rsync -aunAXv --delete --exclude-from='./exclude.txt' --exclude '$BACKUP_LOG_PATH/*' --exclude '$BACKUP_PATH/*' / $BACKUP_PATH/daily.0 >> $thislog &

echo "Finished backup at $(date)" >> $thislog

exit 0
