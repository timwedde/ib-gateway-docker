#!/bin/bash
docker run -p 4002:4002 -p 5900:5900 --env TWSUSERID=$TWSUSERID --env TWSPASSWORD=$TWSPASSWORD ib-gateway-docker:latest
