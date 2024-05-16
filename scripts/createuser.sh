#!/bin/bash

SERVERURL="http://localhost:8080"

if [ ! $CLIENT_SECRET ];
then
    read -p 'Client secret: ' CLIENT_SECRET
    export CLIENT_SECRET
fi

RESULT=`curl --data "grant_type=client_credentials&client_id=lab-api&client_secret=${CLIENT_SECRET}" ${SERVERURL}/auth/realms/ceai/protocol/openid-connect/token`
TOKEN=`echo $RESULT | sed 's/.*access_token":"//g' | sed 's/".*//g'`


if [ ! $CLIENT_SECRET ];
then
    echo "Authorization denied"
    echo RESULT
    exit 255
fi

#curl -v -X GET -H "Authorization: bearer ${TOKEN}" ${SERVERURL}/auth/admin/realms/ceai/users
#exit 255

read -p 'User email: ' EMAIL
read -p 'User firstname: ' FIRSTNAME
read -p 'User lastname: ' LASTNAME
read -p 'User organization: ' ORG

USERID=`curl -X POST -H "Content-Type: application/json" -H "Authorization: bearer ${TOKEN}" -d "{\"username\":\"${EMAIL}\", \"firstName\":\"${FIRSTNAME}\",\"lastName\":\"${LASTNAME}\", \"email\":\"${EMAIL}\", \"enabled\":\"true\", \"groups\":[\"Developer\"], \"attributes\":{\"organisation\":[\"${ORG}\"]}}" -v --stderr - ${SERVERURL}/auth/admin/realms/ceai/users | grep Location | sed 's:.*/::'`

#CLEAN CARRIAGE RETURNS
USERID=`echo $USERID | tr -d '\r'`
USERID=`echo $USERID | tr -d '\n'`

echo $USERID

echo "$SERVERURL/auth/admin/realms/ceai/users/$USERID/execute-actions-email"

MAILRES=`curl -X PUT -H "Content-Type: application/json" -H "Authorization: bearer ${TOKEN}" -d "[\"CONFIGURE_TOTP\",\"UPDATE_PASSWORD\"]" $SERVERURL/auth/admin/realms/ceai/users/$USERID/execute-actions-email`