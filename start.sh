#!/bin/bash

if [ "$ENTRYPOINT" = "workers" ]
then
  echo Starting workers
  # Put any commands here to start background workers
elif [ -z "$ENTRYPOINT" ] || "$ENTRYPOINT" = "web" ]
then
  echo Starting web
  /usr/bin/supervisord -c /supervisord.conf
else
  echo Error, cannot find entrypoint $ENTRYPOINT to start
fi
