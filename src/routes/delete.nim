import std/[strutils, os, httpclient, strformat]
import jester
import norm/[model, postgres]
import ../types/[users, files]
import ../[database, helpers]
import ../config/config

proc purgeUserFiles*(token: string): Future[string] {.async.} =

  var client = newAsyncHttpClient()
  client.headers = newHttpHeaders({"Authorization": token})
  try:
    return await client.deleteContent(fmt"http://{cfg.bindAddr}:{cfg.port}/api/v1/files")
  finally:
    client.close()


proc createDeletionRoutes*(cfg: Cfg) =
  router delete:
    #[
      request parameters:
        token          -  string         -  required via header
      returns: JSON
    ]#
    delete "/api/v1/userCompletely":
      var user = newUser()
      if not db.validToken(user, H"Authorization"):
        resp Http403, "Invalid token.\n"

      discard waitFor purgeUserFiles(H"Authorization")
      db.delete(user)

      resp Http200, "[{}]\n", "application/json"

    #[
      request parameters:
        token          -  string         -  required via header
      returns: JSON
    ]#
    delete "/api/v1/user":
      var user = newUser()
      if not db.validToken(user, H"Authorization"):
        resp Http403, "Invalid token.\n"

      db.delete(user)

      resp Http200, "[{}]\n", "application/json"

    #! endpoint crashes server
    #[
      request parameters:
        token          -  string         -  required via header
        name           -  string         -  required via header
      returns: JSON
    ]#
    delete "/api/v1/file":
      var user = newUser()
      if not db.validToken(user, H"Authorization"):
        resp Http403, "Invalid token.\n"

      var file = newFile()
      try:
        db.select(file, """"File".name = $1""", H"Name")
      except NotFoundError:
        resp Http404, "File does not exist.\n"

      db.delete(file)
      dec user.fileCount
      db.update(user)
      removeFile(file.path)
      resp Http200, "[{}]\n", "application/json"

    #[
      request parameters:
        token          -  string         -  required via header
      returns
        200            -  deleted all of the user's file from db and filesystem only
    ]#
    delete "/api/v1/files":
      var user = newUser()
      if not db.validToken(user, H"Authorization"):
        resp Http403, "Invalid token.\n"

      var listOfFiles = @[newFile()]
      try:
        db.select(listOfFiles, """"File".owner = $1""", user.id)
      except NotFoundError: # this error does not occur even if no files exist
        resp Http404, "Files do not exist.\n"

      for i in 0..(listOfFiles.len - 1):
        var file = listOfFiles[i]
        db.delete(file)
      user.fileCount = 0
      db.update(user)
      removeDir(cfg.uploadDir & user.username & "/")

      resp Http200, "[{}]\n", "application/json"
