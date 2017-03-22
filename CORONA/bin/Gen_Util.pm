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

use FileHandle;


sub debug_msg {
    $DEBUG_OUT = 1;    # if 1 then print message;

    if ($DEBUG_OUT) {

        my($D_grp, @D_msg ) = @_;

        if ($DEBUG_LOG  ==  1 ){   # defined by rrdsnmp.conf

           chomp(@D_msg);
print " GRP : $D_grp \n ";
print " D+msg : @D_msg \n ";
print "=================================================\n";
            
           open ( FOUT, ">>$DEBUG_LOG_PATH/$DEBUG_LOG_FILE");
           print( FOUT   $D_grp ," ::" , @D_msg , "\n" );
           close(FOUT);
        }else{
           print(STDERR "$D_grp::$D_msg \n" );
        }
    }
}

sub readconf {
    my ( $configfile ) = @_;

    if ( ! -r $configfile ) {
	    print " Config File Not Found [rrdsnmp.conf] \n";
	    exit;
    }
    print " READCONF:   $configfile OPEN \n";

    #  RRDDATA    :  RRD file Location Path .
    #  rrdtool    :  rrdtool utility location path.
    #  IMGDIR     :  Graph image files Location Path .
    #  FONT_PATH  :  Font files  Location Path .
    #  LANGUAGE:  Graph image out Language ( ko | en )

    open(CONF ,$configfile) || (print("Could not find $configfile ($!)\n") && exit(1));
    while (<CONF>) {
       if (( $_ =~ /^RRDDATA/) || ($_ =~ /^rrdtool/) ||
           ($_ =~ /^IMGDIR/)   || ($_ =~ /^LANGUAGE/)||
           ($_ =~ /^DEBUG_LOG/)||
           ($_ =~ /^FONT_PATH/)||
           ($_ =~ /^KO_/)      || ($_ =~ /^EN_/)      )
       {
          chomp($_);
          @splited=split(" ",$_);
          if (defined($splited[1])) {
            ${$splited[0]} = $splited[1];
            debug_msg("READCONF","start:  ${splited[0]} = ${splited[1]} ", 0);
          }
       }
    }

    #Verificando se pode executar o rrdtool
    if (!(-r $rrdtool) || !(-x $rrdtool)) {
         die("READCONF: Could not execute/find rrdtool program ($!)\nCheck the rrdtool directive in your config file\n ");
    } else {
         debug_msg("READCONF"," Found $rrdtool", 0);
    }
}


#  READ INPUT Stream With  SNMP LOG
#       c$oronafile = "../conf/corona.conf";
#------------------------------------------------------------------
sub readcoronafile {
    my ( $coronafile ) = @_;

    if ( ! -r $coronafile ) {
        print " Config File Not Found [corona.conf] \n";
        exit;
    }

    $Fcnt=0;
    print " READCONF:   $configfile OPEN \n";
    
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
}

1;
