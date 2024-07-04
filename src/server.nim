# import libs
import std/[strutils, os, logging]
import jester
import norm/[model, sqlite]
import types/[users, files]
import checksums/sha3
import database

addHandler newConsoleLogger(fmtStr = "")

import routes/[newUser]

createNewUserRoute()

routes:

  #[ 
    request parameters:
      token     -  string   -  required via header
                    OR
      username  -  string   -  required
      password  -  string   -  required
    returns:
      success   -  token    -  new login token, old token will not work
      fail      -  403      -  invalid token
      fail      -  403      -  bad username and/or password
  ]#
  post "/api/v1/newSession":
    # generates a new login token after signin
    var user = newUser()
    
    if not request.headers["Authorization"].isEmptyOrWhitespace():
      
      if not db.validToken(user, request.headers["Authorization"]):
        resp Http403, "Invalid token."
      
      db.genNewToken(user)

    else:
      try:
        db.select(user, "username = ?", @"username")
      except NotFoundError:
        resp Http403, "Incorrect username or password." # fails if username is wrong but mentions password to obfuscates if a user exists or not
      echo user.password
      echo @"password"
      echo $Sha3_512.secureHash(@"password")
      if user.password == $Sha3_512.secureHash(@"password"):
        db.genNewToken(user)
      else:
        resp Http403, "Incorrect username or password." # fails if password is wrong but mentions username to obfuscates if a user exists or not
    resp Http200, user.token

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

  #[
    request parameters: 
      ???
    returns:
      ???
  ]#
  # post "/api/v1/getPath":
    # let index = parseInt(@"index")
    # resp """JSON HERE indexedImages[index]["path"]"""

  #[ 
    request parameters: 
      ???
    returns:
      ???
  ]#
  # post "/api/v1/getTags":
    # let index = parseInt(@"index")
    # resp """indexedImages[index]["tags"]"""

  #[
    request parameters: 
      file     -  string/binary  -  required
      token    -  string         -  required via header
      tags     -  JSON           -  optinal
    returns
      success  -  200            -  successful upload
      fail     -  403            -  upload failed, invalid token
  ]#
  post "/api/v1/newFile":

    # fills the new `user` var with saved user data from database
    var user = newUser()
    if not db.validToken(user, request.headers["Authorization"]):
      resp Http403, "Invalid token."
    
    # pull request form data arguments 
    let fileData = request.formData["file"].body
    let fileName = request.formData["file"].fields["filename"]
    var fileTags: string

    # this is a hack, I hate this 
    try:
      fileTags = request.formData["tags"].body 
    except KeyError:
      fileTags = "[]"
    
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
    resp Http200, "File uploaded."

  #[
    request parameters: 
      token    -  string         -  required via header
    returns
      success  -  200            -  deleted user
      fail     -  403            -  deletion failed, invalid token
  ]#
  delete "/api/v1/user":
    var user = newUser()
    if not db.validToken(user, request.headers["Authorization"]):
      resp Http403, "Invalid token."
    # TODO: delete all user's files
    db.delete(user)
    resp Http200, "User has been deleted."

  #[
    request parameters: 
      token    -  string         -  required via header
      name     -  string         -  required via header
    returns
      success  -  200            -  deleted the file
      fail     -  403            -  deletion failed, invalid token
  ]#
  delete "/api/v1/file":
    var user = newUser()
    if not db.validToken(user, request.headers["Authorization"]):
      resp Http403, "Invalid token."

    var file = newFile()
    try:
      db.select(file, "File.name = ?", request.headers["name"])
    except NotFoundError:
      resp Http404, "File does not exist"
  
    db.delete(file)
    resp Http200, "File has been deleted."

  #[
    request parameters: 
      token    -  string         -  required via header
    returns
      success  -  200            -  deleted all files
      fail     -  403            -  deletion failed, invalid token
  ]#
  # delete "/api/v1/AllFiles":
  #   var user = newUser()
  #   if not db.validToken(user, request.headers["Authorization"]):
  #     resp Http403, "Invalid token."
    
  #   db.delete(user)
  #   resp Http200, "User has been deleted."

# template respJson*(node: JsonNode) =
#   resp $node, "application/json"
  extend newUser, ""