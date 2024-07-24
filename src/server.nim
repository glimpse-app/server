import std/[strutils, os, json, asyncdispatch, httpclient]
import jester
import norm/[model, postgres]
import checksums/sha3
import ./types/[users, files]
import ./[database, helpers]
import ./routes/[auth, delete, download, upload, update]

settings:
  bindAddr = "0.0.0.0"
  port = Port(8080)
  reusePort = true
  staticDir = "./public"
  appName = ""

createAuthenticationRoutes()
createDeletionRoutes()
createDownloadRoutes()
createUploadRoutes()
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
