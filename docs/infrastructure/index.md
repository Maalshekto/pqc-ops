# Infrastructure

Cette section décrit, protocole par protocole, **quoi changer et comment le configurer**. Les exemples supposent un pilotage par configuration versionnée (Ansible, Terraform, GitOps) : aucune modification manuelle en production.

| Couche | Priorité | Effort typique | Page |
|---|---|---|---|
| TLS en frontal Internet | :material-numeric-1-circle: | Configuration + mise à jour de bibliothèque | [TLS et reverse proxies](tls.md) |
| Accès d'administration SSH | :material-numeric-1-circle: | Mise à jour OpenSSH | [SSH](ssh.md) |
| Liens inter-sites, opérateurs | :material-numeric-1-circle: | Mise à jour constructeur, parfois matériel | [VPN IPsec](ipsec.md) |
| mTLS est-ouest | :material-numeric-2-circle: | Mise à jour du mesh | [Kubernetes et service mesh](kubernetes.md) |
| PKI et HSM | :material-numeric-3-circle: | Projet long, dépendant des fournisseurs | [PKI et HSM](pki-hsm.md) |

!!! abstract "Prérequis logiciels de référence (fin 2026)"
    | Composant | Version minimale pour ML-KEM / ML-DSA |
    |---|---|
    | OpenSSL | **3.5 LTS** (ML-KEM, ML-DSA, SLH-DSA natifs ; hybride TLS par défaut) |
    | OpenSSL < 3.5 | `oqs-provider` (Open Quantum Safe) — **laboratoire uniquement** |
    | OpenSSH | 9.9 (`mlkem768x25519-sha256`), **10.0** (par défaut) |
    | Go | 1.24 (`crypto/mlkem`, hybride TLS par défaut) |
    | Java | JDK 24 (ML-KEM, ML-DSA dans les API JCA) ; hybride TLS selon version — vérifier |
    | BouncyCastle | 1.79+ (Java), versions .NET récentes |
    | strongSwan | 6.0 (ML-KEM dans IKEv2 via RFC 9370) |
    | Navigateurs | Chrome/Edge 131+, Firefox 132+ : `X25519MLKEM768` activé |

    Toujours vérifier la **certification FIPS 140-3** des modules utilisés si elle est exigée : une bibliothèque peut prendre en charge ML-KEM avant que son module certifié ne l'inclue.
