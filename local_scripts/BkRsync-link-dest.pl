#!/usr/bin/perl
# $Id: BkRsync-link-dest.pl,v 1.4 2019/12/30 02:02:02 lam Exp lam $
#
use warnings;                                              # Enable all warnings
use strict;                             # Force me to use strict variable syntax
my $programName = '';$0 =~ m@.*/(.*)@ and $programName = $1; # path/$programName

my $cfDir = '/etc/Backup'; my $configFile = "$cfDir/$programName.conf";
open (CONFIG, $configFile)                                  # configuration file.
 or die "Run time error: $0\nConfiguration file: $configFile NOT opened!\n$!\n\n";

my %cF = loadConfigHash();                  # Load Configuration Parameters hash!
close(CONFIG);

-e $cF{'Log Base'}               # Perform sync only if Log Base is found/mounted
 or die "Run time error: $0\nSource: $cF{'Log Base'} NOT found!\n$!\n\n";

-d $cF{'Log Base'}                   # Perform sync only if Log Base is directory
 or die "Run time error: $0\nSource: $cF{'Log Base'} NOT directory!\n$!\n\n";

my $newDir = qx(date '+%y%m%d'); chop($newDir);                          # YYMMDD

-d "$cF{'Log Base'}/$newDir"                             # Check if newDir exists
 or system("mkdir $cF{'Log Base'}/$newDir");               # and create it if not

-e $cF{'Target'}                  # Perform sync only if Target is found/mounted
 or die "Run time error: $0\nTarget: $cF{'Target'} NOT found!\n$!\n\n";

-d $cF{'Target'}                      # Perform sync only if Target is directory
 or die "Run time error: $0\nTarget: $cF{'Target'} NOT directory!\n$!\n\n";

-e $cF{'Source'}                  # Perform sync only if Source is found/mounted
 or die "Run time error: $0\nSource: $cF{'Source'} NOT found!\n$!\n\n";

-d $cF{'Source'}                      # Perform sync only if Source is directory
 or die "Run time error: $0\nSource: $cF{'Source'} NOT directory!\n$!\n\n";

my $outPrefix = $programName; my $gen = 1;                 # Set prefix for files
while (-e "$cF{'Log Base'}/$newDir/$outPrefix.out") { # If gen level is used
    $gen++; $outPrefix = "$programName.$gen";  # Increment out prefix generation
}
open(STDOUT, ">>$cF{'Log Base'}/$newDir/$outPrefix.out")       # Re-direct STDOUT
 or die "$0 error:\nCan't redirect stdout\n$!\n\n";
open(STDERR, ">>$cF{'Log Base'}/$newDir/$outPrefix.out.err")         # and STDERR
 or die "$0 error:\nCan't redirect stderr\n$!\n\n";                    # to files

my $uname = qx(uname -n); chomp($uname);                              # Host name
my $sdate = qx(date '+%A, %B %-d, %Y @ %r');                 # System Date / Time

print "=========================================\n",         # Backup job started
      "$uname $outPrefix Job started $sdate\n";

print "Program: $0\nConfiguration file: $configFile\nConfiguration data:\n\n";
system("cat $configFile");                      # Report configuration file data
print "\n=========================================\n";

my $dirsSkipped = 0;

my $lastDir = qx(date +'%Y-%m-%d-%H%M'); chop($lastDir);       # YYYY-MM-DD-HHMM

my @list = split (' ', $cF{'Directories'});
foreach my $dir (@list) {                                      # Perform Backups

    if ( -d "$cF{'Target'}/$dir" ) {                # if target directory exists

    system("date '+%A, %B %-d, %Y @ %r'");

    print "Moving $cF{'Target'}/$dir",
          " to $cF{'Target'}/${dir}_Bk/${lastDir} ...\n\n";

    system("mv $cF{'Target'}/${dir} $cF{'Target'}/${dir}_Bk/${lastDir}");

    system("date '+%A, %B %-d, %Y @ %r'");

    print "Creating hard link copy of $cF{'Target'}/${dir}_Bk/${lastDir}\n",
          "at $cF{'Target'}/${dir} ...\n\n";

    system("cp $cF{'cp Options'} $cF{'Target'}/${dir}_Bk/${lastDir} $cF{'Target'}/${dir}");

    system("date '+%A, %B %-d, %Y @ %r'");

      print "Starting $cF{'Source'}/$dir sync to $cF{'Target'}...\n\n";

    system("rsync $cF{'rsync Options'} $cF{'Source'}/$dir $cF{'Target'}");

    }
    else {                                                 # or warn if skipping
      my $sysDate = qx(date '+%A, %B %-d, %Y @ %r'); ; chop($sysDate);
      warn "$0: Warning: Skipping sync...\n${sysDate}\n",
           "Target: $cF{'Target'}/$dir NOT directory!\n$!\n\n";
      ++ $dirsSkipped;
    }
}

$sdate = qx(date '+%A, %B %-d, %Y @ %r');                   # System Date / Time

print "=========================================\n";               # Almost done
print "$uname $outPrefix Job ended $sdate";
close(STDOUT); close(STDERR);
if ( $dirsSkipped ) {                        # Send email if directories skipped
 open (MAIL, "|/usr/sbin/sendmail -t -O IgnoreDots ");
  print MAIL "From: root\n";
  print MAIL "To: $cF{'Error email recipient'}\n";
  print MAIL "Subject: $0 error: $dirsSkipped directories skipped.\n";
  print MAIL "Content-Type: text/plain\n\n";
  print MAIL "Run time error: $0\n$dirsSkipped directories skipped.\n",
            "See $cF{'Log Base'}/$newDir/$outPrefix.out.err for details.\n\n";
 close (MAIL);
}                                                            # That's all folks!
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
