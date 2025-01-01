# Linux Apache MariaDB in the cloud
## GitLab and GitHub public Projects/Repositories
The
[gitlab.com/aws-lam/no-ssl](https://gitlab.com/aws-lam/no-ssl)
Project is a clone of the
[github.com/LAMurakami/no-ssl](https://github.com/LAMurakami/no-ssl)
Repostory.  My
[gitlab.com/LAMurakami](https://gitlab.com/LAMurakami)
account was created so that Projects can be cloned using https without
authentication over IPv6 as well as IPv4 unlike the
[github.com/LAMurakami](https://github.com/LAMurakami)
Repostories that can only be accessed over IPv6 with the
[IPv6 only workaround.](https://lamurakami.github.io/blog/2024/06/05/Access-GitHub-com-from-an-instance-without-a-public-IPv4-address.html)

## Default unsecure site &lt;http&gt; configuration
[www.lam1.us](http://www.lam1.us/)
[www.lamurakami.com](http://www.lamurakami.com/)

Default unsecure site &lt;http&gt; configuration.

This repo contains content in the html folder and an apache2 configuration.

Content (DocumentRoot) is now at /var/www/&lt;site&gt;/html for all sites and
configuration and supporting files within /var/www/&lt;site&gt; but not the
DocumentRoot.

The LAM AWS EC2 lam1 CloudInit builds a
[LAMP](https://en.wikipedia.org/wiki/LAMP_(software_bundle))
model web service software
stack instance from the Latest Ubuntu Server image available.
The configuration and content is split into several sub directories of
/var/www/ with each being a separate git repository.  Each repo has the
content in a html/ subdirectory as outlined below:

<pre>/var/www/aws/
         |-- aws-lam1-Ubuntu-24-Noble-CloudInit.txt
         |-- cloud-init.pl
         |-- aws_apache2.conf
         |-- aws_ssl_lam1_apache2.conf
         |-- aws_ssl_duckdns_apache2.conf
         |-- html/           DocumentRoot /var/www/aws/html/
/var/www/no-ssl/
         |-- apache2.conf
         |-- Implement_no-ssl_conf.bash
         |-- Implement_more_sites_conf.bash
         |-- Implement_more_apache2_stuff.bash
         |-- no-ssl_apache2.conf
         |-- html/           DocumentRoot /var/www/no-ssl/html/
             |-- Public/
                 |-- Scripts/
/var/www/&lt;additional-sites&gt;/
         |-- &lt;site&gt;_apache2.conf
         |-- &lt;site&gt;_ssl_lam1_apache2.conf
         |-- html/           DocumentRoot /var/www/&lt;additional-sites&gt;/html/
/var/www/lam/
         |-- Implement_lam_conf.bash
         |-- lam_apache2.conf
         |-- .ht{group,passwd}
         |-- data/
         |-- html/           DocumentRoot /var/www/lam/html/
             |-- Private/
                 |-- Scripts/</pre>

* Implement* These four scripts will implement the configuration when run
with root (sudo) permissions.

* [aws-lam1-Ubuntu-24-Noble-CloudInit.txt](https://gitlab.com/aws-lam/aws/-/blob/master/aws-lam1-Ubuntu-24-Noble-CloudInit.txt?ref_type=heads) is a configuration for the initializaton
of the instance during the first and subsequent boots.  During the first boot
it updates all the installed packages and then installs additional packages
to support LAMP model web services including a MediaWiki installation.
It modifies the File System Table so that a LAM AWS Elastic File System (EFS)
instance shared with all the LAM AWS EC2 instances is mounted by nfs4.
The site subdirectories and additional software is installed from tgz
archives on this persistant shared filesystem.

* [apache2.conf](https://gitlab.com/aws-lam/no-ssl/-/blob/master/apache2.conf?ref_type=heads)
is the main apache2 configuration file.  The /Public alias is
included here allowing no-ssl/html/Public/ content to be accessed from any
site and a set of /var/www/no-ssl/html/Public/Scripts Directory directives
defining .cgi-pl as scripts to be accessed from any site.
A set of custom error handlers are also defined here.

* The
[aws_apache2.conf](https://gitlab.com/aws-lam/aws/-/blob/master/aws_apache2.conf?ref_type=heads),
[aws_ssl_lam1_apache2.conf](https://gitlab.com/aws-lam/aws/-/blob/master/aws_ssl_lam1_apache2.conf?ref_type=heads)
and
[aws_ssl_duckdns_apache2.conf](https://gitlab.com/aws-lam/aws/-/blob/master/aws_ssl_duckdns_apache2.conf?ref_type=heads)
apache2 configuration files implment the non secure site, secure site using lam1.us and secure site duckdns.org keys respectively.

* [cloud-init.pl](https://gitlab.com/aws-lam/aws/-/blob/master/cloud-init.pl?ref_type=heads)
applies the public-hostname, public-ipv4, local-hostname and
local-ipv4 values from the /var/log/cloud-init-output.log to the
/var/www/aws/html/index.html and /var/www/aws/aws_apache2.conf files so the
Dynamic Domain Name Service page is displayed when the AWS public domain name
or IP address is visited.

* &lt;site&gt;_apache2.conf is the site apache2 configuration file.  The LAM AWS
EC2 LAMP instance does not support .htaccess files.  The &lt;site&gt;_apache2.conf
file is linked into /etc/apache2/sites-available and then enabled with
a2ensite in the Implement_more_sites_conf.bash script which also assigns
a three digit numerical order for the sites.  Force apache2 to read any
changes in configuration files with:
 systemctl reload apache2

* site_perl-LAM contains perl modules to be linked into site_perl.
The modules simplify a number of cgi perl routines used in both Public
and Private scripts of the sites.

See Also:
* [aws repo](https://gitlab.com/aws-lam/aws/-/tree/master?ref_type=heads)
* [arsc repo](https://gitlab.com/aws-lam/arsc/-/tree/master?ref_type=heads)
