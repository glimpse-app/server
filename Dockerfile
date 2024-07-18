FROM --platform=$BUILDPLATFORM debian:latest AS builder
RUN apt update -y 
RUN apt-get install sqlite3 -y
WORKDIR /app/
COPY . .
RUN chmod +x server
ENTRYPOINT ["./server"]
EXPOSE 5000
