#!/usr/bin/env bash
# pqc-tls-scan.sh — Vérifie la prise en charge de l'échange de clés hybride post-quantique
# sur une liste de points de terminaison TLS et produit un CSV (séparateur ;).
#
# Usage : ./pqc-tls-scan.sh [fichier]     (une cible host:port par ligne, # = commentaire)
#         echo "exemple.com:443" | ./pqc-tls-scan.sh
#
# Prérequis : OpenSSL >= 3.5 (groupes X25519MLKEM768, SecP384r1MLKEM1024).
# À n'utiliser que sur des systèmes pour lesquels vous disposez d'une autorisation.
set -uo pipefail

TIMEOUT="${TIMEOUT:-8}"
OPENSSL="${OPENSSL:-openssl}"

ver=$("$OPENSSL" version | awk '{print $2}')
case "$ver" in
  3.[5-9]*|3.[1-9][0-9]*|[4-9].*) ;;
  *) echo "Erreur : OpenSSL >= 3.5 requis (trouvé : $ver)" >&2; exit 2 ;;
esac

# probe <cible> [options s_client...] -> affiche "protocole|groupe" ou "ECHEC"
probe() {
  local target="$1"; shift
  local host="${target%:*}" out
  if out=$(timeout "$TIMEOUT" "$OPENSSL" s_client -connect "$target" -servername "$host" \
             -brief "$@" </dev/null 2>&1); then
    local proto group
    proto=$(awk -F': ' '/^Protocol version/ {print $2; exit}' <<<"$out")
    group=$(awk -F': ' '/group:/ {print $2; exit}' <<<"$out")
    echo "${proto:-?}|${group:-?}"
  else
    echo "ECHEC"
  fi
}

yesno() { [[ "$1" == "ECHEC" ]] && echo "non" || echo "oui"; }

echo "cible;protocole_defaut;groupe_defaut;X25519MLKEM768;SecP384r1MLKEM1024;X25519_seul;TLSv1.2;groupe_obsolete_kyber"

grep -vE '^\s*(#|$)' "${1:-/dev/stdin}" | while read -r target; do
  [[ "$target" == *:* ]] || target="$target:443"

  def=$(probe "$target")
  if [[ "$def" == "ECHEC" ]]; then
    echo "$target;injoignable;;;;;;"
    continue
  fi
  hyb=$(probe "$target" -groups X25519MLKEM768)
  m1024=$(probe "$target" -groups SecP384r1MLKEM1024)
  x25519=$(probe "$target" -groups X25519)
  tls12=$(probe "$target" -tls1_2)
  # Le groupe pré-standard n'est pas proposé par OpenSSL 3.5 : on le repère via le groupe par défaut
  kyber="non"; [[ "${def#*|}" == *Kyber* ]] && kyber="oui"

  printf '%s;%s;%s;%s;%s;%s;%s;%s\n' \
    "$target" "${def%%|*}" "${def#*|}" \
    "$(yesno "$hyb")" "$(yesno "$m1024")" "$(yesno "$x25519")" "$(yesno "$tls12")" "$kyber"
done
