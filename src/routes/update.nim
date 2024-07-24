import std/[strutils, os, with]
import jester
import norm/postgres
import ../types/[users, files]
import ../[database, helpers]

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
      returns: JSON
    ]#
    put "/api/v1/newFileName":
      var user = newUser()
      if not db.validToken(user, H"Authorization"):
        resp Http403, "Invalid token.\n"

      let
        oldName = H"Old name"
        newName = H"New name"

      var file = newFile()
      try:
        db.select(file, """"File".name = $1""", oldName)
      except NotFoundError:
        resp Http404, "File does not exist.\n"

      block FileDoesNotExist:
        try:
          db.select(file, """"File".name = $1""", newName)
        except NotFoundError:
          break FileDoesNotExist
        resp Http403, "File with that name already exists.\n"

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


      resp Http200, fileInfo & "\n", "application/json"
