#!/usr/bin/env bash

set -e

export WEBAPP_BASE=/usr/local/webapp \
       ARCHIVE_FILE=stnd_pmis.war \
       JAVA_OPTS="$JAVA_OPTS \
-Ddb.Url=\"$DB_URL\" \
-Ddb.Username=$DB_USERNAME \
-Ddb.Password=$DB_PASSWORD \
-Dsystem.upload.handler=$SYSTEM_UPLOAD_HANDLER"

if [ -f "/usr/local/src/$ARCHIVE_FILE" ]; then
    rm -rf $WEBAPP_BASE/ROOT
    mkdir -p $WEBAPP_BASE && mv -f /usr/local/src/$ARCHIVE_FILE $WEBAPP_BASE
fi

export JVM_ROUTE=${JVM_ROUTE:-worker1}
#sed -i "s/worker1/$JVM_ROUTE/" /usr/local/tomcat/conf/server.xml
envsubst '$JVM_ROUTE $ARCHIVE_FILE' < /usr/local/tomcat/conf/server.xml.template > /usr/local/tomcat/conf/server.xml

if [ $# -eq 0 ]; then
    # if no arguments are supplied start apache
    exec catalina.sh run
fi

exec "$@"