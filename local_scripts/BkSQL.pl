#!/usr/bin/perl
# $Id: BkSQL.pl,v 1.6 2019/12/30 01:54:13 lam Exp lam $
# https://q.lam1.us/Comments?Topic=Program;Name=BkSource.pl;Submit=View
use warnings;                                              # Enable all warnings
use strict;                             # Force me to use strict variable syntax
my $programName = '';$0 =~ m@.*/(.*)@ and $programName = $1; # path/$programName

my $cfDir = '/etc/Backup'; my $configFile = "$cfDir/$programName.conf";
open (CONFIG, $configFile)                                  # configuration file.
 or die "Run time error: $0\nConfiguration file: $configFile NOT opened!\n$!\n\n";

my $bkDir = ''; chop($bkDir = <CONFIG>);                # backup target directory
close(CONFIG);

-d $bkDir              # Perform Backup only if target directory is found/mounted
 or die "Run time error: $0\nBackup target: $bkDir NOT found!\n$!\n\n";

my $tmpDir = '/var/tmp';              # Use local temporary then move files later

my $newDir = qx(date '+%y%m%d'); chop($newDir);                          # YYMMDD

my $outPrefix = $programName; my $gen = 1;                 # Set prefix for files
while (-e "$bkDir/$newDir/$outPrefix.out"
    or -e "$tmpDir/$outPrefix.out") {       # If current generation level is used
    $gen++; $outPrefix = "$programName.$gen";   # Increment out prefix generation
}                                   
open(STDOUT, ">>$tmpDir/$outPrefix.out")              # Re-direct standard output
 or die "$0 error:\nCan't redirect stdout\n$!\n\n";
open(STDERR, ">>$tmpDir/$outPrefix.out.err")                   # and error output
 or die "$0 error:\nCan't redirect stderr\n$!\n\n";                    # to files

my $uname = qx(uname -n); chomp($uname);                              # Host name
my $sdate = qx(date '+%A, %B %-d, %Y @ %r');                 # System Date / Time

print "=========================================\n",         # Backup job started
      "$uname $outPrefix Job started $sdate\n";

print "Program: $0\nConfiguration file: $configFile\nConfiguration data:\n\n";
system("cat $configFile");                       # Report configuration file data
print "\n";

chdir '/var/tmp';

print "Backing up all MySQL data ...\n\n";
system("mysqldump --user=lam --all-databases --result-file=$outPrefix.sql");
system("ls -l $outPrefix.sql");

print "\n"; system("date '+%A, %B %-d, %Y @ %r'");
print "\nCompressing backup file ...\n\n";
system("gzip $outPrefix.sql");
system("ls -l $outPrefix.sql.gz");
print "\n";

print "Moving backup files from $tmpDir to ";
chdir $bkDir; system("mkdir $newDir");
chdir $newDir; system('pwd');                                       # Move output
system("mv /var/tmp/$outPrefix.sql.gz .");
system("ls -l $outPrefix*");

$sdate = qx(date '+%A, %B %-d, %Y @ %r');                    # System Date / Time
print "\n$uname $outPrefix Job ended $sdate";
print "=========================================\n";                # Almost done
system("mv /var/tmp/$outPrefix*out* .");
close(STDOUT); close(STDERR);                                 # That's all folks!
