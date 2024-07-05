import std/[strutils, os, httpclient]
import jester
import norm/[model, sqlite]
import ../types/[users, files]
import ../database

proc purgeUserFiles*(token: string): Future[string] {.async.} =

  var client = newAsyncHttpClient()
  client.headers = newHttpHeaders({ "Authorization": token })
  try:
    return await client.deleteContent("http://localhost:5000/api/v1/files")
  finally:
    client.close()


proc createDeletionRoutes*() =
  router delete:
    #[
      request parameters: 
        token    -  string         -  required via header
      returns
        success  -  200            -  deleted user
        fail     -  403            -  deletion failed, invalid token
    ]#
    delete "/api/v1/userCompletely":
      var user = newUser()
      if not db.validToken(user, request.headers["Authorization"]):
        resp Http403, "Invalid token."

      discard waitFor purgeUserFiles($request.headers["Authorization"])
      db.delete(user) 
      
      resp Http200, "User and all files have been deleted.\n"

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

      db.delete(user)

      resp Http200, "User account has been deleted.\n"

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
        resp Http403, "Invalid token.\n"

      var file = newFile()
      try:
        db.select(file, "File.name = ?", request.headers["name"])
      except NotFoundError:
        resp Http404, "File does not exist.\n"
    
      db.delete(file)
      resp Http200, "File has been deleted.\n"

    #[
      request parameters: 
        token    -  string         -  required via header
      returns
        success  -  200            -  deleted all files
        fail     -  403            -  deletion failed, invalid token
    ]#
    delete "/api/v1/files":
      var user = newUser()
      if not db.validToken(user, request.headers["Authorization"]):
        resp Http403, "Invalid token.\n"

      var listOfFiles = @[newFile()]
      try:
        db.select(listOfFiles, "File.owner = ?", user.id)
      except NotFoundError: # this error does not occur even if no files exist
        resp Http404, "Files do not exist.\n"

      for i in 0..(listOfFiles.len - 1):
        var file = listOfFiles[i]
        db.delete(file)

      removeDir("uploads/" & user.username & "/")

      resp Http200, "All files have been deleted.\n"