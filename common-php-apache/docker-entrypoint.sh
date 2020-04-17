#!/bin/bash
set -e

# The logstream fifo. Multiple components can write to this and the output
# will be merged as part of this script's stdout (PID 1) for Docker to log.
export LOG_STREAM=/var/logstream
rm -f $LOG_STREAM
mkfifo $LOG_STREAM
chmod 777 $LOG_STREAM

# Trap certain signals so we can pass them to the child
function sig() {
    echo "Received SIG$1" >&2
    # Forward the signal to our child process
    kill "-$1" "$child" 2>/dev/null
    # Wait for the child to exit or for another trapped signal
    wait "$child"
    exit 0
}
trap "sig HUP" SIGHUP
trap "sig INT" SIGINT
trap "sig TERM" SIGTERM
trap "sig QUIT" SIGQUIT
trap "sig WINCH" SIGWINCH

# Hold open logstream with a temporary writer until the reader starts up
while sleep 1; do :; done >$LOG_STREAM &
tmp_writer=$!

# Start a background process to continuously echo from logstream to stdout
cat $LOG_STREAM &

# Open logstream for writing, replacing stdout, then close the temporary writer
exec 1>&-
exec 1>$LOG_STREAM
kill $tmp_writer

# Start our main child process
"$@" &
child=$! 

# Wait for the child to exit, or for a trapped signal
wait "$child"
