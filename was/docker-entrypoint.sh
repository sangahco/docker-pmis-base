#!/usr/bin/env bash

set -e

# set system timezone
SYSTEM_TIMEZONE="${SYSTEM_TIMEZONE:-Asia/Seoul}"
echo "${SYSTEM_TIMEZONE}">/etc/timezone && \
dpkg-reconfigure --frontend=noninteractive tzdata

export JAVA_OPTS="-Duser.timezone=$SYSTEM_TIMEZONE $JAVA_OPTS"

mkdir -p $WEBAPP_BASE
LOCKFILE=$WEBAPP_BASE/deploy.lock
eval "exec 200>$LOCKFILE"
if flock -n 200; then
    if [ -f "/usr/local/src/$ARCHIVE_FILE" ]; then
        echo "Moving WAR file to appbase directory..."
        rm -rf $WEBAPP_BASE/ROOT
        mv -f /usr/local/src/$ARCHIVE_FILE $WEBAPP_BASE
    fi
else
    echo "WAR file already in appbase directory or locked by another process"
    sleep 120
fi

flock -u 200

#sed -i "s/worker1/$JVM_ROUTE/" /usr/local/tomcat/conf/server.xml
envsubst '$JVM_ROUTE $ARCHIVE_FILE' < /usr/local/tomcat/conf/server.xml.template > /usr/local/tomcat/conf/server.xml

if [ $# -eq 0 ]; then
    # if no arguments are supplied start apache
    exec catalina.sh run
fi

exec "$@"