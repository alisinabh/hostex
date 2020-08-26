FROM elixir:1.10-alpine AS build

RUN mix local.rebar --force
RUN mix local.hex --force

RUN mkdir /hostex
COPY . /hostex
WORKDIR /hostex

ENV MIX_ENV=prod
ENV HOSTEX_STORAGE_PATH=/var/hostex/data
ENV PLUG_TMPDIR=/var/hostex/tmp

RUN mix deps.get
RUN mix release --path release

FROM alpine:3 AS app

ENV LANG=C.UTF-8

# Install openssl
RUN apk update && apk add openssl ncurses-libs

# Copy over the build artifact from the previous step and create a non root user
RUN adduser -h /hostex -D app

ENV HOSTEX_STORAGE_PATH=/var/hostex/data
ENV PLUG_TMPDIR=/var/hostex/tmp

RUN mkdir /hostex & mkdir -p /var/hostex/data && mkdir -p /var/hostex/tmp
COPY --from=build /hostex/release /hostex
WORKDIR /hostex
RUN chown -R app: /hostex
USER app

CMD ["/hostex/bin/hostex", "start"]
