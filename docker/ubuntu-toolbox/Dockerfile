# Ubuntu-based toolbox image
FROM ubuntu:22.04

# Install essential debugging tools in one layer
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      bash \
      curl \
      wget \
      iproute2 \
      iputils-ping \
      net-tools \
      tcpdump \
      dnsutils \
      procps \
      util-linux \
      strace \
      lsof \
      vim \
      less \
    && rm -rf /var/lib/apt/lists/*

# Default command
CMD ["bash"]