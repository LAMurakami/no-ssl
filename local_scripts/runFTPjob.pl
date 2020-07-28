#!/usr/bin/perl
# $Id: runFTPjob.pl,v 1.13 2009/02/06 20:14:43 lam Exp lam $

my $programName = '';$0 =~ m@.*/(.*)@ and $programName = $1; # path/$programName
my $configFile = "/etc/LAM/$programName.conf";  # Use program Configuration file
 -e $configFile or $configFile = '/etc/LAM/GCI-ftp-test.txt';       # or default
my $n = $#ARGV+1;  if ($n > 0) {$configFile = $ARGV[0]} # or passed as parameter

open (CONFIG, $configFile)                             # Open configuration file
 or                                                    # or report error and end
  die "Run time error: $0\nConfiguration file: $configFile NOT opened!\n$!\n\n";

my %cF = loadConfigHash(); # Load Configuration Parameters hash!

our $log = '             Remote Host: '. $cF{'Remote Host'}. "\n".
           '             Remote User: '. $cF{'Remote User'}. "\n";
    use Net::FTP;

    $ftp = Net::FTP->new($cF{'Remote Host'}, Debug => 0)
      or die "Cannot connect to $cF{'Remote Host'}: $@";

    $ftp->login($cF{'Remote User'}, $cF{'Remote Password'})
      or die "Cannot login ", $ftp->message;

$log .= "\nLogin to ftp:$cF{'Remote User'}\@$cF{'Remote Host'} successful.\n";

while(<CONFIG>) { $log .= $_;
    chomp;        # strip newline
    s/#.*//;      # strip comments
    s/^\s+//;     # strip leading white space
    s/\s+$//;     # strip trailing white space
    next unless length; # skip empty lines
CMD:    {                                                 # Allowed FTP Commands
    if (/^pwd$/) {$log .= $ftp->pwd(), "\n"; last CMD} # Print Working Directory
    if (/^dir$/) {my @lines = $ftp->dir();        # Get Remote Directory Listing
      foreach my $line (@lines) {$log .= $line. "\n"}; last CMD}    # add to log
    if (/^dir\s*(.+)$/) {my @lines = $ftp->dir($1);  # Get Remote Directory List
      foreach my $line (@lines) {$log .= $line. "\n"}; last CMD}    # add to log
    if (/^get\s+(.*)$/)      { if ($ftp->get($1))                   # Get a file
      { printSize($1)}                                                # log size
      else { $log .= "Get $1 failed\n"}last CMD}               # or report error
   if (/^put\s+(.*)$/)      { if ($ftp->put($1))                    # Put a file
     { printSize($1) }                                             # return size
     else { $log .= "Put $1 failed\n"}last CMD}                # or report error
} # End - Allowed FTP Commands
}
close(CONFIG); $ftp->quit; $log .= "\nJob complete, logging off, bye.\n";

if ($cF{'eMail Recipients'}) {                      # If we are to email the log
use Net::SMTP;
my $smtp = Net::SMTP->new('mailhost', Hello => $cF{'Local Host Name'});
$log .= $smtp->domain . "\n\n";
my $fromName = $ENV{USER} . '@' . $smtp->domain;
$smtp->mail("$cF{'eMail From'}\@$cF{'Local Host Name'}",);
$smtp->to($cF{'eMail Recipients'});
$smtp->data();
$smtp->datasend("To: $cF{'eMail Recipients'}\n");
$smtp->datasend("Subject: $cF{'eMail Subject'}\n");
$smtp->datasend("Content-type: text/plain; charset=us-ascii\n");
$smtp->datasend("\n");
$smtp->datasend("$log");
$smtp->dataend();
$smtp->quit;
$log .= "   From: $cF{'eMail From'}\@$cF{'Local Host Name'}\n".
        "     To: $cF{'eMail Recipients'}\n".
        "Subject: $cF{'eMail Subject'}\n\n";
} # End - If we are to email the log

if ($cF{'Print Log'}) {print $log} # Print log

# ..:....|....:....|....:....|....:....|....:....|....:....|....:....|....:....|
sub printSize { my $shortFileName = shift;
    $shortFileName =~ s/(.*)\/+//;
    $log .= $ftp->size($shortFileName). " bytes sent\n"
}
# ..:....|....:....|....:....|....:....|....:....|....:....|....:....|....:....|
sub loadConfigHash { my %configParameter = (); # Define a hash!

# modified from Perl Cookbook 8.16 Reading Configuration files

while(<CONFIG>) {          # Load parameters from configuration file into a hash
    chomp;        # strip newline
    s/#.*//;      # strip comments
    s/^\s+//;     # strip leading white space
    s/\s+$//;     # strip trailing white space
    next unless length; # skip empty lines
    last unless not m/z End of Basic Better Configuration paramters/;
    my ($var, $value) = split(/\s*=\s/, $_, 2);
    $configParameter{$var} = $value;
}                    # End - Load parameters from configuration file into a hash
return %configParameter
}
