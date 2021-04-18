#!/bin/bash

for file in $(ls cmd)
do
  go build -ldflags '-w -s' "./cmd/$file"
  upx "./$file"
done