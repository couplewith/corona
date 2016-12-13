/*---------------------------------------------------------------------
 * NET-SNMP Corona Ver 2.0
 * It was modified by Couplewith in Seoul Korea !!.
 *
 * This program demonstrates different ways to query a list of hosts
 * for a list of variables.
 *
 * It would of course be faster just to send one query for all variables,
 * but the intention is to demonstrate the difference between synchronous
 * and asynchronous operation.
 *
 * Niels Baggesen (Niels.Baggesen@uni-c.dk), 1999.
 * couplewith (choi.doo.rip couplewith@yahoo.co.kr) 2003.06
  -------------------------------------------------------------------
 * Compile  : gcc -o $1 $1.c -L/usr/local/lib -lnetsnmp -lcrypto -lm
 * PreRequirement ->
     Net-snmp-developmentkit
 * Changes ->
    2003 06 23 : Original Allocation Complete !!. by couplewith
 *---------------------------------------------------------------------*/

#include <string.h>
#include "Corona.h"

#define PRINT_DEBUG 1             

/*****************************************************************************/

int main (int argc, char **argv)
{
   /****  Variables Declare !! ***********/
   /*----------------------------------------------------*/
    FILE *rconfp;
    int hi, j, Ecode;
    char conf_file[128] = { "../conf/corona.conf" };
    char *sp;

    char hip[128];
    char hname[128];
    char hcommunity[128];
    char hos[128];
  
   /****  Read Target Hosts & Set variables !! ***********/
   /*----------------------------------------------------*/
    if( (rconfp = fopen(conf_file, "r") ) == NULL)
    {
          fprintf(stderr, "Config read err! : File [%s] is open error\n", conf_file);
          fclose(rconfp);
          return(0);
    }
  
    /*  ( fgets(Rbuff, MAXDATA, fp)) */
    /* hosts[] = { { NULL } };        */

    hi = 0; 
    while( (Ecode = fscanf(rconfp, "%s %s %s %s \n", hip, hname, hcommunity, hos )) > 0 )
    { 

       // Skipp for # 
       sp = index(hip , '#');
       if ( sp > 0 ) continue;

       if ( PRINT_DEBUG){
         fprintf (stderr," >> %d [%d]: spoint[%d] ip:[%s] hname:[%s] hcomm:[%s] hos:[%s] \n",Ecode,hi, sp,  hip, hname, hcommunity, hos );
       }
       
       hosts[hi].name = strdup(hname);  // query by HostName
   //  hosts[hi].name = strdup(hip);    // query by HostIP 
       hosts[hi].community = strdup(hcommunity);
       hi++;
    } 
  
   /****  Check Set variables !! ***********/
   /*----------------------------------------------------*/
    if(PRINT_DEBUG){
       fprintf(stderr,"SIZE OF host  : hosts [%d] / struct host [%d] \n",sizeof(hosts), sizeof( struct host ));
    }

    for (j=0 ; j<hi ; j++)
    {
       if ( PRINT_DEBUG)
          fprintf (stderr," LAST    : %s %s \n", hosts[j].name, hosts[j].community  );
    }
  
   /****  Start Call Engine !! ***********/
    initialize();
  
    /*
    fprintf(stderr,"---------- synchronous1-----------\n");
      synchronous();
    */

    fprintf(stderr,"---------- Asynchronous2-----------\n");
    asynchronous();
  
    return 0;
}
 
 
