ARG IMAGE_NAME
ARG IMAGE_VERSION=latest
ARG USER=test

FROM $IMAGE_NAME:$IMAGE_VERSION

# Install dependencies
COPY script/bootstrap-deps /usr/local/bin/
RUN /usr/local/bin/bootstrap-deps

ARG USER

# Create test user
ENV USER=$USER
COPY script/create-test-user /usr/local/bin/
RUN /usr/local/bin/create-test-user "$USER"

# Switch to test user
USER $USER
# ENV HOME=/home/$USER
# WORKDIR $HOME/.local/share/chezmoi

CMD ["tail", "-f", "/dev/null"]
