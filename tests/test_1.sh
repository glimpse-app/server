#!/bin/sh

# terminal colors

YAY='\033[0;102;30m'
NAY='\033[1;101;5m'
BLD='\033[1m'
CLR='\033[0m'

# test setup

CONFIGFILE="../config.ini"
PASSWORD=$(pwgen 50 1)

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

curl -s -X POST http://"$BINDADDR":"$PORT""$ENDPOINT" -d "username=testUser" 
  -d "password=$PASSWORD" -d "email=test@example.xyz"

if test $? -eq 0; then printf "%bTest: Success - $ENDPOINT" "$YAY";
else printf "%bTest: Fail - $ENDPOINT" "$NAY"; exit 1;
fi; printf "%b\n" "$CLR";
