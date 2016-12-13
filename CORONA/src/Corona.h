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

#include <net-snmp/net-snmp-config.h>
#include <net-snmp/net-snmp-includes.h>
#include <net-snmp/mib_api.h>

#define MAX_HOST 500
#define PRINT_ERR  0     /* 1 : can Print message 0 : can not */


/* --------------------------------------------------------- * 
 *  Mem Size of Struct host :        -> 4 + 4   =  8byte  
 *                  hosts[MAX_HOST] -> 8 * 200 = 1600byte
 *                  hosts[MAX_HOST] -> 8 * 500 = 4000byte
 * --------------------------------------------------------- */

struct host {
  const char *name;
  const char *community;
} hosts[MAX_HOST] = {
  { "127.0.0.1",	"RCOMSNMP" },
  { NULL }
};

/*
 * a list of variables to query for
 
 -  struct oid {
 -    const char *Name;
 -    oid Oid[MAX_OID_LEN];
 -    int OidLen;
 -  } oids[] = {

**  2016.12 changed ***
 +  struct oid {
 +    const char *Name;
 +    oid Oid[MAX_OID_LEN];
 +    size_t OidLen;
 +  } oids[] = {
 */

struct oid {
  const char *Name;
  oid Oid[MAX_OID_LEN];
  size_t OidLen;
} oids[] = {
  /********************  Rmem **************************************/
  { ".iso.org.dod.internet.private.enterprises.ucdavis.memory.memIndex.0" },
  { ".iso.org.dod.internet.private.enterprises.ucdavis.memory.memErrorName.0" },
  { ".iso.org.dod.internet.private.enterprises.ucdavis.memory.memTotalSwap.0" },
  { ".iso.org.dod.internet.private.enterprises.ucdavis.memory.memAvailSwap.0" },
  { ".iso.org.dod.internet.private.enterprises.ucdavis.memory.memTotalReal.0" },
  { ".iso.org.dod.internet.private.enterprises.ucdavis.memory.memAvailReal.0" },
  { ".iso.org.dod.internet.private.enterprises.ucdavis.memory.memTotalFree.0" },
  { ".iso.org.dod.internet.private.enterprises.ucdavis.memory.memMinimumSwap.0" },
  { ".iso.org.dod.internet.private.enterprises.ucdavis.memory.memShared.0" },
  { ".iso.org.dod.internet.private.enterprises.ucdavis.memory.memBuffer.0" },
  { ".iso.org.dod.internet.private.enterprises.ucdavis.memory.memCached.0" },
  { ".iso.org.dod.internet.private.enterprises.ucdavis.memory.memSwapError.0" },
  { ".iso.org.dod.internet.private.enterprises.ucdavis.memory.memSwapErrorMsg.0" },

  /********************  Tcpu **************************************/
  { ".iso.org.dod.internet.private.enterprises.ucdavis.systemStats.ssSwapIn.0" },
  { ".iso.org.dod.internet.private.enterprises.ucdavis.systemStats.ssSwapOut.0" },
  { ".iso.org.dod.internet.private.enterprises.ucdavis.systemStats.ssIOSent.0" },
  { ".iso.org.dod.internet.private.enterprises.ucdavis.systemStats.ssIOReceive.0" },
  { ".iso.org.dod.internet.private.enterprises.ucdavis.systemStats.ssSysInterrupts.0" },
  { ".iso.org.dod.internet.private.enterprises.ucdavis.systemStats.ssSysContext.0" },
  { ".iso.org.dod.internet.private.enterprises.ucdavis.systemStats.ssCpuUser.0" },
  { ".iso.org.dod.internet.private.enterprises.ucdavis.systemStats.ssCpuSystem.0" },
  { ".iso.org.dod.internet.private.enterprises.ucdavis.systemStats.ssCpuIdle.0" },
  { ".iso.org.dod.internet.private.enterprises.ucdavis.systemStats.ssCpuRawUser.0" },
  { ".iso.org.dod.internet.private.enterprises.ucdavis.systemStats.ssCpuRawNice.0" },
  { ".iso.org.dod.internet.private.enterprises.ucdavis.systemStats.ssCpuRawSystem.0" },
  { ".iso.org.dod.internet.private.enterprises.ucdavis.systemStats.ssCpuRawIdle.0" },
  { ".iso.org.dod.internet.mgmt.mib-2.system.sysDescr.0" },
  { ".iso.org.dod.internet.mgmt.mib-2.interfaces.ifNumber.0" },
  { ".iso.org.dod.internet.mgmt.mib-2.interfaces.ifNumber.1" },

  /********************  TLoad **************************************/
  { ".iso.org.dod.internet.private.enterprises.ucdavis.laTable.laEntry.laLoad.1" },
  { ".iso.org.dod.internet.private.enterprises.ucdavis.laTable.laEntry.laLoad.2" },
  { ".iso.org.dod.internet.private.enterprises.ucdavis.laTable.laEntry.laLoad.3" },

  /********************  TNet **************************************/
  { ".iso.org.dod.internet.mgmt.mib-2.interfaces.ifTable.ifEntry.ifDescr.1" },
  { ".iso.org.dod.internet.mgmt.mib-2.interfaces.ifTable.ifEntry.ifInOctets.1" },
  { ".iso.org.dod.internet.mgmt.mib-2.interfaces.ifTable.ifEntry.ifOutOctets.1" },
  { ".iso.org.dod.internet.mgmt.mib-2.interfaces.ifTable.ifEntry.ifDescr.2" },
  { ".iso.org.dod.internet.mgmt.mib-2.interfaces.ifTable.ifEntry.ifInOctets.2" },
  { ".iso.org.dod.internet.mgmt.mib-2.interfaces.ifTable.ifEntry.ifOutOctets.2" },
  { ".iso.org.dod.internet.mgmt.mib-2.interfaces.ifTable.ifEntry.ifDescr.3" },
  { ".iso.org.dod.internet.mgmt.mib-2.interfaces.ifTable.ifEntry.ifInOctets.3" },
  { ".iso.org.dod.internet.mgmt.mib-2.interfaces.ifTable.ifEntry.ifOutOctets.3" },
  { ".iso.org.dod.internet.mgmt.mib-2.interfaces.ifTable.ifEntry.ifDescr.4" },
  { ".iso.org.dod.internet.mgmt.mib-2.interfaces.ifTable.ifEntry.ifInOctets.4" },
  { ".iso.org.dod.internet.mgmt.mib-2.interfaces.ifTable.ifEntry.ifOutOctets.4" },

  /********************  TState **************************************/
  { ".iso.org.dod.internet.mgmt.mib-2.tcp.tcpActiveOpens.0" },     /*  Counter32: 67860 : SYN-SENT from CLOSED*/
  { ".iso.org.dod.internet.mgmt.mib-2.tcp.tcpPassiveOpens.0" },    /*  Counter32: 86985 : SYN-RCVD from LISTEN */
  { ".iso.org.dod.internet.mgmt.mib-2.tcp.tcpAttemptFails.0" },    /*  Counter32: 199 	*/
  { ".iso.org.dod.internet.mgmt.mib-2.tcp.tcpEstabResets.0" },     /*  Counter32: 0 	*/
  { ".iso.org.dod.internet.mgmt.mib-2.tcp.tcpCurrEstab.0" },       /*  Gauge32: 20 	*/
  /** Is Can Walk Method Only
   .iso.org.dod.internet.mgmt.mib-2.tcp.tcpInErrs.0 = Counter32: 41
   .iso.org.dod.internet.mgmt.mib-2.tcp.tcpOutRsts.0 = Counter32: 25425
  { ".iso.org.dod.internet.mgmt.mib-2.tcp.tcpConnTable.tcpConnEntry.tcpConnState" },
  **/

  { NULL }
};
/** 
    tcpMaxConn :
       "The limit on the total number of TCP connections the entity
            can support.  In entities where the maximum number of
            connections is dynamic, this object should contain the value
   tcpActiveOpens  :
       The number of times TCP connections have made a direct
            transition to the SYN-SENT state from the CLOSED state.
   tcpPassiveOpens :
        The number of times TCP connections have made a direct
            transition to the SYN-RCVD state from the LISTEN state."

   tcpAttemptFails :
        "The number of times TCP connections have made a direct transition to the CLOSED state
           from either the SYN-SENT state or the SYN-RCVD state,
           plus the number of times TCP connections have made a direct transition
             to the LISTEN state from the SYN-RCVD state."
      tcpCurrEstab :
           The number of TCP connections for which the current state
                       is either ESTABLISHED or CLOSE-WAIT.

     tcpEstabResets :
           "The number of times TCP connections have made a direct transition to the CLOSED
               state from either the ESTABLISHED state or the CLOSE-WAIT state."
  ***/

/* ------------------------------------------ *
 * initialize
 * ------------------------------------------ */
void initialize (void)
{
  struct oid *op = oids;
  
  init_snmp("asynchapp");

  /* parse the oids */
  while (op->Name) {
    op->OidLen = sizeof(op->Oid)/sizeof(op->Oid[0]);

    /**********
      * 2000 : 32bit 
       Function in mib_api [ call man mib_api ]
        --> int read_objid(char *input, oid *output, int *out_len);

      * 2010 : 64bit 
      * [/usr/include/net-snmp/mib_api.h:41]
        41:>  int             read_objid(const char *, oid *, size_t *);

        printf("bef : op [%s] [%d] \n", op->Name, op->OidLen );
    *****/

    if (!read_objid(op->Name, op->Oid, &op->OidLen)) {
      snmp_perror("read_objid");
      exit(1);
    }
    op++;
  }
}

/* ------------------------------------------ *
 * simple printing of returned data
 * ------------------------------------------ */
int print_result (int status, struct snmp_session *sp, struct snmp_pdu *pdu)
{
  char buf[1024];
  struct variable_list *vp;
  int ix;
  struct timeval now;
  struct timezone tz;
  struct tm *tm;

  gettimeofday(&now, &tz);
  tm = localtime(&now.tv_sec);
  /***
  fprintf(stdout, "%.2d:%.2d:%.2d.%.6d ", tm->tm_hour, tm->tm_min, tm->tm_sec, now.tv_usec);
  ****/
  fprintf(stdout, "%4d-%02d-%02d %.2d:%.2d:%.2d ",
               tm->tm_year + 1900, tm->tm_mon + 1, tm->tm_mday, tm->tm_hour, tm->tm_min, tm->tm_sec );
  switch (status) {
  case STAT_SUCCESS:
    vp = pdu->variables;
    if (pdu->errstat == SNMP_ERR_NOERROR) {
      while (vp) {
        snprint_variable(buf, sizeof(buf), vp->name, vp->name_length, vp);
        if (PRINT_ERR )
          fprintf(stderr, "peername:[%s]value:=[%s]\n", sp->peername, buf);
        fprintf(stdout, "%s %s\n", sp->peername, buf);
	vp = vp->next_variable;
      }
    }
    else {
      for (ix = 1; vp && ix != pdu->errindex; vp = vp->next_variable, ix++)
        ;
      if (vp)
          snprint_objid(buf, sizeof(buf), vp->name, vp->name_length);
      else
          strcpy(buf, "(none)");
      fprintf(stdout, "%s %s %s\n", sp->peername, buf, snmp_errstring(pdu->errstat));
    }
    return 1;
  case STAT_TIMEOUT:
    fprintf(stdout, "%s Timeout\n", sp->peername);
    return 0;
  case STAT_ERROR:
    snmp_perror(sp->peername);
    return 0;
  }
  return 0;
}

/*****************************************************************************/

/* ------------------------------------------ *
 * simple synchronous loop
 * ------------------------------------------ */
 
void synchronous (void)
{
  struct host *hp;

  for (hp = hosts; hp->name; hp++) {
    struct snmp_session ss, *sp;
    struct oid *op;

    snmp_sess_init(&ss);			/* initialize session */
    ss.version = SNMP_VERSION_2c;
    ss.peername = strdup(hp->name);
    ss.community = strdup(hp->community);
    ss.community_len = strlen(ss.community);
    if (!(sp = snmp_open(&ss))) {
      snmp_perror("snmp_open");
      continue;
    }
    for (op = oids; op->Name; op++) {
      struct snmp_pdu *req, *resp;
      int status;
      req = snmp_pdu_create(SNMP_MSG_GET);
      snmp_add_null_var(req, op->Oid, op->OidLen);
      status = snmp_synch_response(sp, req, &resp);
      if (!print_result(status, sp, resp)) break;
      snmp_free_pdu(resp);
    }
    snmp_close(sp);
  }
}

/*****************************************************************************/

/*
 * poll all hosts in parallel
 */
struct session {
  struct snmp_session *sess;		/* SNMP session data */
  struct oid *current_oid;		/* How far in our poll are we */
} sessions[sizeof(hosts)/sizeof(hosts[0])];

int active_hosts;			/* hosts that we have not completed */

/*
 * response handler
 */
int asynch_response(int operation, struct snmp_session *sp, int reqid,
		    struct snmp_pdu *pdu, void *magic)
{
  struct session *host = (struct session *)magic;
  struct snmp_pdu *req;

  if (operation == NETSNMP_CALLBACK_OP_RECEIVED_MESSAGE) {
    if (print_result(STAT_SUCCESS, host->sess, pdu)) {
      host->current_oid++;			/* send next GET (if any) */
      if (host->current_oid->Name) {
	req = snmp_pdu_create(SNMP_MSG_GET);
	snmp_add_null_var(req, host->current_oid->Oid, host->current_oid->OidLen);
	if (snmp_send(host->sess, req))
	  return 1;
	else {
	  snmp_perror("snmp_send");
	  snmp_free_pdu(req);
	}
      }
    }
  }
  else
    print_result(STAT_TIMEOUT, host->sess, pdu);

  /* something went wrong (or end of variables) 
   * this host not active any more
   */
  active_hosts--;
  return 1;
}

void asynchronous(void)
{
  struct session *hs;
  struct host *hp;

  /* startup all hosts */

  for (hs = sessions, hp = hosts; hp->name; hs++, hp++) {
    struct snmp_pdu *req;
    struct snmp_session sess;
    snmp_sess_init(&sess);			/* initialize session */
    sess.version = SNMP_VERSION_2c;
    sess.peername = strdup(hp->name);
    sess.community = strdup(hp->community);
    sess.community_len = strlen(sess.community);
    sess.callback = asynch_response;		/* default callback */
    sess.callback_magic = hs;
    if (!(hs->sess = snmp_open(&sess))) {
      snmp_perror("snmp_open");
      continue;
    }
    hs->current_oid = oids;
    req = snmp_pdu_create(SNMP_MSG_GET);	/* send the first GET */
    snmp_add_null_var(req, hs->current_oid->Oid, hs->current_oid->OidLen);
    if (snmp_send(hs->sess, req))
      active_hosts++;
    else {
      snmp_perror("snmp_send");
      snmp_free_pdu(req);
    }
  }

  /* loop while any active hosts */

  while (active_hosts) {
    int fds = 0, block = 1;
    fd_set fdset;
    struct timeval timeout;

    FD_ZERO(&fdset);
    snmp_select_info(&fds, &fdset, &timeout, &block);
    fds = select(fds, &fdset, NULL, NULL, block ? NULL : &timeout);
    if (fds) snmp_read(&fdset);
    else snmp_timeout();
  }

  /* cleanup */

  for (hp = hosts, hs = sessions; hp->name; hs++, hp++) {
    if (hs->sess) snmp_close(hs->sess);
  }
}

/*****************************************************************************/

/* ------------------------------------------------- *
 *  SAMPLE Main in Corona.c
 * ------------------------------------------------- *

int main (int argc, char **argv)
{

  initialize();

  printf("---------- asynchronous2-----------\n");
  asynchronous();
  printf("---------- synchronous1-----------\n");
  synchronous();

  return 0;
}
* ------------------------------------------------- */

