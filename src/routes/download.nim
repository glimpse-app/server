import std/[strutils, logging]
import jester
import jsony
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
    ]#
    get "/api/v1/listOfAllFiles":
      debug "Endpoint used.\n" & reqInfo
      var user = newUser()
      if not db.validToken(user, H"Authorization"):
        respErr "Invalid token.\n"

      var seqOfFiles = @[newFile()]
      try:
        db.selectOneToMany(user, seqOfFiles, "owner")
      except NotFoundError:
        respErr Http404, "No file exists.\n"

      var seqOfFileInfo = @[getFileInfo()]
      for file in seqOfFiles:
        seqOfFileInfo.add(getFileInfo(file))

      info "List user's file.\n" & reqInfo
      resp200 seqOfFileInfo.toJson()
