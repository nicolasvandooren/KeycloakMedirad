FROM jboss/keycloak:4.5.0.Final

COPY themes /opt/jboss/keycloak/themes

COPY scripts /opt/jboss/tools/

ENTRYPOINT ["/opt/jboss/tools/myEntryPoint.sh"]
