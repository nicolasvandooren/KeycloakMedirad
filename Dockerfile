FROM jboss/keycloak:4.5.0.Final

COPY themes /opt/jboss/keycloak/themes

ADD scripts /opt/jboss/tools/

USER root

RUN ["chmod", "+x", "/opt/jboss/tools/myEntryPoint.sh"]

ENTRYPOINT ["/opt/jboss/tools/myEntryPoint.sh"]
