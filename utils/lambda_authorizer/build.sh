#!/bin/bash

go mod tidy

GOARCH=amd64 GOOS=linux go build -o bootstrap main.go

zip authorizer.zip bootstrap

rm bootstrap