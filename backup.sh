#!/bin/bash
BACKUP_PATH="/media/Passport"
BACKUP_LOG_FOLDER="backuplog"
BACKUP_LOG_PATH="$BACKUP_PATH/$BACKUP_LOG_FOLDER"

MAX_LOGS=7
MAX_DAILY_BACKUPS=7
MAX_MONTHLY_BACKUPS=12
MAX_YEARLY_BACKUPS=5

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
	[ -d "$BACKUP_PATH/daily.$i" ] && echo "Rotating $BACKUP_LOG_PATH/daily.$i" >> $thislog && mv $BACKUP_PATH/daily.$i $BACKUP_PATH/daily.$next
	((i--))
done

i=$((MAX_MONTHLY_BACKUPS));
while (( $i >= 0 ))
do
	next=$((i+1));
	[ -d "$BACKUP_PATH/monthly.$i" ] && echo "Rotating $BACKUP_LOG_PATH/monthly.$i" >> $thislog  && mv $BACKUP_PATH/monthly.$i $BACKUP_PATH/monthly.$next
	((i--))
done

i=$((MAX_YEARLY_BACKUPS));
while (( $i >= 0 ))
do
	next=$((i+1));
	[ -d "$BACKUP_PATH/yearly.$i" ] && echo "Rotating $BACKUP_LOG_PATH/yearly.$i" >> $thislog  && mv $BACKUP_PATH/yearly.$i $BACKUP_PATH/yearly.$next
	((i--))
done

overmaxyearly=$((MAX_YEARLY_BACKUPS+1));
[ -d "$BACKUP_PATH/yearly.$overmaxyearly" ] && rm -rf $BACKUP_PATH/yearly.$overmaxyearly

overmaxmonthly=$((MAX_MONTHLY_BACKUPS+1));
[ -d "$BACKUP_PATH/monthly.$overmaxmonthly" ] && mv $BACKUP_PATH/monthly.$overmaxmonthly $BACKUP_PATH/yearly.0

overmaxdaily=$((MAX_DAILY_BACKUPS+1));
[ -d "$BACKUP_PATH/daily.$overmaxdaily" ] && mv $BACKUP_PATH/daily.$overmaxdaily $BACKUP_PATH/monthly.0

[ -d "$BACKUP_PATH/daily.1" ] && cp -al $BACKUP_PATH/daily.1 $BACKUP_PATH/daily.0

[ ! -d "$BACKUP_PATH/daily.0" ] && mkdir $BACKUP_PATH/daily.0


echo "Beginning backup at $(date)" >> $thislog
echo "Creating backup $BACKUP_PATH/daily.0" >> $thislog

nohup rsync -aunAXv --delete --exclude-from='./exclude.txt' --exclude '$BACKUP_LOG_PATH/*' --exclude '$BACKUP_PATH/*' / $BACKUP_PATH/daily.0 >> $thislog &

echo "Finished backup at $(date)" >> $thislog

exit 0
