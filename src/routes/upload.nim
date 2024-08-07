import std/[strutils, os, json, with]
import jester
import norm/[model, postgres]
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
      returns: JSON
    ]#
    post "/api/v1/newFile":
      # fills the new `user` var with saved user data from database
      var user = newUser()
      if not db.validToken(user, H"Authorization"):
        resp Http403, "Invalid token.\n"

      # pull request form data arguments
      let fileData = request.formData["file"].body
      let fileName = request.formData["file"].fields["filename"]
      var fileTags: string

      # this is a hack, I hate this
      # convert to JsonNode to ensure we were given a proper JSON
      # convert back to a string because db doesnt allow for JsonNode
      try:
        fileTags = $parseJson(request.formData[
            "tags"].body) # TODO: sanitize, only an array of strings (e.g. remove nested objects/arrays)
      except KeyError:
        fileTags = "[]"
      except: # "except JsonError:" doesn't work for some reason
        resp Http400, "Bad JSON.\n"

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
        resp Http403, "A file with this name already exists.\n"
      db.update(user)

      # write the file from memory
      writeFile(filePath, fileData)
      var userFileCount: string
      with userFileCount:
        add "[{"
        add("\"fileCount\": \"" & $user.fileCount & "\"")
        add "}]"
      resp Http200, userFileCount & "\n", "application/json"
