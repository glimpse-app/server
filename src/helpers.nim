template H*(s: string): untyped =
  $request.headers[s]
