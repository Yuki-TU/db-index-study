FROM golang:1.23-alpine AS dev

WORKDIR /app

RUN apk update && apk add alpine-sdk jq mysql mysql-client bash curl ruby ruby-dev build-base

RUN go install github.com/sqldef/sqldef/cmd/mysqldef@latest
