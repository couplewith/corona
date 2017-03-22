#!/usr/bin/perl
#############################################################
##   RRD GRAPH Ver 3.0 ( Perl version 3.0 )
##      Made by Choi doo rip In Seoul Korea
##      couplewith@hanmail.net
##
##  Contents : HTMLS Genterate Module in 2003.06
#############################################################

require "/svc/web_app/CORONA/bin/Gen_img.pm";

#===================================================================
#  FIRST STEP  With SNMP Call  and Genterate  SNMP LOG
#===================================================================

# READ Config File Check SECTION
#------------------------------------------------------------------

$coronafile = "../conf/corona.conf";
$rrdconfig  = "../conf/rrdsnmp.conf";

if ( ! -r $coronafile ) {
   print " Config File Not Found [corona.conf] \n"; 
   exit;
}

if ( ! -r $rrdconfig ) {
   print " Config File Not Found [rrdsnmp.conf] \n"; 
   exit;
}



&readconf ( $rrdconfig );


#  READ INPUT Stream With  SNMP LOG 
#------------------------------------------------------------------
$Fcnt=0;
$coronafile = "../conf/corona.conf";

open(CONF ,$coronafile) || (print("Could not find $$coronafile ($!)\n") && exit(1));
while(<CONF>) {
    if ( ( $_ =~ /^[0-9]/) ) {
        chomp($_);
        $Fcnt ++;
        @splited=split(" ","$_"); # divide pelos 2 pontos
        $k_hostip = $splited[0];
        $k_hostname = $splited[1];
        $Corona_host->{$k_hostname} = $k_hostip;
    }
}

if ( $Fcnt < 1 ){
    print STDERR " Can not Read [$coronafile] CONFIG !! \n";
    exit;
}



# MAIN SECTION
#------------------------------------------------------------------
   my ( $c_hname );

   %c_Corona_host = %{$Corona_host}; 
   printf STDOUT " RRD_GENHTML Corona v3.0 START\n";
   #============================================================

   if (!defined($kidpid = fork())) {
       # fork returned undef, so failed
       die "GENHTML : cannot fork: $! ";
   } elsif ($kidpid == 0) {
       # fork returned 0, so this branch is the child
       foreach $c_hname (sort keys %c_Corona_host )
       {
           &RRD_GENHTML( $c_hname,  $rrdtool, $RRDDATA, ${IMGDIR}); 
       }
       exec('sleep 1');
   } else {
           # fork returned neither 0 nor undef,
           # so this branch is the parent
            waitpid($kidpid, 0);
   }
   printf STDOUT " RRD_GENHTML Corona v3.0 END\n";

   exit;
