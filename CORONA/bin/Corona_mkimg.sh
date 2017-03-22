#-----Cron for Corona  V2.1
#---------------------------
cd /svc/web_app/CORONA/bin
LOG=`date +"%Y%m%d"`
LOGFILE="../logs/Cron.dat.${LOG}";
LDATE=`date +"%Y%m%d %H:%M"`

export LANG=C

#== Get RRD data and Generate image
./Gen_img.pl  >/dev/null

echo " GenIMG : $SECONDS " >> $LOGFILE;

