import std/[strutils, os, httpclient]
import jester
import norm/[model, postgres]
import ../types/[users, files]
import ../[database, helpers]

proc purgeUserFiles*(token: string): Future[string] {.async.} =

  var client = newAsyncHttpClient()
  client.headers = newHttpHeaders({"Authorization": token})
  try:
    return await client.deleteContent("http://localhost:5000/api/v1/files")
  finally:
    client.close()


proc createDeletionRoutes*() =
  router delete:
    #[
      request parameters:
        token          -  string         -  required via header
      returns
        200            -  user and all his files are deleted from db and filesystem
    ]#
    delete "/api/v1/userCompletely":
      var user = newUser()
      if not db.validToken(user, H"Authorization"):
        resp Http403, "Invalid token."

      discard waitFor purgeUserFiles(H"Authorization")
      db.delete(user)

      resp Http200, "User and all files have been deleted.\n"

    #[
      request parameters:
        token          -  string         -  required via header
      returns
        200            -  deleted user account from db only
    ]#
    delete "/api/v1/user":
      var user = newUser()
      if not db.validToken(user, H"Authorization"):
        resp Http403, "Invalid token."

      db.delete(user)

      resp Http200, "User has been deleted.\n"

    #[
      request parameters:
        token          -  string         -  required via header
        name           -  string         -  required via header
      returns
        200            -  deleted the specified file
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
      resp Http200, "File has been deleted.\n"

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
      removeDir("uploads/" & user.username & "/")

      resp Http200, "All files have been deleted.\n"
