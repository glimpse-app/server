# import libs
import std/[strutils, os, logging]
import jester
import norm/[model, sqlite]
import ../types/[users, files]
import checksums/sha3
import ../database

router auth:
  #[ 
    request parameters: 
      username  -  string   -  required
      email     -  string   -  required
      password  -  string   -  required
    returns:
      success   -  token    -  new login token
      fail      -  403      - not all required parameters are provided
  ]#
  post "/api/v1/newUser":
    # creates new user with provided info
    # TODO: sanitization + check if username and email are unique
    if @"username".isEmptyOrWhitespace() or @"email".isEmptyOrWhitespace() or @"password".isEmptyOrWhitespace():
      resp Http403, "Not all required parameters are provided."

    var user = newUser(@"username", @"email", @"password")
    db.insert(user)
    resp Http200, user.token

  #[ 
    request parameters:
      token     -  string   -  required via header
                    OR
      username  -  string   -  required
      password  -  string   -  required
    returns:
      success   -  token    -  new login token, old token will not work
      fail      -  403      -  invalid token
      fail      -  403      -  bad username and/or password
  ]#
  post "/api/v1/newSession": #TODO change to GET?
    # generates a new login token after signin
    var user = newUser()
    
    if not request.headers["Authorization"].isEmptyOrWhitespace():
      
      if not db.validToken(user, request.headers["Authorization"]):
        resp Http403, "Invalid token."
      
      db.genNewToken(user)

    else:
      try:
        db.select(user, "username = ?", @"username")
      except NotFoundError:
        resp Http403, "Incorrect username or password." # fails if username is wrong but mentions password to obfuscates if a user exists or not
      echo user.password
      echo @"password"
      echo $Sha3_512.secureHash(@"password")
      if user.password == $Sha3_512.secureHash(@"password"):
        db.genNewToken(user)
      else:
        resp Http403, "Incorrect username or password." # fails if password is wrong but mentions username to obfuscates if a user exists or not
    resp Http200, user.token
