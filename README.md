# Glimpse API server

This is the Glimpse API server.

## Run test server instance

Install needed libraries:

```sh
nimble install jester norm checksums
```

Compile and run:

```sh
nimble run
```

Build project:

```sh
nimble build
```

## Docker

To compile the binary only, run the following (executable will be found in `/bin/`):

```sh
docker buildx build -t glimpse-server:latest --output=bin --target=runner -f
```

To deploy an instance of the server within docker, run:

```sh
docker buildx build -t glimpse-server:latest .
docker run -it --rm glimpse-server:latest
```

## API Endpoints

Each endpoint has comments describing what type of request it is and what parameters it takes.
Example requests using `cURL`:

```sh
curl -X <POST|GET|PUT|DELETE> <Endpoint URI> -H '<Request Body Contents>'
```

```sh
curl -X POST http://localhost:5000/api/v1/newUser -H 'Username=Array' -H 'Password=i8Vl8XZaVRiZFsZ'
```

```sh
curl -X POST -H "Authorization: <access_token>" -F "file=@image.png" http://localhost:5000/api/v1/newFile
```
