import std/[strutils, logging]
import jester
import norm/postgres except error
import ../types/[users, files]
import ../[database, helpers]

proc createDownloadRoutes*() =
  router download:
    #[
      request parameters:
        token          -  string         -  required via header
        name           -  string         -  file name via header
      returns: string/binary 
    ]#
    get "/api/v1/fileByName":
      debug "Endpoint used.\n" & reqInfo

      var user = newUser()
      if not db.validToken(user, H"Authorization"):
        respErr "Invalid token.\n"

      var file = newFile()
      try:
        db.select(file, """"File".name = $1 AND "File".owner = $2""", H"Name", user)
      except NotFoundError:
        respErr Http404, "File does not exist.\n"

      info "User downloaded file.\n" & reqInfo
      sendFile file.path

    #[
      request parameters:
        token          -  string         -  required via header
      returns: JSON
    ]#
    get "/api/v1/listOfAllFiles":
      debug "Endpoint used.\n" & reqInfo
      var user = newUser()
      if not db.validToken(user, H"Authorization"):
        respErr "Invalid token.\n"

      var listOfFiles = @[newFile()]
      try:
        db.select(listOfFiles, """"File".owner = $1""", user.id)
      except NotFoundError:
        respErr Http404, "Files does not exist.\n"

      var allFiles: string

      for file in listOfFiles:
        allFiles = allFiles & "{" & "\"name\": \"" & file.name &
            "\", \"tags\": " & file.tags & "},"
      allFiles = "[" & allFiles[0..^2] & "]" # trim last comma

      info "List user's file.\n" & reqInfo
      resp Http200, allFiles & "\n", "application/json"
