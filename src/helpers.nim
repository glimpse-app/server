import std/httpcore

template H*(s: string): untyped =
  $request.headers[s]

template reqInfo*: string =
  $request.reqMethod & " " & request.host & request.path & " " & request.ip &
      " " & $request.headers["user-agent"]

template respErr*(s: string): untyped =
  error s & reqInfo
  resp Http403, s

template respErr*(e: HttpCode, s: string): untyped =
  error s & reqInfo
  resp e, s

template resp200*(json: string = ""): untyped =
  resp Http200, json & "\n", "application/json"
