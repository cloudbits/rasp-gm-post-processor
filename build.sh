#!/bin/bash
HOMEDIR=/home/rasp/WRF/GM-TEST
LOGDIR=$HOMEDIR/log
NOW=$(date)
TODAY=`date '+%Y-%m-%d'`
LOGFILE=$LOGDIR/build_all.txt
ERRLOGFILE=$LOGDIR/build_all_err.txt
#move log files t oarchive folder
mv $LOGDIR/*-$1-*log $LOGDIR/archive
#now start things ...
echo "Started build_all.sh at $NOW" >> $LOGFILE
CMD1="$HOMEDIR/build_parts.sh 1 $1 > $1-1-$TODAY.txt 2>$ERRLOGFILE"
echo "Now running '$CMD1'"
$CMD1 &
CMD2="$HOMEDIR/build_parts.sh 2 $1 > $1-2-$TODAY.txt 2>$ERRLOGFILE"
echo "Now running '$CMD2'"
$CMD2 &
CMD3="$HOMEDIR/build_parts.sh 3 $1 > $1-3-$TODAY.txt 2>$ERRLOGFILE"
echo "Now running '$CMD3'"
$CMD3 &
CMD4="$HOMEDIR/build_parts.sh 4 $1 > $1-4-$TODAY.txt 2>$ERRLOGFILE"
echo "Now running '$CMD4'"
$CMD4 &
#$HOMEDIR/build_parts.sh 1 $1 > $LOGFILE_$1_1_$TODAY.txt &
#$HOMEDIR/build_parts.sh 2 $1 > $LOGFILE_$1_2_$TODAY.txt &
#$HOMEDIR/build_parts.sh 3 $1 > $LOGFILE_$1_3_$TODAY.txt &
#$HOMEDIR/build_parts.sh 4 $1 > $LOGFILE_$1_4_$TODAY.txt &
TODAY=`date '+%Y-%m-%d'`
echo "Finished build_all.sh at $NOW" >> $LOGFILE
