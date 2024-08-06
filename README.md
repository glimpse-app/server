# Glimpse API server

This is the Glimpse API server.

## Compilation and deployment

### Host

Install needed libraries:

```sh
nimble install jester norm checksums
```

Build glimpse executable:

```sh
nimble build
```

Compile and run:

```sh
nimble run
```

Run unit tests:

```sh
nimble test
```

### Docker

#### Compile binary

To compile the binary only, run the following (executable will be found in `/bin/`):

```sh
docker buildx build -t glimpse-server:latest --output=bin --target=runner -f bin.dockerfile .
```

#### Deploy using docker run

To deploy an instance of glimpse within docker, run the following (make sure to update the database's host accordingly):

```sh
docker buildx build -t glimpse-server:latest .
docker run -it --rm -p 8080:8080 glimpse-server:latest
```

Use the following to run a temporary PostgreSQL database, (**DO NOT USE IN PRODUCTION**):

```sh
docker run -it --rm -e POSTGRES_USER=user -e POSTGRES_PASSWORD=postgresql -p 5432:5432 postgres
```

#### Deploy using docker compose

The docker compose provided sets up a postgres server alongside glimpse. To deploy, run (add the `-d` to detach and run in the background):

```sh
docker compose up
```

To shutdown the servers:

```sh
docker compose down
```

## Usage

### Configuration

Glimpse will create the default configuration file, `config.ini`, in the root of the directory if it does not exist. Configuration relating to web framework, [Jester](https://github.com/dom96/jester), is under the `Server` section. Database configuration is under the `Database` section. Other configuration variables are under `General`. If running glimpse using the docker image, `docker run ...`, make sure to adjust container's network pointing it to the database (When using docker compose, use `network_mode: host` if database is running from host).

### API Endpoints

Each endpoint has comments describing what type of request it is and what parameters it takes.
Example requests using `cURL`, more examples can be found in `/tests/`:

```sh
curl -X <POST|GET|PUT|DELETE> <Endpoint URI> -H '<Request Header Contents>'
```

```sh
curl -X POST http://0.0.0.0:8080/api/v1/newUser -H 'Username=Array' -H 'Password=i8Vl8XZaVRiZFsZ'
```

```sh
curl -X POST -H "Authorization: <access_token>" -F "file=@image.png" http://0.0.0.0:8080/api/v1/newFile
```
