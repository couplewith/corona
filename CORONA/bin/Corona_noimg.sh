#-----Cron for Corona  V2.1
#---------------------------
cd /svc/web_app/CORONA/bin
LOG=`date +"%Y%m%d"`
LOGFILE="../logs/Cron.dat.${LOG}";
LDATE=`date +"%Y%m%d %H:%M"`

export LANG=C

#== Get Remote Servers Status and Save into RRD.
./Corona 2>/dev/null | ./Get_log.pl  >/dev/null
echo -n "$LDATE : Query $SECONDS  / " >> $LOGFILE;

echo " GenIMG : $SECONDS " >> $LOGFILE;

