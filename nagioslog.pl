#!/usr/bin/perl -w
############################## nagioslog.pl #####################
# Version : 0.1
# Date :  Mar 13 2010
# Author  : wiburg ( owittenburg at googlemail.com)
# Licence : GPL - http://www.fsf.org/licenses/gpl.txt
#################################################################
# script is based on a public script which fixes the nagios time format.
# Unfortunately, I can't find the original sources.
# The script was formerly called fixnagioslog.pl.

use Term::ANSIColor qw(:constants);
use strict;
use Getopt::Long;
Getopt::Long::Configure('bundling');

sub help {
	print <<EOT
Usage: \ttail -f <nagios log file> | $0 [ -n ] [ -a ] [ --help]
 -n, --nocolor
   Don't colorize alert log messages.
   The default is to colorize alerts according to the state (ok = green, critical = red, ...)
 -a, --alerts
     Show only alert log messages (and passive check results).
 -h, --help
     Show this help.
Script parses the nagios log file output, fixes the time format and can colorize alert log messages.

EOT
}

sub usage {
	print "@_\n";
	help;
	exit 3
}
my $o_help;
my $o_nocolors;
my $o_onlyalerts;

Getopt::Long::Configure ("bundling");
GetOptions(
  'n' => \$o_nocolors,   'nocolor' => \$o_nocolors,
  'a' => \$o_onlyalerts, 'alerts'  => \$o_onlyalerts,
  'h' => \$o_help,       'help'    => \$o_help
);

# catching signals:
$SIG{'INT'}  = 'CLEANUP';
$SIG{'TERM'} = 'CLEANUP';
sub CLEANUP {
	print "\n\nGood by ...\n";
        print RESET;
	exit(0);
}


# fix the nagios timestamp
sub epochtime
{
  my $epoch_time = shift;
  my ($sec,$min,$hour,$day,$month,$year) = localtime($epoch_time);
  $year = 1900 + $year;
  $month++;
  return sprintf("%02d/%02d/%02d %02d:%02d:%02d", $year, $month, $day, $hour, $min, $sec);
}

sub isAlert 
{
  if ( $_[0] =~ /.? ALERT:|PASSIVE .* CHECK:/ ) {
    return 1;
  }
}

# parse the 
while (<>)
{
  my $epoch = substr $_, 1, 10;
  my $remainder = substr $_, 13;
  my $human_date = &epochtime($epoch);
  if ($o_onlyalerts) {
    if (!isAlert($remainder)) {
      next;
    }
  }
  print "[". $human_date . "] ";
  if ( !$o_nocolors ) {
    if ( $remainder =~ /SERVICE ALERT:/ ) {
      if ( $remainder =~ /.+;.+;OK;.+;.+;.*/ ) {
        print  GREEN "$remainder";
      }
      elsif ( $remainder =~ /.+;.+;WARNING;.+;.+;.*/ ) {
        print YELLOW "$remainder";
      }
      elsif ( $remainder =~ /.+;.+;UNKNOWN;.+;.+;.*/ ) {
        print MAGENTA "$remainder";
      }
      elsif ( $remainder =~ /.+;.+;CRITICAL;.+;.+;.*/ ) {
        print RED "$remainder";
      }
      else { 
        print BOLD "$remainder";
      }
      print RESET;
    }
    elsif ( $remainder =~ /HOST ALERT:/ ) {
      if ( $remainder =~ /.+;OK;.+;.+;.*/ ) {
        print  GREEN BOLD "$remainder";
      }
      elsif ( $remainder =~ /.+;DOWN;.+;.+;.*/ ) {
        print RED BOLD "$remainder";
      }
      print RESET;
    }
    else {
      print $remainder;
    }
  }
  else {
    print $remainder;
  }
}

print RESET;
exit;


