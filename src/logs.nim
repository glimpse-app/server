import std/logging
import ./config/config

proc startLogging*() =
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
