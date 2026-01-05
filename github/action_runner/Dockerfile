FROM ubuntu:24.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
                libc6 git wget curl tar zip unzip binutils xz-utils liblzo2-2 cabextract iproute2 net-tools netcat-openbsd telnet libatomic1 libsdl1.2-dev libsdl2-2.0-0 \
                libfontconfig icu-devtools libunwind8 sqlite3 libsqlite3-dev libzip-dev locales ffmpeg apt-transport-https init-system-helpers \
                libcurl3-gnutls liblua5.1-0 libluajit-5.1-2 libsqlite3-0 bzip2 zlib1g libevent-dev libmariadb-dev-compat libmariadb-dev libssl-dev \
                libfluidsynth-dev libmariadb-dev libicu-dev libssl3 libduktape207 libjsoncpp-dev libleveldb1d libncurses6 libncursesw6 tini gzip make \
                llvm curl jq git sudo gzip make gnupg2 lsb-release libc++abi-dev lld libc++-dev cppcheck \
                software-properties-common python3 python3-venv python3-dev python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Create a user for the runner
RUN useradd -m -s /bin/bash runner && \
    echo "runner ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Install Clang-21
RUN wget https://apt.llvm.org/llvm.sh && \
    chmod u+x llvm.sh && \
    sudo ./llvm.sh 21 all && \
    sudo apt-get install -y \
        clang-21 \
        clang-tidy-21 \
        clang-format-21 \
        libc++-21-dev \
        libc++abi-21-dev \
        lld-21 && \
    rm llvm.sh

RUN update-alternatives --install /usr/bin/clang clang /usr/bin/clang-21 100 && \
    update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-21 100 && \
	update-alternatives --install /usr/bin/lld lld /usr/bin/lld-21 100 && \
    update-alternatives --install /usr/bin/clang-tidy clang-tidy /usr/bin/clang-tidy-21 100 && \
    update-alternatives --install /usr/bin/clang-format clang-format /usr/bin/clang-format-21 100
	
# Switch to runner user
USER runner
WORKDIR /home/runner

# Download and extract GitHub Actions runner
RUN RUNNER_VERSION=$(curl -s https://api.github.com/repos/actions/runner/releases/latest | jq -r '.tag_name' | sed 's/^v//') && \
    curl -o actions-runner-linux.tar.gz -L "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz" && \
    tar xzf actions-runner-linux.tar.gz && \
    rm actions-runner-linux.tar.gz

# Copy startup script
COPY --chown=runner:runner start.sh /home/runner/start.sh
RUN chmod +x /home/runner/start.sh

ENTRYPOINT ["/home/runner/start.sh"]
