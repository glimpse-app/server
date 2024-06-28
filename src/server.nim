# import libs
import std/[strutils, os, logging]
import jester
import norm/[model, sqlite]
import server/[users, files]

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

  post "/api/@operation":

    case @"operation":
    
      #? endpoint POST `/api/register`
      #[ request parameters: 
        username  -  string   -  required
        email     -  string   -  required
        password  -  string   -  required
      ]#
      of "register":
        # creates new user with provided info
        # TODO: sanitization + check if username and email are unique
        if @"username".isEmptyOrWhitespace() or @"email".isEmptyOrWhitespace() or @"password".isEmptyOrWhitespace():
          resp "Registeration failed! A none empty username, email and password are requied!"

        var user = newUser(@"username", @"email", @"password")
        db.insert(user)
        resp user.token

      #? endpoint POST `/api/login`
      #[ request parameters:
        token     -  string   -  required
                      OR
        username  -  string   -  required
        password  -  string   -  required
      ]#
      of "login":
        # generates a new login token after signin
        var user = newUser()
        
        if not @"token".isEmptyOrWhitespace():
          
          if not db.validToken(user, @"token"):
            resp "Login failed, Invalid token!"
          
          db.genNewToken(user)

        else:
          var testUser = newUser()
          try:
            db.select(user, "username = ?", @"username")
            db.select(testUser, "password = ?", @"password")
          except NotFoundError:
            resp "Login failed, Incorrect username and/or password!"
          
          if user.username == testUser.username and user.password == testUser.password:
            db.genNewToken(user)
          
        resp user.token

      #? endpoint POST `/api/getItem`
      #[ request parameters: 
        ???
      ]#
      of "getItem":
        # let index = parseInt(@"index")
        # db.select(file, "File.path = ?", "/car.png")
        resp "JSON HERE indexedImages[index]"

      #? endpoint POST `/api/getPath`
      #[ request parameters: 
        ???
      ]#
      of "getPath":
        # let index = parseInt(@"index")
        resp """JSON HERE indexedImages[index]["path"]"""

      #? endpoint POST `/api/getTags`
      #[ request parameters: 
        ???
      ]#
      of "getTags":
        # let index = parseInt(@"index")
        resp """indexedImages[index]["tags"]"""

      #? endpoint POST `/api/upload`
      #[ request parameters: 
        file   -   string/binary   -  required
        token  -   string          -  required
        tags   -   seq             -  optional
      ]#
      of "upload":

        # fills the new `user` var with saved user data from database
        var user = newUser()
        if not db.validToken(user, request.formData["token"].body):
          resp "Upload failed, Invalid token!"
        
        # pull request form data arguments 
        let fileData = request.formData["file"].body
        let fileName = request.formData["file"].fields["filename"]
        var fileTags: string

        # this is a hack, I hate this 
        try:
          fileTags = request.formData["tags"].body 
        except KeyError:
          fileTags = "[]"
        
        # create new file object
        var file = newFile(user, fileName, fileTags)
        db.insert(file)

        # create needed directories if they don't exist already
        let directory = "uploads/" & user.username & "/"
        if not dirExists(directory):
          createDir(directory)
        
        # TODO: index uploaded files into db using a table for files
        
        # write the file from memory
        writeFile(directory & fileName, fileData)
        resp "Uploaded successfully!"

      else:
        resp "Invalid operation!"
