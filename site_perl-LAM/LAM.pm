# $Id: LAM.pm,v 1.78 2017/07/17 08:54:19 lam Exp lam $
package     LAM;   # Lexicon Abstract Map
use strict;       # Force me to use strict variable syntax.
use warnings;    # Enable all warnings.
use CGI ':all'; # CGI - load standard functions
require     Exporter;

my $LAMpmPath = $INC{"LAM/LAM.pm"};               # LAM.pm path from @INC values
my $LAMpmDir = $LAMpmPath; $LAMpmDir =~ s/LAM.pm//; # Dir is Path less file name

our @ISA        = qw(Exporter);
our @EXPORT     = qw(displayPage);
our @EXPORT_OK  = qw(displayError displayPage emailAddress datetime viewFormData
                     environmentVariables commify displayTextFile timemark
                     displayRCSlog displayRCSdiff displaySource htmlHead
                     getTextFile namedParameters fixString checkSSL reDirect);
our @VERSION    = 1.0;
# ..:....|....:....|....:....|....:....|....:....|....:....|....:....|....:....|
sub emailAddress { return
 p({-class=>'Right'}, "\n", timemark() , br(), $ENV{SERVER_ADMIN})}
# ..:....|....:....|....:....|....:....|....:....|....:....|....:....|....:....|
sub displayPage {          # Display a web page with standard style for LAM site
my $optError=1; my $opt_head=1; my $noMenuBar=0;
my $counter = ''; my $title = ''; my $icon = '';
while ($_[0] =~ m/^-([mehitc])/) { my $option = $1;  # While optional parameters
    if ($option eq 'm') {$noMenuBar=1}                 # -m specifies no menubar
    if ($option eq 'e') {$optError=0}  # -e specified that this is an error page
    if ($option eq 'h') {$opt_head=0}        # -h specifies omit the html header
    if ($option eq 'i') {shift;$icon=$_[0]}           # -i specifies custom icon
    if ($option eq 't') {shift;$title=$_[0]}                        # -t <title>
    if ($option eq 'c') {                    # -c specifies include page counter
        use LAM::Multicount qw(webPageCounter);
        $counter = "\n" . Multicount::webPageCounter('-f') . br() . "\n"
    } shift}
my $headerText = my $bodyText = my $tailText = '';
my $i = 0; my $parameterCount = @_;
while ($parameterCount > $i++) {  # While positional parameters
    if    ($i eq 1) {$headerText=shift}
    elsif ($i eq 2) {$bodyText=shift}
    elsif ($i eq 3) {$tailText=shift}
}
my $path = ''; my $scriptName = '';
my $scriptFileName = $ENV{SCRIPT_FILENAME};
if ($scriptFileName =~ /(.*)\/(.*)/) {$path = $1; $scriptName = $2}
my $html_title = 'LAM Alaska '. $scriptName;
my $docRoot = '/var/www/no-ssl/html';
if ($path =~ /($docRoot)(.*)/) {$path = $2} # Strip document root from path
my $publicScripts = '/Public/Scripts';
if ($path =~ /($publicScripts)(.*)/) {$path = $2} # Strip public from path
my $pageHeader = "\n$path/\n" . # Include link to program source
    a({-href=>"$ENV{SCRIPT_NAME}?Source"}, "\n$scriptName\n");
my $errorPrefix = ''; my $bannerColor = 'lime';
if ($optError ne 1) {
    $html_title .= ' Error';
    $errorPrefix = 'Error - ';
    $bannerColor = 'yellow'
}
if ($title ne '') {$html_title = $title}
if ( $opt_head eq 1 ) {
    if ($icon) {print htmlHead('-i', $icon, $html_title)}
    else {print htmlHead($html_title)}
} else {
    if ($icon) {print htmlHead('-h', '-i', $icon, $html_title)}
    else {print htmlHead('-h', $html_title)}
}
if ( $noMenuBar eq 0 ) { print menuBar(),"\n"}
if ($headerText ne '') {$headerText = hr(). "\n". comment("\nHeader:\n")
    . "\n" . center(h1("\n\n$errorPrefix$headerText\n\n"))}
my $centeredText = '';
if ($bodyText ne '') {$centeredText = hr(). "\n".
 comment("\nBody text:\n"). "\n$bodyText\n\n"};
my $plainText = '';
if ($tailText ne '') {$plainText = "\n".
 comment("\nTail text:\n"). "$tailText\n\n". hr()};
my $uptime = qx(uptime); $uptime =~ s/^(.*) up/Up/; # Strip current time
print center(table(Tr(td({-bgcolor=>$bannerColor}, center("\n"
    , comment("\nSCRIPT_NAME: $ENV{SCRIPT_FILENAME}\n")
    , "$pageHeader\n\n"))), Tr(td($headerText, $centeredText))))
    , hr(), $plainText, $counter , "\n$uptime\n<br>"
    , "\n$ENV{REMOTE_ADDR} $ENV{REQUEST_METHOD} from server \n"
    , a({-href=>"/", -target=>"_top"} , $ENV{SERVER_NAME}) , emailAddress();
if ($opt_head eq 1) { print end_html, "\n" };
exit(0)} # Halt any further execution of program.
# ..:....|....:....|....:....|....:....|....:....|....:....|....:....|....:....|
sub menuBar {my $menuBarName = "$ENV{DOCUMENT_ROOT}/menuBar.html";     # Site or
 -e $menuBarName or $menuBarName = '/var/www/no-ssl/html/Public/Content/menuBar.html';
 if ($ENV{HTTPS} and cookie(-name=>'logon')) {   # If allowd use Private menuBar
    if (cookie(-name=>'logon') eq 'lam') {
    $menuBarName = '/var/www/lam/html/Private/Content/menuBar.html'}}
 if (-e $menuBarName) {return(getTextFile($menuBarName))}       # Return menuBar
 else {return(comment("menuBar: $menuBarName not found."))}}        # or comment
# ..:....|....:....|....:....|....:....|....:....|....:....|....:....|....:....|
sub viewFormData {my $scriptName = $ENV{SCRIPT_FILENAME};      # Use script name
    if ($scriptName =~ /.*\/(.*)\.cgi-pl/) {$scriptName = $1}          # trimmed
    displayPage('-t', 'LAM Alaska '. $scriptName . ' Form Data', $scriptName
        . ' Form Data', namedParameters() , environmentVariables())}
# ..:....|....:....|....:....|....:....|....:....|....:....|....:....|....:....|
sub namedParameters { my $opt_head = ''; my $parameterCount = @_;
if ($parameterCount > 0) {$opt_head = shift}
my @param_names = param(); # Get a list of all the named parameters
my $htmlString = "\n<!--\n namedParameters \n-->\n";

my @table_rows = (td(b('Name')) . td(b('Value')) . "\n");

foreach my $p (@param_names) { # add each name and value pair
     my $Value = param($p);
     push(@table_rows,td({-valign=>'top'}, $p) . td($Value) . "\n");
     };                      #  to the table rows

$htmlString .= "<center>\n". h2('Parameters'). "\n" . table({-border=>1},
    Tr(\@table_rows)). "</center><p>\n";        # and print the table.

if ( $opt_head eq 1 ) {displayPage('', $htmlString)    # Print page with header
} else {return $htmlString}}                             # or return htmlString
# ..:....|....:....|....:....|....:....|....:....|....:....|....:....|....:....|
sub environmentVariables { # List environment variables in a table
my @EnvVar = ('SCRIPT_URI', 'RewriteRule', 'SCRIPT_NAME', 'REMOTE_ADDR',
    'REQUEST_METHOD', 'PATH_INFO','HTTPS', 'HTTP_USER_AGENT', 'HTTP_REFERER',
    'SERVER_SIGNATURE', 'SERVER_NAME', 'SERVER_ADDR', 'REMOTE_USER',);
my $listType = ''; my $parameterCount = @_;
if ($parameterCount > 0) {$listType = shift}
my $htmlString= comment('Print some environment values'). "\n". "<table border>"
    . Tr(td(b('Environmet Variable')). td(b('Value'))). "\n";
if ($listType eq 'list') {@EnvVar = @_;}
elsif($listType eq 'lam') { @EnvVar = keys(%ENV) }
elsif ($listType eq 'user') {# List all user environment variables
    @EnvVar = ('SCRIPT_URI', 'RewriteRule', 'SCRIPT_NAME', 'REMOTE_ADDR',
    'REQUEST_METHOD', 'PATH_INFO','HTTPS', 'HTTP_USER_AGENT', 'HTTP_REFERER',
    'SERVER_SIGNATURE', 'SERVER_ADMIN', 'SERVER_NAME', 'SERVER_ADDR',
    'LOGON_USER', 'AUTH_USER', 'REMOTE_USER')}
foreach my $EV (@EnvVar) {if ($ENV{$EV}) { # Each existing variable in list
    $htmlString .= Tr(td("$EV:") . td("$ENV{$EV}")). "\n"}}
$htmlString .= "</td></tr></table>\n";
return $htmlString}
# ..:....|....:....|....:....|....:....|....:....|....:....|....:....|....:....|
sub displaySource {                                         displaySourceTest: {
my $sourceLink;
my $parameterCount = @_;
if ($parameterCount > 0) {$sourceLink = shift}
my $oP = ''; if ("\L$ARGV[0]") {$oP = "\L$ARGV[0]";                    opTest: {
    if ($oP eq 'txt') {displayTextFile(); last opTest}          # Display source
    if ($oP eq 'source') {                                      # Display source
      if ( ! defined $sourceLink || $sourceLink eq "" )
        {displayTextFile()}
      else {reDirect(0,$sourceLink)} # reDirect($delay,$page)
      last opTest}
    if ($oP eq 'rlog') {displayRCSlog(); last opTest}          # Display RCS log
    if ($oP eq 'diff') {displayRCSdiff(); last opTest}        # Display RCS diff
    if ($oP eq 'lam.pm') {
reDirect(0,"https://github.com/LAMurakami/no-ssl/blob/master/site_perl-LAM/LAM.pm");
                          last opTest}
    if ($oP eq 'multicount.pm') {
reDirect(0,"https://github.com/LAMurakami/no-ssl/blob/master/site_perl-LAM/Multicount.pm");
                          last opTest}
    if ($oP eq 'sql.pm') {
reDirect(0,"https://github.com/LAMurakami/no-ssl/blob/master/site_perl-LAM/SQL.pm");
                          last opTest}
    if ($oP eq 'getdbvalue.pm') {
reDirect(0,"https://github.com/LAMurakami/no-ssl/blob/master/site_perl-LAM/GetDBvalue.pm");
                          last opTest}   }   }                     # end opTest:
my $pI = ''; if ($ENV{PATH_INFO}) {$pI = "\L$ENV{PATH_INFO}";        pathTest: {
    if ($pI eq '/txt') {displayTextFile(); last pathTest}       # Display source
    if ($pI eq '/source') {                                     # Display source
      if ( ! defined $sourceLink || $sourceLink eq "" )
        {displayTextFile()}
      else {reDirect(0,$sourceLink)} # reDirect($delay,$page)
      last pathTest}
    if ($pI eq '/rlog') {displayRCSlog(); last pathTest}       # Display RCS log
    if ($pI eq '/diff') {displayRCSdiff(); last pathTest}     # Display RCS diff
    if ($pI eq '/lam.pm') {
reDirect(0,"https://github.com/LAMurakami/no-ssl/blob/master/site_perl-LAM/LAM.pm");
                          last pathTest}
    if ($pI eq '/multicount.pm') {
reDirect(0,"https://github.com/LAMurakami/no-ssl/blob/master/site_perl-LAM/Multicount.pm");
                          last pathTest}
    if ($pI eq '/sql.pm') {
reDirect(0,"https://github.com/LAMurakami/no-ssl/blob/master/site_perl-LAM/SQL.pm");
                          last pathTest}
    if ($pI eq '/getdbvalue.pm') {
reDirect(0,"https://github.com/LAMurakami/no-ssl/blob/master/site_perl-LAM/GetDBvalue.pm");
                          last pathTest}   }    }                # end pathTest:
if (param('Submit')) {my $submitRequest = param('Submit');     
    if ($submitRequest eq 'View') {if (param('Plain')) {
            if (param('Text File') and $ENV{HTTPS} and cookie(-name=>'logon')) {
                displayTextFile(param('Text File')); last displaySourceTest
   } else {displayTextFile(); last displaySourceTest}}}}}} # end displaySource()
# ..:....|....:....|....:....|....:....|....:....|....:....|....:....|....:....|
sub displayTextFile {     # Display a file as a text/plain content type web page
my $scriptName = $ENV{SCRIPT_FILENAME};                        # Use script name
    if ($scriptName =~ /.*\/(.*)/) {$scriptName = $1} my $cLink = '';  # trimmed
my $viewType = 'text view'; my $source; my $parameterCount = @_; my $tLink = '';
if ($parameterCount > 0) {  $source = shift;
    if ($ENV{HTTPS} and cookie(-name=>'logon')) {$tLink =
        a({-href=>"$ENV{SCRIPT_NAME}?Plain=Text;Submit=View;Text+File=$source"},
        "\nPlain text view\n")}}
else {$source = $ENV{SCRIPT_FILENAME}; $viewType = 'Program Source';
    $tLink = a({-href=>"$ENV{SCRIPT_NAME}?Plain=Text;Submit=View"}
                    , "\nPlain text view\n");
    if ($ENV{HTTPS} and cookie(-name=>'logon')) {$cLink =
        a({-href=>"/Comments?Submit=View;Topic=Program;Name=$scriptName"}
    , "\n<br>$scriptName Program Comments")}}
my $text =  getTextFile($source);
if (param('Plain')) {print header('text/plain'), $text; exit(0)}        # or not
else {my $title = '';                 # Use title from RCS Id or construct title
    if ($text =~ /\x24Id: (.*)\x24/) {$title = "$1 $viewType"}         # x24 = $  
    else {$title = "$source $viewType"}                             # Default to
    LAM::displayPage('-c', '-t', $title, '', center(b($title), "\n$cLink\n"),
    center(textarea({-name=>'Program Source', -wrap=>'soft', -rows=>36,
    -columns=>85, -value=>$text, -READONLY=>1}))	     # use textarea for text
    . p({-class=>'Right'}, $tLink))}}                    # END displayTextFile()
# ..:....|....:....|....:....|....:....|....:....|....:....|....:....|....:....|
sub getTextFile { # Get specified file contents as text.
my $fileName = my $textFileString = ''; my $parameterCount = @_;
if ($parameterCount > 0) {$fileName = shift}
if(-e $fileName) { # test existance
     open(SERVER_FILE, $fileName) or displayPage('-e',
          "File cannot be opened for reading.", "$fileName \n". $!);
     while(<SERVER_FILE>) {$textFileString .= $_ } close(SERVER_FILE);
} else {displayPage('-e', "File not found!"
          , "$fileName does not exist on this server.") }
return $textFileString}
# ..:....|....:....|....:....|....:....|....:....|....:....|....:....|....:....|
sub displayRCSlog { my $source; my $parameterCount = @_;

if ($parameterCount > 0) {$source = shift}
else {$source = $ENV{SCRIPT_FILENAME}};

my $text .= "\nrlog $source\n";

$text .=  `rlog $source 2>&1`;

print header('text/plain'), $text;
exit(0)} # Halt any further execution of program.
# ..:....|....:....|....:....|....:....|....:....|....:....|....:....|....:....|
sub displayRCSdiff { my $source; my $parameterCount = @_;
if ($parameterCount > 0) {$source = shift}
else {$source = $ENV{SCRIPT_FILENAME}}
my $text = "\nrcsdiff -b -U0 $source\n";
$text .=  `rcsdiff -b -U0 $source 2>&1`; print header('text/plain'), $text;
exit(0)} # Halt any further execution of program.
# ..:....|....:....|....:....|....:....|....:....|....:....|....:....|....:....|
sub htmlHead {my $optHead = 0; my $html_title = ''; my $icon = '';
while ($_[0] =~ m/^-([hi])/) { my $option = $1;      # While optional parameters
    if ($option eq 'h') {$optHead=1}         # -h specifies omit the html header
    if ($option eq 'i') {shift;$icon=$_[0]}           # -i specifies custom icon
    shift} my $parameterCount = @_;
if ($parameterCount > 0) {$html_title = shift}                # Use title passed
else {$html_title = 'LAM Alaska '. $ENV{SCRIPT_FILENAME};        # Or Scriptname
    if ($html_title =~ /(.*)\/(.*)/) {$html_title = $2}}
my $htmlHead1 = <<ENDhtmlHead1;        # Specify english html definition of 1999
<!DOCTYPE html
    PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
     "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en-US" xml:lang="en-US">
<head><title>
ENDhtmlHead1
;
my $htmlHead2 = <<ENDhtmlHead2;
</title>
<meta name="Author" content="q.ServerAdmin\@lam1.us" />
<!--
                              By: Lawrence A. Murakami - Fairbanks, Alaska -->

<link rel="Shortcut Icon" href="/Images/My/Journal.ico" />
<link rel="stylesheet" type="text/css" href="/Public/Style.css" />
<script type="text/javascript" src="/Public/Scripts/Java/Navigation.js"></script>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
</head>
<body onload="initializeMenuBarforIE();">
ENDhtmlHead2
;
if ($icon) {$htmlHead2 =~ s/Journal/$icon/}      # Use custom icon if specified
if ($optHead) {return($htmlHead1. $html_title. $htmlHead2)}
else {return(header. $htmlHead1. $html_title. $htmlHead2)}}
# ..:....|....:....|....:....|....:....|....:....|....:....|....:....|....:....|
sub displayError {
my $headerText='';
my $boldedText='';
my $opt_head=1;
my $bodyText='';
my $optError=0;
my $html_title = 'LAM Alaska';

my $parameterCount = @_;
my $i = 0;
while ($parameterCount > $i++) {
    if ($i eq 1) {$headerText=shift}
    elsif ($i eq 2) {$boldedText=shift}
    elsif ($i eq 3) {$opt_head=shift}
    elsif ($i eq 4) {$bodyText=shift}
    elsif ($i eq 5) {$optError=shift}
    elsif ($i eq 6) {$html_title=shift}
}
my $errorPrefix = '';
my $bannerColor = 'lime';
if ($optError ne 1) {
    $errorPrefix = 'Error - ';
    $bannerColor = 'yellow'
}
if ( $opt_head eq 1 ) {print htmlHead($html_title)};
my $h2Text = '';
if ($boldedText ne '') {$h2Text = hr(). h2("\n\n$boldedText\n\n")};
my $plainText = '';
if ($bodyText ne '') {$plainText = hr(). p(). "\n$bodyText\n\n"};
print center(table(Tr(td({-bgcolor=>$bannerColor}, center("\n"
    , font({-size=>4, -face=>'Arial'}, comment("\n\nSCRIPT_NAME\n")
    , "\n$ENV{SCRIPT_NAME}\n\n")))),Tr(td(hr()
    , h1("\n\n$errorPrefix$headerText\n\n"), $h2Text, $plainText
    , hr(), p(), "\n$ENV{REMOTE_ADDR} $ENV{REQUEST_METHOD} from server "
    , "$ENV{SERVER_NAME}\n")))), emailAddress();
if ($opt_head eq 1) { print end_html, "\n" };
exit(0)} # Halt any further execution of program.
# ..:....|....:....|....:....|....:....|....:....|....:....|....:....|....:....|
sub timemark { my $parameterCount = @_;
my $epoch_time = ''; # Optional time to convert to local time.
my $timeFormat = 0; # Optional parameter to specify format
if ($parameterCount > 0) {$epoch_time = shift}
else {$epoch_time = time}; # Get the date and time
if ($parameterCount > 1) {$timeFormat = shift}

(my $Second, my $Minute, my $Hour, my $Day_Of_Month, my $Month, my $Year,
  my $Day_Of_Week) = localtime($epoch_time);

if ($timeFormat eq 0) {
    # Define a list with months of the year as it's contents.
    my @Month = ('January', 'February', 'March', 'April', 'May',
              'June', 'July', 'August', 'September', 'October',
              'November', 'December');

    # Define a list with days of the week as it's contents.
    my @Day = ('Sunday', 'Monday', 'Tuesday', 'Wednesday',
             'Thursday', 'Friday', 'Saturday');
   
    my ($H12, $AM_PM); # Define values  for a 12 hour clock.
    if($Hour < 1)     { $H12 = $Hour + 12; $AM_PM = 'AM'; }
    elsif($Hour < 12) { $H12 = $Hour;      $AM_PM = 'AM'; }
    elsif($Hour < 13) { $H12 = $Hour;      $AM_PM = 'PM'; }
    else              { $H12 = $Hour - 12; $AM_PM = 'PM'; }

    return "$Day[$Day_Of_Week], $Month[$Month] "
     . $Day_Of_Month . ', ' . ($Year + 1900) . ' @ ' . $H12
     . sprintf ":%.2d:%.2d $AM_PM", $Minute, $Second;
} elsif ($timeFormat eq 1) { # YYYY-MM-DD HH:MN:SS
    return sprintf "%.4d-%.2d-%.2d %.2d:%.2d:%.2d",
     $Year + 1900, $Month + 1, $Day_Of_Month, $Hour, $Minute, $Second;
} elsif ($timeFormat eq 2) { # YYYY-MM-DD HH:MN
    return sprintf "%.4d-%.2d-%.2d %.2d:%.2d",
     $Year + 1900, $Month + 1, $Day_Of_Month, $Hour, $Minute;
} elsif ($timeFormat eq 3) { # YYYYMMDDHHMNSS
    return sprintf "%.4d%.2d%.2d%.2d%.2d%.2d",
     $Year + 1900, $Month + 1, $Day_Of_Month, $Hour, $Minute, $Second;
} elsif ($timeFormat eq 4) { # YYYYMMDD
    return sprintf "%.4d%.2d%.2d",
     $Year + 1900, $Month + 1, $Day_Of_Month;
} elsif ($timeFormat eq 5) { # YYMMDD
     my $tmpString = sprintf "%.4d%.2d%.2d",
     $Year + 1900, $Month + 1, $Day_Of_Month;
    return substr($tmpString, 2);
} elsif ($timeFormat eq 6) { # YYYY/MM/DD HH:MM:SS
    return sprintf "%.4d/%.2d/%.2d %.2d:%.2d:%.2d",
     $Year + 1900, $Month + 1, $Day_Of_Month, $Hour, $Minute, $Second;
}}
# ..:....|....:....|....:....|....:....|....:....|....:....|....:....|....:....|
sub datetime {
# Get the fommated date and time
(my $Second, my $Minute, my $Hour, my $Day_Of_Month, my $Month, my $Year,
  my $Day_Of_Week, my $Day_Of_Year, my $Daylight_Savings_Time)
  = localtime($_[0]);

my $s_year = $Year + 1900;

return sprintf "%.4d/%.2d/%.2d %.2d:%.2d:%.2d",
                $s_year, $Month + 1, $Day_Of_Month, $Hour,
                $Minute, $Second;
}
# ..:....|....:....|....:....|....:....|....:....|....:....|....:....|....:....|
sub commify { # reformat numeric strings with commas
    my $text = reverse $_[0];
    $text =~ s/(\d\d\d)(?=\d)(?!\d*\.)/$1,/g;
    $text = reverse $text;
    return $text;
}
# ..:....|....:....|....:....|....:....|....:....|....:....|....:....|....:....|
sub checkSSL { # Require SSL and provide secure link if not used.
if ($ENV{HTTPS} ne 'on') { my $URL = $ENV{SERVER_NAME} . $ENV{REQUEST_URI};
my $secureURL = '<a href="https://' . $URL . '">https://' . $URL .'</a>';
my $text1 = "Unsecured communications"; my $text2 = "Try: $secureURL";
my $SSLmessage = 'It is intended that this content be requested and displayed'
 . ' over an encrypted secure socket layer (SSL) or transport layer security'
 . ' (TLS) transport mechanism. This ensures reasonable protection from'
 . ' eavesdroppers and man in the middle attacks';
use LAM::Multicount qw(webPageCounter);
displayPage('-e', $text1, "\n$text2\n", "\n$SSLmessage.\n<p>\n" .
    Multicount::webPageCounter('-f'));}}
# ..:....|....:....|....:....|....:....|....:....|....:....|....:....|....:....|
sub fixString {
$_ = shift;  # String is parameter
s/'/''/g;    # fix single quotes
s/\\/\\\\/g; # fix backslash characters
return $_     }
# --:----|----:----|----:----|----:----|----:----|----:----|----:----|----:----|
sub reDirect { # reDirect($delay,$page)
my $delay = shift;
my $page = shift;

print "Content-type:text/html\r\n\r\n";
print "<!DOCTYPE html\n";
print '          PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"', "\n";
print '          "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">', "\n";
print '<html>';
print "<head>\n";
print '<meta http-equiv="refresh" content="', $delay, '; url=', "'";
print $page, "'";
print '" />', "\n";
print "<title>Redirects to $page </title> \n";
print "</head>\n";
print "<body>\n";
print '<p>Redirects to <a href="';
print $page;
print '">', $page, '</a><br>', "\n";
print "after a $delay seconds delay.</p>\n";
print "</body>\n";
print "</html>\n";
}
# ..:....|....:....|....:....|....:....|....:....|....:....|....:....|....:....|
