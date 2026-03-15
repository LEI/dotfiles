ARG IMAGE
FROM $IMAGE
COPY script/entrypoint /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/entrypoint"]
