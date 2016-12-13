#!/usr/bin/perl
#############################################################
##   RRD GRAPH Ver 3.0 ( Perl version 3.0 )
##      Made by Choi doo rip In Seoul Korea
##      couplewith@hanmail.net    in 2003.06
#############################################################
use lib qw( /svc/web_app/CORONA/bin );

require "Get_log.pm";
require "Gen_Util.pm";

#===================================================================
#  FIRST STEP  With SNMP Call  and Genterate  SNMP LOG
#===================================================================

    # READ Config File Check SECTION
    #------------------------------------------------------------------

    $coronafile = "../conf/corona.conf";
    $rrdconfig  = "../conf/rrdsnmp.conf";
    $VER  = "3.1";


    #  READ 호스트 목록
    &readconf ( $rrdconfig );

    #  READ INPUT Stream With  SNMP LOG 
    #------------------------------------------------------------------
    $Fcnt=0;
    print  " [Get_log] start STDIN====================================\n";
    while(<STDIN>) {
    
      chomp($_);
      if (  "$_" !~ /[=]/ ){
        # print " [Get_log] skipped [ $_ ] \n" ;
      }else {

        $Fcnt ++;
        @splited=split(" ","$_"); # divide pelos 2 pontos

        $L_Year=$splited[0];
        $L_Time=$splited[1];
        $L_hostname=$splited[2];
        $L_MIB=$splited[3];
        $L_Spliter=$splited[4];
        $L_Type=$splited[5];
        $L_Value=$splited[6];

       #print  "[$Fcnt] splited : @splited ";
       #print  "[$Fcnt] splited 0: {$splited[0]} : $L_Year \n";
       #print  "[$Fcnt] splited 1: {$splited[1]} : $L_Time \n";
       #print  "[$Fcnt] splited 2: {$splited[2]} : $L_hostname \n";
       #print  "[$Fcnt] splited 3: {$splited[3]} : $L_MIB \n";
       #print  "[$Fcnt] splited 4: {$splited[4]} : $L_Spliter \n";
       #print  "[$Fcnt] splited 5: {$splited[5]} : $L_Type \n";
       #print  "[$Fcnt] splited 6: {$splited[6]} : $L_Value \n";

        if ( ( "$L_Spliter" =~ /[=]/ )  &&
             ( $L_Type !~ /No/ )    && ( $L_Type !~ /Wrong/ )  ) {
            @T_MIB = split("::","$L_MIB");
            $V_MIB = $T_MIB[1];
 
           # Set Variable and Value
           #-----------------------------------------
            $Snmp_log->{$L_hostname}{$V_MIB} = $L_Value; 
            $Snmp_log->{$L_hostname}{Year}   = $L_Year; 
            $Snmp_log->{$L_hostname}{Time}   = $L_Time; 
            #$Snmp_MIB->{$V_MIB}= $V_MIB;

            debug_msg ("Get_log","OK:[$Fcnt] [$L_Spliter] {$L_hostname} : $V_MIB->$Snmp_log->{$L_hostname}{$V_MIB}] [$Snmp_log->{$L_hostname}{Year}] [$Snmp_log->{$L_hostname}{Time}]", 1 ); 
        }else{
            debug_msg  ("Get_log","ERR[$Fcnt] [$L_Spliter] {$L_hostname} : $V_MIB->$Snmp_log->{$L_hostname}{$V_MIB}] [$Snmp_log->{$L_hostname}{Year}] [$Snmp_log->{$L_hostname}{Time}]", 1 );
        }
      }
    }
    print  " [Get_log] END STDIN====================================\n";

    if ( $Fcnt < 1 ){
        print STDERR " Can not Read system LOG !! \n";
        exit;
    }


    # MAIN SECTION
    #------------------------------------------------------------------
    my ( $c_hname );

    %c_snmp_log = %{$Snmp_log}; 
    printf STDOUT "START RRD Corona v3.0\n";
 
    foreach $c_hname (sort keys %c_snmp_log )
    {
        if (!defined($kidpid = fork())) {
            # fork returned undef, so failed
            die "UPDATE : cannot fork: $! ";
        } elsif ($kidpid == 0) {
            # fork returned 0, so this branch is the child
                printf STDOUT " IN : $c_hname \n";
 
            &RRD_UPDATE( $c_hname, $Snmp_log, $rrdtool, $RRDDATA, ${IMGDIR}); 
 
            exec("echo 'FORK-EXIT' ");
            die "can't exec RRD_GENIMG: $!";
        } else {
                # fork returned neither 0 nor undef,
                # so this branch is the parent
                 waitpid($kidpid, 0);
        }
    }
    printf STDOUT "END RRD Corona v3.0\n";
 
    exit;
