import std/[strutils, os, json, asyncdispatch, httpclient, with, logging]

import jester
import checksums/sha3
import norm/model
import norm/postgres except error
import jsony

import ./config/config
import ./[database, helpers, logs]
import ./types/[users, files]
import ./routes/[auth, delete, download, upload, update]

startLogging()

settings:
  bindAddr = cfg.bindAddr
  port = Port(cfg.port)
  reusePort = cfg.reusePort
  staticDir = cfg.staticDir
  appName = cfg.appName

debug "Starting creating routes."
createAuthenticationRoutes()
createDeletionRoutes(cfg)
createDownloadRoutes()
createUploadRoutes(cfg)
createUpdateRoutes()
debug "Finished creating routes."

debug "Starting Jester."
routes:

  extend auth, ""
  extend delete, ""
  extend download, ""
  extend upload, ""
  extend update, ""
