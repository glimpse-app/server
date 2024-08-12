import std/[strutils, os, with, logging]
import jester
import norm/postgres except error
import ../types/[users, files]
import ../[database, helpers]

proc createUpdateRoutes*() =
  router update:

    #[
      request parameters:
        token          -  string         -  required via header
        name           -  string         -  old file name via header
        name           -  string         -  new file name via header
    ]#
    put "/api/v1/newFileName":
      debug "Endpoint used.\n" & reqInfo
      var user = newUser()
      if not db.validToken(user, H"Authorization"):
        respErr "Invalid token.\n"

      let
        oldName = H"Old name"
        newName = H"New name"

      var file = newFile()
      try:
        db.select(file, """"File".name = $1 AND "File".owner = $2""", oldName, user)
      except NotFoundError:
        respErr Http404, "File does not exist.\n"

      block FileDoesNotExistCheck:
        try:
          db.select(file, """"File".name = $1 AND "File".owner = $2""", newName, user)
        except NotFoundError:
          break FileDoesNotExistCheck
        respErr "File with that name already exists.\n"

      let newPath = file.path[0..^file.name.len+1] & newName
      moveFile(file.path, newPath)

      # rename file in db
      file.path = newPath
      file.name = newName
      db.update(file)

      var fileInfo: string
      with fileInfo:
        add "[{"
        add("\"name\": \"" & file.name & "\",")
        add("\"tags\": \"" & file.tags & "\"")
        add "}]"

      info "File renamed.\n" & reqInfo
      resp Http200, fileInfo & "\n", "application/json"
