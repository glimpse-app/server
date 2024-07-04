import norm/model
import users

# file objects are owned by a user
type File* = ref object of Model
  owner*: User
  path*: string
  name*: string
  tags*: string #? This is a temporary hack should be of type `tags: seq[string]` instead

# creates a new file object and sets default values, recommended by the norm documentation 
func newFile*(user: User = newUser(), path: string = "", name: string = "", tags: string = ""): File =
  File(owner: user, path: path, name: name, tags: tags)
