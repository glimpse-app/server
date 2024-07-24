import std/[unittest, os, osproc]

test "Run tests":
  copyFile("./tests/image.png", "./image.png")
  if execCmd("cd tests && bash -c ./test_1.sh") > 0:
    fail()
  removeFile("./image.png")