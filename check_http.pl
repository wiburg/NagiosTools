#!/usr/bin/perl -w
#
## check_http.pl
## Copyright (c) 2008, Oliver Wittenburg  <oliver@wiburg.de>
## Patch for correct handling of https from Jose Pedro Oliveira
## 
## This program is free software: you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation, either version 3 of the License, or (at your option) any later
## version.
## 
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
## FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program.  If not, see <http://www.gnu.org/licenses/>.
#
#
# A new check_http Nagios Plugin with the following requirement(s):
# - able to use multiple conditions for warning or critical status
# example
# ok: 200 ok and contents "abc" or "def" 
# warning: if one gets a 200 OK and content "xyz"
# critical: 500 Server error

use strict;
use LWP::UserAgent;
use Getopt::Long;
use Time::HiRes qw( gettimeofday );

# variables/lists
my $cexpr;
my $ccode;
my $protocol = "http";
my $o_url;
my $o_host;
my $o_port;
my $o_ssl = 0;
my @o_criticalHttpCodes;
my @o_criticalExpressions;
my @o_warningHttpCodes;
my @o_warningExpressions;
my $proxy_url;
my $o_help;


# FIXME:
sub help {
    print <<EOT
Usage: \t$0 -H <Host> [-u <uri>] [-p <port>] [-s]
	[-w warning http code] [-c critical http code]
	[-W warning content regex] [-C critical content regex]

This plugin tests the HTTP service on the specified host.  The warning and/or
critical conditions can bei either the http response code or a regular
expression which matches the http body.

-H <Hostname>
-u <uri> (default: /)
-p <port> (default: 80)
-P, --proxy <proxy url>
  example: --proxy="http://172.16.1.252:8080"
-s, --ssl 
  connection via ssl (default off)
-w <warning httpresponsecode>
  state=warning, if the specified http code (404, 303, ...) is returned
-c <critical httpresponsecode>
  state=critical, if the specified http code (404, 303, ...) is returned
-W <warning content regex> 
  if regex matches against page content -> state = warning
-C <critical content regex>
  if regex matches against page content -> state = critical
-h, --help
  prints this help message

The -w, -c, -W and -C options can be specified multiple times.

If no -w, -c, -W or -C option is specified the following rules apply:
  OK:           HTTP Response Code 2xx
  WARNING:      HTTP Response Code 3xx
  CRITICAL:     HTTP Response Code 4xx or 5xx
But without -w, -c, -W and -C option you better use the standard check_http plugin.
EOT
}

# FIXME: timeouts, user, password, follow redirects
Getopt::Long::Configure ("bundling");
GetOptions(
  'u=s'  => \$o_url,      'url=s'  => \$o_url,
  's'    => \$o_ssl,      'ssl'    => \$o_ssl,
  'H=s'  => \$o_host,     'host=s' => \$o_host,
  'p=i'  => \$o_port,     'port=i' => \$o_port,
  'w=s'  => \@o_warningHttpCodes, 'warningHttpCode=s' => \@o_warningHttpCodes,
  'W=s'  => \@o_warningExpressions, 'warningExpression=s' => \@o_warningExpressions,
  'c=s'  => \@o_criticalHttpCodes, 'criticalHttpCode=s' => \@o_criticalHttpCodes,
  'C=s'	 => \@o_criticalExpressions, 'criticalExpression=s' => \@o_criticalExpressions,
  'P=s'  => \$proxy_url, 'proxy=s' => \$proxy_url,
  'h'    => \$o_help,      'help'  => \$o_help
);
if ($o_help) { help(); exit 0};

# Follwing Parameters have to be set by the user, otherwise exit ...:
if (!$o_host) { print "Host not specified\n"; exit 3; };

# Setting some default values:
# ....
if (!$o_port and $o_ssl == 0 ) {$o_port = 80 }
if (!$o_port and $o_ssl == 1 ) { $o_port = 443 }
if (!$o_url ) { $o_url = "/" }
if ($o_ssl) { $protocol = "https" }

my $start = gettimeofday();
my $ua = LWP::UserAgent->new();
$ua->agent('Nagios chech_http.pl/0.1');

if ($proxy_url) {
  $ua->proxy(['http','https'], "$proxy_url");
}

$ua->timeout(10); # 10 seconds timeout FIXME: configurable
$ua->max_redirect(7); # 7 is the default

my $url = $protocol . "://" . $o_host . ":" . $o_port . $o_url ;
my $request = HTTP::Request->new('GET', $url);
my $response = $ua->request($request);
# Get the HTTP Responde Code (200, 404, 500 ...)
my $code = $response->code();
my $content = $response->content();

my $end = gettimeofday();
my $delta = ($end - $start);
# for performance measurements (sometimes later):
# print "$delta\n";

# Critical?
if (@o_criticalHttpCodes or @o_criticalExpressions) {
  # Test wether a (user-defined) critical HTTP-Code is returned
  foreach $ccode (@o_criticalHttpCodes) {
    if ($code =~ m/$ccode/) {
      print "Status: " . $response->status_line . "\n";
      exit (2);
    }
  }
  # Test wether a (user-defined) critical string can be found in the body
  foreach $cexpr (@o_criticalExpressions) {
    if ($content =~m/$cexpr/) {
      print "Status: Critical. Matching critical regular expression\n";
      exit (2);
    }
  }
} 
else {
  # no critical condition was supplied by user
  if ($code >= 400) {
    print "Status: Critical (" . $response->status_line . ")\n";
    exit 2;
  }
}

# Warning?
if (@o_warningHttpCodes or @o_warningExpressions) {
  # Test wether a (user-defined) warning HTTP-Code is returned
  foreach $ccode (@o_warningHttpCodes) {
    if ($code =~ m/$ccode/) {
      print "Status: " . $response->status_line . "\n"; 
      exit 1;
    }
  }
  # Test wether a (user-defined) warning string can be found in the body
  foreach $cexpr (@o_warningExpressions) {
    if ($content =~m/$cexpr/) {
      print "Status: Warning. Matching warning regular expression\n";
      exit 1;
    }
  }
}
else {
  # no critical condition was supplied by user
  if ($code >= 300) {
    print "Status: WARNING (" . $response->status_line . ")\n";
    exit 1;
  }
}

# ?
print "Status: " . $response->status_line . "\n";


