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
      returns: JSON
    ]#
    post "/api/v1/newUser":
      if @"username".isEmptyOrWhitespace() or @"email".isEmptyOrWhitespace() or
          @"password".isEmptyOrWhitespace():
        resp Http403, "Not all required parameters are provided.\n"

      block UniqueParametersCheck:
        try:
          var user = newUser()
          db.select(user, """"User".username = $1""", @"username")
        except NotFoundError:
          try:
            var user = newUser()
            db.select(user, """"User".email = $1""", @"email")
          except NotFoundError:
            break UniqueParametersCheck
          resp Http403, "A user with that email already exists.\n"
        resp Http403, "A user with that username already exists.\n"

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
      returns: JSON
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

