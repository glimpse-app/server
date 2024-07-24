import std/[parsecfg, os, strutils]
import ./defConf

type
  Cfg* = ref object
    # server
    bindAddr*: string
    port*: int
    reusePort*: bool
    staticDir*: string
    appName*: string

#! Taken from https://github.com/zedeus/nitter
#! SPDX-License-Identifier: AGPL-3.0-only
proc get*[T](config: Config; section, key: string; default: T): T =
  let val = config.getSectionValue(section, key)
  if val.len == 0: return default
  when T is int: parseInt(val)
  elif T is bool: parseBool(val)
  elif T is string: val

proc getConfig*(): Cfg =

  const conf = "config.ini"

  if not conf.fileExists():
    writeFile(conf, defaultConf)

  var config = loadConfig(conf)

  return Cfg(
    # server
    bindAddr: config.get("Server", "bindAddr", "0.0.0.0"),
    port: config.get("Server", "port", 8080),
    reusePort: config.get("Server", "reusePort", true),
    staticDir: config.get("Server", "staticDir", "./public"),
    appName: config.get("Server", "appName", ""),
  )
