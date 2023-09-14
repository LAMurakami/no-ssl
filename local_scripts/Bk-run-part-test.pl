#!/usr/bin/perl
use warnings;                                              # Enable all warnings
use strict;                             # Force me to use strict variable syntax

my $programName = '';$0 =~ m@.*/(.*)@ and $programName = $1; # path/$programName
my $programPath = '';$0 =~ m@(.*/).*@ and $programPath = $1; # $programPath/Name

my $openConfigFailed = '0';
my $configFile = "$programPath$programName.conf";           # configuration file
open (CONFIG, $configFile) or $openConfigFailed = '1';

if ($openConfigFailed) {                             # If open config file fails
 my $cfDir = '/etc/Backup'; $configFile = "$cfDir/$programName.conf";
 open (CONFIG, $configFile)         # configuration file from alternate location
 or die "Run time error: $0\nConfiguration file: $programName.conf NOT opened" .
                                       " from $programPath or $cfDir/!\n$!\n\n";
}

my %cF = loadConfigHash();                  # Load Configuration Parameters hash!
close(CONFIG);

-e $cF{'Log Base'}              # Perform sync only if Log Base is found/mounted
 or die "Run time error: $0\nSource: $cF{'Log Base'} NOT found!\n$!\n\n";

-d $cF{'Log Base'}                  # Perform sync only if Log Base is directory
 or die "Run time error: $0\nSource: $cF{'Log Base'} NOT directory!\n$!\n\n";

my $newDir = qx(date '+%y%m%d'); chop($newDir);                         # YYMMDD

-d "$cF{'Log Base'}/$newDir"                            # Check if newDir exists
 or system("mkdir $cF{'Log Base'}/$newDir");              # and create it if not

my $outPrefix = $programName; my $gen = 1;                # Set prefix for files
while (-e "$cF{'Log Base'}/$newDir/$outPrefix.out") {     # If gen level is used
    $gen++; $outPrefix = "$programName.$gen";  # Increment out prefix generation
}
open(STDOUT, ">>$cF{'Log Base'}/$newDir/$outPrefix.out")      # Re-direct STDOUT
 or die "$0 error:\nCan't redirect stdout\n$!\n\n";
open(STDERR, ">>$cF{'Log Base'}/$newDir/$outPrefix.out.err")        # and STDERR
 or die "$0 error:\nCan't redirect stderr\n$!\n\n";                   # to files

my $uname = qx(uname -n); chomp($uname);                             # Host name
my $sdate = qx(date '+%A, %B %-d, %Y @ %r');                # System Date / Time
print "$uname $outPrefix Job started $sdate\n";             # Backup job started

print "Program: $0\nConfiguration file: $configFile\nConfiguration data:\n\n";
system("cat $configFile");                      # Report configuration file data
print "\n=========================================\n";
# ..:....|....:....|....:....|....:....|....:....|....:....|....:....|....:....|
# Do the real work here!
# ..:....|....:....|....:....|....:....|....:....|....:....|....:....|....:....|
$sdate = qx(date '+%A, %B %-d, %Y @ %r');                   # System Date / Time
print "=========================================\n";               # Almost done
print "$uname $outPrefix Job ended $sdate";
close(STDOUT); close(STDERR);
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
