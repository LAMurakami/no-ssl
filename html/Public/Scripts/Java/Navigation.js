function initializeMenuBarforIE(){if(navigator.appVersion.indexOf("MSIE")==-1){return;}
 var i,k,g,lg,r=/\s*fixIEhvr/,nn='',c,cs='fixIEhvr',bv='menuBar';
 for(i=0;i<10;i++){g=document.getElementById(bv+nn);if(g){
 lg=g.getElementsByTagName("LI");if(lg){for(k=0;k<lg.length;k++){
 lg[k].onmouseover=function(){c=this.className;cl=(c)?c+' '+cs:cs;
 this.className=cl;};lg[k].onmouseout=function(){c=this.className;
 this.className=(c)?c.replace(r,''):'';};}}}nn=i+1;}}
function GoTo_URL(theform) {if (theform.New_Window.checked)
 var newwin = window.open(theform.LAM_URL[theform.LAM_URL.selectedIndex].value);
else document.location = theform.LAM_URL[theform.LAM_URL.selectedIndex].value;
return true}
