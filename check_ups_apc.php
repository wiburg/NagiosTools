<?php
/*
 * PNP Template for check_ups_apc.pl nagios plugin
 */

$opt[1] = "--lower=0 --upper=100 --vertical-label \"%\" --title \"capacity, load, and temperature of $hostname\" ";
$def[1] =  "DEF:var1=$RRDFILE[1]:$DS[1]:MAX " ;
$def[1] .= "DEF:var2=$RRDFILE[1]:$DS[2]:MAX " ;
$def[1] .= "DEF:var3=$RRDFILE[1]:$DS[3]:MAX " ;

$def[1] .= "AREA:var1#99ccff:\"Capacity in % \" " ;
$def[1] .= "GPRINT:var1:LAST:\"%6.2lf last\" " ;
$def[1] .= "GPRINT:var1:AVERAGE:\"%6.2lf avg\" " ;
$def[1] .= "GPRINT:var1:MAX:\"%6.2lf max\\n\" ";

$def[1] .= "AREA:var2#99ff33:\"Load in % \" " ;
$def[1] .= "GPRINT:var2:LAST:\"%6.2lf last\" " ;
$def[1] .= "GPRINT:var2:AVERAGE:\"%6.2lf avg\" " ;
$def[1] .= "GPRINT:var2:MAX:\"%6.2lf max\\n\" ";

$def[1] .= "LINE:var3#cc3333:\"Temperature \" " ;
$def[1] .= "GPRINT:var3:LAST:\"%6.2lf last\" " ;
$def[1] .= "GPRINT:var3:AVERAGE:\"%6.2lf avg\" " ;
$def[1] .= "GPRINT:var3:MAX:\"%6.2lf max\\n\" " ;

?>
