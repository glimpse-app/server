# import libs
import std/[strutils, os, logging]
import jester
import norm/[model, sqlite]
import server/[users, files]
import checksums/sha3

addHandler newConsoleLogger(fmtStr = "")

# using sqlite as it makes setup faster
# once project is stable enough this will switch to postgresql
let db = open("storage.db", "", "", "")
db.createTables(newFile()) # file objects require a user object, thus a tables for both are created

routes:
  get "/":
    resp "Hello, World!" # idk what to put here

  get "/api":
    resp "Hello, World!" # idk what to put here

  #[ 
    request parameters: 
      username  -  string   -  required
      email     -  string   -  required
      password  -  string   -  required
    returns:
      success   -  token    -  new login token
      fail      -  1        - not all required parameters are provided
  ]#
  post "/api/v1/register":
    # creates new user with provided info
    # TODO: sanitization + check if username and email are unique
    if @"username".isEmptyOrWhitespace() or @"email".isEmptyOrWhitespace() or @"password".isEmptyOrWhitespace():
      resp "1"

    var user = newUser(@"username", @"email", @"password")
    db.insert(user)
    resp user.token

  #[ 
    request parameters:
      token     -  string   -  required
                    OR
      username  -  string   -  required
      password  -  string   -  required
    returns:
      success   -  token    -  new login token, old token will not work
      fail      -  1        -  invalid token
      fail      -  2        -  bad username and/or password
  ]#
  post "/api/v1/login":
    # generates a new login token after signin
    var user = newUser()
    
    if not @"token".isEmptyOrWhitespace():
      
      if not db.validToken(user, @"token"):
        resp "1"
      
      db.genNewToken(user)

    else:
      try:
        db.select(user, "username = ?", @"username")
      except NotFoundError:
        resp "2" # fails if username is wrong but mentions password to obfuscates if a user exists or not
      echo user.password
      echo @"password"
      echo $Sha3_512.secureHash(@"password")
      if user.password == $Sha3_512.secureHash(@"password"):
        db.genNewToken(user)
      else:
        resp "2" # fails if password is wrong but mentions username to obfuscates if a user exists or not
    resp user.token

  #[ 
    request parameters: 
      ???
    returns:
      ???
  ]#
  post "/api/v1/getItem":
    # let index = parseInt(@"index")
    # db.select(file, "File.path = ?", "/car.png")
    resp "JSON HERE indexedImages[index]"

  #[
    request parameters: 
      ???
    returns:
      ???
  ]#
  post "/api/v1/getPath":
    # let index = parseInt(@"index")
    resp """JSON HERE indexedImages[index]["path"]"""

  #[ 
    request parameters: 
      ???
    returns:
      ???
  ]#
  post "/api/v1/getTags":
    # let index = parseInt(@"index")
    resp """indexedImages[index]["tags"]"""

  #[
    request parameters: 
      file      -   string/binary   -  required
      token     -   string          -  required
      tags      -   seq             -  optional
    returns:
      success   -  0                -  successful upload
      fail      -  1                - upload failed, invalid token
  ]#
  post "/api/v1/upload":

    # fills the new `user` var with saved user data from database
    var user = newUser()
    if not db.validToken(user, request.formData["token"].body):
      resp "1"
    
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
    resp "0"