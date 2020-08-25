FROM elixir:1.10

RUN mix local.rebar --force
RUN mix local.hex --force

RUN mkdir /hostex
COPY . /hostex
WORKDIR /hostex

ENV MIX_ENV=prod
ENV HOSTEX_STORAGE_PATH=/var/hostex/data
ENV PLUG_TMPDIR=/var/hostex/tmp
RUN mkdir -p /var/hostex/data && mkdir -p /var/hostex/tmp

RUN mix deps.get
RUN mix compile

CMD ["/hostex/entrypoint.sh"]
