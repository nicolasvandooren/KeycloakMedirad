#!/bin/sh

./tools/docker-entrypoint.sh -b 0.0.0.0 > log &

PID=$!

LASTLINE=$(tac log |egrep -m 1 .)
substring="[org.jboss.as] (Controller Boot Thread) WFLYSRV0025: Keycloak 4.5.0.Final (WildFly Core 5.0.0.Final) started"

if [[ -z "${REALM}" ]]; then
  REALM=irdbb
fi

if [[ -z "${CLIENT}" ]]; then
  CLIENT=irdbb-ui
fi

if [[ -z "${REDIRECTURIS}" ]]; then
  REDIRECTURIS=*
fi

if [[ -z "${WEBORIGINS}" ]]; then
  WEBORIGINS=*
fi

sleep 10

while [[ $LASTLINE != *"${substring}"* ]] ; do
  LASTLINE=$(tac log |egrep -m 1 .)
done

echo ""
cat log
echo ""


./keycloak/bin/kcadm.sh config credentials --server http://localhost:8080/auth --realm master --user ${KEYCLOAK_USER} --password ${KEYCLOAK_PASSWORD}
./keycloak/bin/kcadm.sh update realms/master -s sslRequired=NONE

REALMS_PRESENTS="$(./keycloak/bin/kcadm.sh get realms --fields realm --format csv --noquotes)"

if [[ ! $REALMS_PRESENTS = *"${REALM}"* ]] ; then
  ./keycloak/bin/kcadm.sh create realms -s realm=${REALM} -s enabled=true -s registrationAllowed=true -s sslRequired=NONE
  ./keycloak/bin/kcadm.sh create clients -r ${REALM} -s clientId=${CLIENT} -s enabled=true -s publicClient=true -s 'webOrigins=["'${WEBORIGINS}'"]' -s 'redirectUris=["'${REDIRECTURIS}'"]'
fi

userlists=/run/secrets/users_lists
firstpassword=/run/secrets/users_password
if [ -f $userlists ]; then
  if [ -f $firstpassword ]; then
    password=$(cat $firstpassword)
  else
    password=changeme
  fi

  while read -r line; do
      user="$line"
      echo "Create user : $user"
      ./keycloak/bin/kcadm.sh create users -r ${REALM} -s username=$user -s enabled=true
      ./keycloak/bin/kcadm.sh set-password -r ${REALM} --username $user  --new-password $password --temporary
  done < "$userlists"
fi

wait $PID
