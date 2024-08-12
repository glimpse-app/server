import std/[strutils, with, logging]
import jester
import norm/model
import norm/postgres except error
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
      debug "Endpoint used.\n" & reqInfo

      if @"username".isEmptyOrWhitespace() or @"email".isEmptyOrWhitespace() or
          @"password".isEmptyOrWhitespace():
        respErr "Registeration failed, not all parameters provided.\n"

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
          respErr "Registeration failed, email already in use.\n"
        respErr "Registeration failed, username already in use.\n"

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

      info "User created.\n" & reqInfo
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
      debug "Endpoint used.\n" & reqInfo

      var user = newUser()

      if not H"Authorization".isEmptyOrWhitespace():
        if not db.validToken(user, H"Authorization"):
          resp Http403, "Invalid token.\n"

        db.generateToken(user)

      else:
        try:
          db.select(user, """"User".username = $1""", H"Username")
        except NotFoundError:
          respErr"Incorrect username or password.\n" # fails if username is wrong but mentions password to obfuscates if a user exists or not
        if user.password == $Sha3_512.secureHash($H"Password"):
          db.generateToken(user)
        else:
          respErr"Incorrect username or password.\n" # fails if password is wrong but mentions username to obfuscates if a user exists or not

      var userToken: string
      with userToken:
        add "[{"
        add("\"token\": \"" & user.token & "\"")
        add "}]"

      info "Replaced token.\n" & reqInfo
      resp Http200, userToken & "\n", "application/json"

