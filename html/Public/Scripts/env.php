<html><head>

<title> Environment/Server Variables </title>

<meta name="Author" content="www.ServerAdmin@lam-ak.com" />
<link rel="stylesheet" type="text/css" href="/Public/Style.css" />
</head><body>
<h1><center >
<a href="/Comments.cgi-pl?Topic=Program;Name=env.php;Submit=View"
>
		Environment/Server Variables

</a></center ></h1><p />

This is a combination of html and php code to display some of
 the environment and server variables on my website.

<p />

I played with php over a decade ago when it was known as
 Personal Home Page Tools.  I got into it because it was
 Free Software.  <a href="http://en.wikipedia.org/wiki/PHP" >
 According to Wikipedia</a >, it was originally created to
 replace some Perl scripts.  I still use my custom Perl scripts.
 I suppose if you are uncomfortable with programming languages
 but know html it might be the thing.  If you are comfortable
 with programming it might just be whichever you learned first.

<p /><center ><hr width="50%" ></center >

<p />ENV_HOSTNAME: <?php echo $_ENV['HOSTNAME'] ?>

<p />HTTPS: <?php echo $_SERVER['HTTPS'] ?>

<p />SERVER_SIGNATURE: <?php echo $_SERVER['SERVER_SIGNATURE'] ?>

</body></html>
