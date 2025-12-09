FROM registry.fedoraproject.org/fedora:41

WORKDIR /app

# Install system dependencies including podman, python, and required tools
RUN dnf install -y \
    podman \
    python3.12 \
    python3-pip \
    python3-devel \
    gcc \
    gcc-c++ \
    make \
    cmake \
    wget \
    tar \
    git \
    && dnf clean all

# Install krknctl
ARG KRKNCTL_VERSION=v0.10.15-beta
RUN wget -q https://github.com/krkn-chaos/krknctl/releases/download/${KRKNCTL_VERSION}/krknctl-${KRKNCTL_VERSION}-linux-amd64.tar.gz \
    && tar -xzf krknctl-${KRKNCTL_VERSION}-linux-amd64.tar.gz \
    && mv krknctl /usr/local/bin/krknctl \
    && chmod +x /usr/local/bin/krknctl \
    && rm -f krknctl-${KRKNCTL_VERSION}-linux-amd64.tar.gz LICENSE README.md

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN python3 -m pip install --no-cache-dir -r requirements.txt

# Copy the project files
COPY . .

# Install krkn-ai in editable mode
RUN python3 -m pip install -e .

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Create mount points for input/output
RUN mkdir -p /input /output

# Environment variables with defaults
ENV MODE=run
ENV KUBECONFIG=/input/kubeconfig
ENV CONFIG_FILE=/input/krkn-ai.yaml
ENV OUTPUT_DIR=/output
ENV NAMESPACE=".*"
ENV POD_LABEL=".*"
ENV NODE_LABEL=".*"
ENV FORMAT=yaml
ENV RUNNER_TYPE=""
ENV VERBOSE=0
ENV SKIP_POD_NAME=""
ENV EXTRA_PARAMS=""

ENTRYPOINT ["/entrypoint.sh"]
