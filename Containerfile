ARG IMAGE=alpine:latest
FROM $IMAGE

# User setup is handled at runtime to support multiple distros with one image
# COPY --chmod=755 script/entrypoint /usr/local/bin/
# ENTRYPOINT ["/usr/local/bin/entrypoint"]

# FIXME: termux aarch64: exec /usr/local/bin/entrypoint: no such file or directory
COPY --chmod=755 script/entrypoint /entrypoint
ENTRYPOINT ["/entrypoint"]
