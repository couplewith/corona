gcc -o $1 $1.c -L/usr/local/lib -lnetsnmp -lcrypto -lm

if [ -e $1 ]
then
   echo "Compile $1  was Complete !!";
   cp Corona ../bin;
else
   echo "Compile $1 was UnComplete !!";
fi
