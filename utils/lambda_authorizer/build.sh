#!/bin/bash

GOOS=linux CGO_ENABLED=0 go build main.go

zip - main > ./function.zip

rm main