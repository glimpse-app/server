import norm/[model, pragmas]
import ./users

# file objects are owned by a user
type File* = ref object of Model
  owner*: User
  path* {.unique.}: string
  name* {.unique.}: string
  tags*: string #? This is a temporary hack should be `seq[string]` or `JsonNode` instead

              # creates a new file object and sets default values, recommended by the norm documentation
func newFile*(user: User = newUser(), path: string = "", name: string = "",
    tags: string = ""): File =
  inc user.fileCount
  File(owner: user, path: path, name: name, tags: tags)
