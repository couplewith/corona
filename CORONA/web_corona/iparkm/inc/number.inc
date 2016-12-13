<?

function format_number($value, $decimal_pos='2',$decimal_padding="0", $dec_sep = '.', $thousands_sep=',' ){
       $value          =  number_format($value,$decimal_pos,"$dec_sep","$thousands_sep");    // will return 12345.67
       return $value;
/**
       $number      = explode('.',$value);
       $number[1]    = (isset($number[1]))?$number[1]:''; 
       $decimal    = value_pad($number[1], $decimal_pos, $decimal_padding);
       if ( is_null($number[1]){
           return (float) $number[0];
       }else{
           return (float) $number[0].'.'.$decimal;
       }
**/
}
function format_decimal($value,$decimal_places='2',$decimal_padding="0"){
       /* firstly format number and shorten any extra decimal places */
       /* Note this will round off the number pre-format $value if you dont want this fucntionality */
       $value          =  number_format($value,$decimal_places,'.',',');    // will return 12345.67
       $number      = explode('.',$value);
       $number[1]    = (isset($number[1]))?$number[1]:''; 
       $decimal    = str_pad($number[1],$decimal_places,$decimal_padding);
       return (float) $number[0].'.'.$decimal;
}
function format_ratio($value_up, $value_down, $out="echo",  $font_size='6pt', $font_color='black'){
   if($value_down == 0 ){
       $ret = format_number(0, 2, 0 );
   }else{
       $ret= $value_up/ $value_down * 100;
       $ret = format_number($ret, 2, 0 );
   }

   $ret = "<font style='font-size=$font_size; font-weight=normal ;color=$font_color;'> $ret%</font>";
   
   if( strcmp($out, "return") ){
       echo $ret;
   }else{
       return $ret;
   }
}


?>
