FROM debian:bookworm-slim

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Set ARGs for user/group IDs
ARG USER_ID=1000
ARG GROUP_ID=1000

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    curl \
    gnupg \
    ruby-full \
    ruby-dev \
    nodejs \
    npm \
    zlib1g-dev \
    libffi-dev \
    cmake \
    sudo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user to run Jekyll with the same UID/GID as the host user
RUN groupadd -g $GROUP_ID jekyll && \
    useradd -u $USER_ID -g $GROUP_ID -m -s /bin/bash jekyll && \
    echo "jekyll ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/jekyll && \
    mkdir -p /app && \
    chown -R jekyll:jekyll /app

# Switch to the new user
USER jekyll
WORKDIR /home/jekyll

# Set up user's gem environment
ENV GEM_HOME=/home/jekyll/gems
ENV PATH=/home/jekyll/gems/bin:$PATH
RUN mkdir -p ${GEM_HOME}

# Install Jekyll and Bundler as the jekyll user
RUN gem install jekyll bundler

# Set up the application directory
WORKDIR /app

# Expose port 4000 for Jekyll server
EXPOSE 4000

# Copy the entrypoint script (needs to be next to this Dockerfile)
COPY --chown=jekyll:jekyll entrypoint.sh /home/jekyll/entrypoint.sh
RUN chmod +x /home/jekyll/entrypoint.sh

# Set the entry point
ENTRYPOINT ["/home/jekyll/entrypoint.sh"]

# Usage instructions:
# 1. Place this Dockerfile and entrypoint.sh in the same directory as your Jekyll theme or site
# 2. Build the image: 
#    docker build -t jekyll-chirpy --build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g) .
# 3. Run the container:
#    docker run -p 4000:4000 -v $(pwd):/app jekyll-chirpy
