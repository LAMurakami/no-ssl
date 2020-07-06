# $Id: SQL.pm,v 1.4 2017/12/22 09:09:45 ubuntu Exp ubuntu $
#
package     SQL;
use LAM::LAM qw(displayError namedParameters);
use DBI;         # Load Database Interface module.
use strict;     # Force me to use strict variable syntax.
#use warnings;  # Enable all warnings.
use CGI ':all'; # CGI - load standard functions

require     Exporter;

our @ISA        = qw(Exporter);
our @EXPORT     = qw(connectPrepareExecute finishDisconnect
                     $db $user $dbh $stmt $rc @names);
our @EXPORT_OK  = qw(connectPrepareExecute finishDisconnect
                     $db $user $dbh $stmt $rc @names);
our @VERSION    = 1.0;

our ($db, $user, $dbh, $stmt, $rc, @names);
1;
# ..:....|....:....|....:....|....:....|....:....|....:....|....:....|....:....|
sub connectPrepareExecute {

my $stmtText = shift; # First parameter is SQL statement to Prepare and Execute.

if (not defined($dbh)) { # Connect to database on this host.
    if (not defined($db)) {$db = 'test'} # Use test database if not specified.
    $dbh = DBI->connect("DBI:mysql:$db:host=", $user) # Return database handle.
     or LAM::displayError("Could not connect to SQL database.", DBI->errstr, 1);
}
$dbh->{RaiseError} = 0; # I will handle errors

$stmt = $dbh->prepare('SET @rn=0;') # Prepare the SQL statement and return handle.
 or LAM::displayError('Could not prepare SET @rn.' , $stmt->errstr, 1,
    "\nSQL Statement:<b><pre>\n$stmtText\n</pre></b>");

$rc = $stmt->execute() # Execute the SQL statement and return row count.
 or LAM::displayError('Could not execute SET @rn.' , $stmt->errstr, 1,
    "\nSQL Statement:<b><pre>\n$stmtText\n</pre></b>");

$stmt = $dbh->prepare($stmtText) # Prepare the SQL statement and return handle.
 or LAM::displayError("Could not prepare SQL queries." , $stmt->errstr, 1,
    "\nSQL Statement:<b><pre>\n$stmtText\n</pre></b>");

$rc = $stmt->execute() # Execute the SQL statement and return row count.
 or LAM::displayError("Could not execute SQL statement." , $stmt->errstr, 1,
    "\nSQL Statement:<b><pre>\n$stmtText\n</pre></b>");

if (defined($stmt->{'NAME'})) { # If column names were returned for statement
    @names = @{$stmt->{'NAME'}}; # retrieve column names for executed query.
    }
}
# ..:....|....:....|....:....|....:....|....:....|....:....|....:....|....:....|
sub connectPrepareExecuteUnchecked {

my $stmtText = shift; # First parameter is SQL statement to Prepare and Execute.

if (not defined($dbh)) { # Connect to database on this host.
    if (not defined($db)) {$db = 'test'} # Use test database if not specified.
    $dbh = DBI->connect("DBI:mysql:$db:host=", $user); # Return database handle.
}
$dbh->{RaiseError} = 0; # I will handle errors

$stmt = $dbh->prepare($stmtText); # Prepare the SQL statement and return handle.
$rc = $stmt->execute(); # Execute the SQL statement and return row count.
if (defined($stmt->{'NAME'})) { # If column names were returned for statement
    @names = @{$stmt->{'NAME'}}; # retrieve column names for executed query.
    }
}
# ..:....|....:....|....:....|....:....|....:....|....:....|....:....|....:....|
sub logProgramRequest {
# LAM::displayError("Named Parameters" , LAM::namedParameters(), 1,
#     "\n");
my $nameValue = "\'$ENV{'SCRIPT_NAME'}\'";
my $commentsValue = '';
my $tempString = $ENV{'QUERY_STRING'};
if ($tempString ne undef) {
$commentsValue = "\'$ENV{'QUERY_STRING'}\'";}
else {
	my @param_names = param(); # Get a list of all the named parameters
	if ($#param_names ge 0) {
		my $tempString = LAM::namedParameters();
		$commentsValue = "\'$tempString\'";
	}
}
my $REQUEST_METHOD_Value = "\'$ENV{'REQUEST_METHOD'}\'";
my $HTTP_USER_AGENT_Value = "\'$ENV{'HTTP_USER_AGENT'}\'";
my $HTTP_REFERER_Value = "\'$ENV{'HTTP_REFERER'}\'";
my $REMOTE_ADDR_Value = "\'$ENV{'REMOTE_ADDR'}\'";
my $tempString = cookie(-name=>'logon');
my $LOGON_USER_Value = "\'$tempString\'";

    my $insertStatement # Prepare the SQL statement
     = 'insert into request_log(DATE_TIME, SCRIPT_NAME, QUERY_STRING, '."\n"
     . 'REQUEST_METHOD, HTTP_USER_AGENT, HTTP_REFERER, REMOTE_ADDR,'."\n"
     . ' LOGON_USER) VALUES (now(), ' . $nameValue .', ' . $commentsValue."\n" .', '
     . $REQUEST_METHOD_Value . ', ' . $HTTP_USER_AGENT_Value . ', '."\n"
     . $HTTP_REFERER_Value . ', ' . $REMOTE_ADDR_Value . ', '."\n"
     . $LOGON_USER_Value .  ' )';

my $db = 'lam';
my $user = 'lam';
$dbh = DBI->connect("DBI:mysql:$db:host=", $user); # Return database handle.
SQL::connectPrepareExecuteUnchecked($insertStatement); 
SQL::finishDisconnect();
}
# ..:....|....:....|....:....|....:....|....:....|....:....|....:....|....:....|
sub finishDisconnect {
$stmt->finish();     # Close the DataBase cursor.
$dbh->disconnect(); # Disconnect from DataBase.
undef($dbh);       # Undefine the database handle.
}
# ..:....|....:....|....:....|....:....|....:....|....:....|....:....|....:....|
