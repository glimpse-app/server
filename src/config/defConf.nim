const defaultConf* =
  """
; Default Glimpse server configuration.

[Server]
#bindAddr = "0.0.0.0"
#port = "8080"
#reusePort = "true"
#staticDir = "./public/"
#appName = ""

[Database]
; 2 database types are supported PostgreSQL or SQLite.
#db = postgresql
#dbHost = "0.0.0.0"
#dbUser = "user"
#dbPassword = "postgresql"
; I have no idea what this is for.
#dbDatabase = ""

[General]
#uploadDir = "./uploads/"
"""
