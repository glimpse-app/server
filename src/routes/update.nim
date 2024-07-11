import std/[strutils, os]
import jester
import norm/sqlite
import ../types/[users, files]
import ../database

proc createUpdateRoutes*() =
  router update:
    #[
      request parameters:
        ???
      returns:
        ???
    ]#
    # put "/api/v1/newTags":
    
    #[
      request parameters:
        token          -  string         -  required via header
        name           -  string         -  old file name via header
        name           -  string         -  new file name via header
      returns:
        200            -  file renamed successfully
    ]#
    put "/api/v1/newFileName":
      var user = newUser()
      if not db.validToken(user, request.headers["Authorization"]):
        resp Http403, "Invalid token.\n"

      let
        oldName = request.headers["Old name"]
        newName = request.headers["New name"]

      var file = newFile()
      try:
        db.select(file, "File.name = ?", oldName)
      except NotFoundError:
        resp Http404, "File does not exist.\n"

      block FileDoesNotExist:
        try:
          db.select(file, "File.name = ?", newName)
        except NotFoundError:
          break FileDoesNotExist
        resp Http403, "File with that name already exists.\n"

      let newPath = file.path[0..^file.name.len+1] & newName
      moveFile(file.path, newPath)

      # rename file in db
      file.path = newPath
      file.name = newName
      db.update(file)
      resp Http200, "File renamed.\n"
