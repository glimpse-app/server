import std/[strutils, os, logging, random, base64]
import jester
import norm/[model, sqlite]

addHandler newConsoleLogger(fmtStr = "")

type
  File* = ref object of Model
    owner*: User
    path*: string
    # tags*: Option[seq[string]]
  User* = ref object of Model
    username*, password*, token*: string
    # email*: string

proc generateToken(length: int = 40): string =
  for _ in 0..length:
    add(result, char(rand(int('A') .. int('z'))))
  encode(result, safe = true)

# func validateToken(db: DbConn, user: User, token: string): bool =
#   db.select()

proc newUser*(username: string = "", password: string = ""): User =
  User(username: username, password: password, token: generateToken())

# func newFile*(user: User, path: string, tags = none seq[string]): File =
#   File(owner: user, path: path, tags: tags)

func newFile*(user: User = newUser(), path: string = ""): File =
  File(owner: user, path: path)

# Using sqlite as it makes setup faster. Once project is stable enough this will switch to postgresql.
let db* = open("storage.db", "", "", "")
db.createTables(User())
# db.createTables(newFile())

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
        try:
          db.select(user, "token = ?", request.formData["token"].body)
        except:
          resp "Upload failed!"

        let fileData = request.formData["file"].body
        let fileName = request.formData["file"].fields["filename"]
        
        let directory = "uploads/" & user.username & "/"
        if not dirExists(directory):
          createDir(directory)
        # TODO: index uploaded files into db using a table for files
        writeFile(directory & fileName, fileData)
        resp "Uploaded successfully!"

      else:
        resp "SOMETHING HERE"
