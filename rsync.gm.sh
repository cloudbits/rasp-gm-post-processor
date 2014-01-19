#!/bin/sh
HOMEDIR=/home/rasp
MODEL=$1
#should check we get a model to copy ...
        rsync -u -e 'ssh -p 8022' $HOMEDIR/WRF/GM-TEST/OUT/$MODEL/*.png rasp@192.168.1.1:$HOMEDIR/wx/gm/$MODEL/FCST/GM &
        #rsync -u -e 'ssh' $HOMEDIR/WRF/GM-TEST/*.png rasp@rasp-g5-02:$HOMEDIR/wx/gm &

