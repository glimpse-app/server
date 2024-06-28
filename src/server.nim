# import libs
import std/[strutils, os, logging, random, base64, with]
import jester
import norm/[model, sqlite]

addHandler newConsoleLogger(fmtStr = "")

# TODO: create new tags type which is a string which is used to deserialize into a json for requests? 'import std/marshal' when needed

# file objects are owned by a user
type
  File = ref object of Model
    owner: User
    path: string
    tags: string #? This is a temporary hack should be of type `tags: seq[string]` instead
  User = ref object of Model
    username, email, password, token: string # username, email and token should be unique

# creates a url safe login token
# TODO: make sure this is secure + hash this maybe?
# https://stackoverflow.com/questions/41432816/generate-totally-unique-token-that-has-never-been-used-using-php
proc generateToken(username: string = "", length: int = 20): string =
  for _ in 0..length:
    with result:
      add username
      add char(rand(int('A') .. int('z')))
  encode(result, safe = true)


# creates a new user object and sets default values, recommended by the norm documentation 
proc newUser(username: string = "", email: string = "", password: string = ""): User =
  User(username: username, email: email, password: password, token: generateToken())

# creates a new file object and sets default values, recommended by the norm documentation 
func newFile(user: User = newUser(), path: string = "", tags: string = ""): File =
  File(owner: user, path: path, tags: tags)

# checks if the provided token exists in the database
proc validToken(db: DbConn, user: var User, token: string): bool =
  try:
    db.select(user, "token = ?", token)
    return true
  except NotFoundError:
    return false

proc genNewToken(db: DbConn, user: var User) =
  user.token = generateToken()
  db.update(user)

# using sqlite as it makes setup faster
# once project is stable enough this will switch to postgresql
let db = open("storage.db", "", "", "")
db.createTables(newFile()) # file objects require a user object, thus a tables for both are created

# TODO: build API documentation

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
