#!/usr/bin/perl
# $Id: Multicount.pm,v 1.8 2008/03/24 04:45:35 lam Exp lam $

package     Multicount;
use LAM::LAM qw(displayPage namedParameters);
require     Exporter;
our @ISA        = qw(Exporter);
our @EXPORT     = qw(webPageCounter);
our @EXPORT_OK  = qw(webPageCounter getPageCounter);
our @VERSION    = 1.0;

our $errorText;

# Modified: Monday, June 19, 2006 @ 7:58:15 PM - Fairbanks, Alaska
#       By: Lawrence A. Murakami - www.ServerAdmin@lam-ak.com

# I found this a: http://www.mattriffle.com/software/multicount/

# I Made the script into a module and modified the main subroutine
#  to return a formatted count string rather than writing a page.
# 1. Changed file name from mcount.cgi to Multicount.pm
# 2. Eliminated main program
# 3. Renamed the main inc_and_display subroutine to webPageCounter
# 4. Renamed display_counts subroutine to to formatCounts

# Monday, June 19, 2006 @ 7:58:15 PM - Fairbanks, Alaska
# Modified script to work in my Linux Apache environment.

# Tuesday, July 23, 2002 @ 8:49:21 PM - Fairbanks, Alaska
# Modified script to work in my Windows 2000 environment.

# Multicount                             Version 3.0                  
# Copyright 1998-2002 by Matt Riffle     All Rights Reserved.         
# Initial Full Release: 7/4/98           This Release: 6/16/02         
# pingPackets                            http://www.pingpackets.com/  

# This program is free software; you can redistribute it and/or       
# modify it under the terms of the GNU General Public License         
# as published by the Free Software Foundation; either version 2      
# of the License, or (at your option) any later version.              
#                                                                     
# This program is distributed in the hope that it will be useful,     
# but WITHOUT ANY WARRANTY; without even the implied warranty of      
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the       
# GNU General Public License for more details.  It is included in     
# this distribution in the file "license.txt".                        
#                                                                     
# You should have received a copy of the GNU General Public License   
# along with this program; if not, write to the Free Software         
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA           
# 02111-1307, USA.            

# a standard pragma & module
use strict;
use Fcntl qw(:DEFAULT :flock);
# A fairly popular module for those with CGI web pages on their site.
use CGI qw(:all);

# This is the directory in which the script will keep its data files.
# It should be chmod 777, or what is needed to ensure the server can write 
# to it.
my $DATA_DIR = '/var/www/Multicount';

# If this is set to 1, the last IP address to access the counter will be
# cached to prevent one person from repeatedly updating the counter.  If
# it is set to 0, one person can increment the counter multiple times in
# succession.
my $IP_CACHING = 0;

# The counts can be reported in various styles.  To use normal numbers,
# specify 'numeric' or do not set this variable.  To use numbers with 
# commas inserted at the correct points, specify 'commas'.  To use
# Roman numerals, specify 'roman'.  For hexadecimal numbers, specify
# 'hex'.  For binary, use 'binary'.  For octal, use 'octal'.
my $STYLE = 'commas';

# This is the format in which the output will be returned.  Put
# OVERALL where you want the total count, DAILY where you want the
# daily count, and WEEKLY where the weekly count should go, MONTHLY
# for monthly count, and YEARLY for yearly count.  If you
# don't want a certain count, just omit its keyword.
my $FORMAT = 'OVERALL visits (DAILY today, WEEKLY this week, MONTHLY this
              month, YEARLY this year)';

#### DO NOT EDIT BELOW THIS LINE ####


sub webPageCounter {my $fbase;
	my $fileName = ''; my $byProtocol = 1; my $byURL = '';
	while ($_[0] =~ m/^-([fsu])/) { my $option = $1;	# While optional parameters
		if ($option eq 'f') {$fileName = 1} # -f - Use SCRIPT_'FILE'NAME
		if ($option eq 'u') {$byURL = 1} # -u - Use SCRIPT_URL
		if ($option eq 's') {$byProtocol = 0} # -s - Use one counter for HTTP and HTTPS
		shift}
FBASE:{
	if ($fileName) {$fbase = filename_base($ENV{SCRIPT_FILENAME})
        or error("Error determining file"); last FBASE}
	if ($byURL) {$fbase = filename_base("$ENV{DOCUMENT_ROOT}$ENV{SCRIPT_URL}")
        or error("Error determining file"); last FBASE}
	$fbase = filename_base($ENV{SCRIPT_FILENAME})
        or error("Error determining file");
}
	if ($byProtocol) {
    if ($ENV{HTTPS} ne 'on') { $fbase = $fbase . '_HTTPS_OFF'}}
    lock_file($fbase) or
    
LAM::displayPage("Multicount - Error locking file!"   # Error
 , "\nFile name: " . $fbase), $!;
    
    
	if ($fbase =~ /(.+)/) {$fbase = "$1"} # Unsafe untaint!
    sysopen(F1,"$fbase.cnt",O_RDWR|O_CREAT) or error("Error opening count"); 
    chomp(my $counts = <F1>);
    my $upcounts = update_counts($counts) or error("Error updating count");
    seek(F1,0,0) or error("Error updating count");
    truncate(F1,0) or error("Error updating count");
    print F1 $upcounts;
    close(F1) or error("Error updating count");
    unlock_file();
    return formatCounts($upcounts);
}

sub filename_base {
    my $uri = shift || return undef;
    (my $filename = $uri) =~ s/[\W\0]/_/g;
    # limit length, mostly to keep compatibility with previous versions
    $filename = substr($filename,0,240) if length($filename) > 240;
    return "$DATA_DIR/$filename";
} 

sub formatCounts {
    my @results = (split(/:/,shift))[0..4];
    @results = commas(@results) if $STYLE eq 'commas';
    @results = hexa(@results) if $STYLE eq 'hex';
    @results = binary(@results) if $STYLE eq 'binary';
    @results = octal(@results) if $STYLE eq 'octal';
    @results = roman(@results) if $STYLE eq 'roman';
    $FORMAT =~ s/OVERALL/$results[0]/ig;
    $FORMAT =~ s/DAILY/$results[1]/ig;
    $FORMAT =~ s/WEEKLY/$results[2]/ig;
    $FORMAT =~ s/MONTHLY/$results[3]/ig;
    $FORMAT =~ s/YEARLY/$results[4]/ig;
    return $FORMAT;
}

sub update_counts {
    my $counts = shift;
    unless ($counts =~ /^(\d+:){7}([\d\.]+)$/)
	    {$counts = '0:0:0:0:0:0:0:127.0.0.1';}
    my ($overall,$daily,$weekly,$monthly,$yearly,$fdstamp,$fwstamp,$ip) 
        = split(/:/,$counts);
    my $dstamp = dstamp();
    my $wstamp = wstamp();
    $yearly = 0 if (substr($fdstamp,0,4) < substr($dstamp,0,4));
    $monthly = 0 if (substr($fdstamp,0,6) < substr($dstamp,0,6));
    if ($fdstamp < $dstamp) { $daily = 0; $fdstamp = $dstamp }
    if ($fwstamp < $wstamp) { $weekly = 0; $fwstamp = $wstamp }
    unless ($IP_CACHING && $ENV{REMOTE_ADDR} eq $ip)
	    {$overall++; $daily++; $weekly++; $monthly++; $yearly++}
    return <<END
$overall:$daily:$weekly:$monthly:$yearly:$fdstamp:$fwstamp:$ENV{REMOTE_ADDR}
END
}

sub lock_file {
    my $fbase = shift;
	if ($fbase =~ /(.+)/) {$fbase = "$1"} # Unsafe untaint!
    open(LOCK,">$fbase.lck") or return undef;
    eval { 
        local $SIG{ALRM} = sub { die };
        alarm(10);
        flock(LOCK,LOCK_EX) or return undef;
        alarm(0);
    };
    return ($@) ? undef : 1;
}

sub unlock_file {
    close(LOCK);
}

sub error {
    print header(),"[MC Error: ",shift,"]";
    exit;
}

sub dstamp {
    my ($d,$m,$y) = (localtime())[3,4,5];
    return sprintf("%4d%02d%02d",$y+=1900,++$m,$d)
}

sub wstamp {
    my ($d,$m,$y) = (localtime(((7-(localtime())[6])*86400)+time))[3,4,5];
    return sprintf("%4d%02d%02d",$y+=1900,++$m,$d)
}

sub header { 
    "Content-type: text/html\n\n"
}

sub commas {
    map { $_ = reverse; s/(\d\d\d)(?=\d)(?!\d*\.)/$1,/g; scalar reverse } @_
}

sub hexa {
    map { uc(sprintf("%x",$_)) } @_
}

sub octal {
    map { sprintf("%o",$_) } @_
}

sub binary {
    map { ($_ = unpack('B32',pack('N',$_))) =~ s/^0+(?=\d)//; $_ } @_
}

sub roman {
    map {
        my $rnum;
        my $n1 = $_ % 10; $_ = ($_-$n1) / 10;   
        my $n10 = $_ % 10; $_ = ($_-$n10) / 10;
        my $n100 = $_ % 10; $_ = ($_-$n100) / 10;
        $rnum .= ('C','CC','CCC','CD','D','DC','DCC','DCCC','CM')[$n100-1]
            if $n100;
        $rnum .= ('X','XX','XXX','XL','L','LX','LXX','LXXX','XC')[$n10-1]   
            if $n10;
        $rnum .= ('I','II','III','IV','V','VI','VII','VIII','IX')[$n1-1]
            if $n10;
        while ($_) { $rnum = 'M' . $rnum ; $_-- }
        $rnum
    } @_
}

sub getPageCounter {
	my $fileName = ''; my $byProtocol = 1;
	while ($_[0] =~ m/^-([fs])/) { my $option = $1;	# While optional parameters
		if ($option eq 'f') {$fileName = 1} # -f - Use SCRIPT_'FILE'NAME
		if ($option eq 's') {$byProtocol = 0} # -s - Use one counter for HTTP and HTTPS
		shift}
	my $fbase = shift;
	if(-e "$fbase.cnt") { # test existance
		if ($fbase =~ /(.+)/) {$fbase = "$1"} # Unsafe untaint!
	    sysopen(F1,"$fbase.cnt",O_RDONLY) or error("Error opening count"); 
	    chomp(my $counts = <F1>);
	    my $upcounts = update_counts($counts) or error("Error updating count");
	    close(F1) or error("Error updating count");
	    return formatCounts($upcounts);
	} else {use LAM::LAM qw(displayPage); LAM::displayPage('-e', "File not found!"
	          , "$fbase.cnt does not exist on this server.")}}
