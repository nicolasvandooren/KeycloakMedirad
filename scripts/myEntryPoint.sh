#!/bin/sh

./tools/docker-entrypoint.sh -b 0.0.0.0 > log &

PID=$!

LASTLINE=$(tac log |egrep -m 1 .)
substring="[org.jboss.as] (Controller Boot Thread) WFLYSRV0025: Keycloak 4.5.0.Final (WildFly Core 5.0.0.Final) started"
SIZE_1=0
SIZE_2=1

sleep 5

while [[ $LASTLINE != *"${substring}"* ]] ; do
  SIZE_1=$(stat --printf="%s" log)
  sleep 1
  SIZE_2=$(stat --printf="%s" log)
  LASTLINE=$(tac log |egrep -m 1 .)
done
echo ""
cat log
echo ""


./keycloak/bin/kcadm.sh config credentials --server http://localhost:8080/auth --realm master --user ${KEYCLOAK_USER} --password ${KEYCLOAK_PASSWORD}
./keycloak/bin/kcadm.sh update realms/master -s sslRequired=NONE

./keycloak/bin/kcadm.sh create realms -s realm=irdbb -s enabled=true -s registrationAllowed=true -s sslRequired=NONE
./keycloak/bin/kcadm.sh create clients -r irdbb -s clientId=irdbb-ui -s enabled=true -s publicClient=true -s 'webOrigins=["*"]' -s 'redirectUris=["*"]' -s implicitFlowEnabled=true

wait $PID
