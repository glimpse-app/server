import std/strutils
import jester
import norm/[model, sqlite]
import checksums/sha3
import ../types/users
import ../database

proc createAuthenticationRoutes*() =
  router auth:
    #[
      request parameters:
        username       -  string   -  required
        email          -  string   -  required
        password       -  string   -  required
      returns:
        token          -  new login token
    ]#
    post "/api/v1/newUser":
      # TODO: sanitization + check if username and email are unique
      if @"username".isEmptyOrWhitespace() or @"email".isEmptyOrWhitespace() or @"password".isEmptyOrWhitespace():
        resp Http403, "Not all required parameters are provided.\n"

      var user = newUser(@"username", @"email", @"password")
      db.insert(user)
      resp Http200, user.token & "\n"

    #[
      request parameters:
        token          -  string   -  required via header
                      OR
        username       -  string   -  required
        password       -  string   -  required
      returns:
        token          -  token will be replaced by a new one
    ]#
    post "/api/v1/newSession": #TODO change to GET?
      var user = newUser()

      if not request.headers["Authorization"].isEmptyOrWhitespace():

        if not db.validToken(user, request.headers["Authorization"]):
          resp Http403, "Invalid token.\n"

        db.generateToken(user)

      else:
        try:
          db.select(user, "username = ?", @"username")
        except NotFoundError:
          resp Http403, "Incorrect username or password.\n" # fails if username is wrong but mentions password to obfuscates if a user exists or not
        if user.password == $Sha3_512.secureHash(@"password"):
          db.generateToken(user)
        else:
          resp Http403, "Incorrect username or password.\n" # fails if password is wrong but mentions username to obfuscates if a user exists or not
      resp Http200, user.token & "\n"
