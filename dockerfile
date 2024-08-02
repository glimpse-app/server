FROM nimlang/nim:latest AS builder

WORKDIR /src
COPY . /src

RUN apt-get -y update && apt-get -y upgrade && apt-get -y autoremove
RUN apt-get -y install libpq5

RUN nimble -y install jester norm checksums
RUN nimble build -d:release

ARG PORT=8080
EXPOSE $PORT

ENTRYPOINT ["./glimpse"]