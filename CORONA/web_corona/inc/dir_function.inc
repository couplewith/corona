<?
     require_once "{$_SERVER['DOCUMENT_ROOT']}/inc/charset.inc";
     require_once "{$_SERVER['DOCUMENT_ROOT']}/inc/corona_web.inc";

$DEBUG=0;

############################################
# GET_DIR_LIST 생성된 이미지 폴더를 검색 한다.
#############################################



function GET_IMAGE_PATH( $hostnm, $fname ){
    global $DEBUG, $CORONA;

    #  domain/hostid/ads.couplewith.com_YEAR_MEMSTAT.png 
    # '*/kaatal.com/admin/admin.kaatal.com_DAY_CPU.png'>
    #  (hostname , fname ) == (  admin.kaatal.com DAY_CPU )
    if($DEBUG) echo "<br> $mfile // $hostnm // $fname "; 

    if( isset ($hostnm) &&
        isset ($fname ) )
    {
         if (ereg ("([0-9a-z\.]+)/([0-9a-z]+)", $hostnm, $regs)) {

            $image_file="${CORONA['IMAGE']}/${hostnm}/${regs[2]}.${regs[1]}_${fname}.png";
        }
    }

    return $image_file;
}

function GET_DIR_LIST( $level , $target=""){

    global $DEBUG, $CORONA;

    if( ! isset($level) ) return "";
    if($DEBUG) echo "<BR> GET_DIR_LIST : start ";

    // $level => host or domain 
    if($level == "host"){
         $read_dir = "${CORONA['IMAGE']}/$target";
         $read_fmt = "([a-z0-9]+)";
    }else{
         $read_dir = "${CORONA['IMAGE']}";
         $read_fmt = "([a-z0-9]+).([a-z0-9\.]+)";
    }

    if($DEBUG) echo "<BR>===[$level]=================================== ";
    if($DEBUG) echo "<BR> GET_DIR_LIST : read_dir = [$read_dir] ";
    if($DEBUG) echo "<BR> GET_DIR_LIST : read_fmt = [$read_fmt] ";

    if (is_dir($read_dir)) {
      if ( ! $fhandle = @opendir($read_dir)) {
	return false;
      }
    }

    if( isset( $fhandle )) {
       while (($files = readdir($fhandle))!==false)
       {
           if ( ereg(${read_fmt} , $files) ){
               $File_lst[]=$files;
               if($DEBUG) echo "<BR> GET_DIR_LIST : files = [$files] ";
           }
       }
       closedir($fhandle);
    }

    if($DEBUG) echo "<BR> GET_DIR_LIST : end ";

    sort ($File_lst);

    return $File_lst;
    unset( $File_lst );
}

############################################
# CORONA_TREE : 이미지 디렉 토리를 출력한다.
#############################################


function CORONA_TREE(  ) {
    global $CORONA;


    // 1. GET_DIR_LIST( $level )

    $Domain_list = GET_DIR_LIST( "domain", "/");
    
  
    for ($i=0 ; $i < count($Domain_list); $i++)
    {
         $Mname=strtoupper($Domain_list[$i]);
         $domain_id = $Domain_list[$i];

         echo  <<<TA
                  <img src=/image/plus.gif id=${domain_id} class=outline style='cursor:hand'
                      WIDTH=11 HEIGHT=11 onClick="clickHandler()">
                       <Font color=#333668><B>&nbsp;$Mname</B><br> </img>
                   <DIV id=${domain_id}d style='display:none'>
TA;
         $Host_list = GET_DIR_LIST( "host", $Domain_list[$i] );
         CORONA_TREE_HTML($domain_id, $Host_list );

          echo " </DIV>";
    }

}

function CORONA_TREE_HTML($Domain_id, $Host_list ) {

    for ($j=0 ; $j < count($Host_list); $j++)
    {
        /// 파일 명에서 해당 파트를 찾고 hostname 을 잘라 내어 출력 한다.
            $hostnm = "${Domain_id}/${Host_list[$j]}";
            $host_id = $Host_list[$j];
            echo <<<S_LIST
                  &nbsp;&nbsp;&nbsp;
                 <img src=/image/minus.gif border=0 width=11 height=11 onClick="clickHandler();"></img>
                 &nbsp;
                  <A href="${CORONA['WEB']}/Host_Summery.cdr?host=${hostnm}" target="sbody" >
                  ${host_id}
                 </A>
                  <BR>
S_LIST;
    }

    unset($File_lst);
}



function CORONA_TREE_ARRAY(  ) {
    global $CORONA;


    // 1. GET_DIR_LIST( $level )

    $Domain_list = GET_DIR_LIST( "domain", "/");
    
  
    for ($i=0 ; $i < count($Domain_list); $i++)
    {
         $Mname=strtoupper($Domain_list[$i]);
         $domain_id = $Domain_list[$i];


         $Corona_Tree[$domain_id] = GET_DIR_LIST( "host", $Domain_list[$i] );

    }

    return $Corona_Tree;

}

?>
