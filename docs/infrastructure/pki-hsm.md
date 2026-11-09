# PKI et HSM

La PKI est le chantier **le plus long** : hiérarchies de confiance à longue durée de vie, dépendance aux HSM, aux logiciels d'AC, à tous les consommateurs de certificats. Il faut le démarrer tôt, même s'il ne sera livré qu'en vague 3.

## Stratégies de hiérarchie

| Option | Principe | Avantages | Inconvénients |
|---|---|---|---|
| **Hiérarchie parallèle** | Nouvelle racine ML-DSA à côté de la racine RSA/ECDSA ; double émission | Pas de rupture pour les clients anciens ; bascule progressive | Double gestion, double distribution des ancres de confiance |
| **Certificats composites** | Une clé et une signature ML-DSA + ECDSA dans un même certificat | Une seule chaîne ; sécurité hybride | Tous les vérificateurs doivent comprendre le format composite (drafts IETF) |
| **Certificats « catalyseurs »** (extensions alternatives) | Clé et signature PQC dans des extensions non critiques | Ignorées par les clients anciens | Format moins consensuel ; taille |
| **PQC seul** | ML-DSA uniquement | Simple, compact (relativement) | Pas de rétrocompatibilité ; non conforme ANSSI en phase de transition |

!!! tip "Recommandation"
    Pour une PKI interne bancaire : monter dès maintenant une **hiérarchie parallèle de préproduction** (racine SLH-DSA ou ML-DSA-87, intermédiaires ML-DSA-65) pour tester l'écosystème, et suivre la stabilisation des certificats composites avant de choisir le modèle de production.

## Générer une hiérarchie de test (OpenSSL 3.5)

```bash
# Racine ML-DSA-87
openssl genpkey -algorithm ML-DSA-87 -out racine.key
openssl req -x509 -new -key racine.key -days 3650 \
  -subj "/O=Banque Exemple/CN=Racine PQC Test" -out racine.crt

# Intermédiaire ML-DSA-65
openssl genpkey -algorithm ML-DSA-65 -out inter.key
openssl req -new -key inter.key -subj "/O=Banque Exemple/CN=AC Intermediaire PQC" -out inter.csr
openssl x509 -req -in inter.csr -CA racine.crt -CAkey racine.key -days 1825 \
  -extfile <(printf "basicConstraints=critical,CA:TRUE,pathlen:0\nkeyUsage=critical,keyCertSign,cRLSign") \
  -out inter.crt

# Feuille serveur ML-DSA-65
openssl genpkey -algorithm ML-DSA-65 -out serveur.key
openssl req -new -key serveur.key -subj "/CN=api.labo.banque.example" -out serveur.csr
openssl x509 -req -in serveur.csr -CA inter.crt -CAkey inter.key -days 90 \
  -extfile <(printf "subjectAltName=DNS:api.labo.banque.example\nextendedKeyUsage=serverAuth") \
  -out serveur.crt

# Taille de la chaîne
cat serveur.crt inter.crt | openssl crl2pkcs7 -nocrl -certfile /dev/stdin -outform DER | wc -c
```

!!! danger "Laboratoire uniquement"
    Clés générées hors HSM, sur un poste : **jamais** pour un usage réel.

## HSM

Les HSM sont souvent le **chemin critique** :

- [ ] **Version de firmware** prenant en charge ML-KEM, ML-DSA (et LMS/XMSS si signature de firmware/code) — les principaux constructeurs (Thales, Entrust, Utimaco, Marvell, Securosys…) en proposent, mais à des niveaux de maturité variables ;
- [ ] **Certification** : FIPS 140-3 incluant les algorithmes PQC (CAVP/CMVP), Critères communs / qualification ANSSI selon l'usage ;
- [ ] **Interfaces** : mécanismes PKCS#11 3.2 (ML-KEM, ML-DSA), JCE, KMIP ;
- [ ] **Performance** : signatures ML-DSA par seconde, notamment pour une AC à fort volume (mTLS, certificats de courte durée) ;
- [ ] **Gestion d'état** pour LMS/XMSS : interdiction de réutilisation garantie y compris en cluster et après restauration ;
- [ ] **HSM de paiement** : traités séparément (voir [Flux de paiement et HSM](../banque/paiement.md)) ;
- [ ] **KMS cloud** : vérifier le support PQC des KMS et des HSM managés si l'établissement les utilise.

## Révocation, OCSP, CT

Des signatures plus grandes rendent les **CRL** et les réponses **OCSP** nettement plus lourdes. Mesurer l'impact sur les points de distribution et les répondeurs OCSP, et considérer des certificats de courte durée (sans révocation) pour l'est-ouest.
