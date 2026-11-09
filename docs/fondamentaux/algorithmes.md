# Algorithmes standardisés

## Vue d'ensemble

| Standard | Algorithme | Famille | Fonction | Statut |
|---|---|---|---|---|
| **FIPS 203** | ML-KEM (ex-Kyber) | Réseaux euclidiens (Module-LWE) | Encapsulation de clé | Publié (août 2024) |
| **FIPS 204** | ML-DSA (ex-Dilithium) | Réseaux euclidiens (Module-LWE/SIS) | Signature | Publié (août 2024) |
| **FIPS 205** | SLH-DSA (ex-SPHINCS+) | Hachage, sans état | Signature | Publié (août 2024) |
| **FIPS 206** | FN-DSA (ex-Falcon) | Réseaux NTRU | Signature compacte | En cours de finalisation — vérifier le statut |
| *(à venir)* | HQC | Codes correcteurs | KEM de secours, diversité mathématique | Sélectionné en mars 2025, standard attendu ~2027 |
| **SP 800-208** | LMS / XMSS | Hachage, **avec état** | Signature (firmware, code) | Publié (2020) |

## ML-KEM — l'échange de clés

| Paramètre | Catégorie NIST | Clé publique | Chiffré | Secret partagé |
|---|---|---|---|---|
| ML-KEM-512 | 1 (≈ AES-128) | 800 o | 768 o | 32 o |
| **ML-KEM-768** | 3 (≈ AES-192) | 1 184 o | 1 088 o | 32 o |
| ML-KEM-1024 | 5 (≈ AES-256) | 1 568 o | 1 568 o | 32 o |

*À comparer : X25519 = 32 o de clé publique.*

- **ML-KEM-768** est le choix par défaut de l'écosystème TLS (groupe hybride `X25519MLKEM768`).
- **ML-KEM-1024** est exigé par CNSA 2.0 (NSA) et préféré par l'ANSSI pour les usages les plus sensibles ; il existe en TLS via `SecP384r1MLKEM1024`.
- ML-KEM est **très rapide** (souvent plus que ECDH) : le coût est dans la **taille**, pas dans le CPU.

!!! warning "Un KEM n'est pas un Diffie-Hellman"
    Un KEM est asymétrique dans son usage : l'un génère une paire de clés, l'autre encapsule. Il n'existe pas d'équivalent direct à un DH statique-statique. Les protocoles construits sur DH statique (certaines variantes de Noise, de l'authentification implicite, ou des schémas « DH sur clé de certificat ») doivent être **repensés**, pas simplement recâblés.

## ML-DSA — la signature généraliste

| Paramètre | Catégorie | Clé publique | Signature |
|---|---|---|---|
| ML-DSA-44 | 2 | 1 312 o | 2 420 o |
| **ML-DSA-65** | 3 | 1 952 o | 3 309 o |
| ML-DSA-87 | 5 | 2 592 o | 4 627 o |

*À comparer : ECDSA P-256 = 64 o de clé publique, ~72 o de signature.*

Conséquence directe : une chaîne de certificats TLS (feuille + intermédiaire, avec signatures et SCT) passe de ~3 Ko à **15–20 Ko** en ML-DSA. Cela a des effets mesurables sur le *handshake*, la fenêtre de congestion TCP initiale et les équipements qui inspectent ou mettent en tampon le trafic. Voir [Performance](../tests/performance.md).

## SLH-DSA — la signature conservatrice

Repose uniquement sur la sécurité des fonctions de hachage : c'est l'hypothèse la plus solide. Contreparties : signatures de **7,8 Ko** (variante `128s`, lente à signer) à **~50 Ko** (`256f`). Usage typique : **racines de confiance**, CA hors ligne, signature d'artefacts critiques rarement vérifiés.

## LMS / XMSS — signatures avec état

Très bien adaptées à la **signature de firmware et de code** (recommandées par CNSA 2.0 dans ce cas), mais l'état (compteur d'utilisation des clés) **ne doit jamais être réutilisé** : une restauration de sauvegarde d'un HSM, une réplication active-active ou un rollback de VM peut entraîner la réutilisation d'une clé one-time et compromettre totalement la sécurité. À n'utiliser qu'avec un HSM qui gère l'état nativement.

## Hybridation

En période de transition, on **combine** un algorithme classique et un algorithme PQC de façon à ce que le résultat soit sûr si **au moins l'un** des deux l'est.

=== "Échange de clés hybride"

    Les deux secrets partagés sont concaténés puis passés dans une KDF :

    ```text
    ss = KDF( ss_MLKEM768 || ss_X25519 )
    ```

    En TLS 1.3, c'est le groupe `X25519MLKEM768` (codepoint `0x11EC`) : la *key share* du client contient la clé publique ML-KEM (1 184 o) suivie de la clé X25519 (32 o).

=== "Signature hybride / composite"

    Deux approches coexistent :

    - **Composite** : une seule clé et une seule signature encapsulent ML-DSA + ECDSA/RSA (drafts IETF LAMPS `composite-sigs`). Transparent pour le protocole, mais requiert un support explicite partout.
    - **Double certificat / double signature** : deux chaînes parallèles. Plus simple à introduire progressivement, plus lourd à opérer.

!!! tip "Règle pratique"
    Hybride **systématique** pour l'échange de clés. Pour les signatures, hybride ou ML-DSA seul selon la position de votre autorité de tutelle et la maturité de l'écosystème du flux concerné.
