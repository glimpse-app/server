import std/[strutils, os, httpclient, strformat, with, logging]
import jester
import norm/model
import norm/postgres except error
import ../types/[users, files]
import ../[database, helpers]
import ../config/config

proc purgeUserFiles*(token: string): Future[string] {.async.} =

  var client = newAsyncHttpClient()
  client.headers = newHttpHeaders({"Authorization": token})
  try:
    return await client.deleteContent(fmt"http://{cfg.bindAddr}:{cfg.port}/api/v1/files")
  finally:
    info "Finished deleting user's files.\n"
    client.close()


proc createDeletionRoutes*(cfg: Cfg) =
  router delete:
    #[
      request parameters:
        token          -  string         -  required via header
      returns: JSON
    ]#
    delete "/api/v1/userCompletely":
      debug "Endpoint used.\n" & reqInfo
      var user = newUser()
      if not db.validToken(user, H"Authorization"):
        respErr "Invalid token.\n"

      discard waitFor purgeUserFiles(H"Authorization")
      db.delete(user)

      info "User deactivated.\n" & reqInfo
      resp Http200, "[]\n", "application/json"

    #[
      request parameters:
        token          -  string         -  required via header
      returns: JSON
    ]#
    delete "/api/v1/user":
      debug "Endpoint used.\n" & reqInfo
      var user = newUser()
      if not db.validToken(user, H"Authorization"):
        respErr "Invalid token.\n"

      db.delete(user)

      info "User account deleted.\n" & reqInfo
      resp Http200, "[]\n", "application/json"

    #[
      request parameters:
        token          -  string         -  required via header
        name           -  string         -  required via header
      returns: JSON
    ]#
    delete "/api/v1/file":
      debug "Endpoint used.\n" & reqInfo
      var user = newUser()
      if not db.validToken(user, H"Authorization"):
        respErr "Invalid token.\n"

      var file = newFile()
      try:
        db.select(file, """"File".name = $1 AND "File".owner = $2""", H"Name", user)
      except NotFoundError:
        respErr Http404, "File does not exist.\n"

      removeFile(file.path)
      db.delete(file)
      dec user.fileCount
      db.update(user)

      var userFileCount: string
      with userFileCount:
        add "[{"
        add("\"fileCount\": \"" & $user.fileCount & "\"")
        add "}]"

      info "Deleted file.\n" & reqInfo
      resp Http200, userFileCount & "\n", "application/json"

    #[
      request parameters:
        token          -  string         -  required via header
      returns
        200            -  deleted all of the user's file from db and filesystem only
    ]#
    delete "/api/v1/files":
      debug "Endpoint used.\n" & reqInfo
      var user = newUser()
      if not db.validToken(user, H"Authorization"):
        respErr "Invalid token.\n"

      var listOfFiles = @[newFile()]
      try:
        db.select(listOfFiles, """"File".owner = $1""", user)
      except NotFoundError: # this error does not occur even if no files exist
        respErr Http404, "Files do not exist.\n"

      for i in 0..(listOfFiles.len - 1):
        var file = listOfFiles[i]
        db.delete(file)
      user.fileCount = 0
      db.update(user)
      removeDir(cfg.uploadDir & user.username & "/")

      info "Deleting user's files.\n" & reqInfo
      resp Http200, "[]\n", "application/json"
