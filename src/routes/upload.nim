import std/[strutils, os, logging]
import jester
import jsony
import norm/model
import norm/postgres except error
import ../types/[users, files]
import ../[database, helpers]
import ../config/config

proc createUploadRoutes*(cfg: Cfg) =
  router upload:
    #[
      request parameters:
        file           -  string/binary  -  required
        token          -  string         -  required via header
        tags           -  JSON           -  optinal
    ]#
    post "/api/v1/newFile":
      debug "Endpoint used.\n" & reqInfo
      # fills the new `user` var with saved user data from database
      var user = newUser()
      if not db.validToken(user, H"Authorization"):
        respErr "Invalid token.\n"

      # pull request form data arguments
      let fileData = request.formData["file"].body
      let fileName = request.formData["file"].fields["filename"]
      var fileTags: string

      try:
        # check if tags json sent is of seq[string], otherwise reject it.
        fileTags = request.formData["tags"].body.fromJson(seq[string]).toJson()
      except KeyError:
        fileTags = "[]"
      except JsonError:
        respErr Http400, "Bad JSON, must be an array of strings.\n"

      # create needed directories if they don't exist already
      let directory = cfg.uploadDir & user.username & "/"
      if not dirExists(directory):
        createDir(directory)

      let filePath = directory & fileName

      # create new file object and add to db
      var file = newFile(user, filePath, fileName, fileTags)
      try:
        db.insert(file)
      except DbError:
        respErr "A file with this name already exists.\n"
      db.update(user)

      # write the file from memory
      writeFile(filePath, fileData)

      info "File uploaded.\n" & reqInfo
      resp200 getFileInfo(file).toJson()
