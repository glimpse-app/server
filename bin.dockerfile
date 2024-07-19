FROM nimlang/nim:latest AS builder
WORKDIR /src
COPY . /src

RUN apt-get -y update && apt-get -y upgrade && apt-get -y autoremove

RUN nimble -y install jester norm checksums
RUN nimble build

FROM scratch AS runner

COPY --from=builder /src/server .