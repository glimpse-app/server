import std/strutils
import jester
import norm/sqlite
import ../types/[users, files]
import ../database

proc createDownloadRoutes*() =
  router download:
    #[
      request parameters:
        token          -  string         -  required via header
        name           -  string         -  file name via header
      returns:
        string/binary  -  server responds with the requested file
    ]#
    get "/api/v1/fileByName":
      var user = newUser()
      if not db.validToken(user, request.headers["Authorization"]):
        resp Http403, "Invalid token.\n"

      var file = newFile()
      try:
        db.select(file, "File.name = ?", request.headers["name"])
      except NotFoundError:
        resp Http404, "File does not exist.\n"

      sendFile file.path
    #[
      request parameters:
        token          -  string         -  required via header
      returns:
        JSON           -  JSON node containing all files and tags
    ]#
    get "/api/v1/listAllFiles":
      var user = newUser()
      if not db.validToken(user, request.headers["Authorization"]):
        resp Http403, "Invalid token.\n"

      var listOfFiles = @[newFile()]
      try:
        db.select(listOfFiles, "File.owner = ?", user.id)
      except NotFoundError:
        resp Http404, "Files does not exist.\n"

      var allFiles: string

      for file in listOfFiles:
        allFiles = allFiles & "{" & "\"name\": \"" & file.name &
            "\", \"tags\": " & file.tags & "},"
      allFiles = "[" & allFiles[0..^2] & "]" # trim last comma

      resp Http200, allFiles & "\n", "application/json"
