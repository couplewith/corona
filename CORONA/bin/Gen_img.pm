#! /usr/bin/perl
#############################################################
##   RRD GRAPH Ver 3.1 ( Perl version 3.1 )
##      Made by Choi doo rip In Seoul Korea
##      couplewith@hanmail.net
##
##  Contents : Graph Genterate Module  in 2003.06
##              Modify PERL::Gen image 2007.07
#############################################################
    
   #makes things work when run without install
use lib qw( /usr/local/rrdtool/lib/perl );
use lib qw( /usr/local/rrdtool/lib/perl/5.8.8/i386-linux-thread-multi );
use lib qw( /svc/web_app/CORONA/bin );
    
use RRDs;


use FileHandle;

$VER = "3.1";

#===================================================================
#  1. FIRST STEP  : With SNMP Call  and Genterate  SNMP LOG
#===================================================================


# &RRD_GENIMG( $c_hname,  $rrdtool, $RRDDATA, ${IMGDIR}, $FONT_PATH, $RRDIDX);    

        # Hostname ot HOST CALL
        #----------------------------------
    sub RRD_GET_HOSTID {
        my ( $k_hname )= @_;
        $S_ind = index($k_hname, "." );
        $E_ind = length($k_hname);
        $k_hostid=substr($k_hname,0,$S_ind);
        return $k_hostid;
    }
        # Hostname to DOMAIN CALL
        #----------------------------------
    sub RRD_GET_DOMAIN {
        my ( $k_hname )= @_;
        $S_ind = index($k_hname, "." );
        $E_ind = length($k_hname);
        $k_domain=substr($k_hname,$S_ind+1,$E_ind);
        return $k_domain;
    }
    
    sub RRD_GENIMG {

        # Called by  << [RRD_UPDATE]
        my ( $k_hname, $rrdtool,$RRDDATA, $IMGDIR, $RRDIDX )= @_;
        debug_msg ("[RRD_GENIMG]","start:$k_hname : ${RRDDATA} ${IMGDIR} [${RRDIDX}]", 1);
    
    
        # Hostname 별 데이타 업데이트 CALL
        #----------------------------------
        $S_ind = index($k_hname, "." );
        $E_ind = length($k_hname);
        $k_hostid=substr($k_hname,0,$S_ind);
        $k_domain=substr($k_hname,$S_ind+1,$E_ind);
    
    #    $IMGDIR="/export/corona/CORONA/web_corona/test";
    
       #$RRDDIR = "${IMGDIR}/${k_domain}";
       $HOST_SUB = "${k_domain}/${k_hostid}";
       $RRD_IMG_DIR  = "${IMGDIR}/${HOST_SUB}";
       $RRD_DATA_DIR = "${RRDDATA}/${HOST_SUB}";
    
        if ( ! -d ${RRD_IMG_DIR} ) {
           $cmd = "mkdir -p ${RRD_IMG_DIR} ";
           system ( $cmd );
           debug_msg ( "  RRD_GENIMG","MK_IMGDIR : $cmd ", 1);
        }
    
    
        ##################  FONT SETTING  ################## 2007. 7. 7
        # AXIS    : for the axis labels
        # UNIT    : for the vertical unit label
        # TITLE   : for the graph title
        # LEGEND  : for the graph legend
        # DEFAULT : default value for all elements
        #
        #/usr/share/fonts/ko/TrueType/dotum.ttf ";
        #/usr/share/fonts/hanyang/Gulim.ttf
        ## 사용 가능한 Font의 구분
        @Font_title = ('ACDC.ttf','adema.ttf','planetbe.ttf','LOAD.TTF','deftones.ttf');
        @Font_body = ('Gulim.ttf','TIMESBD.TTF','TIMESBI.TTF','times.ttf' );
    
        if( $LANGUAGE eq "ko" ){
	    ### KOREAN
             $RRD_FONT{'DEFAULT'} = "DEFAULT:7:${FONT_PATH}/${KO_FONT_UNIT}";
             $RRD_FONT{'TITLE'}   = "TITLE:12:${FONT_PATH}/${KO_FONT_TITLE}";
             $RRD_FONT{'AXIS'}    = "AXIS:7:${FONT_PATH}/${KO_FONT_AXIS}";
             $RRD_FONT{'UNIT'}    = "UNIT:7:${FONT_PATH}/${KO_FONT_UNIT}";
             $RRD_FONT{'LEGEND'}  = "LEGEND:7:${FONT_PATH}/${KO_FONT_LEGEND}";
        }elsif( $LANGUAGE eq "en" ){
	    ### ENGLISH
             $RRD_FONT{'DEFAULT'} = "DEFAULT:0:${FONT_PATH}/${EN_FONT_DEFAULT}";
             $RRD_FONT{'TITLE'}   = "TITLE:12:${FONT_PATH}/${EN_FONT_TITLE}";
             $RRD_FONT{'AXIS'}    = "AXIS:0:${FONT_PATH}/${EN_FONT_AXIS}";
             $RRD_FONT{'UNIT'}    = "UNIT:0:${FONT_PATH}/${EN_FONT_UNIT}";
             $RRD_FONT{'LEGEND'}  = "LEGEND:0:${FONT_PATH}/${EN_FONT_LEGEND}";
    
        }else{
             $RRD_FONT{'DEFAULT'} = "DEFAULT:7:";
             $RRD_FONT{'TITLE'}   = "TITLE:12:";
             $RRD_FONT{'AXIS'}    = "AXIS:7:";
             $RRD_FONT{'UNIT'}    = "UNIT:7:";
             $RRD_FONT{'LEGEND'}  = "LEGEND:7:";
        }
    
        @Start_Days=('-2days', '-1weeks', '-1months','-1years');
        @Title_Days=('DAY', 'WEEK', 'MONTH','YEAR');
        $Cnt = $#Start_Days;
    
    
        #my $name = $0;
        #$name =~ s/.*\///g;
        #$name =~ s/\.pl.*//g;
        
        my $c1="f57912a0";
        my $c2="2a79e9a0";
    
        $IMGSIZE{'W'} = 400;
        $IMGSIZE{'H'} = 120;
    
        ##################  DATE SETTING  ################## 2007.7.7
        ($Second, $Minute, $Hour, $Day, $Month, $Year, $WeekDay, $DayOfYear, $IsDST) = localtime(time) ;
         $Month++;
         $Year += 1900;
    
        $Now = " $Year/$Month/$Day $Hour\\:$Minute\\:$Second ";
    
        $start_idx = $#Start_Days;

        if     ( ( ($Hour%12) == 0 ) &&  ( $Minute <= 6 ) ){
            # 년간 그래프 생성 [매일 12시]
            $start_idx = 3;
        }elsif ( ( ($Hour%6) == 0 ) && ( $Minute <= 6 ) ){
            # 주간 그래프 생성 [매 6시간 마다 ]
            $start_idx = 1;
        }else{
            $start_idx = 0;
        }

        debug_msg ("[RRD_GENIMG]","RRDIDX : now [${Now}] ${RRDIDX} -> $start_idx \n" , 1);
    
        for ( $i=${start_idx}; $i >= 0 ; $i--)
        {
            $start=$Start_Days[$i];

            debug_msg ("[RRD_GENIMG]","start_idx : ${start_idx} / $Start_Days[$start_idx] \n" , 1);
            debug_msg ("[RRD_GENIMG]","RRD_FONT : ${RRD_FONT} / RRD_DATA_DIR : $RRD_DATA_DIR \n" , 1);
    
            &RRD_GENIMG_CPU    ($k_hname, $RRD_FONT, $RRD_DATA_DIR, $RRD_IMG_DIR, $Now, $IMGSIZE, $Start_Days, $Title_Days, $i);
            &RRD_GENIMG_LOAD   ($k_hname, $RRD_FONT, $RRD_DATA_DIR, $RRD_IMG_DIR, $Now, $IMGSIZE, $Start_Days, $Title_Days, $i);
            &RRD_GENIMG_IO     ($k_hname, $RRD_FONT, $RRD_DATA_DIR, $RRD_IMG_DIR, $Now, $IMGSIZE, $Start_Days, $Title_Days, $i);
            &RRD_GENIMG_MEMORY ($k_hname, $RRD_FONT, $RRD_DATA_DIR, $RRD_IMG_DIR, $Now, $IMGSIZE, $Start_Days, $Title_Days, $i);
    
            &RRD_GENIMG_NETWORK($k_hname, $RRD_FONT, $RRD_DATA_DIR, $RRD_IMG_DIR, $Now, $IMGSIZE, $Start_Days, $Title_Days, $i);
            &RRD_GENIMG_TCP    ($k_hname, $RRD_FONT, $RRD_DATA_DIR, $RRD_IMG_DIR, $Now, $IMGSIZE, $Start_Days, $Title_Days, $i);
    
        }
    }

    sub RRD_GENIMG_CPU {

        # Called by  << [RRD_UPDATE->RRD_GENIMG->RRD_GENIMG_CPU]
        #
    
        my ( $k_hname, $RRD_FONT, $RRD_DATA_DIR, $RRD_IMG_DIR, $Now, $IMGSIZE, $Start_Days, $Title_Days, $i ) = @_;
        debug_msg ("[RRD_GENIMG_CPU]","start : ${k_hname} [$Title_Days[$i] \n" , 1);
    
        debug_msg ("[RRD_GENIMG_CPU]","k_hname : ${k_hname}\n" , 0);
        debug_msg ("[RRD_GENIMG_CPU]","RRD_DATA_DIR : ${RRD_DATA_DIR} \n" , 0);
        debug_msg ("[RRD_GENIMG_CPU]","RRD_IMG_DIR : ${RRD_IMG_DIR} \n" , 0);
        debug_msg ("[RRD_GENIMG_CPU]","RRD_FONT : $RRD_FONT{'DEFAULT'}/ $RRD_FONT{'TITLE'}/ $RRD_FONT{'LEGEND'} \n" , 1);

        #--- CPU STAT -------------------------------------------
        $RRDFILE = "${RRD_DATA_DIR}/${k_hname}_cpu.rrd";
        if ( -e $RRDFILE ){ 
               $RRDIMG = "${RRD_IMG_DIR}/${k_hname}_${Title_Days[$i]}_CPU.png";
    
            $k_hostid = RRD_GET_HOSTID ($k_hname); 

        RRDs::graph "${RRDIMG}",
            "--title", "$k_hostid  CPU-Usage  [ $Title_Days[$i] ]", 
            "--font","$RRD_FONT{'DEFAULT'}",
            "--font","$RRD_FONT{'TITLE'}",
            "--font","$RRD_FONT{'AXIS'}",
            "--font","$RRD_FONT{'LEGEND'}",
            "--start", "$start",
            "--end", "now",
            "--lower-limit=0",
            "--upper-limit=100",
            "--interlace", 
            "--imgformat","PNG",
            "--width=$IMGSIZE{W}",
            "--height=$IMGSIZE{H}",
            "DEF:user=${RRDFILE}:user:AVERAGE",
            "DEF:system=${RRDFILE}:system:AVERAGE",
            "DEF:idle=${RRDFILE}:idle:AVERAGE",
            "DEF:luser=${RRDFILE}:user:LAST",
            "DEF:lsystem=${RRDFILE}:system:LAST",
            "HRULE:0#333333",
            "CDEF:Auser=user,UN,0,user,IF",
            "CDEF:Asystem=system,UN,0,system,IF",
            "CDEF:Cuser=luser",
            "CDEF:Csystem=lsystem",
            "TEXTALIGN:left",
            "COMMENT:          CPU STAT  ",
            "COMMENT:     Average ",
            "COMMENT:     Current ",
            "COMMENT:         MAX ",
            "COMMENT:         MIN ",
            "COMMENT:\\j",
            "COMMENT:       ",
            "AREA:Asystem#FFAAAA: SYSTEM",
            "GPRINT:Asystem:AVERAGE:%14.2lf",
            "GPRINT:Csystem:LAST:%14.2lf",
            "GPRINT:Asystem:MAX:%14.2lf",
            "GPRINT:Asystem:MIN:%14.2lf",
            "COMMENT:\\j",
            "COMMENT:       ",
            "LINE:Auser#9900FF:USER",
            "COMMENT: ",
            "GPRINT:Auser:AVERAGE:%14.2lf",
            "GPRINT:Cuser:LAST:%14.2lf",
            "GPRINT:Auser:MAX:%14.2lf",
            "GPRINT:Auser:MIN:%14.2lf",
            "COMMENT:\\j",
            "COMMENT: [$k_hname] / Updated\\:$Now \\r",
            "--watermark","Generated by Dr.Choi"
           ;


            if ($ERROR = RRDs::error) {
              die "  RRD_GENIMG_CPU:ERROR: $ERROR\n";
            }else{
                debug_msg ("RRD_GENIMG_CPU","END:$k_hname : Generate [$RRDIMG] ", 1);
            }
        }
    }
    

    sub RRD_GENIMG_LOAD {

        # Called by  << [RRD_UPDATE->RRD_GENIMG->RRD_GENIMG_LOAD]
        #
    
        debug_msg ( "  [RRD_GENIMG_LOAD]",":start : ${k_hname}\n" , 1);
        my ( $k_hname, $RRD_FONT, $RRD_DATA_DIR, $RRD_IMG_DIR, $Now, $IMGSIZE, $Start_Days, $Title_Days, $i ) = @_;
    
        debug_msg ( "  [RRD_GENIMG_LOAD]","k_hname : ${k_hname}\n" , 0);
        debug_msg ( "  [RRD_GENIMG_LOAD]","RRD_DATA_DIR : ${RRD_DATA_DIR} \n" , 0);
        debug_msg ( "  [RRD_GENIMG_LOAD]","RRD_IMG_DIR : ${RRD_IMG_DIR} \n" , 0);
        debug_msg ( "  [RRD_GENIMG_LOAD]","RRD_FONT : $RRD_FONT{'DEFAULT'}/ $RRD_FONT{'TITLE'}/ $RRD_FONT{'LEGEND'}\n" , 0);

        #--- LOAD STAT -------------------------------------------
        $RRDFILE = "${RRD_DATA_DIR}/${k_hname}_cpu.rrd";
            #     DS:load1:GAUGE:600:0:U
            #     DS:load2:GAUGE:600:0:U
            #     DS:load3:GAUGE:600:0:U

        if ( -e $RRDFILE ){ 
               $RRDIMG = "${RRD_IMG_DIR}/${k_hname}_${Title_Days[$i]}_LOAD.png";
    
            $k_hostid = RRD_GET_HOSTID ($k_hname); 

        RRDs::graph "${RRDIMG}",
            "--title", "$k_hostid  System-LOAD [ $Title_Days[$i] ] ", 
            "--font","$RRD_FONT{'DEFAULT'}",
            "--font","$RRD_FONT{'TITLE'}",
            "--font","$RRD_FONT{'AXIS'}",
            "--font","$RRD_FONT{'LEGEND'}",
            "--start", "$start",
            "--end", "now",
            "--lower-limit=0",
            "--upper-limit=100",
            "--interlace", 
            "--imgformat","PNG",
            "--width=$IMGSIZE{W}",
            "--height=$IMGSIZE{H}",
            "DEF:load1=${RRDFILE}:load1:AVERAGE",
            "DEF:load2=${RRDFILE}:load2:AVERAGE",
            "DEF:load3=${RRDFILE}:load3:AVERAGE",
            "DEF:cload1=${RRDFILE}:load1:LAST",
            "DEF:cload2=${RRDFILE}:load2:LAST",
            "DEF:cload3=${RRDFILE}:load3:LAST",
            "HRULE:0#333333",
            "CDEF:GLoad1=load1,UN,0,load1,IF",
            "CDEF:GLoad2=load2,UN,0,load2,IF",
            "CDEF:GLoad3=load3,UN,0,load3,IF",
            "CDEF:CLoad1=cload1",
            "CDEF:CLoad2=cload2",
            "CDEF:CLoad3=cload3",
            "COMMENT:      LOAD STAT ",
            "COMMENT:     Average ",
            "COMMENT:     Current ",
            "COMMENT:         MAX ",
            "COMMENT:         MIN \\j",
            "COMMENT:     ",
            "AREA:GLoad1#3333FF:Load  1",
            "GPRINT:CLoad1:AVERAGE:%15.2lf",
            "GPRINT:CLoad1:LAST:%15.2lf",
            "GPRINT:CLoad1:MAX:%15.2lf",
            "GPRINT:CLoad1:MIN:%15.2lf\\j",
            "COMMENT:     ",
            "STACK:GLoad2#CCFF99:Load  5",
            "GPRINT:CLoad2:AVERAGE:%15.2lf",
            "GPRINT:CLoad2:LAST:%15.2lf",
            "GPRINT:CLoad2:AVERAGE:%15.2lf",
            "GPRINT:CLoad2:AVERAGE:%15.2lf\\j",
            "COMMENT:     ",
            "STACK:GLoad3#CC0000:Load15",
            "GPRINT:CLoad3:AVERAGE:%15.2lf",
            "GPRINT:CLoad3:LAST:%15.2lf",
            "GPRINT:CLoad3:MAX:%15.2lf",
            "GPRINT:CLoad3:MIN:%15.2lf\\j",
            "COMMENT: [$k_hname] / Updated\\:$Now \\r",
            "--watermark","Generated by Dr.Choi"
           ;


            if ($ERROR = RRDs::error) {
              die "  RRD_GENIMG_LOAD:ERROR: $ERROR\n";
            }else{
                debug_msg ("RRD_GENIMG_LOAD","END:$k_hname : Generate [$RRDIMG] ", 1);
            }
        }
    }
    
    sub RRD_GENIMG_IO {

        # Called by  << [RRD_UPDATE->RRD_GENIMG->RRD_GENIMG_IO]
        #
    
        debug_msg ( "  [RRD_GENIMG_IO] :start : ${k_hname}\n" , 1);
        my ( $k_hname, $RRD_FONT, $RRD_DATA_DIR, $RRD_IMG_DIR, $Now, $IMGSIZE, $Start_Days, $Title_Days, $i ) = @_;
    
        debug_msg ( "  [RRD_GENIMG_IO]",":k_hname : ${k_hname}\n" , 0);
        debug_msg ( "  [RRD_GENIMG_IO]",":RRD_DATA_DIR : ${RRD_DATA_DIR} \n" , 0);
        debug_msg ( "  [RRD_GENIMG_IO]",":RRD_IMG_DIR : ${RRD_IMG_DIR} \n" , 0);
        debug_msg ( "  [RRD_GENIMG_IO]",":RRD_FONT : $RRD_FONT{'DEFAULT'}/ $RRD_FONT{'TITLE'}/ $RRD_FONT{'LEGEND'}\n" , 0);

        #--- I/O STAT -------------------------------------------
        #         DS:IOReceive:GAUGE:600:0:U
        #         DS:IOSent:GAUGE:600:0:U
        #         DS:SwapIn:GAUGE:600:0:U
        #         DS:SwapOut:GAUGE:600:0:U

        $RRDFILE = "${RRD_DATA_DIR}/${k_hname}_cpu.rrd";
        if ( -e $RRDFILE ){ 
               $RRDIMG = "${RRD_IMG_DIR}/${k_hname}_${Title_Days[$i]}_IO.png";
    
            $k_hostid = RRD_GET_HOSTID ($k_hname); 

        RRDs::graph "${RRDIMG}",
            "--title", "$k_hostid  IO / Swap [ $Title_Days[$i] ] ", 
            "--font","$RRD_FONT{'DEFAULT'}",
            "--font","$RRD_FONT{'TITLE'}",
            "--font","$RRD_FONT{'AXIS'}",
            "--font","$RRD_FONT{'LEGEND'}",
            "--font","$RRD_FONT{'UNIT'}",
            "--start", "$start",
            "--end", "now",
            "--lower-limit=-100",
            "--upper-limit=100",
            "--interlace", 
            "--imgformat","PNG",
            "--width=$IMGSIZE{W}",
            "--height=$IMGSIZE{H}",
            "TEXTALIGN:right",
            "DEF:AIOReceive=${RRDFILE}:IOReceive:AVERAGE",
            "DEF:AIOSent=${RRDFILE}:IOSent:AVERAGE",
            "DEF:ASwapIn=${RRDFILE}:SwapIn:AVERAGE",
            "DEF:ASwapOut=${RRDFILE}:SwapOut:AVERAGE",
            "HRULE:0#333333",
            "CDEF:CIOReceive=AIOReceive",
            "CDEF:CIOSent=AIOSent",
            "CDEF:CSwapIn=ASwapIn",
            "CDEF:CSwapOut=ASwapOut",
            "CDEF:GIOReceive=AIOReceive,UN,0,AIOReceive,IF",
            "CDEF:GIOSent=AIOSent,UN,0,AIOSent,IF",
            "CDEF:GSwapIn=ASwapIn,UN,0,ASwapIn,IF,-1,*",
            "CDEF:GSwapOut=ASwapOut,UN,0,ASwapOut,IF,-1,*",
            "COMMENT:     I/O STAT",
            "COMMENT:     Average ",
            "COMMENT:     Current ",
            "COMMENT:         MAX ",
            "COMMENT:         MIN ",
            "COMMENT:\\j",
            "COMMENT:  ",
            "AREA:GIOReceive#FFCCCC: IO-Recv",
            "GPRINT:CIOReceive:AVERAGE:%14.2lf",
            "GPRINT:CIOReceive:LAST:%14.2lf",
            "GPRINT:CIOReceive:MAX:%14.2lf",
            "GPRINT:CIOReceive:MIN:%14.2lf",
            "COMMENT:\\j",
            "COMMENT:  ",
            "LINE1:GIOSent#6666FF: IO-Sent",
            "GPRINT:CIOSent:AVERAGE:%14.2lf",
            "GPRINT:CIOSent:LAST:%14.2lf",
            "GPRINT:CIOSent:MAX:%14.2lf",
            "GPRINT:CIOSent:MIN:%14.2lf",
            "COMMENT:\\j",
            "COMMENT:  ",
            "AREA:GSwapIn#CCFF99: Swap-  In",
            "GPRINT:CSwapIn:AVERAGE:%14.2lf",
            "GPRINT:CSwapIn:LAST:%14.2lf",
            "GPRINT:CSwapIn:MAX:%14.2lf",
            "GPRINT:CSwapIn:MIN:%14.2lf",
            "COMMENT:\\j",
            "COMMENT:  ",
            "LINE1:GSwapOut#0066CC: Swap-Out",
            "GPRINT:CSwapOut:AVERAGE:%14.2lf",
            "GPRINT:CSwapOut:LAST:%14.2lf",
            "GPRINT:CSwapOut:MAX:%14.2lf",
            "GPRINT:CSwapOut:MIN:%14.2lf",
            "COMMENT:\\j",
            "COMMENT: [$k_hname] / Updated\\:$Now \\r",
            "--watermark","Generated by Dr.Choi"
           ;


            if ($ERROR = RRDs::error) {
              die "  RRD_GENIMG_IO:ERROR: $ERROR\n";
            }else{
                debug_msg ("RRD_GENIMG_IO","END:$k_hname : Generate [$RRDIMG] ", 1);
            }
        }
    }
    
    sub RRD_GENIMG_MEMORY {

        # Called by  << [RRD_UPDATE->RRD_GENIMG->RRD_GENIMG_MEMORY]
        #
    
        debug_msg ( "  [RRD_GENIMG_MEMORY]",":start : ${k_hname}\n" , 1);
        my ( $k_hname, $RRD_FONT, $RRD_DATA_DIR, $RRD_IMG_DIR, $Now, $IMGSIZE, $Start_Days, $Title_Days, $i ) = @_;
    
        debug_msg ( "  [RRD_GENIMG_MEMORY]",":k_hname : ${k_hname}\n" , 0);
        debug_msg ( "  [RRD_GENIMG_MEMORY]",":RRD_DATA_DIR : ${RRD_DATA_DIR} \n" , 0);
        debug_msg ( "  [RRD_GENIMG_MEMORY]",":RRD_IMG_DIR : ${RRD_IMG_DIR} \n" , 0);
        debug_msg ( "  [RRD_GENIMG_MEMORY]",":RRD_FONT : $RRD_FONT{'DEFAULT'}/ $RRD_FONT{'TITLE'}/ $RRD_FONT{'LEGEND'}\n" , 0);

        #--- MEMSTAT------------------------------------
        $RRDFILE = "${RRD_DATA_DIR}/${k_hname}_memstat.rrd";
        
        if ( -e $RRDFILE ){ 
               $RRDIMG = "${RRD_IMG_DIR}/${k_hname}_${Title_Days[$i]}_MEMORY.png";
    
            $k_hostid = RRD_GET_HOSTID ($k_hname); 

        RRDs::graph "${RRDIMG}",
            "--title", "$k_hostid  Memory-Usage [ $Title_Days[$i] ] ", 
            "--font","$RRD_FONT{'DEFAULT'}",
            "--font","$RRD_FONT{'TITLE'}",
            "--font","$RRD_FONT{'AXIS'}",
            "--font","$RRD_FONT{'LEGEND'}",
            "--font","$RRD_FONT{'UNIT'}",
            "--start", "$start",
            "--end", "now",
            "--lower-limit=0",
#            "--upper-limit=100",
            "--interlace", 
            "--imgformat","PNG",
            "--width=$IMGSIZE{W}",
            "--height=$IMGSIZE{H}",
            "--base","1024",
            "DEF:rtotal=${RRDFILE}:total:AVERAGE",
            "DEF:rfree=${RRDFILE}:free:AVERAGE",
            "DEF:rused=${RRDFILE}:used:AVERAGE",
            "DEF:rshared=${RRDFILE}:shared:AVERAGE",
            "DEF:rbuffed=${RRDFILE}:buffed:AVERAGE",
            "DEF:rcached=${RRDFILE}:cached:AVERAGE",
            "DEF:Ctotal=${RRDFILE}:total:LAST",
            "DEF:Cfree=${RRDFILE}:free:LAST",
            "DEF:Cused=${RRDFILE}:used:LAST",
            "DEF:Cshared=${RRDFILE}:shared:LAST",
            "DEF:Cbuffed=${RRDFILE}:buffed:LAST",
            "DEF:Ccached=${RRDFILE}:cached:LAST",
            "CDEF:Gfree=rfree,UN,0,rfree,IF,1024,*",
            "CDEF:Gused=rused,UN,0,rused,IF,1024,*",
            "CDEF:Gshared=rshared,UN,0,rshared,IF,1024,*",
            "CDEF:Gbuffed=rbuffed,UN,0,rbuffed,IF,1024,*",
            "CDEF:Gcached=rcached,UN,0,rcached,IF,1024,*",
            "CDEF:Rfree=rfree,1024,/",
            "CDEF:Rused=rused,1024,/",
            "CDEF:Rshared=rshared,1024,/",
            "CDEF:Rbuffed=rbuffed,1024,/",
            "CDEF:Rcached=rcached,1024,/",
            "HRULE:0#333333",
            "COMMENT:     SIZE (MB) ",
            "COMMENT:       Average ",
            "COMMENT:       Current ",
            "COMMENT:          MAX  ",
            "COMMENT:          MIN  ",
            "COMMENT:\\j",
            "COMMENT:    ",
            "AREA:Gused#CCFF99:USED   ",
            "GPRINT:Rused:AVERAGE:%14.2lf",
            "GPRINT:Rused:LAST:%14.2lf",
            "GPRINT:Rused:MAX:%14.2lf",
            "GPRINT:Rused:MIN:%14.2lf",
            "COMMENT:\\j",
            "COMMENT:    ",
            "STACK:Gfree#3399FF:FREE   ",
            "GPRINT:Rfree:AVERAGE:%14.2lf",
            "GPRINT:Rfree:LAST:%14.2lf",
            "GPRINT:Rfree:MAX:%14.2lf",
            "GPRINT:Rfree:MIN:%14.2lf",
            "COMMENT:\\j",
            "COMMENT:    ",
            "AREA:Gshared#FF6666:SHAR  ",
            "GPRINT:Rshared:AVERAGE:%14.2lf",
            "GPRINT:Rshared:LAST:%14.2lf",
            "GPRINT:Rshared:MAX:%14.2lf",
            "GPRINT:Rshared:MIN:%14.2lf",
            "COMMENT:\\j",
            "COMMENT:    ",
            "STACK:Gbuffed#000066:BUFF   ",
            "GPRINT:Rbuffed:AVERAGE:%14.2lf",
            "GPRINT:Rbuffed:LAST:%14.2lf",
            "GPRINT:Rbuffed:MAX:%14.2lf",
            "GPRINT:Rbuffed:MIN:%14.2lf",
            "COMMENT:\\j",
            "COMMENT:    ",
            "STACK:Gcached#99CCCC:CACH   ",
            "GPRINT:Rcached:AVERAGE:%14.2lf",
            "GPRINT:Rcached:LAST:%14.2lf",
            "GPRINT:Rcached:MAX:%14.2lf",
            "GPRINT:Rcached:MIN:%14.2lf",
            "COMMENT:\\j",
            "COMMENT: [$k_hname] / Updated\\:$Now \\r",
           ;


            if ($ERROR = RRDs::error) {
              die "  RRD_GENIMG_MEMORY:ERROR: $ERROR\n";
            }else{
                debug_msg ("RRD_GENIMG_MEMORY","END:$k_hname : Generate [$RRDIMG] ", 1);
            }
        }
    }


    sub RRD_GENIMG_NETWORK {

        # Called by  << [RRD_UPDATE->RRD_GENIMG->RRD_GENIMG_NETWORK]
        #
    
        debug_msg ( "  [RRD_GENIMG_NETWORK]",":start : ${k_hname}\n" , 1);
        my ( $k_hname, $RRD_FONT, $RRD_DATA_DIR, $RRD_IMG_DIR, $Now, $IMGSIZE, $Start_Days, $Title_Days, $i ) = @_;
    
        debug_msg ( "  [RRD_GENIMG_NETWORK]",":k_hname : ${k_hname}\n" , 0);
        debug_msg ( "  [RRD_GENIMG_NETWORK]",":RRD_DATA_DIR : ${RRD_DATA_DIR} \n" , 0);
        debug_msg ( "  [RRD_GENIMG_NETWORK]",":RRD_IMG_DIR : ${RRD_IMG_DIR} \n" , 0);
        debug_msg ( "  [RRD_GENIMG_NETWORK]",":RRD_FONT : $RRD_FONT{'DEFAULT'}/ $RRD_FONT{'TITLE'}/ $RRD_FONT{'LEGEND'}\n" , 0);
    
        debug_msg ( "  [RRD_GENIMG_NETWORK]",":Start_Days : $#{Start_Days} : $#Title_Days : ${i} \n" , 0);
        debug_msg ( "  [RRD_GENIMG_NETWORK]",":IMGSIZE :$IMGSIZE{'W'} * $IMGSIZE{'H'} \n" , 0);
    
        #--- NETWORK STAT -------------------------------------------
        #--- NETWORK------------------------------------
        #          DS:netin0:COUNTER:600:0:U
        #          DS:netout0:COUNTER:600:0:U
        #          DS:netin1:COUNTER:600:0:U
        #          DS:netout1:COUNTER:600:0:U
        #          DS:netin2:COUNTER:600:0:U
        #          DS:netout2:COUNTER:600:0:U

        $RRDFILE = "${RRD_DATA_DIR}/${k_hname}_netstat.rrd";
        if ( -e $RRDFILE ){ 
               $RRDIMG = "${RRD_IMG_DIR}/${k_hname}_${Title_Days[$i]}_NETWORK.png";
    
            $k_hostid = RRD_GET_HOSTID ($k_hname);       
    
        
        RRDs::graph "${RRDIMG}",
            "--title", "$k_hostid  Network-Traffice  [ $Title_Days[$i] ] ", 
            "--font","$RRD_FONT{'DEFAULT'}",
            "--font","$RRD_FONT{'TITLE'}",
            "--font","$RRD_FONT{'AXIS'}",
            "--font","$RRD_FONT{'LEGEND'}",
            "--start", "$start",
            "--end", "now",
            "--upper-limit","1024",
            "--lower-limit","-1024",
            "--base","1000","-v","Bit/Sec",
            "--interlace", 
            "--imgformat","PNG",
            "--width=$IMGSIZE{W}",
            "--height=$IMGSIZE{H}",
            "DEF:netin0=${RRDFILE}:netin0:AVERAGE",
            "DEF:netout0=${RRDFILE}:netout0:AVERAGE",
            "DEF:netin1=${RRDFILE}:netin1:AVERAGE",
            "DEF:netout1=${RRDFILE}:netout1:AVERAGE",
            "DEF:netin2=${RRDFILE}:netin2:AVERAGE",
            "DEF:netout2=${RRDFILE}:netout2:AVERAGE",
            "DEF:cnetin0=${RRDFILE}:netin0:LAST",
            "DEF:cnetout0=${RRDFILE}:netout0:LAST",
            "DEF:cnetin1=${RRDFILE}:netin1:LAST",
            "DEF:cnetout1=${RRDFILE}:netout1:LAST",
            "DEF:cnetin2=${RRDFILE}:netin2:LAST",
            "DEF:cnetout2=${RRDFILE}:netout2:LAST",
            "HRULE:0#333333",
            "CDEF:Nbytein0=netin0,UN,0,netin0,IF,8,*",
            "CDEF:Nbytein1=netin1,UN,0,netin1,IF,8,*",
            "CDEF:Nbytein2=netin2,UN,0,netin2,IF,8,*",
            "CDEF:Nbyteout0=netout0,UN,0,netout0,IF,-8,*",
            "CDEF:Nbyteout1=netout1,UN,0,netout1,IF,-8,*",
            "CDEF:Nbyteout2=netout2,UN,0,netout2,IF,-8,*",
            "CDEF:Cbytein0=cnetin0,8,*,1024,/",
            "CDEF:Cbytein1=cnetin1,8,*,1024,/",
            "CDEF:Cbytein2=cnetin2,8,*,1024,/",
            "CDEF:Cbyteout0=cnetout0,8,*,1024,/",
            "CDEF:Cbyteout1=cnetout1,8,*,1024,/",
            "CDEF:Cbyteout2=cnetout2,8,*,1024,/",
            "COMMENT:   NET-IO (kbit/s)",
            "COMMENT:   Average ",
            "COMMENT:   Current ",
            "COMMENT:       MAX ",
            "COMMENT:       MIN ",
            "COMMENT:\\j",
            "COMMENT: eth0 ",
            "AREA:Nbytein0#000099: In",
            "GPRINT:Cbytein0:AVERAGE:%10.2lf",
            "GPRINT:Cbytein0:LAST:%10.2lf",
            "GPRINT:Cbytein0:MAX:%10.2lf",
            "GPRINT:Cbytein0:MIN:%10.2lf",
            "COMMENT:\\j",
            "COMMENT:      ",
            "LINE1:Nbyteout0#FF0099:Out",
            "GPRINT:Cbyteout0:AVERAGE:%10.2lf",
            "GPRINT:Cbyteout0:LAST:%10.2lf",
            "GPRINT:Cbyteout0:MAX:%10.2lf",
            "GPRINT:Cbyteout0:MIN:%10.2lf",
            "COMMENT:\\j",
            "COMMENT: eth1 ",
            "AREA:Nbytein1#6699FF: In",
            "GPRINT:Cbytein1:AVERAGE:%10.2lf",
            "GPRINT:Cbytein1:LAST:%10.2lf",
            "GPRINT:Cbytein1:MAX:%10.2lf",
            "GPRINT:Cbytein1:MIN:%10.2lf",
            "COMMENT:\\j",
            "COMMENT:      ",
            "LINE1:Nbyteout1#FF9999:Out",
            "GPRINT:Cbyteout1:AVERAGE:%10.2lf",
            "GPRINT:Cbyteout1:LAST:%10.2lf",
            "GPRINT:Cbyteout1:MAX:%10.2lf",
            "GPRINT:Cbyteout1:MIN:%10.2lf",
            "COMMENT:\\j",
            "COMMENT: eth2 ",
            "AREA:Nbytein2#336699: In",
            "GPRINT:Cbytein2:AVERAGE:%10.2lf",
            "GPRINT:Cbytein2:LAST:%10.2lf",
            "GPRINT:Cbytein2:MAX:%10.2lf",
            "GPRINT:Cbytein2:MIN:%10.2lf",
            "COMMENT:\\j",
            "COMMENT:      ",
            "LINE1:Nbyteout2#CCFF99:Out",
            "GPRINT:Cbyteout2:AVERAGE:%10.2lf",
            "GPRINT:Cbyteout2:LAST:%10.2lf",
            "GPRINT:Cbyteout2:MAX:%10.2lf",
            "GPRINT:Cbyteout2:MIN:%10.2lf",
            "COMMENT:\\j",
            "COMMENT: [$k_hname] / Updated\\:$Now \\r",
    ;
            if ($ERROR = RRDs::error) {
              die "  RRD_GENIMG_NETWORK:ERROR: $ERROR\n";
            }else{
                debug_msg ("RRD_GENIMG_NETWORK","END:$k_hname : Generate [$RRDIMG] ", 1);
            };
        }
    }
    

    sub RRD_GENIMG_TCP {

        # Called by  << [RRD_UPDATE->RRD_GENIMG->RRD_GENIMG_TCP]
        #
    
        debug_msg ( "  [RRD_GENIMG_TCP]",":start : ${k_hname}\n" , 1);
        my ( $k_hname, $RRD_FONT, $RRD_DATA_DIR, $RRD_IMG_DIR, $Now, $IMGSIZE, $Start_Days, $Title_Days, $i ) = @_;
    
        debug_msg ( "  [RRD_GENIMG_TCP]",":k_hname : ${k_hname}\n" , 0);
        debug_msg ( "  [RRD_GENIMG_TCP]",":RRD_DATA_DIR : ${RRD_DATA_DIR} \n" , 0);
        debug_msg ( "  [RRD_GENIMG_TCP]",":RRD_IMG_DIR : ${RRD_IMG_DIR} \n" , 0);
        debug_msg ( "  [RRD_GENIMG_TCP] :RRD_FONT : $RRD_FONT{'DEFAULT'}/ $RRD_FONT{'TITLE'}/ $RRD_FONT{'LEGEND'}\n" , 0);

        #---CONNSTAT-------------------------------------
        #          DS:tcpActiveOpens:COUNTER:600:0:U
        #          DS:tcpPassiveOpens:COUNTER:600:0:U
        #          DS:tcpAttemptFails:COUNTER:600:0:U
        #          DS:tcpEstabResets:COUNTER:600:0:U
        #          DS:tcpCurrEstab:GAUGE:600:0:U
        $RRDFILE = "${RRD_DATA_DIR}/${k_hname}_netstat.rrd";
        if ( -e $RRDFILE ){ 
               $RRDIMG = "${RRD_IMG_DIR}/${k_hname}_${Title_Days[$i]}_TCP.png";
    
            $k_hostid = RRD_GET_HOSTID ($k_hname); 

        RRDs::graph "${RRDIMG}",
            "--title", "$k_hostid  TCP-Connection  [ $Title_Days[$i] ] ", 
            "--font","$RRD_FONT{'DEFAULT'}",
            "--font","$RRD_FONT{'TITLE'}",
            "--font","$RRD_FONT{'AXIS'}",
            "--font","$RRD_FONT{'LEGEND'}",
            "--start", "$start",
            "--end", "now",
            "--lower-limit=0",
            "--upper-limit=100",
            "--interlace", 
            "--imgformat","PNG",
            "--width=$IMGSIZE{W}",
            "--height=$IMGSIZE{H}",
            "DEF:ActiveOpens=${RRDFILE}:tcpActiveOpens:AVERAGE",
            "DEF:PassiveOpens=${RRDFILE}:tcpPassiveOpens:AVERAGE",
            "DEF:AttemptFails=${RRDFILE}:tcpAttemptFails:AVERAGE",
            "DEF:EstabResets=${RRDFILE}:tcpEstabResets:AVERAGE",
            "DEF:CurrEstab=${RRDFILE}:tcpCurrEstab:AVERAGE",
            "DEF:cActiveOpens=${RRDFILE}:tcpActiveOpens:LAST",
            "DEF:cPassiveOpens=${RRDFILE}:tcpPassiveOpens:LAST",
            "DEF:cAttemptFails=${RRDFILE}:tcpAttemptFails:LAST",
            "DEF:cEstabResets=${RRDFILE}:tcpEstabResets:LAST",
            "DEF:cCurrEstab=${RRDFILE}:tcpCurrEstab:LAST",
            "HRULE:0#333333",
            "CDEF:NActiveOpens=ActiveOpens,UN,0,ActiveOpens,IF",
            "CDEF:NPassiveOpens=PassiveOpens,UN,0,PassiveOpens,IF",
            "CDEF:NAttemptFails=AttemptFails,UN,0,AttemptFails,IF",
            "CDEF:NEstabResets=EstabResets,UN,0,EstabResets,IF",
            "CDEF:NCurrEstab=CurrEstab,UN,0,CurrEstab,IF",
            "CDEF:CActiveOpens=cActiveOpens",
            "CDEF:CPassiveOpens=cPassiveOpens",
            "CDEF:CAttemptFails=cAttemptFails",
            "CDEF:CEstabResets=cEstabResets",
            "CDEF:CCurrEstab=cCurrEstab",
            "COMMENT:    ",
            "COMMENT: CONNECTION ",
            "COMMENT:  Average  ",
            "COMMENT:  Current  ",
            "COMMENT:      MAX  ",
            "COMMENT:      MIN  ",
            "COMMENT:\\j",
            "COMMENT: ",
            "AREA:NActiveOpens#000066:ActiveOpens ",
            "GPRINT:CActiveOpens:AVERAGE:%10.2lf",
            "GPRINT:CActiveOpens:LAST:%10.2lf",
            "GPRINT:CActiveOpens:MAX:%10.2lf",
            "GPRINT:CActiveOpens:MIN:%10.2lf",
            "COMMENT:\\j",
            "COMMENT: ",
            "STACK:NPassiveOpens#CCFF99:PassiveOpens",
            "GPRINT:CPassiveOpens:AVERAGE:%10.2lf",
            "GPRINT:CPassiveOpens:LAST:%10.2lf",
            "GPRINT:CPassiveOpens:MAX:%10.2lf",
            "GPRINT:CPassiveOpens:MIN:%10.2lf",
            "COMMENT:\\j",
            "COMMENT: ",
            "STACK:NAttemptFails#FF0033:AttemptFails",
            "GPRINT:CAttemptFails:AVERAGE:%10.2lf",
            "GPRINT:CAttemptFails:LAST:%10.2lf",
            "GPRINT:CAttemptFails:MAX:%10.2lf",
            "GPRINT:CAttemptFails:MIN:%10.2lf",
            "COMMENT:\\j",
            "COMMENT: ",
            "STACK:NEstabResets#FF99FF:EstabResets ",
            "GPRINT:CEstabResets:AVERAGE:%10.2lf",
            "GPRINT:CEstabResets:LAST:%10.2lf",
            "GPRINT:CEstabResets:MAX:%10.2lf",
            "GPRINT:CEstabResets:MIN:%10.2lf",
            "COMMENT:\\j",
            "COMMENT: ",
            "STACK:NCurrEstab#3333FF:CurrEstab   ",
            "GPRINT:CCurrEstab:AVERAGE:%10.2lf",
            "GPRINT:CCurrEstab:LAST:%10.2lf",
            "GPRINT:CCurrEstab:MAX:%10.2lf",
            "GPRINT:CCurrEstab:MIN:%10.2lf",
            "COMMENT:\\j",
            "COMMENT: [$k_hname] / Updated\\:$Now \\r",
           ;


            if ($ERROR = RRDs::error) {
              die "  RRD_GENIMG_TCP:ERROR: $ERROR\n";
            }else{
                debug_msg ("RRD_GENIMG_TCP","END:$k_hname : Generate [$RRDIMG] ", 1);
            }
        }
    }
    

1;

