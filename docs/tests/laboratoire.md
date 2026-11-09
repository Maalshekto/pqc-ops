# Laboratoire de test

Le dossier [`lab/`](https://github.com/Maalshekto/pqc-ops/tree/main/lab) du dépôt fournit un environnement Docker basé sur **Debian 13 (OpenSSL 3.5 LTS)** avec un serveur nginx exposant trois profils et un client outillé.

| Port | Profil | Groupes | Certificat |
|---|---|---|---|
| 8443 | Hybride préféré, repli classique | `X25519MLKEM768:X25519:secp256r1` | ECDSA P-256 |
| 9443 | Hybride exigé | `X25519MLKEM768:SecP384r1MLKEM1024` | ECDSA P-256 |
| 10443 | PQC complet (pilote PKI interne) | `X25519MLKEM768` | ML-DSA-65 |

## Démarrage

```bash
cd lab
docker compose up --build -d
docker compose exec client bash
```

## Premiers tests

```bash
# 1. Client moderne : l'hybride doit être négocié
openssl s_client -connect serveur:8443 -brief </dev/null 2>&1 | grep -i group
# Negotiated TLS1.3 group: X25519MLKEM768

# 2. Client « ancien » (classique uniquement) sur le profil avec repli : doit réussir
openssl s_client -connect serveur:8443 -groups X25519 -brief </dev/null 2>&1 | grep -i group
# Negotiated TLS1.3 group: X25519

# 3. Client classique sur le profil exigeant l'hybride : doit ÉCHOUER
openssl s_client -connect serveur:9443 -groups X25519 -brief </dev/null
# ... handshake failure / alert

# 4. Certificat ML-DSA : vérifier l'algorithme de signature du pair
openssl s_client -connect serveur:10443 -CAfile /etc/nginx/certs/mldsa-ca.crt </dev/null 2>/dev/null \
  | grep -E "Peer signature type|Verification"

# 5. Côté applicatif, la variable $ssl_curve renvoyée par nginx
curl -sk https://serveur:8443/
```

!!! note "curl"
    `curl` négocie l'hybride si sa bibliothèque TLS le permet (OpenSSL 3.5, BoringSSL, rustls…). Avec `curl --curves X25519MLKEM768` on force le groupe.

## Simuler un réseau réaliste

```bash
# Dans le conteneur client (NET_ADMIN) : 40 ms de latence, 0,5 % de perte
tc qdisc add dev eth0 root netem delay 40ms loss 0.5%

# Réduire le MTU pour simuler un tunnel (IPsec, GRE, VXLAN)
ip link set dev eth0 mtu 1280

# Capturer pour analyser la segmentation du ClientHello
tshark -i eth0 -f "tcp port 8443" -w /tmp/hybride.pcapng &
openssl s_client -connect serveur:8443 </dev/null >/dev/null 2>&1
kill %1
tshark -r /tmp/hybride.pcapng -Y "tls.handshake.type == 1" -T fields \
  -e frame.number -e tcp.len -e tls.handshake.length

# Nettoyer
tc qdisc del dev eth0 root
```

## Étendre le laboratoire

- **strongSwan 6** (disponible dans Debian 13) pour les tests IPsec hybrides ;
- **OpenSSH 10** pour SSH ;
- Une **image de l'équipement réel** (pare-feu virtuel, WAF virtuel, répartiteur de charge virtuel) intercalée entre client et serveur : c'est là que les vrais problèmes apparaissent ;
- Des clients **Java, .NET, Go, Python** représentatifs du parc applicatif.
