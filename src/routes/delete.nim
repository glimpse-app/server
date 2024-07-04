# import libs
import std/[strutils, os, logging]
import jester
import norm/[model, sqlite]
import ../types/[users, files]
import checksums/sha3
import ../database

proc createDeletionRoutes*() =
  router delete:
    #[
      request parameters: 
        token    -  string         -  required via header
      returns
        success  -  200            -  deleted user
        fail     -  403            -  deletion failed, invalid token
    ]#
    delete "/api/v1/user":
      var user = newUser()
      if not db.validToken(user, request.headers["Authorization"]):
        resp Http403, "Invalid token."
      # TODO: delete all user's files
      db.delete(user)
      resp Http200, "User has been deleted."

    #[
      request parameters: 
        token    -  string         -  required via header
        name     -  string         -  required via header
      returns
        success  -  200            -  deleted the file
        fail     -  403            -  deletion failed, invalid token
    ]#
    delete "/api/v1/file":
      var user = newUser()
      if not db.validToken(user, request.headers["Authorization"]):
        resp Http403, "Invalid token."

      var file = newFile()
      try:
        db.select(file, "File.name = ?", request.headers["name"])
      except NotFoundError:
        resp Http404, "File does not exist"
    
      db.delete(file)
      resp Http200, "File has been deleted."

    #[
      request parameters: 
        token    -  string         -  required via header
      returns
        success  -  200            -  deleted all files
        fail     -  403            -  deletion failed, invalid token
    ]#
    # delete "/api/v1/AllFiles":
    #   var user = newUser()
    #   if not db.validToken(user, request.headers["Authorization"]):
    #     resp Http403, "Invalid token."
      
    #   db.delete(user)
    #   resp Http200, "User has been deleted."
