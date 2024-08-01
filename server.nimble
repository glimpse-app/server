version       = "0.0.1"
author        = "Array in a Matrix"
description   = "Glimpse backend server."
license       = "AGPL-3.0-or-later"

bin           = @["glimpse"]
srcDir        = "src"
backend       = "c"

requires "nim >= 2.0.2"
requires "jester"
requires "norm"
requires "checksums"