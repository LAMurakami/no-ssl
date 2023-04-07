#!/usr/bin/perl
# $Id: IPStatusPage.pl,v 1.7 2015/05/09 07:38:20 lam Exp lam $

my $cfDir = '/etc/LAM'; my $configFile = "$cfDir/IPStatus.conf";
open (CONFIG, $configFile)                             # Open configuration file
 or                                                    # or report error and end
  die "Run time error: $0\nConfiguration file: $configFile NOT opened!\n$!\n\n";

my %cF = loadConfigHash(); # Load Configuration Parameters hash!
close(CONFIG);

my $oldIP        = $cF{'Last IP Address'};         # old IP Address

use LAM::LAM qw(timemark);
my $timePhrase = LAM::timemark(time);
my $timeMark = LAM::timemark(time, '1');
my $timeMarkColor = $cF{'Change Detected color'};   # Highlight timemark
my $timeLeaseColor = $cF{'Change Detected color'};   # Highlight Lease Obtained

use Net::SMTP;

my $smtp = Net::SMTP->new('mailhost', Hello => $cF{'Local Host Name'});
my $comments = "\n";

use LWP::UserAgent;                 # Use a module of the libwww-perl collection

my $routerStatus = LWP::UserAgent->new;                # Create a new User Agent
my $req = HTTP::Request->new(GET =>  $cF{'Router Status URI'});    # and request
   $req->authorization_basic($cF{'Router User'}, $cF{'Router Password'});
my $response = $routerStatus->request($req)->as_string;      # Get Router Status

my $table = ''; my $title = ''; my $ipAddress = '';  # Initialize some variables
my $subnetMask = ''; my $defaultGateway = '';
my $dnsServer = ''; my $leaseTime = ''; my $leaseExpires = '';

if ($response =~ /<title>(.+)<\/title>/is)  {$title = $1};       # Extract title

if ($title eq '401 Unauthorized') {    # If we get the 401 Unauthorized response
$comments .= "\n401 Unauthorized\n";
$response = $routerStatus->request($req)->as_string;     # Repeat Status request
if ($response =~ /<title>(.+)<\/title>/is)  {$title = $1};    # Re-Extract title
} # End - If we get the 401 Unauthorized response

if ($response =~ /function wanlink_status/) {     # Extract remaining parameters

if ($response =~ /function wanlink_ipaddr.. { return .(.+?).;}/s)
 {$ipAddress = $1};

$comments .= "\nIP Address: $ipAddress\n";

if ($response =~ /function wanlink_netmask.. { return .(.+?).;}/s)
 {$subnetMask = $1};

if ($response =~ /function wanlink_gateway.. { return .(.+?).;}/s)
 {$defaultGateway = $1};

if ($response =~ /function wanlink_dns.. { return .(.+?).;}/s)
 {$dnsServer = $1};

if ($response =~ /function wanlink_lease.. { return (.+?);}/s)
 {$leaseTime = $1};

if ($response =~ /function wanlink_expires.. { return (.+?);}/s)
 {$leaseExpires = $1};

my $oldIPcolor = $cF{'No Change color'};      # Set background for Old IP

if ($ipAddress ne $oldIP) {$oldIPcolor = $cF{'Change Detected color'}};

if ($timeMark le $leaseExpires)
 {$timeMarkColor = $cF{'No Change color'}};  # If within lease time range

if (($leaseTime ge 0) and ($leaseExpires ge 0) and ($leaseExpires ge $leaseTime/3))
 {$timeMarkColor = $cF{'No Change color'}};  # If > 2/3 of lease time remains

my $tr = '</td></tr><tr><td align=right>';

$table = "<table border><tr><td align=right>\n\n"
 . "     IP Address:\t</td><td><a href=" . '"http://' . $ipAddress . '">'
 .                                             "\n\n\t\t$ipAddress\t</a>$tr\n\n"
 . "  Cable Modem MAC Address:</td><td>$cF{'Cable Modem MAC Address'}$tr\n"
 . "Internet Port MAC Address:</td><td>$cF{'Internet Port MAC Address'}$tr\n\n"
 . "    Subnet Mask:</td><td>$subnetMask$tr\n"
 . "Default Gateway:</td><td>$defaultGateway$tr\n"
 . "     DNS Server:</td><td>$dnsServer$tr\n"
 . "Current Date Time:</td><td>$timeMark$tr\n"
 . "     Lease Time:</td><td>" . humanTime($leaseTime, "Renewing...") . "$tr\n"
 . "  Lease Expires:</td><td bgcolor=$timeMarkColor>"
 . humanTime($leaseExpires, "Expired") . "$tr\n"
 . " Old IP Address:</td><td bgcolor=$oldIPcolor>$oldIP\n"
 . "</td></tr></table>\n</center>\n\n";
}

my $host_name = `uname -n`; chomp($host_name);

my $page = <<END_OF_PAGE;
<head><title>LAM Alaska Connection Status</title>
<link rel="Shortcut Icon" href="favicon.ico" />
<link rel="stylesheet" type="text/css" href="Public/Style.css" />
<meta name="Author" content="www.ServerAdmin\@lam1.us" />
<!--
                              By: Lawrence A. Murakami - Fairbanks, Alaska -->

<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
</head><body>
<center><h1>LAM Alaska Connection Status<br>
(<a href="http://z.lam1.us/About/Program/IPStatus" target="_top">IPStatus</a>)
</h1>

$table

<h2>Remote static page at <a href=".">my space</a>
 on <a href="..">the home page server of my ISP</a>.</h2>
</center>
<hr />
<a target="_top" href="http://sites.lam1.us">sites.lam1.us</a><p align="right">

Page last updated $timePhrase

<a href="http://www.time.gov/timezone.cgi?Alaska/d/-9/java">(Alaska Time)</a>

<br />
 $host_name.ServerAdmin\@lam1.us</p>
</body></html>
END_OF_PAGE

open (ROUTERSTATUSPAGE, ">$cF{'update page location'}")
 or
  die "Run time error: $0\nRouter Status Page: $cF{'update page location'} NOT opened for update!\n$!\n\n";

print ROUTERSTATUSPAGE $page;

close(ROUTERSTATUSPAGE);

$comments .= `/usr/local/scripts/runFTPjob.pl /etc/LAM/GCI-IPStatus-FTPjob.conf`;

$comments .= $page;

my $n = $#ARGV+1;  if ($n > 0) { if ($ARGV[0] eq '-v')
         {print $comments, $table}} # Don't print commenments when running as a cron job
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
# ..:....|....:....|....:....|....:....|....:....|....:....|....:....|....:....|
sub humanTime # format seconds into days, hours, minutes, seconds.
{
my $s = shift(@_);
my $error = shift(@_);
if ($s <= 0)  { return($error) }
my $r = '';
if ($s > 86399) # ((60*60*24)-1) = 86399 then calculate days
 {
   my $t = int($s / 86400);
   if ($t > 1) { $r = "$t days"}
   else { $r = "$t day"}
   $s = $s % 86400;
 }
if ($s > 3599) # ((60*60)-1) = 3599 then calculate hours
 {
   my $t = int($s / 3600);
   if ((length $r) > 1) {$r .= ", "}
   if ($t > 1) { $r .= "$t hours"}
   else { $r .= "$t hour"}
   $s = $s % 3600;
 }
if ($s > 59) # then calculate minutes
 {
   my $t = int($s / 60);
   if ((length $r) > 1) {$r .= ", "}
   if ($t > 1) { $r .= "$t minutes"}
   else { $r .= "$t minute"}
   $s = $s % 60;
 }
if ($s > 0) # then calculate seconds
 {
   if ((length $r) > 1) {$r .= ", "}
   if ($s > 1) { $r .= "$s seconds"}
   else { $r .= "$s second"}
 }
return($r);
}
