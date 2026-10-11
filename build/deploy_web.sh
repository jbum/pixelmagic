#!/bin/sh
# Publish build/web (made by build_web.py) to qts.jbum.com: a static site on mibbles,
# served from /home/jbum/qts.jbum.com (/var/www/qts.jbum.com links to it).
set -e
cd "$(dirname "$0")"
[ -f web/qts.wasm ] || { echo "build/web is missing: run build/build_web.py first"; exit 1; }
rsync -az --delete web/ jbum@mibbles:qts.jbum.com/
echo "published to https://qts.jbum.com/"
