import std/strutils
import jester
import norm/sqlite
import ../types/[users, files]
import ../database

proc createDownloadRoutes*() =
  router download:
    #[ 
      request parameters: 
        token     -  string         -  required via header
        name      -  string         -  file name via header 
      returns:
        success   -  string/binary  -  file
        fail      -  403            -  invalid token
        fail      -  404            -  file doesn't exist
    ]#
    get "/api/v1/fileByName":
      var user = newUser()
      if not db.validToken(user, request.headers["Authorization"]):
        resp Http403, "Invalid token."
      
      var file = newFile()
      try:
        db.select(file, "File.name = ?", request.headers["name"])
      except NotFoundError:
        resp Http404, "File does not exist"
    
      sendFile file.path
