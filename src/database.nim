import norm/[model, postgres]
import types/[users, files]
# using sqlite as it makes setup faster
# once project is stable enough this will switch to postgresql
let db* = open("0.0.0.0", "user", "postgres", "")
db.createTables(newFile()) # file objects require a user object, thus a tables for both are created
