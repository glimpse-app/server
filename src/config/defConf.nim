const defaultConf* =
  """
; Default Glimpse server configuration.

[Server]
; IP address glimpse will use.
#bindAddr = "0.0.0.0"
; Port that glimpse will use.
#port = "8080"
#reusePort = "true"
; Currently unused.
#staticDir = "./public/"
; What URL path glimpse will run under. If the value of appName is set
; to '<value>', then glimpse will be accessiable under 'http:<IP>:<PORT>/value/...'.
#appName = ""

[Database]
; 2 database types are supported PostgreSQL or SQLite.
#dbType = postgresql
; IP address or domain of the database.
#dbHost = "db"
; Database user.
#dbUser = "postgres"
; Database Password.
#dbPassword = "postgresql"
; I have no idea what this is for.
#dbDatabase = ""

[General]
; This is the path to the directory which contains all users' uploaded files.
#uploadDir = "./uploads/"
"""
