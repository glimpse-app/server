import std/[strutils, os, logging, random, base64]
import jester
import norm/[model, sqlite]

addHandler newConsoleLogger(fmtStr = "")

# TODO: create new tags type which is a string which is used to deserialize into a json for requests? 'import std/marshal' when needed

type
  File = ref object of Model
    owner: User
    path: string
    tags: string # tags: seq[string]
  User = ref object of Model
    username, email, password, token: string

proc generateToken(length: int = 40): string =
  for _ in 0..length:
    add(result, char(rand(int('A') .. int('z'))))
  encode(result, safe = true)

# func validateToken(db: DbConn, user: User, token: string): bool =
#   db.select()

proc newUser(username: string = "", email: string = "", password: string = ""): User =
  User(username: username, password: password, token: generateToken())

# func newFile(user: User = newUser(), path: string = "", tags: seq[string] = @[""]): File =
func newFile(user: User = newUser(), path: string = "", tags: string = ""): File =
  File(owner: user, path: path, tags: tags)

#? Using sqlite as it makes setup faster. Once project is stable enough this will switch to postgresql.
let db = open("storage.db", "", "", "")
db.createTables(newFile())

# TODO: build API documentation

routes:
  get "/":
    resp "Hello, World!"

  get "/api":
    
    # TODO: import this from db, export as JSON

    resp "JSON HERE"

  post "/api/@operation":

    # TODO: import this from db, export as JSON

    case @"operation":
    
      of "register":
        var user = newUser(@"username", @"password") # TODO: check if username is unique and sanitize user inputs
        db.insert(user)
        resp "Registered \"" & user.username & "\" successfully!\n Token: " & user.token

      # of "login":
        # TODO: replace old token with new provided one after successful login
      #   resp "Logined as \"" & user.username & "\" successfully!\n Token: " & user.token

      of "getItem":
        # let index = parseInt(@"index")
        # db.select(pee, "File.path = ?", "/car.png")
        resp "JSON HERE indexedImages[index]"

      of "getPath":
        # let index = parseInt(@"index")
        resp """JSON HERE indexedImages[index]["path"]"""

      of "getTags":
        # let index = parseInt(@"index")
        resp """indexedImages[index]["tags"]"""

      of "upload":
        var user = newUser()
        try: # TODO: turn this into validateToken() returning a bool
          db.select(user, "token = ?", request.formData["token"].body)
        except NotFoundError:
          resp "Upload failed!"
        
        let fileData = request.formData["file"].body
        let fileName = request.formData["file"].fields["filename"]
        var fileTags: string 
        try: # I hate this 
          fileTags = request.formData["tags"].body 
        except:
          fileTags = "[]"
        
        var file = newFile(user, fileName, fileTags)
        db.insert(file)

        let directory = "uploads/" & user.username & "/"
        if not dirExists(directory):
          createDir(directory)
        # TODO: index uploaded files into db using a table for files
        writeFile(directory & fileName, fileData)
        resp "Uploaded successfully!"

      else:
        resp "SOMETHING HERE"
