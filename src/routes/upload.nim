import std/[strutils, os, json]
import jester
import norm/[model, sqlite]
import ../types/[users, files]
import ../[database, helpers]

proc createUploadRoutes*() =
  router upload:
    #[
      request parameters:
        file           -  string/binary  -  required
        token          -  string         -  required via header
        tags           -  JSON           -  optinal
      returns
        200            -  file saved to db and indexed into db
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
            "tags"].body) # TODO: sanitize, only an array of strings (e.g. nested objects/arrays)
      except KeyError:
        fileTags = "[]"
      except: # "except JsonError:" doesn't work for some reason
        resp Http400, "Bad JSON.\n"

      # create needed directories if they don't exist already
      let directory = "uploads/" & user.username & "/"
      if not dirExists(directory):
        createDir(directory)

      let filePath = directory & fileName

      # create new file object and add to db
      var file = newFile(user, filePath, fileName, fileTags)
      db.insert(file)

      # write the file from memory
      writeFile(filePath, fileData)
      resp Http200, "File uploaded.\n"
