

if [[ -f "/usr/bin/rrdtool" &&  -f "/usr/include/rrd.h" ]]
then

   echo " --------------------------------------------- "
   echo " >>>>  Install RRD Tools  already exists !! "
   echo " --------------------------------------------- "

else
   echo " --------------------------------------------- "
   echo " >>>>> Install RRD Tools  start"
   echo " --------------------------------------------- "

   # yum install  -y  rrdtool rrdtool-devel 

   Ret=$?

   echo " --------------------------------------------- "
   echo " >>>>  Install RRD Tools  End !! Ret[$Ret]  "
   echo " --------------------------------------------- "
   
fi
