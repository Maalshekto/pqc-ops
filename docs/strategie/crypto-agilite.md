# Crypto-agilité et hybridation

La crypto-agilité est la capacité à **changer d'algorithme, de paramètre ou de fournisseur cryptographique sans réécrire l'application** et sans interruption de service. C'est le véritable objectif du programme : ML-KEM sera peut-être remplacé ou complété par HQC, et les drafts IETF évoluent encore.

## Principes d'architecture

1. **Centraliser la terminaison cryptographique.** Plus TLS est terminé à peu d'endroits (reverse proxies, ingress, service mesh), plus la migration est une affaire de configuration.
2. **Externaliser la politique.** Les listes d'algorithmes autorisés vivent dans une configuration versionnée (policy as code), pas dans le code.
3. **S'appuyer sur la politique crypto du système.** Sur RHEL et dérivés, `update-crypto-policies` permet d'appliquer une politique cohérente à OpenSSL, GnuTLS, NSS, OpenSSH et Java.
4. **Abstraire les primitives dans le code.** Les applications appellent « chiffre ce message pour ce destinataire » ou « signe ce document », jamais `RSA/ECB/PKCS1Padding`.
5. **Prévoir la place.** Champs de base de données, en-têtes, formats de message, tailles de tampons : prévoir des clés et signatures **50 à 70 fois plus grandes**.
6. **Identifier l'algorithme dans les données.** Tout objet chiffré ou signé stocké doit porter un identifiant d'algorithme et de version de clé, pour permettre la cohabitation et la re-signature.

## Anti-patterns à traquer

| Anti-pattern | Pourquoi c'est bloquant | Détection |
|---|---|---|
| Algorithme codé en dur (`Cipher.getInstance("RSA")`) | Changement = développement + recette | SAST / Semgrep |
| Colonne `VARCHAR(512)` pour une signature | ML-DSA-65 = 3 309 o, base64 ≈ 4,4 Ko | Revue de schéma |
| Tampon réseau de taille fixe, MTU supposé | Handshakes multi-segments | Tests de charge, fuzzing |
| Épinglage de clé publique (*pinning*) dans les applis mobiles | Rotation impossible sans nouvelle version de l'appli | Revue mobile |
| Bibliothèque crypto embarquée et figée (OpenSSL vendored) | Pas de mise à jour via le système | SCA |
| Dépendance à un DH statique | Pas d'équivalent KEM direct | Revue de conception |
| Certificats à durée de vie de 5 ans et plus | Rotation lente et risquée | Inventaire PKI |

## Modèles d'hybridation par protocole

| Protocole | Mécanisme hybride | Maturité fin 2026 |
|---|---|---|
| TLS 1.3 | Groupe `X25519MLKEM768` / `SecP256r1MLKEM768` / `SecP384r1MLKEM1024` | :material-check-circle:{ .statut-ok } Large déploiement (navigateurs, CDN, OpenSSL 3.5+, Go, BoringSSL, rustls) |
| SSH | `mlkem768x25519-sha256`, `sntrup761x25519-sha512` | :material-check-circle:{ .statut-ok } Par défaut dans OpenSSH 10 |
| IKEv2 / IPsec | Échanges de clés additionnels (RFC 9370) + ML-KEM | :material-alert:{ .statut-warn } strongSwan 6 ; support constructeurs hétérogène |
| X.509 | ML-DSA, certificats composites | :material-alert:{ .statut-warn } Bibliothèques prêtes ; navigateurs et CA publiques pas encore |
| S/MIME, CMS | ML-KEM et ML-DSA dans CMS | :material-alert:{ .statut-warn } Émergent |
| Paiement (TR-34, EMV) | — | :material-close-circle:{ .statut-ko } Normes sectorielles en cours |
