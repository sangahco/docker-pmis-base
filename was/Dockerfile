FROM sangah/tomcat-base:jre8

COPY server.xml.template /usr/local/tomcat/conf/
ONBUILD COPY ./ /usr/local/src/

# force locale to Korean
ENV LC_ALL=ko_KR.UTF8 \
    WEBAPP_BASE=/usr/local/webapp \
    ARCHIVE_FILE=stnd_pmis.war \
    JVM_ROUTE=worker1 \
    MACHINE_HOST=127.0.0.1 \
    SYSTEM_TIMEZONE=GMT

EXPOSE 8080
EXPOSE 8081

# don't add anything else after this!
COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
#CMD ["catalina.sh", "run"]

HEALTHCHECK CMD curl -Ss http://127.0.0.1:8080/ || exit 1
