<?
     require_once "{$_SERVER['DOCUMENT_ROOT']}/inc/charset.inc";
     require_once "{$_SERVER['DOCUMENT_ROOT']}/inc/corona_web.inc";
?>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=euc-kr">
    <meta http-equiv=Pragma content=no-cache>
    <meta http-equiv=Cache-Control content=No-Cache>

    <title><?echo "서버정보 : [[ $PHP_AUTH_USER ]] "; ?></title>

<style type="text/css">
frameset,frame {
    margin:0px;
    padding:0px;
    border:0px;
    background-color:buttonface;
}
</style>
</head>

<?
        $logingb=0;

		if( ! isset($_REQUEST['mloc']) ) $mloc = "right";
        else $mloc = $_REQUEST['mloc'];
		//if( ! isset($mloc) ) $mloc = "right";
    
		if ( $mloc == "right" ){
			echo <<<TB1
          <frameset cols=*,170  border=1> 
            <frame src='blank.html' name="sbody" noresize>
            <frame src='/common/Left_Menu.cdr?mloc=right' name="statmain" noresize >
          </frameset>
TB1;
		}else{
			echo <<<TB2
          <frameset cols=170,*  border=1> 
            <frame src='/common/Left_Menu.cdr?mloc=left' name="statmain" noresize >
            <frame src='blank.html' name="sbody" noresize>
          </frameset>
TB2;
		}
?>
</html>
