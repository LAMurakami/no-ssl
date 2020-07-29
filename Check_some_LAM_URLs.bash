#!/bin/bash
# Check a list of URLs including detecting redirection and SSL issuer

check_URL () {
for URL in "$@" ; do
  echo "Checking ${URL}"
  curl -v -s -o /dev/null -L ${URL} 2>&1 | grep \
  '^\* Connected to\|^< HTTP\|^< Location\|^< Status\|^\*  issuer:\|^curl:'
  echo
  done
}

URL_LIST=('https://aws.lam1.us' 'https://www.lam1.us' \
'https://ak17.lam1.us' 'http://github.lamurakami.com/blog' \
'lamurakami.com' 'lam1.us' 'larryforalaska.com' \
'larrymurakami.com')

echo

check_URL ${URL_LIST[@]}

