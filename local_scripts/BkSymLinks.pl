#!/usr/bin/perl
# $Id: BkSymLinks.pl,v 1.2 2017/07/26 05:09:33 lam Exp lam $
# https://q.lam1.us/Comments?Topic=Program;Name=BkIncremental.pl;Submit=View
use warnings;                                              # Enable all warnings
use strict;                             # Force me to use strict variable syntax
my $programName = '';$0 =~ m@.*/(.*)@ and $programName = $1; # path/$programName

my $cfDir = '/etc/Backup'; my $configFile = "$cfDir/$programName.conf";
open (CONFIG, $configFile)                                  # configuration file.
 or die "Run time error: $0\nConfiguration file: $configFile NOT opened!\n$!\n\n";

my $bkDir = ''; chop($bkDir = <CONFIG>);                # backup target directory
my $bkList = ''; chop($bkList = <CONFIG>);                          # backup list
close(CONFIG);

-d $bkDir              # Perform Backup only if target directory is found/mounted
 or die "Run time error: $0\nBackup target: $bkDir NOT found!\n$!\n\n";

my $tmpDir = '/var/tmp';              # Use local temporary then move files later

my $newDir = qx(date '+%y%m%d'); chop($newDir);                          # YYMMDD
chdir '/';            # Perform Backup so archives have relative path information

my $outPrefix = $programName; my $gen = 1;                 # Set prefix for files
while (-e "$bkDir/$newDir/$outPrefix.out"
    or -e "$tmpDir/$outPrefix.out") {       # If current generation level is used
    $gen++; $outPrefix = "$programName.$gen";   # Increment out prefix generation
}                                   
open(STDOUT, ">>$tmpDir/$outPrefix.out")              # Re-direct standard output
 or die "$0 error:\nCan't redirect stdout\n$!\n\n";
open(STDERR, ">>$tmpDir/$outPrefix.out.err")                   # and error output
 or die "$0 error:\nCan't redirect stderr\n$!\n\n";                    # to files

print "=========================================\n",         # Backup job started
    "$outPrefix Job started\n"; system("date '+%A, %B %-d, %Y @ %r'"); print "\n";

print "Program: $0\nConfiguration file: $configFile\nConfiguration data:\n\n";
system("cat $configFile");                       # Report configuration file data
print "\n";
my @list = split (' ', $bkList);
foreach my $dir (@list) {                                       # Perform Backups
    print "Backing up $dir Symbolic Links ...\n\n";
    my $dirOut = $dir;$dirOut =~ s@/@\.@g;
    my $find = "find $dir -type l -print0";                        # find command
    my $tar = "tar -cvpzf $tmpDir/$outPrefix.$dirOut.tar.gz";       # tar command
    system("$find | xargs -0 $tar");               # execute using pipe and xargs
    print "\n"; system("ls -l $tmpDir/$outPrefix.$dirOut.tar.gz");
    print "\n"; system("date '+%A, %B %-d, %Y @ %r'"); print "\n";
}
print "Moving backup files from $tmpDir to";
chdir $bkDir; system("mkdir $newDir");
chdir $newDir; system('pwd');                                       # Move output
system("mv /var/tmp/$outPrefix*tar.gz .");
system("ls -l $outPrefix*");
print "\n$outPrefix Job ended\n";
system("date '+%A, %B %-d, %Y @ %r'");
print "=========================================\n";                # Almost done
system("mv /var/tmp/$outPrefix*out* .");
close(STDOUT); close(STDERR);                                 # That's all folks!
