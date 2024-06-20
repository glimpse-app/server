# Glimpse API server

This is the Glimpse API server.

## Run test server instance

Install needed libraries:

```sh
nimble install jester norm
```

Compile and run:

```sh
nimble run --verbose -d:normDebug
```

## API Endpoints

### /api/register

Arguments required: `username` `password`

```sh
curl -s -X POST http://localhost:5000/api/register -d 'username=Array' -d 'password=i8Vl8XZaVRiZFsZ'
```

### /api/upload

Arguments required: `file` `token`

Example:

```sh
curl -i -X POST -H "Content-Type: multipart/form-data" -F "file=@image.png" -F "token=SkNaeltRR2RPS3FXTUlvVkdBZ154S3Bjam5iZllkWnlxeVN3cUtfTVQ=" http://localhost:5000/api/upload
```
