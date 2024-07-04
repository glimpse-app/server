# import libs
import std/[strutils, os, logging]
import jester
import norm/[model, sqlite]
import types/[users, files]
import checksums/sha3
import database

# addHandler newConsoleLogger(fmtStr = "")

import routes/[auth, delete, download, upload]

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