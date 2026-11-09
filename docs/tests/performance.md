# Performance

## Ce qu'il faut savoir avant de mesurer

- **ML-KEM est rapide** : en CPU, l'échange hybride coûte à peine plus qu'un X25519 seul. L'impact CPU sur les terminaisons TLS est généralement négligeable.
- **Le coût est dans les octets** : environ +1,1 Ko dans chaque direction pour l'échange de clés, et **+10 à 17 Ko** pour une chaîne de certificats ML-DSA.
- La fenêtre de congestion initiale TCP (10 segments ≈ 14 Ko) peut être dépassée par le premier vol du serveur avec une chaîne ML-DSA : **un aller-retour supplémentaire**, surtout visible sur les réseaux mobiles à forte latence.

## Ordres de grandeur

| Scénario | Octets supplémentaires (approx.) | Impact attendu |
|---|---|---|
| Échange hybride `X25519MLKEM768`, certificats ECDSA | +2,2 Ko par handshake | Négligeable dans la plupart des cas |
| Échange hybride + chaîne ML-DSA-65 (feuille + intermédiaire) | +12 à 15 Ko | Possible RTT supplémentaire ; à mesurer |
| Échange hybride + chaîne ML-DSA-87 | +17 à 20 Ko | RTT supplémentaire probable sur mobile |
| HelloRetryRequest | +1 RTT complet | À éviter par une bonne configuration des *key shares* |

## Mesures à réaliser

```bash
# Débit de handshakes (nouvelles connexions, sans reprise) :
# lancer une fois avec le serveur en configuration classique, une fois en hybride
openssl s_time -connect serveur:8443 -new -time 30

# Micro-benchmarks des primitives
openssl speed -seconds 5 ML-KEM-768 X25519
openssl speed -seconds 5 ML-DSA-65 ecdsap256

# Latence de bout en bout côté client
curl -sk -o /dev/null -w "connect=%{time_connect} tls=%{time_appconnect} total=%{time_total}\n" \
  https://serveur:8443/
```

Pour la charge, utiliser un outil capable de **forcer de nouvelles connexions TLS** (sans keep-alive ni reprise) : `h2load`, `wrk` avec un script dédié, k6 ou Gatling. Comparer classique vs hybride **avec les mêmes conditions réseau** (netem).

## Indicateurs et seuils d'acceptation (exemple)

| Indicateur | Méthode | Seuil d'acceptation proposé |
|---|---|---|
| Latence de handshake p50 / p99 | `curl -w`, journaux du frontal | Dégradation < 5 % (p50) et < 10 % (p99) vs référence |
| Handshakes / s par cœur | `openssl s_time`, outil de charge | Dégradation < 10 % |
| CPU des terminaisons TLS à charge nominale | Supervision | < 5 points de plus |
| Taux d'échec de handshake | Journaux, métriques du LB | Aucune hausse significative |
| Taille du premier vol serveur | Capture | < 14 Ko (fenêtre initiale) si possible |

!!! tip "Optimisations"
    - Raccourcir les chaînes (pas d'intermédiaire superflu, pas de racine envoyée) ;
    - Compression de certificats TLS (RFC 8879) si les deux extrémités la prennent en charge ;
    - Reprise de session (tickets / PSK) pour amortir les handshakes complets ;
    - Garder les certificats **classiques** sur le Web public tant que l'écosystème n'est pas prêt.
