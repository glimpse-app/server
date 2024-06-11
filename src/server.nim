import jester, json, strutils

routes:
  get "/":
    resp "Hello, World!"

  get "/api":
    
    # import this from db 
    var indexedImages = 
      """[
        {"path": "/photos/image1.png",        "tags": ["monochrome", "filtered", "waterfall"]}, 
        {"path": "/photos/image2.jxl",        "tags": ["wedding", "family"]},
        {"path": "/wallpapers/france.jpeg",   "tags": ["eiffel tower", "paris", "france"]},
        {"path": "/turtle.gif",               "tags": ["turtle", "grass", "wildlife"]},
        {"path": "/car.png",                  "tags": ["road", "lights", "bridge", "neon", "signs", "car"]},
      ]""".parseJson

    resp indexedImages

  post "/api/@operation":
    
    # import this from db 
    var indexedImages = 
      """[
        {"path": "/photos/image1.png",        "tags": ["monochrome", "filtered", "waterfall"]}, 
        {"path": "/photos/image2.jxl",        "tags": ["wedding", "family"]},
        {"path": "/wallpapers/france.jpeg",   "tags": ["eiffel tower", "paris", "france"]},
        {"path": "/turtle.gif",               "tags": ["turtle", "grass", "wildlife"]},
        {"path": "/car.png",                  "tags": ["road", "lights", "bridge", "neon", "signs", "car"]},
      ]""".parseJson

    case @"operation":
    
      of "getItem":
        let index = parseInt(@"index")
        resp indexedImages[index]

      of "getPath":
        let index = parseInt(@"index")
        resp indexedImages[index]["path"]

      of "getTags":
        let index = parseInt(@"index")
        resp indexedImages[index]["tags"]

      else:
        resp indexedImages
