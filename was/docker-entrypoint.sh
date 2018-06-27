#!/usr/bin/env bash

set -e

export WEBAPP_BASE="/usr/local/webapp" \
       ARCHIVE_FILE="${ARCHIVE_FILE:-stnd_pmis.war}" \
       JAVA_OPTS="-Duser.timezone=GMT $JAVA_OPTS"

# set system timezone
echo "${SYSTEM_TIMEZONE:-Asia/Seoul}">/etc/timezone && \
dpkg-reconfigure --frontend=noninteractive tzdata

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

export JVM_ROUTE=${JVM_ROUTE:-worker1}
#sed -i "s/worker1/$JVM_ROUTE/" /usr/local/tomcat/conf/server.xml
envsubst '$JVM_ROUTE $ARCHIVE_FILE' < /usr/local/tomcat/conf/server.xml.template > /usr/local/tomcat/conf/server.xml

if [ $# -eq 0 ]; then
    # if no arguments are supplied start apache
    exec catalina.sh run
fi

exec "$@"