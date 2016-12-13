
#############################################################
##   RRD GRAPH Ver 3.0 ( Perl version 3.0 )
##      Made by Choi doo rip In Seoul Korea
##      couplewith@hanmail.net   in 2003.06
#############################################################
#
# Function  List
#--------------------
#  1.1  debug_msg       : error output.
#  1.2  readconf    : read Config fiile.
#  2.1  RRD_MAKE    : Create RRD ( round robin database) file.
#  2.2  RRD_UPDATE  : Update RRD  with Current snmp-log variables.
#  2.3  RRD_GENIMG  : Create Graph imgaes With RRD.
#
# if you craeat new function then must briffing that.
#############################################################

#===================================================================
#  1. FIRST STEP  : With SNMP Call  and Genterate  SNMP LOG
#===================================================================

#sub debug {
#    $opt_d = 1;    # if 1 then print message;
#    if ($opt_d) {
#        my($parm1) = @_;
#        chomp($parm1);
#        print(STDERR $parm1 ,"\n" );
#    }
#}

sub readconf {
    my ( $configfile ) = @_;
    print " READCONF:   $configfile OPEN \n";

    #  RRDDATA :  RRD file Location Path .
    #  rrdtool :  rrdtool utility location path.
    #  IMGDIR  :  Graph image files Location Path .

    open(CONF ,$configfile) || (print("Could not find $configfile ($!)\n") && exit(1));
    while (<CONF>) {
       if (( $_ =~ /^RRDDATA/) || ($_ =~ /^rrdtool/) ||
           ($_ =~ /^IMGDIR/)   || ($_ =~ /^DEBUG_LOG/) )
       {
          chomp($_);
          @splited=split(" ",$_);
          if (defined($splited[1])) {
            ${$splited[0]} = $splited[1];
            debug_msg( "READCONF:  ${$splited[0]} = $splited[1]\n ");
          }
       }
    }

    #Verificando se pode executar o rrdtool
    if (!(-r $rrdtool) || !(-x $rrdtool)) {
         die("READCONF: Could not execute/find rrdtool program ($!)\nCheck the rrdtool directive in your config file\n ");
    } else {
         debug_msg("READCONF"," Found $rrdtool\n");
    }
}

#===================================================================
#  2. SECOND STEP : With RRD and Genterate  RRD LOG
#===================================================================
sub RRD_MAKE {

    # Called by  << [RRD_UPDATE]
    my ( $k_domain, $k_hname, $rrdtool, $RRDDATA)= @_;

    debug_msg ("[RRD_MAKE]",":$k_hname : ${RRDDATA} \n");

    # Hostname 별 데이타 업데이트 CALL
    #----------------------------------
    $S_ind = index($k_hname, "." );
    $E_ind = length($k_hname);
    $k_hostid=substr($k_hname,0,$S_ind);
    $k_domain=substr($k_hname,$S_ind+1,$E_ind);

    $RRDDIR = "${RRDDATA}/${k_domain}";

   $HOST_SUB = "${k_domain}/${k_hostid}";
   $RRD_IMG_DIR  = "${IMGDIR}/${HOST_SUB}";
   $RRD_DATA_DIR = "${RRDDATA}/${HOST_SUB}";

    if ( ! -d ${RRD_DATA_DIR} ) {
       $cmd = "mkdir -p ${RRD_DATA_DIR} ";
       debug_msg( " >> MKDIR",": $cmd \n");
       system ( $cmd );
    }

    # LOADSTAT------------------------------------------------
    $RRDFILE = "${RRD_DATA_DIR}/${k_hname}_cpu.rrd";
    if ( ! -e $RRDFILE ) {
          $cmd = " ${rrdtool} create ${RRDFILE} --step 300  \\
                  DS:user:GAUGE:600:0:U     \\
                  DS:system:GAUGE:600:0:U   \\
                  DS:idle:GAUGE:600:0:U     \\
                  DS:load1:GAUGE:600:0:U    \\
                  DS:load2:GAUGE:600:0:U    \\
                  DS:load3:GAUGE:600:0:U    \\
                  DS:IOReceive:GAUGE:600:0:U \\
                  DS:IOSent:GAUGE:600:0:U    \\
                  DS:SwapIn:GAUGE:600:0:U    \\
                  DS:SwapOut:GAUGE:600:0:U   \\
                  RRA:AVERAGE:0.5:1:600     RRA:AVERAGE:0.5:6:700     \\
                  RRA:AVERAGE:0.5:24:800    RRA:AVERAGE:0.5:288:800   \\
                  RRA:LAST:0.5:1:600        RRA:LAST:0.5:6:700     \\
                  RRA:LAST:0.5:24:800       RRA:LAST:0.5:288:800   \\
                  RRA:MAX:0.5:1:600         RRA:MAX:0.5:6:700      \\
                  RRA:MAX:0.5:24:800        RRA:MAX:0.5:288:800    \\
                  RRA:MIN:0:1:600           RRA:MIN:0:6:700        \\
                  RRA:MIN:0.5:24:800        RRA:MIN:0.5:288:800  ";
          system ( $cmd );
          print STDOUT " CREATE $RRDFILE : [cmd]\n";
    }else {
          print STDOUT " $RRDFILE Exists  !!\n";
    }

    # MemStatus------------------------------------------------
    $RRDFILE = "${RRD_DATA_DIR}/${k_hname}_memstat.rrd";
    if ( ! -e $RRDFILE ) {
          $cmd = " ${rrdtool} create ${RRDFILE} --step 300   \\
                   DS:total:GAUGE:600:0:U   \\
                   DS:free:GAUGE:600:0:U    \\
                   DS:used:GAUGE:600:0:U    \\
                   DS:shared:GAUGE:600:0:U  \\
                   DS:buffed:GAUGE:600:0:U  \\
                   DS:cached:GAUGE:600:0:U  \\
                   RRA:AVERAGE:0.5:1:600     RRA:AVERAGE:0.5:6:700    \\
                   RRA:AVERAGE:0.5:24:800    RRA:AVERAGE:0.5:288:800  \\
                   RRA:LAST:0.5:1:600        RRA:LAST:0.5:6:700       \\
                   RRA:LAST:0.5:24:800       RRA:LAST:0.5:288:800     \\
                   RRA:MAX:0.5:1:600         RRA:MAX:0.5:6:700        \\
                   RRA:MAX:0.5:24:800        RRA:MAX:0.5:288:800      \\
                   RRA:MIN:0:1:600           RRA:MIN:0:6:700          \\
                   RRA:MIN:0.5:24:800        RRA:MIN:0.5:288:800  ";
          system ( $cmd );
          print STDOUT " CREATE $RRDFILE : [cmd]\n";
    }else {
          print STDOUT " $RRDFILE Exists  !!\n";
    }
     
    # NetStat------------------------------------------------
    $RRDFILE = "${RRD_DATA_DIR}/${k_hname}_netstat.rrd";
    if ( ! -e $RRDFILE ) {
          $cmd = " ${rrdtool} create ${RRDFILE} --step 300   \\
                   DS:netin0:COUNTER:600:0:U    \\
                   DS:netout0:COUNTER:600:0:U   \\
                   DS:netin1:COUNTER:600:0:U    \\
                   DS:netout1:COUNTER:600:0:U   \\
                   DS:netin2:COUNTER:600:0:U    \\
                   DS:netout2:COUNTER:600:0:U   \\
                   DS:tcpActiveOpens:COUNTER:600:0:U    \\
                   DS:tcpPassiveOpens:COUNTER:600:0:U   \\
                   DS:tcpAttemptFails:COUNTER:600:0:U   \\
                   DS:tcpEstabResets:COUNTER:600:0:U    \\
                   DS:tcpCurrEstab:GAUGE:600:0:U        \\
                   RRA:AVERAGE:0.5:1:600     RRA:AVERAGE:0.5:6:700    \\
                   RRA:AVERAGE:0.5:24:800    RRA:AVERAGE:0.5:288:800  \\
                   RRA:LAST:0.5:1:600        RRA:LAST:0.5:6:700       \\
                   RRA:LAST:0.5:24:800       RRA:LAST:0.5:288:800     \\
                   RRA:MAX:0.5:1:600         RRA:MAX:0.5:6:700        \\
                   RRA:MAX:0.5:24:800        RRA:MAX:0.5:288:800      \\
                   RRA:MIN:0:1:600           RRA:MIN:0:6:700          \\
                   RRA:MIN:0.5:24:800        RRA:MIN:0.5:288:800  ";
          system ( $cmd );
          print STDOUT " CREATE $RRDFILE : [cmd]\n";
    }else {
          print STDOUT " $RRDFILE Exists  !!\n";
    }
     
}

sub RRD_UPDATE {

    my ( $k_hname, $Snmp_log, $rrdtool, $RRDDATA, $IMGDIR ) = @_;
    my ( $k_mibs, $k_value );
    debug_msg ("[RRD_UPDATE]",":$k_hname : ${RRDDATA} ${IMGDIR} \n");


    if ( 1==1 )
    {
        debug_msg (" RRD_UPDATE", " ======= START [${k_hname}] : ${RRDDATA} \n");

        foreach $k_mibs (keys %{$Snmp_log->{$k_hname}} )
        {
            print STDERR " OUT : $k_hname,$k_mibs, $Snmp_log->{$k_hname}{$k_mibs}  \n";
            if ( $Snmp_log->{$k_hname}{$k_mibs} == ''){
                ${$k_mibs} = 0;
                debug_msg (" RRD_UPDATE", "{$k_hname}:: $k_mibs invalid  [$Snmp_log->{$k_hname}{$k_mibs}]" );
            }else {
                ${$k_mibs} = $Snmp_log->{$k_hname}{$k_mibs};
            }
        }

        # Hostname 별 데이타 업데이트 CALL 
        #----------------------------------
        $S_ind = index($k_hname, "." ); 
        $E_ind = length($k_hname); 
        $k_domain=substr($k_hname,$S_ind+1,$E_ind);
        $k_hostid=substr($k_hname,0,$S_ind);
        $k_domain=substr($k_hname,$S_ind+1,$E_ind);

        $HOST_SUB = "${k_domain}/${k_hostid}";
        $RRD_IMG_DIR  = "${IMGDIR}/${HOST_SUB}";
        $RRD_DATA_DIR = "${RRDDATA}/${HOST_SUB}";


        # RRDFILE And Server Data Dir Chking
        #-----------------------------------
        debug_msg (" RRD_UPDATE", " =====RRD_MAKE  Start Update RRD : [$k_hname] =======\n" );

        RRD_MAKE ( $k_domain, $k_hname, $rrdtool,$RRDDATA);

     #--------------------------------------------------
     # Caution : 
     #     Fork Function Make Confisued Result 
     #          Don not use Fork function !!!.
     #--------------------------------------------------
     #   if (!defined($kidpid = fork())) {
     #       # fork returned undef, so failed
     #       die "UPDATE : cannot fork: $! ";
     #   } elsif ($kidpid == 0) {
                # fork returned 0, so this branch is the child
            
        debug_msg (" RRD_UPDATE", " Update RRDFILE : [$k_hname] - $kidpid =======\n" );

            # CPU &Load ------------------------------------------------------------------
            $RRDFILE = "${RRD_DATA_DIR}/${k_hname}_cpu.rrd";
            $cmd = " $rrdtool update $RRDFILE \\
                     N:${'ssCpuUser.0'}:${'ssCpuSystem.0'}:${'ssCpuIdle.0'}:${'laLoad.1'}:${'laLoad.2'}:${'laLoad.3'}:${'ssIOReceive.0'}:${'ssIOSent.0'}:${'ssSwapIn.0'}:${'ssSwapOut.0'}"; 
            system( $cmd );
            print STDERR "UPDATE $RRDFILE : [$cmd]\n";
            debug_msg (" RRD_UPDATE", " Update RRDFILE : [$RRDFILE] - [cmd: $cmd] =\n" );


            # Memory  ------------------------------------------------------------------
            $Rused= ${'memTotalReal.0'} - ${'memAvailReal.0'} ;   
            $RRDFILE = "${RRD_DATA_DIR}/${k_hname}_memstat.rrd";
            $cmd = " $rrdtool update $RRDFILE  N:${'memTotalReal.0'}:${'memAvailReal.0'}:${Rused}:${'memShared.0'}:${'memBuffer.0'}:${'memCached.0'} ";
            system( $cmd );
            print STDERR "UPDATE $RRDFILE : [$cmd]\n";

            # TCP_IP  ------------------------------------------------------------------
            # rrdtool update ${SERV}_net.rrd N:${Netin0}:${Netout0}:${Netin1}:${Netout1}:${Netin2}:${Netout2};
            # rrdtool update ${SERV}_tcp.rrd N:${Nclosed}:${Nlisten}:${NsynSent}:${Nestablish}:${Ntimewait};
            chomp(${'ifDescr.2'} );
            chomp(${'ifDescr.3'} );
            chomp(${'ifDescr.4'} );
            if ( ${'ifDescr.2'}  = '' ){ ${'ifInOctets.2'} = 0; ${'ifOutOctets.2'} = 0; }
            if ( ${'ifDescr.3'}  = '' ){ ${'ifInOctets.3'} = 0; ${'ifOutOctets.3'} = 0; }
            if ( ${'ifDescr.4'}  = '' ){ ${'ifInOctets.4'} = 0; ${'ifOutOctets.4'} = 0; }

            $RRDFILE = "${RRD_DATA_DIR}/${k_hname}_netstat.rrd";
            $cmd = " $rrdtool update $RRDFILE N:${'ifInOctets.2'}:${'ifOutOctets.2'}:${'ifInOctets.3'}:${'ifOutOctets.3'}:${'ifInOctets.4'}:${'ifOutOctets.4'}:${'tcpActiveOpens.0'}:${'tcpPassiveOpens.0'}:${'tcpAttemptFails.0'}:${'tcpEstabResets.0'}:${'tcpCurrEstab.0'}";
            system( $cmd );
            print STDERR "UPDATE $RRDFILE : [$cmd]\n";

            # if the exec fails, fall through to the next statement
            # die "can't exec date: $!";
     #  } else {
     #      # fork returned neither 0 nor undef,
     #      # so this branch is the parent
     #       waitpid($kidpid, 0);
     #  }
    }

    debug_msg(" RRD_UPDATE", " Update END : [$k_hname] - $kidpid =======\n" );
}


1;
