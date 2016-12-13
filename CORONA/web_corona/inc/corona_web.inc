<?
    //***********************************
    // For WEB_CORONA VER 3.0 php
    // Copyright: 2003. 6. 22 Dr.choi 
    //          : 2007. 7. 10 Dr.choi 
    //             Korea Linux Mannia
    //***********************************
    require_once "{$_SERVER['DOCUMENT_ROOT']}/inc/charset.inc";

    $CHARSET="euc-kr";

    if (!headers_sent()) {
      header("Content-Type:text/html; charset=$CHARSET");
      header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
      //header('Last-Modified: '.gmdate('D, d M Y H:i:s').' GMT');
      header('Cache-Control: private, no-cache');
      header('Pragma: no-cache');
    }

    $CORONA['VER']="Corona web NMS V3.3";
    $CORONA['COPY']=gmdate('Y. d ')."IN KOREA By Dr.Choi ";


    //$CORONA['WEB']="http://manager.interparkm.co.kr";
    $CORONA['WEB']="http://{$_SERVER['HTTP_HOST']}";

    $CORONA['BASE']="/svc/web_app/CORONA";
    $CORONA['company']="iparkm";

  // CORONA_DB
    $CORONA['DB']    = "${CORONA['BASE']}/data";
  // CORONA_IMAGE
    $CORONA['IMAGE'] = "${CORONA['BASE']}/img";
  // CORONA_HTML
    $CORONA['HTML']  = "${CORONA['BASE']}/htmls";

    //***********************************
    // For Smenu.php
    //***********************************
    //$CORONA['HOSTS'] = array("crepot.com","netffice.com","zinny.com", "photojoy.com");
    $CORONA['HOSTS'] = array("forket.com","goople.co.kr","541.co.kr");

    
    //***********************************
    // For Server Summery and user STATUS
    //***********************************
    $GRAPH_DATE   = array("DAY","MONTH","WEEK", "YEAR");
    $GRAPH_STATUS = array("TCP", "NETWORK", "MEMORY", "CPU","IO", "LOAD");

    function GetVar( $vname, $value="" ){
        if ( isset($_GET[$vname] ) ) {
            $ret= $_GET[$vname];
        }else
        if ( isset($_POST[$vname] ) ) {
            $ret= $_POST[$vname];
        }else{
            $ret= $value;
        }
        return $ret;
    }


?>
