#!/bin/sh

# terminal colors

YAY='\033[0;102;30m'
NAY='\033[1;101;5m'
BLD='\033[1m'
CLR='\033[0m'

# test setup

CONFIGFILE="../config.ini"
PASSWORD=$(pwgen 50 1)
ERR=0

if grep -q ^bindAddr $CONFIGFILE; then
  BINDADDR=$(grep ^bindAddr $CONFIGFILE | tr -d '"' | tr -d '[:blank:]' | cut -c 10-)
else
  BINDADDR=0.0.0.0
fi

if grep -q ^port $CONFIGFILE; then
  PORT=$(grep ^port $CONFIGFILE | tr -d '"' | tr -d '[:blank:]' | cut -c 6- )
else
  PORT=8080
fi

# tests

ENDPOINT="/api/v1/newUser"

printf "\n%bTest: $ENDPOINT%b\n" "$BLD" "$CLR"

curl --show-error --fail-early --request POST http://"$BINDADDR":"$PORT""$ENDPOINT" \
  -d "username=testUser"  -d "password=$PASSWORD"  \
  -d "email=test@example.xyz"

if test $? -eq 0; then printf "%bTest: Success - $ENDPOINT" "$YAY";
else printf "%bTest: Fail - $ENDPOINT" "$NAY"; ((ERROR++));
fi; printf "%b\n" "$CLR";



ENDPOINT="/api/v1/newSession"
printf "\n%bTest: $ENDPOINT%b\n" "$BLD" "$CLR"
TOKEN=$(curl --show-error --fail-early --request POST http://"$BINDADDR":"$PORT""/api/v1/newUser" -d "username=testUser1" -d "password=$PASSWORD" -d "email=test@example.xyz" | jq ".[0].token" | tr -d '"')

curl --show-error --fail-early --request GET http://"$BINDADDR":"$PORT""$ENDPOINT" \
  -H "Authorization: $TOKEN"

if test $? -eq 0; then printf "%bTest: Success - $ENDPOINT" "$YAY";
else printf "%bTest: Fail - $ENDPOINT" "$NAY"; ((ERROR++));
fi; printf "%b\n" "$CLR";



ENDPOINT="/api/v1/newFile"
printf "\n%bTest: $ENDPOINT%b\n" "$BLD" "$CLR"
TOKEN=$(curl --show-error --fail-early --request POST http://"$BINDADDR":"$PORT""/api/v1/newUser" -d "username=testUser2" -d "password=$PASSWORD" -d "email=test@example.xyz" | jq ".[0].token" | tr -d '"')

curl --show-error --fail-early --request POST http://"$BINDADDR":"$PORT""$ENDPOINT" \
  -H "Authorization: $TOKEN" -F "file=@image.png"

if test $? -eq 0; then printf "%bTest: Success - $ENDPOINT" "$YAY";
else printf "%bTest: Fail - $ENDPOINT" "$NAY"; ((ERROR++));
fi; printf "%b\n" "$CLR";



ENDPOINT="/api/v1/newFileName"
printf "\n%bTest: $ENDPOINT%b\n" "$BLD" "$CLR"

curl --show-error --fail-early --request PUT http://"$BINDADDR":"$PORT""$ENDPOINT" \
  -H "Authorization: $TOKEN" -H "Old name: image.png" -H "New name: kitty.png"

if test $? -eq 0; then printf "%bTest: Success - $ENDPOINT" "$YAY";
else printf "%bTest: Fail - $ENDPOINT" "$NAY"; ((ERROR++));
fi; printf "%b\n" "$CLR";



exit $ERROR;