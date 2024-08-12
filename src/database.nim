import std/logging
import norm/model
import norm/postgres except error
import types/[users, files]
import config/config

info "connecting to database.\n"
let db* = open(cfg.dbHost, cfg.dbUser, cfg.dbPassword, cfg.dbDatabase)
db.createTables(newFile()) # file objects require a user object, thus a tables for both are created
info "connected to database.\n"
