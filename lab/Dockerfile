# Image de laboratoire : Debian 13 (trixie) embarque OpenSSL 3.5 LTS,
# donc ML-KEM / ML-DSA natifs et nginx capable de négocier X25519MLKEM768.
FROM debian:trixie-slim
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      nginx openssl ca-certificates curl tshark iproute2 iputils-ping \
 && rm -rf /var/lib/apt/lists/*
COPY gen-certs.sh /usr/local/bin/gen-certs.sh
RUN chmod +x /usr/local/bin/gen-certs.sh && /usr/local/bin/gen-certs.sh /etc/nginx/certs
