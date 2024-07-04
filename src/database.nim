import norm/[model, sqlite]
import types/[users, files]
# using sqlite as it makes setup faster
# once project is stable enough this will switch to postgresql
let db* = open("storage.db", "", "", "")
db.createTables(newFile()) # file objects require a user object, thus a tables for both are created
