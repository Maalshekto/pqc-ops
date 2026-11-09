#!/usr/bin/env bash
# Génère deux chaînes de test : une classique (ECDSA P-256) et une PQC (ML-DSA-65).
# LABORATOIRE UNIQUEMENT — clés hors HSM.
set -euo pipefail
out="${1:-./certs}"
mkdir -p "$out"
cd "$out"

gen_chain() {
  local name="$1" algo_opts=("${@:2}")
  openssl genpkey "${algo_opts[@]}" -out "$name-ca.key"
  openssl req -x509 -new -key "$name-ca.key" -days 365 \
    -subj "/O=PQC-Ops Lab/CN=Lab CA $name" -out "$name-ca.crt"
  openssl genpkey "${algo_opts[@]}" -out "$name.key"
  openssl req -new -key "$name.key" -subj "/CN=$name.lab" -out "$name.csr"
  openssl x509 -req -in "$name.csr" -CA "$name-ca.crt" -CAkey "$name-ca.key" \
    -days 90 -set_serial "0x$(openssl rand -hex 8)" \
    -extfile <(printf "subjectAltName=DNS:%s.lab,DNS:localhost\nextendedKeyUsage=serverAuth" "$name") \
    -out "$name.crt"
  rm -f "$name.csr"
}

gen_chain classic -algorithm EC -pkeyopt ec_paramgen_curve:P-256
gen_chain mldsa   -algorithm ML-DSA-65
echo "Certificats générés dans $out"
