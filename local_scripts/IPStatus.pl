#!/usr/bin/perl
# $Id: IPStatus.pl,v 1.26 2017/07/26 05:06:32 lam Exp lam $

my $cfDir = '/etc/LAM'; my $configFile = "$cfDir/IPStatus.conf";
open (CONFIG, $configFile)                             # Open configuration file
 or                                                    # or report error and end
  die "Run time error: $0\nConfiguration file: $configFile NOT opened!\n$!\n\n";

my %cF = loadConfigHash(); # Load Configuration Parameters hash!
close(CONFIG);

my $oldIP        = $cF{'Last IP Address'};         # old IP Address

use Net::SMTP;

my $smtp = Net::SMTP->new('mailhost', Hello => $cF{'Local Host Name'});
my $comments = "\n";

$comments .= '   From: '. $cF{'eMail From'}. "\n".
             '     To: '. $cF{'eMail Recipients'}. "\n".
             'AliasTo: '. $cF{'eMail Alias'}. "\n".
             "\nConnection Status Message sent\n";

use LWP::UserAgent;                 # Use a module of the libwww-perl collection

my $routerStatus = LWP::UserAgent->new;                # Create a new User Agent
my $req = HTTP::Request->new(GET =>  $cF{'Router Status URI'});    # and request
   $req->authorization_basic($cF{'Router User'}, $cF{'Router Password'});
my $response = $routerStatus->request($req)->as_string;      # Get Router Status

my $table = ''; my $title = ''; my $ipAddress = '';  # Initialize some variables
my $subnetMask = ''; my $defaultGateway = ''; my $dhcpServer = '';
my $dnsServer = ''; my $leaseObtained = ''; my $leaseExpires = '';

if ($response =~ /<title>(.+)<\/title>/is)  {$title = $1};       # Extract title

if ($title eq '401 Unauthorized') {    # If we get the 401 Unauthorized response
$comments .= "\n401 Unauthorized\n";
$response = $routerStatus->request($req)->as_string;     # Repeat Status request
if ($response =~ /<title>(.+)<\/title>/is)  {$title = $1};    # Re-Extract title
} # End - If we get the 401 Unauthorized response

if ($title ne 'Connection Status') {       # If we did not get the expected page
    $comments = "\nIP Status error\n\n$title\n\n$response"     # report response

} else {          # Extract the rest of the parameters and display in a web page

if ($response =~ /IP Address<\/B><\/td>\s*<TD NOWRAP width="50%">(.+?)<\/td>/s)
 {$ipAddress = $1};

if ($response =~ /Subnet Mask<\/B><\/td>\s*<TD NOWRAP>(.+?)<\/td>/s)
 {$subnetMask = $1};

if ($response =~ /Default Gateway<\/B><\/td>\s*<TD NOWRAP>(.+?)<\/td>/s)
 {$defaultGateway = $1};

if ($response =~ /DHCP Server<\/B><\/td>\s*<TD NOWRAP>(.+?)<\/td>/s)
 {$dhcpServer = $1};

if ($response =~ /DNS Server<\/B><\/td>\s*<TD NOWRAP>(.+?)<\/td>/s)
 {$dnsServer = $1};

if ($response =~ /Lease Obtained<\/B><\/td>\s*<TD NOWRAP>(.+?)<\/td>/s)
 {$leaseObtained = $1};

if ($response =~ /Lease Expires<\/B><\/td>\s*<TD NOWRAP>(.+?)<\/td>/s)
 {$leaseExpires = $1};

my $oldIPcolor = $cF{'No Change color'};      # Set background for Old IP

if ($ipAddress ne $oldIP) {$oldIPcolor = $cF{'Change Detected color'}};

use LAM::LAM qw(timemark);
my $timeMark = LAM::timemark(time, '1');
my $timeMarkColor = $cF{'Change Detected color'};   # Highlight timemark

if (($leaseObtained le $timeMark) and ($timeMark le $leaseExpires))
 {$timeMarkColor = $cF{'No Change color'}};  # If within lease time range

my $tr = '</td></tr><tr><td align=right>';

$table = "<table border><tr><td align=right>\n\n"
 . "     IP Address:\t</td><td><a href=" . '"http://' . $ipAddress . '">'
 .                                           "\n\n\t\t$ipAddress\t</a>$tr\n\n"
 . "    Subnet Mask:</td><td>$subnetMask$tr\n"
 . "Default Gateway:</td><td>$defaultGateway$tr\n"
 . "    DHCP Server:</td><td>$dhcpServer$tr\n"
 . "     DNS Server:</td><td>$dnsServer$tr\n"
 . " Lease Obtained:</td><td>$leaseObtained$tr\n\n"
 . "Current Date Time:</td><td bgcolor=$timeMarkColor>$timeMark$tr\n"
 . "  Lease Expires:\t</td><td>\n\n\t\t$leaseExpires\t$tr\n\n"
 . " Old IP Address:\t</td><td bgcolor=$oldIPcolor>\n\n\t\t$oldIP\t\n\n"
 . "</td></tr></table>";

$smtp->mail("$cF{'eMail From'}",);
$smtp->to($cF{'eMail Recipients'});

$smtp->data();
$smtp->datasend("To: $cF{'eMail Alias'}\n");
$smtp->datasend("Subject: LAM Alaska Connection Status from $cF{'eMail From'}\n");
$smtp->datasend("Content-type: text/html; charset=us-ascii\n");
$smtp->datasend("\n");
$smtp->datasend("<center><h1>LAM Alaska $title</h1>\n$table</center>");
$smtp->dataend();

$smtp->quit;
}
my $n = $#ARGV+1;  if ($n > 0) { if ($ARGV[0] eq '-v')
         {print $comments}} # Don't print commenments when running as a cron job

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
