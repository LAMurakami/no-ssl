#!/usr/bin/perl
# /var/www/no-ssl/local_scripts/BkRsync-remote-source.pl    # In no-ssl git repo
#
use warnings;                                              # Enable all warnings
use strict;                             # Force me to use strict variable syntax

use IO::CaptureOutput qw(capture_exec);

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

-e $cF{'Target'}                  # Perform sync only if Target is found/mounted
 or die "Run time error: $0\nTarget: $cF{'Target'} NOT found!\n$!\n\n";

-d $cF{'Target'}                      # Perform sync only if Target is directory
 or die "Run time error: $0\nTarget: $cF{'Target'} NOT directory!\n$!\n\n";

#-e $cF{'Source'}                  # Perform sync only if Source is found/mounted
# or die "Run time error: $0\nSource: $cF{'Source'} NOT found!\n$!\n\n";
#
#-d $cF{'Source'}                      # Perform sync only if Source is directory
# or die "Run time error: $0\nSource: $cF{'Source'} NOT directory!\n$!\n\n";

my $command = "ssh -q $cF{'Remote'} " . '"uname -n"';             # ssh to Remote
my($stdout, $stderr, $success, $rc) = capture_exec($command);
if ($rc) { # If error with ssh to remote report and exit
    print "ERROR: Cannot connect to $cF{'Remote'}\n";
    exit $rc >> 8;                                           # or exit on failure
}

$command = "ssh -q $cF{'Remote'} "
    . '"ls -ld --time-style=long-iso ' . "$cF{'Source'}" . '"' ;
($stdout, $stderr, $success, $rc) = capture_exec($command);
if ($rc) { # If error with RemotePath
    print "ERROR: Remote source does not exist: $cF{'Remote'}:$cF{'Source'}\n";
    exit $rc >> 8;
}

$command = "ssh -q $cF{'Remote'} " . '"[ -d ' . "$cF{'Source'}" . ' ]"' ;
($stdout, $stderr, $success, $rc) = capture_exec($command);
if ($rc) { # If error with RemotePath
    print 'ERROR: Remote source is not a directory: ';
    print "$cF{'Remote'}:$cF{'Source'}\n";
    exit $rc >> 8;
}

my $dirsSkipped = 0;

my @list = split (' ', $cF{'Directories'});
foreach my $dir (@list) {                                      # Perform Backups
    system("date '+%A, %B %-d, %Y @ %r'");

    if ( -d "$cF{'Target'}/$dir" ) {                # if target directory exists
      print "Starting $cF{'Source'}$dir sync to $cF{'Target'}...\n\n";

$command = "ssh -q $cF{'Remote'} "
    . '"ls -ld --time-style=long-iso ' . "$cF{'Source'}/$dir" . '"' ;
($stdout, $stderr, $success, $rc) = capture_exec($command);
if ($rc) { # If error with RemotePath
    print 'ERROR: Remote source does not exist: ';
    print "$cF{'Remote'}:$cF{'Source'}/$dir\n";
    exit $rc >> 8;
}

$command = "ssh -q $cF{'Remote'} " . '"[ -d ' . "$cF{'Source'}/$dir" . ' ]"' ;
($stdout, $stderr, $success, $rc) = capture_exec($command);
if ($rc) { # If error with RemotePath
    print 'ERROR: Remote source is not a directory: ';
    print "$cF{'Remote'}:$cF{'Source'}/$dir\n";
    exit $rc >> 8;
}

system("rsync $cF{'rsync Options'} $cF{'Remote'}:$cF{'Source'}/$dir $cF{'Target'}");

    }
    else {                                                 # or warn if skipping
      warn "$0: Warning: Skipping sync...\n",
           "Target: $cF{'Target'}/$dir NOT directory!\n$!\n\n";
      ++ $dirsSkipped;
    }
}

print "=========================================\n";               # Almost done
$sdate = qx(date '+%A, %B %-d, %Y @ %r');                   # System Date / Time
print "$uname $outPrefix Job ended $sdate";
close(STDOUT); close(STDERR);
if ( $dirsSkipped ) {                        # Send email if directories skipped
 open (MAIL, "|/usr/sbin/sendmail -t -O IgnoreDots ");
  print MAIL "From: root\n";
  print MAIL "To: q\n";
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
