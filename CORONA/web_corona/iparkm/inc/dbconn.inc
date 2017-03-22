<?
  $DB["HOST"]="maindb.crepot.com";
  $DB["USER"]="kaatalweb";
  $DB["PASS"]="Rkxkfdnpq";
  $DB["DBNAME"]="crepot_main";

   $dbconn = mysql_connect($DB["HOST"], $DB["USER"], $DB["PASS"]);
   if (!$dbconn) {
	die(' dbconn.inc : Could not connect: ' . mysql_error());
   }
 


?>
