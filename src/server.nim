import std/[strutils, os, json, asyncdispatch, httpclient]

import jester
import checksums/sha3
import norm/[model, postgres]

import ./config/config
import ./[database, helpers]
import ./types/[users, files]
import ./routes/[auth, delete, download, upload, update]

settings:
  bindAddr = cfg.bindAddr
  port = Port(cfg.port)
  reusePort = cfg.reusePort
  staticDir = cfg.staticDir
  appName = cfg.appName

createAuthenticationRoutes()
createDeletionRoutes(cfg)
createDownloadRoutes()
createUploadRoutes(cfg)
createUpdateRoutes()

routes:
  #[
    request parameters:
      ???
    returns:
      ???
  ]#
  # post "/api/v1/getTags":
    # let index = parseInt(@"index")
    # resp """indexedImages[index]["tags"]"""

  extend auth, ""
  extend delete, ""
  extend download, ""
  extend upload, ""
  extend update, ""
