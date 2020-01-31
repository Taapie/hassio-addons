#!/usr/bin/env sh
set +u

cd find3/server
while true; do
    echo Starting AI server...
    cd ai
    make &

    sleep 10 

    echo.
    echo Starting data storage server...
    cd ../main
    ./main -port 8005
done
