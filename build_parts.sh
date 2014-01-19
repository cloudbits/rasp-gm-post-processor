#!/bin/bash
# Version 2 with support for right number of forward hours
HOMEDIR=/home/rasp/WRF/GM-TEST

if [ ! -f $HOMEDIR/ncl_jack_fortran.so ]
then
	echo $(date): Have you run ./install.sh\?
	exit
fi
grep 'YYYY' $HOMEDIR/test.sh | grep -v grep > /dev/null
if [ $? == 0 ]
then
	echo $(date): Have you adjusted ENV_NCL_FILENAME in test.sh\?
	exit
fi

echo ""
echo "$(date): If you have added Hendrik's rain patch to rasp.site_load.contour-parameters.ncl"
echo "$(date): Comment out this code or wrf2gm will bomb - it is built in"
echo ""
# -----------------------------------------------------------------------------
# Function to cal hour ahead
#	input mode land hour period
calc_hours_ahead()
{
	MODEL=$1
	HOUR_AHEAD=$2
	R_TIME=0

	#check the hour we've got
	case $HOUR_AHEAD in
	06:00)
		R_TIME=6
		;;
	07:00)
		R_TIME=7
		;;
	08:00)
		R_TIME=8
		;;
	09:00)
		R_TIME=9
		;;
	10:00)
		R_TIME=10
		;;
	11:00)
		R_TIME=11
		;;
	12:00)
		R_TIME=12
		;;
	13:00)
		R_TIME=13
		;;
	14:00)
		R_TIME=14
		;;
	15:00)
		R_TIME=15
		;;
	16:00)
		R_TIME=16
		;;
	17:00)
		R_TIME=17
		;;
	18:00)
		R_TIME=18
		;;
	19:00)
		R_TIME=19
		;;
	*)
		echo ""
		echo "$HOUR_AHEAD not found - using default of zero ..."
		R_TIME=0
	esac
	# now check the model
	# UK2 = 0, +1=24, +2=48, +3=72, +4=96, +5=120, +6=144
	case $MODEL in
	UK2)
		RESULT=`expr $R_TIME + 0`
		echo $RESULT
		;;
	UK2+1)
		RESULT=`expr $R_TIME + 24`
		echo $RESULT
   		;;
	UKEA62+1)
		RESULT=`expr $R_TIME + 24`
		echo $RESULT
   		;;
	UK4+1)
		RESULT=`expr $R_TIME + 24`
		echo $RESULT
   		;;
	UK12+3)
		RESULT=`expr $R_TIME + 72`
		echo $RESULT
   		;;
	UK12+5)
		RESULT=`expr $R_TIME + 120`
		echo $RESULT
   		;;
	*)
   		echo ""
   		echo "No model found - using default of zero ..."
		echo "0"
   		;;
	esac
}
# -----------------------------------------------------------------------------
# Function needs to know the hour it is to be used for ...
build_an_hour()
{
	# THIS CODE REQUIRES NCL V6
	# Version 5 (as supplied with RASP) *will not work*
	# NCL V6 is usually  available in the distros
	# NCARG_ROOT may well then be
	#./usr/share/ncarg/nclscripts/csm/contributed.ncl
	NCARG_ROOT=/usr
	export NCARG_ROOT

	export NCARG_FONTCAPS=/usr/lib64/ncarg/fontcaps
	export LD_LIBRARY_PATH=/home/rasp/UTIL/PGI:/home/rasp/UTIL/NCARG/:/home/rasp/usr/lib
	export NCARG_RANGS=/home/rasp/UTIL/NCARG/lib/ncarg/database/rangs
	export NCARG_GRAPHCAPS=/usr/lib64/ncarg/graphcaps
	export NCARG_DATABASE=/usr/lib64/ncarg/database
	export NCARG_LIB=/usr/lib64/ncarg
	export NCARG_NCARG=/usr/share/ncarg
	export NETCDF=/home/rasp/UTIL/NETCDF


	# You may need to specify the NCL_COMMAND, if not on your $PATH
	#NCL_COMMAND=$NCARG_ROOT/bin/ncl
	NCL_COMMAND=/usr/bin/ncl
	export NCL_COMMAND

	# Specify Output Image Size
	export GMIMAGESIZE=1600
	# export GMIMAGESIZE=800        # good for FMT=x11

	# Set the o/p format to "x11", "png" or "ncgm"
	# Should be lower-case
	# Choose ONE only!
	# export FMT="x11"
	# export FMT="png"      # (Default)
	# export FMT="ncgm"     # Not really supported (Who wants it?)

	# You can specify PROJECTION to be Lambert, in which case o/p is same as RASP
	# Useful as a test.
	export PROJECTION="Mercator" # Default
	# export PROJECTION="Lambert"
	
	#export NCARG_GRAPHCAPS=/usr/lib64/ncarg/graphcaps
	BASEDIR=/home/rasp
	export BASEDIR

	export RUNDIR=$BASEDIR/WRF/GM-TEST

	T_HOUR=$1
	T_DAY=$2
	R_MODEL=$3
	T_HOURS_AHEAD=$(calc_hours_ahead $R_MODEL $T_HOUR)
	echo "$(date): --------------------------------------------------------------------------------" >> $4
	echo "$(date): Starting period $1 for day $2 at $(date) for period $T_HOURS_AHEAD"
	echo "$(date): Starting period $1 for day $2 at $(date)" >> $4
	echo "$(date): --------------------------------------------------------------------------------" >> $4

	# To test a single ENV_NCL_FILENAME, specify here
	export ENV_NCL_FILENAME="$BASEDIR/WRF/WRFV2/RASP/$3/wrfout_d02_$2_$T_HOUR:00"

	echo "$(date): Using this wrf output file ...$ENV_NCL_FILENAME" >> $4

	# But don't change this - unless you want to explicitly specify it
	export ENV_NCL_REGIONNAME=`echo $ENV_NCL_FILENAME | sed -e 's/.*RASP\///' | sed -e 's/\/.*//'`
	echo "$(date): Using $ENV_NCL_REGIONNAME" >> $4

	# Build ENV_NCL_ID (as far as possible)
	FILEDATE=`echo $ENV_NCL_FILENAME | cut -d _ -f 3`
	FILETIME=`echo $ENV_NCL_FILENAME | cut -d _ -f 4`
	localhh=`echo $FILETIME | cut -d : -f 1`
	localmin=`echo $FILETIME | cut -d : -f 2`
	localdow=`date -d $FILEDATE +%a`
	localday=`date -d $FILEDATE +%-d`
	localmon=`date -d $FILEDATE +%b`
	localyyyy=`date -d $FILEDATE +%Y`
	localtimeid=`date -d $FILEDATE +%Z`
	filehh=`date -u -d $FILETIME +%H`
	filemin=`date -u -d $FILETIME +%M`
	file_creat_hr=`ls -l --time-style="+%H" $ENV_NCL_FILENAME | cut -d " " -f 6`
	file_creat_mn=`ls -l --time-style="+%M" $ENV_NCL_FILENAME | cut -d " " -f 6`

        echo "$(date): Using $FILEDATE"  >> $4
        echo "$(date): Using $FILETIME" >> $4
        echo "$(date): Using $localhh" >> $4
        echo "$(date): Using $localmin" >> $4
        echo "$(date): Using $localdow" >> $4
        echo "$(date): Using $localday"  >> $4
        echo "$(date): Using $localmon"  >> $4
        echo "$(date): Using $localyyyy" >> $4
        echo "$(date): Using $localtimeid" >> $4
        echo "$(date): Using $filehh"  >> $4
        echo "$(date): Using $filemin"  >> $4
        echo "$(date): Using $file_creat_hr" >> $4
        echo "$(date): Using $file_creat_mn" >> $4

	# These cannot be filled in from a test script: In normal operation, rasp.pl supplies values
	#fcstperiodprt='??'
	#ztime='????'
	#FcstPeriod=$((localhh - file_create_hr))
	#echo $localhh
	#echo $file_create_hr
	#echo $FcstPeriod
	#fcstperiodprt=$FcstPeriod
	fcstperiodprt=$T_HOURS_AHEAD
	ztime=$file_creat_hr$file_creat_mn
	TIME_NOW=`date -d 'now' +%b%d-%H%M`

	ENV_NCL_ID=`printf "Valid %s%s %s ~Z75~(%s%sZ)~Z~ %s %s %s %d ~Z75~[%shrFcst@%sz][%s]~Z~" \
  $localhh $localmin $localtimeid $filehh $filemin $localdow $localday $localmon $localyyyy $fcstperiodprt $ztime $TIME_NOW`

	export ENV_NCL_ID
	echo "$(date): Using $ENV_NCL_ID" >> $4
	echo "$(date): Using $ENV_NCL_ID" 

	# If using ENV_NCL_FILENAME=... you may wish to set UNITS=celsius|metric|american
	# UNITS="american" is default, to maintain compatibility with RASP
	# export UNITS="celsius"
	# Otherwise, Units are taken from rasp.region_data.ncl if a ENV_NCL_REGIONNAME is specified
	# NB rasp.region_data is linked to ../NCL/rasp.ncl.region.data 

	# To do all parameters for all files for a run, specify ENV_NCL_REGIONNAME
	# All wrfout_d02* files in $BASEDIR/WRF/WRFV2/RASP/$ENV_NCL_REGIONNAME are processed

	# PARAMETERS
	# NB: Soundings *MUST* be last
	# This is a bug, which I have not been able to fix - even with the help of ncl-talk!
	# RASP puts Soundings at the end, so all should be well (?)

	# This is a fairly full set (uncomment each line)
	#export ENV_NCL_PARAMS="wstar"
	export ENV_NCL_PARAMS="mslpress:sfcwind0:sfcwind:sfcwind2:blwind:\
bltopwind:dbl:experimental1:sfctemp:zwblmaxmin:blicw:hbl:hwcrit:\
dwcrit:wstar:bsratio:sfcshf:zblcl:zblcldif:zblclmask:blcwbase:\
press1000:press950:press850:press700:press500:bltopvariab:wblmaxmin:\
zwblmaxmin:blwindshear:sfctemp:sfcdewpt:cape:rain1:wrf=HGT:\
wstar_bsratio:bsratio_bsratio:blcloudpct:sfcsunpct:zsfclcl:zsfclcldif:\
zsfclclmask:hglider:stars:sounding1:sounding2:sounding3:sounding4:sounding5:\
sounding6:sounding7:sounding8:sounding9:sounding10:sounding11:sounding12:\
sounding13:sounding14:sounding15"

        echo "$(date): Using $ENV_NCL_PARAMS" >> $4

	# Overide Params with cmd-line args
	# Can be space-separated OR ":" separated
	#if [ $# -gt 0 ]
	#then
#		ENV_NCL_PARAMS=`echo $* | sed -e 's/ /:/g'`
#		export ENV_NCL_PARAMS
#	fi

#        echo "Using last $ENV_NCL_PARAMS"
	# To use the NCL supplied wrf_user_getvar() select NCL below.
	# However, *note carefully* DrJack's observations about "mass" and "grid" points
	# and "staggered" and "unstaggered" grids, to be found at 
	# http://www.drjack.info/twiki/bin/view/RASPop/AdvancedPlotting

	# export GETVAR=DRJACK # Default
	# export GETVAR=NCL

	# For use with RASP, set ENV_NCL_OUTDIR as below (rasp.pl sets this)
	# export ENV_NCL_OUTDIR=$BASEDIR/RASP/HTML/$ENV_NCL_REGIONNAME/GM

	# To test for differences between NCL & DrJack's wrf_user_getvar()
	# you may wish to set ENV_NCL_OUTDIR as below

	# if [ $GETVAR == "DRJACK" ]
	# then
	# 	export ENV_NCL_OUTDIR=./DrJack
	# else
	# 	export ENV_NCL_OUTDIR=./NCL
	# fi

	# Ensure Output Directories exist
	if [ ! -d $ENV_NCL_OUTDIR ]
	then
		mkdir -p $ENV_NCL_OUTDIR
	fi

	#remove any existing files for this period
	#rm $ENV_NCL_OUTDIR/*$localhh$localmin*.png

	# Finally!!
	$NCL_COMMAND -n -p $HOMEDIR/wrf2gm.ncl >> $4

}
# end build_hour  -------------------------------------------------------------
# -----------------------------------------------------------------------------
#set this directory as the home so other scripts get found
cd $HOMEDIR
TODAY=`date '+%Y-%m-%d'`
LOGDIR=$HOMEDIR/log
LOGFILE=$LOGDIR/build_all-$TODAY-$2-$1.log
ERRLOGFILE=$LOGDIR/build_all_err$TODAY-$2-$1.txt

if [ "$2" == "UK2" ]
then
	THEDAY=`date '+%Y-%m-%d'`
elif [ "$2" == "UK2+1" ]
then
	THEDAY=`date --date tomorrow '+%Y-%m-%d'`
elif [ "$2" == "UK12+3" ]
then
	THEDAY=`date --date '3 day' '+%Y-%m-%d'`
elif [ "$2" == "UK12+5" ]
then
	THEDAY=`date --date '5 day' '+%Y-%m-%d'`
elif [ "$2" == "UKEA62+1" ]
then
	THEDAY=`date --date '1 day' '+%Y-%m-%d'`
else
	echo "No model or region given - use UK2, UK2+1, UK12+3, UK12+5 or UKEA62+1" 2>> $ERRLOGFILE
	exit
fi

OUTPUTDIR=/home/rasp/WRF/GM-TEST/OUT/$2
export ENV_NCL_OUTDIR=$OUTPUTDIR

echo "$(date): Started run at $(date) for the forecast day of $THEDAY for model $2 ...."
echo "$(date): Started run at $(date) for the forecast day of $THEDAY for model $2 ...." > $LOGFILE
echo "$(date): Using $OUTPUTDIR as the folder for the output" >> $LOGFILE

#if we are passed a parameter, check if 1/2/3/4
if [ $# -gt 0 ]
then
	if [ $1 -eq 1 ]
	then
		# do the first three periods8yy
		for T_PERIOD in 07:00 10:00 13:00 
		do
			echo "$(date): Building  hour $T_PERIOD" >> $LOGFILE
			build_an_hour $T_PERIOD $THEDAY $2 $LOGFILE
			# now copy the files over ....
			$HOMEDIR/rsync.gm.sh $2 & >> $LOGFILE 2>> $ERRLOGFILE
		done
	elif [ $1 -eq 2 ]
	then
		# do the next three periods
		for T_PERIOD in 08:00 11:00 14:00 
		do
			echo "$(date): Building  hour $T_PERIOD" >> $LOGFILE
			build_an_hour $T_PERIOD $THEDAY $2 $LOGFILE
			# now copy the files over ....
			$HOMEDIR/rsync.gm.sh $2 & >> $LOGFILE 2>> $ERRLOGFILE
		done
	elif [ $1 -eq 3 ]
	then
		# do periods
		for T_PERIOD in 09:00 12:00 18:00 
		do
			echo "$(date): Building  hour $T_PERIOD" >> $LOGFILE
			build_an_hour $T_PERIOD $THEDAY $2 $LOGFILE
			# now copy the files over ....
			$HOMEDIR/rsync.gm.sh $2 & >> $LOGFILE 2>> $ERRLOGFILE
		done
	elif [ $1 -eq 4 ]
	then
		# do periods
		for T_PERIOD in 15:00 16:00 17:00 
		do
			echo "$(date): Building  hour $T_PERIOD" >> $LOGFILE
			build_an_hour $T_PERIOD $THEDAY $2 $LOGFILE
			# now copy the files over .... 
			$HOMEDIR/rsync.gm.sh $2 & >> $LOGFILE 2>> $ERRLOGFILE
		done
	else
		echo "Note sure what I can do with: $1"
	fi
else
	echo "Specifiy 1,2,3,4 to run a block of NCL commands" 2>> $ERRLOGFILE
fi

echo "$(date): Finished run at $(date)"
echo "$(date): Finished run at $(date)" >> $LOGFILE
