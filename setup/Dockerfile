## Base image
FROM jenkins/jenkins:lts-jdk21

# Switch to root user for installations
USER root

## Update and install prerequisites
# Added lsb-release which is needed for $(lsb_release -cs)
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    software-properties-common \
    jq && \
    apt clean && apt autoremove -y

## Install Docker CLI and Docker Compose
# Add Docker's official GPG key
RUN install -m 0755 -d /etc/apt/keyrings
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
RUN chmod a+r /etc/apt/keyrings/docker.gpg
# Set up the Docker stable repository
RUN echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
# Update apt package index again and install Docker CLI
RUN apt-get update && apt-get install -y docker-ce-cli docker-compose-plugin \
    apt clean && apt autoremove -y

## Improve Jenkins initial setup
# Switch back to jenkins user
USER jenkins
# Install Jenkins plugins
RUN jenkins-plugin-cli --plugins \
        blueocean \
        json-path-api \
        locale \
        saferestart \
        configuration-as-code

