# syntax = docker/dockerfile:1
FROM alpine:3.20

LABEL maintainer="Geco-iT Team <contact@geco-it.fr>" \
      name="geco-it/woodpecker-git-basic-changelog-plugin" \
      vendor="Geco-iT"

RUN apk add --no-cache bash git

# Add script file
COPY git-log.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/git-log.sh

ENTRYPOINT ["git-log.sh"]
