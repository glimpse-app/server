# Glimpse API server

This is the Glimpse API server.

## Run test server instance

Install needed libraries:

```sh
nimble install jester norm checksums
```

Compile and run:

```sh
nimble run --verbose -d:normDebug
```

## API Endpoints

Each endpoint has comments describing what type of request it is and what parameters it takes.
Example requests using `cURL`:

```sh
curl --header "Authorization: <access_token>" -X <POST|GET|PUT|DELETE> <Endpoint URI> -d '<Request Body Contents>'
```

```sh
curl -s -X POST http://localhost:5000/api/v1/register -d 'username=Array' -d 'password=i8Vl8XZaVRiZFsZ'
```

```sh
curl -s -X POST -H "Authorization: <access_token>" -F "file=@image.png" http://localhost:5000/api/v1/upload
```
