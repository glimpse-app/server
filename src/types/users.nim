import std/[random, with, times]
import norm/[model, sqlite]
import checksums/sha3

# define user object
type User* = ref object of Model
  username*: string # should be unique
  email*: string    # should be unique
  password*: string # sha3-512 hash
  token*: string    # should be unique

# generate secure login token
proc generateToken*(username: string = ""): string =
  randomize()
  with result:
    add $getTime().nanosecond()
    add $rand(1_000_000_000)
    add username
    add $(getTime().toUnix())
  $Sha3_512.secureHash(result)

# checks if the provided token exists in the database
proc validToken*(db: DbConn, user: var User, token: string): bool =
  try:
    db.select(user, "token = ?", token)
    return true
  except NotFoundError:
    return false

# update user's token using a newly generated token
proc genNewToken*(db: DbConn, user: var User) =
  user.token = generateToken(user.username)
  db.update(user)

# creates a new user object and sets default values, recommended by the norm documentation
proc newUser*(username: string = "", email: string = "",
    password: string = ""): User =
  User(username: username, email: email, password: $Sha3_512.secureHash(
      password), token: generateToken(username))
