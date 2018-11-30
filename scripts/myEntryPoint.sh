#!/bin/sh
if [ -f /run/secrets/db_password ]; then
  export DB_PASSWORD=$(cat /run/secrets/db_password)
fi

./tools/docker-entrypoint.sh -b 0.0.0.0 > log &

PID=$!

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

LASTLINE=$(tac log |egrep -m 1 .)
substring="[org.jboss.as] (Controller Boot Thread) WFLYSRV0025: Keycloak 4.5.0.Final (WildFly Core 5.0.0.Final) started"

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
  ./keycloak/bin/kcadm.sh create realms -s realm=${REALM} -s enabled=true -s sslRequired=NONE
  ./keycloak/bin/kcadm.sh create clients -r ${REALM} -s clientId=${CLIENT} -s enabled=true -s publicClient=true -s 'webOrigins=["'${WEBORIGINS}'"]' -s 'redirectUris=["'${REDIRECTURIS}'"]'
fi

users_lists=/run/secrets/users_lists
if [ -f $users_lists ]; then

  #TODO: Improve this loop
  IFS=,
  sed 1d $users_lists | while read -r username email firstName lastName password
  do
    exist=$(./keycloak/bin/kcadm.sh get users -r ${REALM} -q username=$username)
    if [ ${#exist} -le 3 ]
    then
      cmd='./keycloak/bin/kcadm.sh create users -r '${REALM}' -s enabled=true'
      if [[ ! -z "$username" ]]; then
        cmd+=' -s username='$username
      fi

      if [[ ! -z "$email" ]]; then
        cmd+=' -s email='$email
      fi

      if [[ ! -z "$firstName" ]]; then
        cmd+=' -s firstName='$firstName
      fi

      if [[ ! -z "$lastName" ]]; then
        cmd+=' -s lastName='$lastName
      fi
      eval $cmd
      ./keycloak/bin/kcadm.sh set-password -r ${REALM} --username ${username}  --new-password ${password} --temporary
    fi
  done

fi

tail -f /opt/jboss/log

wait $PID
