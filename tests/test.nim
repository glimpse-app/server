import std/[unittest, os, osproc]

test "Run tests":
  copyFile("./tests/image.png", "./image.png")
  copyFile("./tests/image2.jpg", "./image2.jpg")

  if execCmd("bash -c ./tests/test_1.sh") > 0:
    fail()

  removeFile("./image.png")
  removeFile("./image2.jpg")
