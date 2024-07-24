import std/[strutils, with]
import jester
import norm/[model, postgres]
import checksums/sha3
import ../types/users
import ../[database, helpers]

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
      if @"username".isEmptyOrWhitespace() or @"email".isEmptyOrWhitespace() or
          @"password".isEmptyOrWhitespace():
        resp Http403, "Not all required parameters are provided.\n"

      var user = newUser(@"username", @"email", @"password")
      db.insert(user)

      var userProfile: string
      with userProfile:
        add "[{"
        add("\"username\": \"" & user.username & "\",")
        add("\"email\": \"" & user.email & "\",")
        add("\"password\": \"" & user.password & "\",")
        add("\"token\": \"" & user.token & "\",")
        add("\"fileCount\": \"" & $user.fileCount & "\"")
        add "}]"

      resp Http200, userProfile & "\n", "application/json"

    #[
      request parameters:
        token          -  string   -  required via header
                      OR
        username       -  string   -  required via header
        password       -  string   -  required via header
      returns:
        token          -  token will be replaced by a new one
    ]#
    get "/api/v1/newSession":
      var user = newUser()

      if not H"Authorization".isEmptyOrWhitespace():

        if not db.validToken(user, H"Authorization"):
          resp Http403, "Invalid token.\n"

        db.generateToken(user)

      else:
        try:
          db.select(user, """"User".username = $1""", H"Username")
        except NotFoundError:
          resp Http403, "Incorrect username or password.\n" # fails if username is wrong but mentions password to obfuscates if a user exists or not
        if user.password == $Sha3_512.secureHash($H"Password"):
          db.generateToken(user)
        else:
          resp Http403, "Incorrect username or password.\n" # fails if password is wrong but mentions username to obfuscates if a user exists or not

      var userToken: string
      with userToken:
        add "[{"
        add("\"token\": \"" & user.token & "\"")
        add "}]"

      resp Http200, userToken & "\n", "application/json"

