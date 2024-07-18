#FROM --platform=$BUILDPLATFORM nimlang/nim AS builder
FROM --platform=$BUILDPLATFORM nimlang/nim:alpine AS builder
#FROM nimlang/nim:2.0.0-alpine-regular AS builder

RUN apk --no-cache update && apk --no-cache upgrade

WORKDIR /src/
COPY . .

RUN nimble install -y jester norm checksums
RUN nimble build --verbose --spellSuggest --deepcopy:on -d:nimDebugDlOpen -d:normDebug 


#FROM --platform=$BUILDPLATFORM debian:latest AS runner
FROM --platform=$BUILDPLATFORM nimlang/nim:alpine AS runner
#FROM --platform=$BUILDPLATFORM archlinux:base AS runner 
# https://github.com/nim-lang/Nim/issues/22546

WORKDIR /app/

#RUN apt update -y && apt upgrade -y && apt autoremove -y
#RUN apt install sqlite3 -y
RUN apk --no-cache update && apk --no-cache upgrade
RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub
RUN wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.35-r1/glibc-2.35-r1.apk
RUN apk add glibc-2.35-r1.apk
RUN apk add --no-cache --virtual=.build-deps pcre ca-certificates sqlite sqlite-libs sqlite-dev build-base

#RUN pacman -Syyuu --noconfirm

COPY --from=builder /src/server /app/

ENTRYPOINT ["/app/server"]
EXPOSE 5000
