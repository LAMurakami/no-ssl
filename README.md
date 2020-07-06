# Default unsecure site (http://)

[no-ssl.lam1.us](http://no-ssl.lam1.us/)
[no-ssl.lamurakami.com](http://no-ssl.lamurakami.com/)

This repo contains content in the html folder and an apache2 configuration.
that can be implemented with:

The LAM AWS EC2 lam1 CloudInit builds a LAMP model web service software stack
instance from the Latest Ubuntu Server image available.
The configuration and content is split into several sub directories of
/var/www/ with the content in a html/ subdirectory of each as outlined below:

/var/www/aws/
         |-- aws-nwo-lam1-Ubuntu-CloudInit.txt
         |-- apache2.conf
         |-- cloud-init.pl
         |-- <site>_apache2.conf
         |-- <site>_archive_rebuild.bash
         |-- html/
/var/www/no-ssl/
         |-- Implement_no-ssl_conf.bash
         |-- Implement_more_sites_conf.bash
         |-- Implement_more_apache2_stuff.bash
         |-- <site>_apache2.conf
         |-- <site>_archive_rebuild.bash
         |-- html/
             |-- Public/
                 |-- Scripts/
/var/www/<additional-sites>/
         |-- <site>_apache2.conf
         |-- <site>_archive_rebuild.bash
         |-- html/
/var/www/lam/
         |-- Implement_lam_conf.bash
         |-- <site>_apache2.conf
         |-- <site>_archive_rebuild.bash
         |-- {.htgroup,.htpasswd}
         |-- data/
         |-- html/
             |-- Private/
                 |-- Scripts/

* Implement* These four scripts will implement the configuration when run with
root (sudo) permissions.

* aws-nwo-lam1-Ubuntu-CloudInit.txt is the configuration for the initializaton
of the instance during the first and subsequent boots.  During the first boot
it updates all the installed packages and then installs additional packages
to support LAMP model web services including a MediaWiki installation.
It modifies the File System Table so that a LAM AWS Elastic File System (EFS)
instance shared with all the LAM AWS EC2 instances is mounted by nfs4.
The site subdirectories and additional software is installed from tgz archives
on this persistant shared filesystem.

* apache2.conf is the main apache2 configuration file.  The /Public alias is
included here allowing no-ssl/html/Public/ content to be accessed from any
site and a set of /var/www/no-ssl/html/Public/Scripts Directory directives
defining .cgi-pl as scripts to be accessed from any site.
A set of custom error handlers are also defined here.

* cloud-init.pl applies the ublic-hostname, public-ipv4, local-hostname and
local-ipv4 values from the /var/log/cloud-init-output.log to the
/var/www/aws/html/index.html and /var/www/aws/aws_apache2.conf files so the
Dynamic Domain Name Service page is displayed when the AWS public domain
name or IP address is visited.

* site_perl-LAM contains some perl modules to be linked into site_perl.
The modules simplify a number of cgi perl routines used in both Public
and Private scripts of the sites.
