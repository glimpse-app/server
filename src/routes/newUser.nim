# import libs
import std/[strutils, os, logging]
import jester
import norm/[model, sqlite]
import ../types/[users, files]
import checksums/sha3
import ../database

proc createNewUserRoute*() =
  router newUser:
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
