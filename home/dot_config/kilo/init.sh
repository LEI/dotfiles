kilo() {
  OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317 \
    OTEL_SERVICE_NAME=kilo \
    command kilo "${@:---continue}"
}
alias kl=kilo
