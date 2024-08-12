import std/[strutils, os, json, asyncdispatch, httpclient, with, logging]

import jester
import checksums/sha3
import norm/model
import norm/postgres except error

import ./config/config
import ./[database, helpers]
import ./types/[users, files]
import ./routes/[auth, delete, download, upload, update]

const logo = """

    █████████  ████   ███                                            
  ███░░░░░███░░███  ░░░                                             
 ███     ░░░  ░███  ████  █████████████   ████████   █████   ██████ 
░███          ░███ ░░███ ░░███░░███░░███ ░░███░░███ ███░░   ███░░███
░███    █████ ░███  ░███  ░███ ░███ ░███  ░███ ░███░░█████ ░███████ 
░░███  ░░███  ░███  ░███  ░███ ░███ ░███  ░███ ░███ ░░░░███░███░░░  
  ░░█████████  █████ █████ █████░███ █████ ░███████  ██████ ░░██████ 
  ░░░░░░░░░  ░░░░░ ░░░░░ ░░░░░ ░░░ ░░░░░  ░███░░░  ░░░░░░   ░░░░░░  
                                          ░███                      
                                          █████                     
                                          ░░░░░                      
"""

const logFormattingString = "[$date $time] - [$levelname]: "

if cfg.enableLogs:
  var choosenThreshold: Level
  if cfg.enableDebugLogs:
    choosenThreshold = lvlDebug
  else:
    choosenThreshold = lvlInfo

  addHandler newConsoleLogger(fmtStr = logFormattingString,
      levelThreshold = choosenThreshold)
  addHandler newRollingFileLogger("glimpse-logs.log",
      fmtStr = logFormattingString, levelThreshold = choosenThreshold)

if cfg.enableErrorLogs:
  addHandler newRollingFileLogger("glimpse-errors.log",
      fmtStr = logFormattingString, levelThreshold = lvlError)

debug "Debug logs enabled!"
info "Info logs enabled!"
notice "Notice logs enabled!"
warn "Warn logs enabled!"
error "Error logs enabled!"
fatal "Fatal logs enabled!"

notice logo

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
