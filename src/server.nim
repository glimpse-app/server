import std/[strutils, os, json]
import jester
import norm/[model, sqlite]
import checksums/sha3
import ./types/[users, files]
import ./database
import ./routes/[auth, delete, download, upload]

createAuthenticationRoutes()
createDeletionRoutes()
createDownloadRoutes()
createUploadRoutes()

# addHandler newConsoleLogger(fmtStr = "")

routes:
  #[
    request parameters: 
      ???
    returns:
      ???
  ]#
  # post "/api/v1/getPath":
    # let index = parseInt(@"index")
    # resp """JSON HERE indexedImages[index]["path"]"""

  #[ 
    request parameters: 
      ???
    returns:
      ???
  ]#
  # post "/api/v1/getTags":
    # let index = parseInt(@"index")
    # resp """indexedImages[index]["tags"]"""

# template respJson*(node: JsonNode) =
#   resp $node, "application/json"
  extend auth, ""
  extend delete, ""
  extend download, ""
  extend upload, ""