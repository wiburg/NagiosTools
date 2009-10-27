#!/usr/bin/perl -w
#

use DBI;
use HTTP::Date;
use Getopt::Long;
use vars qw($o_timelimit $o_host $o_user $o_pass $o_port $o_help );
use vars qw($PROGNAME);
use lib "/usr/local/nagios/libexec"  ;
use utils qw($TIMEOUT %ERRORS &print_revision &support &usage);



# Default:
# Timelimit in seconds:
my $o_timelimit = 60;
my $o_port = 3306;

sub print_usage {
    print "\nUsage: \t$0 -H <mysqlserver> [-P <port>] -d <database> -u <user> -p <password> | -i instance_name | [ -t timeframe (in seconds) | -h ]\n";
}

sub help {
    print "\n Checks wether nagios db is updated on a regular basis.\n";
    print_usage ();
    print <<EOT;

-h, --help
    print this help message

EOT
}

    Getopt::Long::Configure ("bundling");
        GetOptions(
	'd=s'   => \$o_db,      'database=s'  => \$o_db,
	'H=s'   => \$o_host,    'host=s'  => \$o_host,
	'P=i'   => \$o_port,    'port=i'  => \$o_port,
	'u=s'   => \$o_user,    'user=s'  => \$o_user,
	't=i'	=> \$o_timelimit, 'timelimit=i' => \$o_timelimit,
	'p=s'   => \$o_pass,    'pass=s'  => \$o_pass,
	'i=s'   => \$o_instance, 'instance=s'  => \$o_instance,
	'h'   => \$o_help,     	'help'  => \$o_help
	);
    if (defined ($o_help) ) { help(); exit 0};
    if (defined ($o_host) ) {$host = "$o_host"; }
    else
    { help(); exit 0};

    ($o_db) || ($o_db = shift) || usage("No database specified\n");
    my $database = $o_db if ($o_db =~ /^([-_.A-Za-z0-9]+\$?)$/);
    ($database) || usage("Invalid db: $o_db\n");

    ($o_user) || ($o_user = shift) || usage("user not specified\n");
    my $user = $o_user if ($o_user =~ /^([-_.A-Za-z0-9]+\$?)$/);
    ($user) || usage("Invalid user name: $o_user\n");

    ($o_pass) || ($o_pass = shift) || usage("password not specified\n");
    my $passwd = $o_pass if ($o_pass =~ /^([-_.A-Za-z0-9]+\$?)$/);
    ($passwd) || usage("Invalid password: $o_pass\n");
    

# connect to mysql
$db = "DBI:mysql:database=$database;host=$host;port=$o_port";
$dbh_db = DBI->connect ($db, $user, $passwd) or $abort=1;
if ($abort) {
 print ("ERROR: Database connect failed\n");
 exit $ERRORS{"UNKNOWN"};
}

if ($abort) {
    print ("ERROR: Database connect failed<br>\n");
    exit 1;
}

$start =  time() - $o_timelimit;

$sql = "SELECT instance_name, is_currently_running, status_update_time FROM nagios_programstatus, nagios_instances 
	WHERE nagios_programstatus.instance_id = nagios_instances.instance_id
	AND instance_name = '$o_instance'
	";

$sth = $dbh_db->prepare ($sql);

$sth->execute ();
my @row;
my @fields;
while ( @row = $sth->fetchrow_array ()) {
	my @record = @row;
	push(@fields, \@record);
}
$sth->finish();


$state = "OK";
if (@fields != 0) {
	my $i=0;
	foreach $line (@fields) {
		my $instance_name =  @$line[0];
		my $isrunning = @$line[1];
		my $updatetime = str2time(@$line[2]);
		if ($isrunning != 1) {
			$answer .= "$instance_name is not running. ";
			$state = "CRITICAL";
		} 
		if ($updatetime < $start){
			$answer .= "$instance_name was not updated during the last $o_timelimit seconds. ";
			$state = "CRITICAL";
		}
		$i++;
	}
}
else {
	$state = "CRITICAL";
	$answer = "No instance $o_instance found in database.";
}

if (defined($answer)){
	print "$answer\n";
}
else {
	print "Instance \"$o_instance\" is running and database was updated during the last $o_timelimit seconds. OK\n";
}
exit $ERRORS{$state};
#

