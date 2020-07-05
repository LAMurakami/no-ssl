# $Id: GetDBvalue.pm,v 1.3 2009/08/11 20:11:43 lam Exp lam $

package     GetDBvalue;
use LAM::LAM qw(displayError);
use DBI;         # Load Database Interface module.
use strict;     # Force me to use strict variable syntax.
use warnings;  # Enable all warnings.

require     Exporter;

our @ISA        = qw(Exporter);
our @EXPORT     = qw(tableRowFormat);
our @EXPORT_OK  = qw(tableRowFormat programText);
our @VERSION    = 1.0;

1;
# ..:....|....:....|....:....|....:....|....:....|....:....|....:....|....:....|
sub tableRowFormat {

my ($dbh, $stmt, $rc);

my $tableRowFormat = shift; # Parameter is a Table Row Format key.

my $stmtText = "select MESSAGE from guestbook where BOOK_NAME = 'LAM' "
              ."and GUEST_NAME = 'TableRowFormat' "
              ."and EMAIL_ADDRESS = '$tableRowFormat'";

if (not defined($dbh)) { # Connect to database on this host.
    $dbh = DBI->connect("DBI:mysql:lam:host=", 'lam') # Return database handle.
     or LAM::displayError("Could not connect to SQL database.", DBI->errstr, 1);
}
$dbh->{RaiseError} = 0; # I will handle errors

$stmt = $dbh->prepare($stmtText) # Prepare the SQL statement and return handle.
 or LAM::displayError("Could not prepare SQL queries." , $stmt->errstr, 1,
    "\nSQL Statement:<b><pre>\n$stmtText\n</pre></b>");

$rc = $stmt->execute() # Execute the SQL statement and return row count.
 or LAM::displayError("Could not execute SQL statement." , $stmt->errstr, 1,
    "\nSQL Statement:<b><pre>\n$stmtText\n</pre></b>");

if ($rc lt 1) { $tableRowFormat = ''}
else {($tableRowFormat) = $stmt->fetchrow_array()}
    $stmt->finish();
    $dbh->disconnect();
    return $tableRowFormat
}
# ..:....|....:....|....:....|....:....|....:....|....:....|....:....|....:....|
sub programText {

my $scriptName = $ENV{SCRIPT_FILENAME};                        # Use script name
    if ($scriptName =~ /.*\/(.*)/) {$scriptName = $1} my $cLink = '';  # trimmed

my ($dbh, $stmt, $rc);

my $programText = shift;                  # Parameter is a Table Row Format key.

my $stmtText = "select MESSAGE from guestbook where BOOK_NAME = 'Program' "
              ."and GUEST_NAME = '$scriptName' "
              ."and EMAIL_ADDRESS = 'ProgramText'";

if (not defined($dbh)) {                     # Connect to database on this host.
    $dbh = DBI->connect("DBI:mysql:lam:host=", 'lam')  # Return database handle.
     or LAM::displayError("Could not connect to SQL database.", DBI->errstr, 1);
}
$dbh->{RaiseError} = 0;                                   # I will handle errors

$stmt = $dbh->prepare($stmtText)  # Prepare the SQL statement and return handle.
 or LAM::displayError("Could not prepare SQL queries." , $stmt->errstr, 1,
    "\nSQL Statement:<b><pre>\n$stmtText\n</pre></b>");

$rc = $stmt->execute()         # Execute the SQL statement and return row count.
 or LAM::displayError("Could not execute SQL statement." , $stmt->errstr, 1,
    "\nSQL Statement:<b><pre>\n$stmtText\n</pre></b>");

if ($rc lt 1)
    { $programText = "<!-- No ProgramText for Program: $scriptName -->"}
else {($programText) = $stmt->fetchrow_array()}
    $stmt->finish();
    $dbh->disconnect();
    return $programText
}
# ..:....|....:....|....:....|....:....|....:....|....:....|....:....|....:....|
