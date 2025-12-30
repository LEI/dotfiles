ARG IMAGE_NAME
ARG IMAGE_VERSION
FROM $IMAGE_NAME:$IMAGE_VERSION
COPY script/entrypoint /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/entrypoint"]
