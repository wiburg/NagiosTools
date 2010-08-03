#!/usr/bin/perl

#    Copyright (C) 2004 Altinity Limited
#    E: info@altinity.com    W: http://www.altinity.com/
#    Modified by pierre.gremaud@bluewin.ch
#    
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#    
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.    See the
#    GNU General Public License for more details.
#    
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA    02111-1307    USA
# 
# Changelog
# * Mon Aug 02 2010 owittenburg@googlemail.com
# - added battery capacity to performance data

use Net::SNMP;
use Getopt::Std;

$script    = "check_ups_apc.pl";
$script_version = "1.1";

$metric = 1;

$ipaddress = "192.168.1.1"; 	# default IP address, if none supplied
$version = "1";			# SNMP version
$timeout = 2;			# SNMP query timeout
# $warning = 100;			
# $critical = 150;
$status = 0;
$returnstring = "";
$perfdata = "";

$community = "public"; 		# Default community string

$oid_sysDescr = ".1.3.6.1.2.1.1.1.0";
$oid_upstype = ".1.3.6.1.4.1.318.1.1.1.1.1.1.0";
$oid_battery_capacity = ".1.3.6.1.4.1.318.1.1.1.2.2.1.0";
$oid_output_status = ".1.3.6.1.4.1.318.1.1.1.4.1.1.0";
$oid_output_current = ".1.3.6.1.4.1.318.1.1.1.4.2.4.0";
$oid_output_load = ".1.3.6.1.4.1.318.1.1.1.4.2.3.0";
$oid_temperature = ".1.3.6.1.4.1.318.1.1.1.2.2.2.0";

$upstype = "";
$battery_capacity = 0;
$output_status = 0;
$output_current =0;
$output_load = 0;
$temperature = 0;


# Do we have enough information?
if (@ARGV < 1) {
     print "Too few arguments\n";
     usage();
}

getopts("h:H:C:w:c:");
if ($opt_h){
    usage();
    exit(0);
}
if ($opt_H){
    $hostname = $opt_H;
}
else {
    print "No hostname specified\n";
    usage();
}
if ($opt_C){
    $community = $opt_C;
}
else {
}



# Create the SNMP session
my ($s, $e) = Net::SNMP->session(
     -community  =>  $community,
     -hostname   =>  $hostname,
     -version    =>  $version,
     -timeout    =>  $timeout,
);

main();

# Close the session
$s->close();

if ($status == 0){
    print "Status is OK - $returnstring|$perfdata\n";
    # print "$returnstring\n";
}
elsif ($status == 1){
    print "Status is a WARNING level - $returnstring|$perfdata\n";
}
elsif ($status == 2){
    print "Status is CRITICAL - $returnstring|$perfdata\n";
}
else{
    print "Problem with plugin. No response from SNMP agent.\n";
}
 
exit $status;


####################################################################
# This is where we gather data via SNMP and return results         #
####################################################################

sub main {

        #######################################################
 
    if (!defined($s->get_request($oid_upstype))) {
        if (!defined($s->get_request($oid_sysDescr))) {
            $returnstring = "SNMP agent not responding";
            $status = 1;
            return 1;
        }
        else {
            $returnstring = "SNMP OID does not exist";
            $status = 1;
            return 1;
        }
    }
     foreach ($s->var_bind_names()) {
         $upstype = $s->var_bind_list()->{$_};
    }
    
    #######################################################
 
    if (!defined($s->get_request($oid_battery_capacity))) {
        if (!defined($s->get_request($oid_sysDescr))) {
            $returnstring = "SNMP agent not responding";
            $status = 1;
            return 1;
        }
        else {
            $returnstring = "SNMP OID does not exist";
            $status = 1;
            return 1;
        }
    }
     foreach ($s->var_bind_names()) {
         $battery_capacity = $s->var_bind_list()->{$_};
    }

    #######################################################
 
    if (!defined($s->get_request($oid_output_status))) {
        if (!defined($s->get_request($oid_sysDescr))) {
            $returnstring = "SNMP agent not responding";
            $status = 1;
            return 1;
        }
        else {
            $returnstring = "SNMP OID does not exist";
            $status = 1;
            return 1;
        }
    }
     foreach ($s->var_bind_names()) {
         $output_status = $s->var_bind_list()->{$_};
    }
    #######################################################
 
    if (!defined($s->get_request($oid_output_current))) {
        if (!defined($s->get_request($oid_sysDescr))) {
            $returnstring = "SNMP agent not responding";
            $status = 1;
            return 1;
        }
        else {
            $returnstring = "SNMP OID does not exist";
            $status = 1;
            return 1;
        }
    }
     foreach ($s->var_bind_names()) {
         $output_current = $s->var_bind_list()->{$_};
    }
    #######################################################
 
    if (!defined($s->get_request($oid_output_load))) {
        if (!defined($s->get_request($oid_sysDescr))) {
            $returnstring = "SNMP agent not responding";
            $status = 1;
            return 1;
        }
        else {
            $returnstring = "SNMP OID does not exist";
            $status = 1;
            return 1;
        }
    }
     foreach ($s->var_bind_names()) {
         $output_load = $s->var_bind_list()->{$_};
    }
    #######################################################
  
    if (!defined($s->get_request($oid_temperature))) {
        if (!defined($s->get_request($oid_sysDescr))) {
            $returnstring = "SNMP agent not responding";
            $status = 1;
            return 1;
        }
        else {
            $returnstring = "SNMP OID does not exist";
            $status = 1;
            return 1;
        }
    }
     foreach ($s->var_bind_names()) {
         $temperature = $s->var_bind_list()->{$_};
    }
    #######################################################
     
    $returnstring = "";
    $status = 0;
    $perfdata = "";

    if (defined($oid_upstype)) {
        $returnstring = "$upstype - ";
    }

    if ($battery_capacity < 25) {
        $returnstring = $returnstring . "BATTERY CAPACITY $battery_capacity% - ";
        $status = 2;
    }
    elsif ($battery_capacity < 50) {
        $returnstring = $returnstring . "BATTERY CAPACITY $battery_capacity% - ";
        $status = 1 if ( $status != 2 );
    }
    elsif ($battery_capacity <= 100) {
        $returnstring = $returnstring . "BATTERY CAPACITY $battery_capacity% - ";
    }
    else {
        $returnstring = $returnstring . "BATTERY CAPACITY UNKNOWN! - ";
        $status = 3 if ( ( $status != 2 ) && ( $status != 1 ) );
    }

    if ($output_status eq "2"){
        $returnstring = $returnstring . "STATUS NORMAL - ";
    }
    elsif ($output_status eq "3"){
        $returnstring = $returnstring . "UPS RUNNING ON BATTERY! - ";
        $status = 1 if ( $status != 2 );
    }
    elsif ($output_status eq "9"){
        $returnstring = $returnstring . "UPS RUNNING ON BYPASS! - ";
        $status = 1 if ( $status != 2 );
    }
    elsif ($output_status eq "10"){
        $returnstring = $returnstring . "HARDWARE FAILURE UPS RUNNING ON BYPASS! - ";
        $status = 1 if ( $status != 2 );
    }
    elsif ($output_status eq "6"){
        $returnstring = $returnstring . "UPS RUNNING ON BYPASS! - ";
        $status = 1 if ( $status != 2 );
    }
    else {
        $returnstring = $returnstring . "UNKNOWN OUTPUT STATUS! - ";
        $status = 3 if ( ( $status != 2 ) && ( $status != 1 ) );
    }

    $perfdata = $perfdata . "'capacity'=$battery_capacity ";
    if ($output_load > 90) {
        $returnstring = $returnstring . "OUTPUT LOAD $output_load% - ";
        $perfdata = $perfdata . "'load'=$output_load ";
        $status = 2;
    }
    elsif ($output_load > 80) {
        $returnstring = $returnstring . "OUTPUT LOAD $output_load% - ";
        $perfdata = $perfdata . "'load'=$output_load ";
        $status = 1 if ( $status != 2 );
    }
    elsif ($output_load >= 0) {
        $returnstring = $returnstring . "OUTPUT LOAD $output_load% - ";
        $perfdata = $perfdata . "'load'=$output_load ";
    }
    else {
        $returnstring = $returnstring . "OUTPUT LOAD UNKNOWN! - ";
        $perfdata = $perfdata . "'load'=NAN ";
        $status = 3 if ( ( $status != 2 ) && ( $status != 1 ) );
    }

    if ($temperature > 32) {
        $returnstring = $returnstring . "TEMPERATURE $temperature C";
        $perfdata = $perfdata . "'temp'=$temperature ";
        $status = 2;
    }
    elsif ($temperature > 28) {
        $returnstring = $returnstring . "TEMPERATURE $temperature C";
        $perfdata = $perfdata . "'temp'=$temperature ";
        $status = 1 if ( $status != 2 );
    }
    elsif ($temperature >= 0) {
        $returnstring = $returnstring . "TEMPERATURE $temperature C";
        $perfdata = $perfdata . "'temp'=$temperature ";
    }
    else {
        $returnstring = $returnstring . "TEMPERATURE UNKNOWN!";
        $perfdata = $perfdata . "'temp'=NAN ";
        $status = 3 if ( ( $status != 2 ) && ( $status != 1 ) );
    }
}

####################################################################
# help and usage information                                       #
####################################################################

sub usage {
    print << "USAGE";
-----------------------------------------------------------------	 
$script v$script_version

Monitors APC SmartUPS via AP9617 SNMP management card.

Usage: $script -H <hostname> -C <community> [...]

Options: -H 	Hostname or IP address
         -C 	Community (default is public)
	 
-----------------------------------------------------------------	 
Copyright 2004 Altinity Limited	 
	 
This program is free software; you can redistribute it or modify
it under the terms of the GNU General Public License
-----------------------------------------------------------------

USAGE
     exit 1;
}


