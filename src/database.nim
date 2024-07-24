import norm/[model, postgres]
import types/[users, files]
import config/config

let db* = open(cfg.dbHost, cfg.dbUser, cfg.dbPassword, cfg.dbDatabase)
db.createTables(newFile()) # file objects require a user object, thus a tables for both are created
