FROM dev.sangah.com:5043/tomcat-base:jre8

COPY server.xml.template /usr/local/tomcat/conf/
ONBUILD COPY ./ /usr/local/src/

# force locale to Korean
ENV LC_ALL=ko_KR.UTF8

EXPOSE 8080
EXPOSE 8081

# don't add anything else after this!
COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
#CMD ["catalina.sh", "run"]

HEALTHCHECK CMD curl -Ss http://127.0.0.1:8080/ || exit 1
