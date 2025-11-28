FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    iverilog \
    make \
    git \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
COPY . /workspace

ENTRYPOINT ["/bin/bash","-lc","make test"]
