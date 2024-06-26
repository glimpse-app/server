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
curl -s -X POST http://localhost:5000/api/register -d 'username=Array' -d 'password=i8Vl8XZaVRiZFsZ'
```

```sh
curl -s -X POST -H "Content-Type: multipart/form-data" -F "file=@image.png" -F "token=<some long hash here>" http://localhost:5000/api/upload
```
