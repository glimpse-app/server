#!/bin/sh

# terminal colors

YAY='\033[0;102;30m'
NAY='\033[1;101;5m'
BLD='\033[1m'
CLR='\033[0m'

# test setup

CONFIGFILE="../config.ini"
PASSWORD=$(pwgen 50 1)
ERROR=0

MKUSER(){
  TESTUSER="testUser_$(pwgen 4 1)"
}

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
MKUSER
curl --show-error --fail-with-body --request POST http://"$BINDADDR":"$PORT""$ENDPOINT" \
  -d "username=$TESTUSER"  -d "password=$PASSWORD"  \
  -d "email=$TESTUSER@example.xyz"

if test $? -eq 0; then printf "%bTest: Success - $ENDPOINT" "$YAY";
else printf "%bTest: Fail - $ENDPOINT" "$NAY"; ERROR=$((ERROR+1));
fi; printf "%b\n" "$CLR";



ENDPOINT="/api/v1/newSession"
printf "\n%bTest: $ENDPOINT%b\n" "$BLD" "$CLR"
MKUSER; TOKEN=$(curl --show-error --fail-with-body --request POST http://"$BINDADDR":"$PORT""/api/v1/newUser" -d "username=$TESTUSER" -d "password=$PASSWORD" -d "email=$TESTUSER@example.xyz" | jq ".[0].token" | tr -d '"')

curl --show-error --fail-with-body --request GET http://"$BINDADDR":"$PORT""$ENDPOINT" \
  -H "Authorization: $TOKEN"

if test $? -eq 0; then printf "%bTest: Success - $ENDPOINT" "$YAY";
else printf "%bTest: Fail - $ENDPOINT" "$NAY"; ERROR=$((ERROR+1));
fi; printf "%b\n" "$CLR";



ENDPOINT="/api/v1/newFile"
printf "\n%bTest: $ENDPOINT%b\n" "$BLD" "$CLR"
MKUSER; TOKEN=$(curl --show-error --fail-with-body --request POST http://"$BINDADDR":"$PORT""/api/v1/newUser" -d "username=$TESTUSER" -d "password=$PASSWORD" -d "email=$TESTUSER@example.xyz" | jq ".[0].token" | tr -d '"')

curl --show-error --fail-with-body --request POST http://"$BINDADDR":"$PORT""$ENDPOINT" \
  -H "Authorization: $TOKEN" -F "file=@image.png"

if test $? -eq 0; then printf "%bTest: Success - $ENDPOINT" "$YAY";
else printf "%bTest: Fail - $ENDPOINT" "$NAY"; ERROR=$((ERROR+1));
fi; printf "%b\n" "$CLR";



printf "\n%bTest: $ENDPOINT%b\n" "$BLD" "$CLR"

curl --show-error --fail-with-body --request POST http://"$BINDADDR":"$PORT""$ENDPOINT" \
  -H "Authorization: $TOKEN" -F "file=@image2.jpg" -F 'tags=["4k HDR", "Fruit", "Yummy"]'

if test $? -eq 0; then printf "%bTest: Success - $ENDPOINT 2" "$YAY";
else printf "%bTest: Fail - $ENDPOINT 2" "$NAY"; ERROR=$((ERROR+1));
fi; printf "%b\n" "$CLR";


ENDPOINT="/api/v1/newFileName"
printf "\n%bTest: $ENDPOINT%b\n" "$BLD" "$CLR"

curl --show-error --fail-with-body --request PUT http://"$BINDADDR":"$PORT""$ENDPOINT" \
  -H "Authorization: $TOKEN" -H "Old name: image.png" -H "New name: kitty.png"

if test $? -eq 0; then printf "%bTest: Success - $ENDPOINT" "$YAY";
else printf "%bTest: Fail - $ENDPOINT" "$NAY"; ERROR=$((ERROR+1));
fi; printf "%b\n" "$CLR";



ENDPOINT="/api/v1/fileByName"
printf "\n%bTest: $ENDPOINT%b\n" "$BLD" "$CLR"

curl --show-error --fail-with-body --request GET http://"$BINDADDR":"$PORT""$ENDPOINT" \
  -H "Authorization: $TOKEN" -H "Name: kitty.png" --output downloaded.png

if test $? -eq 0; then printf "%bTest: Success - $ENDPOINT" "$YAY";
else printf "%bTest: Fail - $ENDPOINT" "$NAY"; ERROR=$((ERROR+1));
fi; printf "%b\n" "$CLR";
rm downloaded.png



ENDPOINT="/api/v1/listOfAllFiles"
printf "\n%bTest: $ENDPOINT%b\n" "$BLD" "$CLR"

curl --show-error --fail-with-body --request GET http://"$BINDADDR":"$PORT""$ENDPOINT" \
  -H "Authorization: $TOKEN"

if test $? -eq 0; then printf "%bTest: Success - $ENDPOINT" "$YAY";
else printf "%bTest: Fail - $ENDPOINT" "$NAY"; ERROR=$((ERROR+1));
fi; printf "%b\n" "$CLR";



ENDPOINT="/api/v1/file"
printf "\n%bTest: $ENDPOINT%b\n" "$BLD" "$CLR"

curl --show-error --fail-with-body --request DELETE http://"$BINDADDR":"$PORT""$ENDPOINT" \
  -H "Authorization: $TOKEN" -H "Name: image2.jpg"

if test $? -eq 0; then printf "%bTest: Success - $ENDPOINT" "$YAY";
else printf "%bTest: Fail - $ENDPOINT" "$NAY"; ERROR=$((ERROR+1));
fi; printf "%b\n" "$CLR";



ENDPOINT="/api/v1/files"
printf "\n%bTest: $ENDPOINT%b\n" "$BLD" "$CLR"

curl --show-error --fail-with-body --request DELETE http://"$BINDADDR":"$PORT""$ENDPOINT" \
  -H "Authorization: $TOKEN"

if test $? -eq 0; then printf "%bTest: Success - $ENDPOINT" "$YAY";
else printf "%bTest: Fail - $ENDPOINT" "$NAY"; ERROR=$((ERROR+1));
fi; printf "%b\n" "$CLR";



ENDPOINT="/api/v1/user"
printf "\n%bTest: $ENDPOINT%b\n" "$BLD" "$CLR"

curl --show-error --fail-with-body --request DELETE http://"$BINDADDR":"$PORT""$ENDPOINT" \
  -H "Authorization: $TOKEN"

if test $? -eq 0; then printf "%bTest: Success - $ENDPOINT" "$YAY";
else printf "%bTest: Fail - $ENDPOINT" "$NAY"; ERROR=$((ERROR+1));
fi; printf "%b\n" "$CLR";



ENDPOINT="/api/v1/userCompletely"
printf "\n%bTest: $ENDPOINT%b\n" "$BLD" "$CLR"
MKUSER; TOKEN=$(curl --show-error --fail-with-body --request POST http://"$BINDADDR":"$PORT""/api/v1/newUser" -d "username=$TESTUSER" -d "password=$PASSWORD" -d "email=$TESTUSER@example.xyz" | jq ".[0].token" | tr -d '"')

curl --show-error --fail-with-body --request DELETE http://"$BINDADDR":"$PORT""$ENDPOINT" \
  -H "Authorization: $TOKEN"

if test $? -eq 0; then printf "%bTest: Success - $ENDPOINT" "$YAY";
else printf "%bTest: Fail - $ENDPOINT" "$NAY"; ERROR=$((ERROR+1));
fi; printf "%b\n" "$CLR";



if [ "$ERROR" -gt 0 ]; then
  echo "$ERROR errors occured!"
else
  echo "No errors!"
fi
exit "$ERROR";
