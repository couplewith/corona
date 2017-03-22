#!/usr/bin/perl
#############################################################
##   RRD GRAPH Ver 3.1 ( Perl version 3.1 )
##      Made by Choi doo rip In Seoul Korea
##      couplewith@hanmail.net
##
##  Contents : Graph Genterate Module  in 2003.06
##              Modify PERL::Gen image 2007.07
#############################################################

use lib qw( /svc/web_app/CORONA/bin );
require "Gen_img.pm";
require "Gen_Util.pm";

#===================================================================
#  FIRST STEP  With SNMP Call  and Genterate  SNMP LOG
#===================================================================

    # READ Config File Check SECTION
    #------------------------------------------------------------------

    $coronafile = "../conf/corona.conf";
    $rrdconfig  = "../conf/rrdsnmp.conf";
    $VER  = "3.1";


    #  READ ȣ��Ʈ ���
    &readconf ( $rrdconfig );

    #  READ ȯ�� ���� 
    &readcoronafile ( $coronafile );


    # MAIN SECTION
    #------------------------------------------------------------------
   my ( $c_hname );

   %c_Corona_host = %{$Corona_host}; 
   printf STDOUT " RRD_IMG Corona $VER START\n";
   #============================================================
   #  ��� �Ǵ� �̹����� ����Ʈ �� DAY ~ YEARly �� ������ ���Ƿ� ��� ��� ���� �ϳ��� ���� ���Ѵ�.
   #  �̹��������� �ϴ� ���� �ð��� ���� ���ϰ�  ���ϴ�.
   ## RRDIDX   : 1: DAY ONLY  2: WEEK ~ DAY 3: MONTH ~ DAY 4: YEAR ~ DAY
   ## =========================================================
   $RRDIDX = 1;

   foreach $c_hname (sort keys %c_Corona_host )
   {
       if (!defined($kidpid = fork())) {
           # fork returned undef, so failed
           die "RRD_GENIMG : cannot fork: $! ";
       } elsif ($kidpid == 0) {
           # fork returned 0, so this branch is the child
           printf STDOUT " IN : $c_hname \n";
           &RRD_GENIMG( $c_hname,  $rrdtool, $RRDDATA, ${IMGDIR}, $FONT_PATH, $RRDIDX ); 
           exec("echo 'FORK-EXIT' ");
           die "can't exec RRD_GENIMG: $!";
       } else {
               # fork returned neither 0 nor undef,
               # so this branch is the parent
                waitpid($kidpid, 0);
       }
   }
   printf STDOUT " RRD_IMG Corona ${VER} END\n";

   exit;
