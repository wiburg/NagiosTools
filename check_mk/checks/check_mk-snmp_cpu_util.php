<?php

$opt[1] = "--vertical-label 'CPU utilization %' -l0  -u 100 --title \"CPU Utilization for $hostname\" ";
#
$def[1] =  "DEF:user=$RRDFILE[1]:$DS[1]:AVERAGE " ;
$def[1] .= "DEF:system=$RRDFILE[2]:$DS[2]:AVERAGE " ;
$def[1] .= "DEF:wait=$RRDFILE[3]:$DS[3]:AVERAGE " ;
$def[1] .= "CDEF:us=user,system,+ ";
$def[1] .= "CDEF:sum=us,wait,+ ";
$def[1] .= "CDEF:idle=100,sum,- ";

if ($TEMPLATE[1] == "check_mk-decru_cpu")
   $thirdname = "IRQs";
else
   $thirdname = "Wait";


$def[1] .= ""
        . "COMMENT:Average\:  "
        . "AREA:system#ff6000:\"System\" " 
        . "GPRINT:system:AVERAGE:\"%2.1lf%%  \" " 
        . "AREA:user#60f020:\"User\":STACK " 
        . "GPRINT:user:AVERAGE:\"%2.1lf%% \" " 
        . "AREA:wait#00b0c0:\"$thirdname\":STACK " 
        . "GPRINT:wait:AVERAGE:\"%2.1lf%%  \" " 
        . "LINE:sum#004080:\"Total\" " 
        . "GPRINT:sum:AVERAGE:\"%2.1lf%%  \\n\" "

        . "COMMENT:\"Last\:   \" "
        . "AREA:system#ff6000:\"System\" " 
        . "GPRINT:system:LAST:\"%2.1lf%%  \" " 
        . "AREA:user#60f020:\"User\":STACK " 
        . "GPRINT:user:LAST:\"%2.1lf%%  \" " 
        . "AREA:wait#00b0c0:\"$thirdname\":STACK " 
        . "GPRINT:wait:LAST:\"%2.1lf%%  \" " 
        . "LINE:sum#004080:\"Total\" " 
        . "GPRINT:sum:LAST:\"%2.1lf%%  \\n\" "

        ."";

?>
