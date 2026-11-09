# Tests d'interopérabilité TLS

## Matrice d'interopérabilité

L'objectif est de vérifier, pour **chaque combinaison client × serveur × chemin réseau** représentative, que :

1. l'hybride est négocié quand les deux extrémités le prennent en charge ;
2. le **repli** vers un groupe classique fonctionne quand le client ne le prend pas en charge (profil de transition) ;
3. le refus est **net** (alerte TLS, pas de blocage silencieux) quand la politique exige l'hybride.

| Client \ Serveur | OpenSSL 3.5 (nginx/HAProxy) | Envoy / BoringSSL | Java (JDK récent) | Appliance (WAF/LB) |
|---|---|---|---|---|
| Chrome / Edge 131+ | ? | ? | ? | ? |
| Firefox 132+ | ? | ? | ? | ? |
| Safari / iOS / macOS récents | ? | ? | ? | ? |
| Appli mobile Android (OkHttp/Conscrypt) | ? | ? | ? | ? |
| Java 17/21 (classique) | ? | ? | ? | ? |
| Go 1.24+ | ? | ? | ? | ? |
| Python (`ssl`, selon OpenSSL lié) | ? | ? | ? | ? |
| curl (OpenSSL 3.5) | ? | ? | ? | ? |
| Partenaire B2B (OpenSSL 1.1.1 / 3.0) | ? | ? | ? | ? |

*Remplir chaque case par : groupe négocié / repli / échec, et temps de handshake.*

## Commandes de référence

```bash
CIBLE=api.preprod.banque.example:443

# Groupe négocié par défaut
openssl s_client -connect $CIBLE -brief </dev/null 2>&1 | grep -E "Protocol|group"

# Forcer chaque groupe et vérifier le support serveur
for g in X25519MLKEM768 SecP256r1MLKEM768 SecP384r1MLKEM1024 X25519 secp256r1; do
  printf '%-22s ' "$g"
  if out=$(openssl s_client -connect "$CIBLE" -groups "$g" -brief </dev/null 2>&1); then
    echo "$out" | awk -F': ' '/group/ {print "OK", $2}'
  else
    echo "REFUSÉ"
  fi
done

# Le serveur choisit-il l'hybride même si le client le propose en second ?
openssl s_client -connect $CIBLE -groups X25519:X25519MLKEM768 -brief </dev/null 2>&1 | grep group

# Détecter un HelloRetryRequest (aller-retour supplémentaire)
openssl s_client -connect $CIBLE -groups X25519:X25519MLKEM768 -msg </dev/null 2>&1 \
  | grep -c "HelloRetryRequest"
```

Le script [`scripts/pqc-tls-scan.sh`](https://github.com/Maalshekto/pqc-ops/blob/main/scripts/pqc-tls-scan.sh) automatise ces vérifications sur une liste de cibles et produit un CSV exploitable par le CBOM.

## Navigateurs

- `chrome://flags` → *TLS 1.3 post-quantum key agreement* (activé par défaut depuis Chrome 131) ;
- Outils de développement → onglet *Security* : affiche le groupe d'échange de clés (`X25519MLKEM768`) ;
- Firefox : `about:config` → `security.tls.enable_kyber` / `network.http.http3.enable_kyber`.

Pour un test reproductible, préférez un navigateur piloté (Playwright) et l'analyse des captures.

## Analyse de capture

```bash
# Groupes proposés par le client (supported_groups) et key shares effectivement envoyées
tshark -r test.pcapng -Y "tls.handshake.type == 1" -T fields \
  -e ip.src -e tls.handshake.extensions_supported_group -e tls.handshake.extensions_key_share_group

# Groupe retenu par le serveur
tshark -r test.pcapng -Y "tls.handshake.type == 2" -T fields \
  -e ip.src -e tls.handshake.extensions_key_share_group
```

| Valeur | Groupe |
|---|---|
| `0x11ec` (4588) | X25519MLKEM768 |
| `0x11eb` (4587) | SecP256r1MLKEM768 |
| `0x11ed` (4589) | SecP384r1MLKEM1024 |
| `0x6399` (25497) | X25519Kyber768Draft00 (obsolète) |
| `0x001d` (29) | x25519 |
| `0x0017` (23) | secp256r1 |

## Cas particuliers à couvrir

- [ ] **QUIC / HTTP/3** : le ClientHello hybride dépasse souvent un datagramme initial ; vérifier que le CDN et les pare-feux gèrent un **Initial sur plusieurs paquets**.
- [ ] **Reprise de session / 0-RTT** : comportement avec tickets émis avant et après la bascule.
- [ ] **mTLS** : certificat client et groupe hybride combinés.
- [ ] **SNI multiples** sur un même frontal avec des politiques différentes.
- [ ] **Clients embarqués** : TPE, automates, objets connectés, applications mobiles anciennes.
