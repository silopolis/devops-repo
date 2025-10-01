#-------------------------------------------------------------------------------
# Build
#-------------------------------------------------------------------------------
FROM ekzhang/bore AS upstream

#-------------------------------------------------------------------------------
# Runtime
#-------------------------------------------------------------------------------
FROM alpine:3.20

# bash for pipefail/traps; tini for PID 1 signal/reaping
RUN apk add --no-cache bash tini

# Install binary and runtime script
WORKDIR /usr/local/bin
COPY --from=upstream /bore .
# Start script (kept tiny & robust)
# - pipefail: fail if any stage fails
# - trap: forward TERM/INT to the whole process group (so bore gets the signal)
# - write first match to .env as REMOTE_PORT=NNNNN while preserving stdout
RUN printf '%s\n' \
'#!/usr/bin/env bash' \
'set -Eeuo pipefail' \
'trap "kill -- -$$" TERM INT' \
'cmd=(bore local --local-host $BORE_LOCAL_HOST)' \
'("${cmd[@]}") |& awk '"'"'{ print; if (!done && match($0,/remote_port=([0-9]+)/,m)) { print "REMOTE_PORT=" m[1] > "/var/run/bore/remote_port"; close("/var/run/bore/remote_port"); done=1 } }'"'" \
> run_bore.sh \
&& chmod +x run_bore.sh

# Set runtime environment
RUN install --owner=1000 --group=1000 --mode=755 --directory /var/run/bore
USER 1000:1000
WORKDIR /var/run/bore
# Environment
ENV NO_COLOR=1
# Default bore args
# Override at runtime with: -e BORE_LOCAL_PORT=...
ENV BORE_LOCAL_HOST="localhost"
ENV BORE_LOCAL_PORT="8080"
ENV BORE_SERVER="bore.pub"
ENV BORE_SERVER_PORT="0"
ENV BORE_SECRET=""

#ENTRYPOINT ["bore --local-host $BORE_LOCAL_HOST"]
# Use tini as PID 1
#ENTRYPOINT ["/sbin/tini","--"]
#CMD ["/usr/local/bin/run_bore.sh"]
ENTRYPOINT ["/usr/local/bin/run_bore.sh"]
