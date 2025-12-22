ARG IMAGE_NAME
ARG IMAGE_VERSION=latest

FROM $IMAGE_NAME:$IMAGE_VERSION

# Install dependencies
COPY script/bootstrap-deps /usr/local/bin/
RUN /usr/local/bin/bootstrap-deps

# Create user
ENV USER=test
COPY script/create-test-user /usr/local/bin/
RUN /usr/local/bin/create-test-user "$USER"

# Switch to user
USER $USER
ENV HOME=/home/$USER

# Copy dotfiles
ENV CHEZMOI_ROOT=$HOME/.local/share/chezmoi
# COPY --chown=$USER:$USER . $CHEZMOI_ROOT
COPY --chown=$USER:$USER .chezmoi* mise.toml $CHEZMOI_ROOT/
COPY --chown=$USER:$USER home $CHEZMOI_ROOT/home/
COPY --chown=$USER:$USER script $CHEZMOI_ROOT/script/
COPY --chown=$USER:$USER test $CHEZMOI_ROOT/test/
WORKDIR $CHEZMOI_ROOT

# RUN set -x && id && groups && pwd && ls -la

ENV CI=true
# ENV DEBIAN_FRONTEND=noninteractive
# ENV TZ=Etc/UTC
RUN ./script/bootstrap

ENV PATH="$PATH:$HOME/.local/bin"
# RUN sh -c ' \
#   if chezmoi feature atuin; then run_command mkdir -p "$HOME/.config/atuin"; fi \
#   if chezmoi feature goss; then run_command mkdir -p "$HOME/.config/goss"; fi \
#   if chezmoi feature helix; then run_command mkdir -p "$HOME/.config/helix"; fi \
#   if chezmoi feature nushell; then run_command mkdir -p "$HOME/.config/nushell/"{functions,modules,themes}; fi \
#   if chezmoi feature zsh; then run_command mkdir -p "$HOME/.config/zsh"; fi \
#   '

RUN ./script/check
# hadolint ignore=DL3059
RUN ./script/update
# hadolint ignore=DL3059
RUN ./script/test

CMD ["bash", "-l"]
