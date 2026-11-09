# Flux de paiement et HSM

Le paiement est le domaine où la banque a **le moins de latitude** : algorithmes, formats et équipements sont fixés par des normes de place (ISO TC68, ANSI X9, EMVCo, PCI PIN/PTS, schémas de cartes) et par des HSM certifiés. La stratégie est d'**anticiper et d'exiger**, pas de bricoler.

## Bonne nouvelle : le cœur est symétrique

Une grande partie de la cryptographie des paiements est **symétrique** :

| Usage | Cryptographie | Statut PQC |
|---|---|---|
| Chiffrement du PIN (blocs PIN) | 3DES (format 0, héritage), **AES** (format ISO 4) | Migrer vers AES — exigence déjà existante, indépendante du quantique |
| Cryptogrammes EMV (ARQC/ARPC) | 3DES / AES, clés dérivées | Symétrique : pas de rupture quantique |
| MAC des messages | 3DES / AES CMAC, HMAC | Préférer AES-256 |
| Hiérarchies de clés (DUKPT AES, clés de zone) | Symétrique | Préférer AES-256 |
| Échange de clés entre HSM (**TR-31** — key blocks) | Symétrique | Sûr |

## Les points durs asymétriques

| Usage | Cryptographie actuelle | Enjeu PQC |
|---|---|---|
| **Distribution de clés à distance (TR-34)** | RSA | Vulnérable ; c'est par ce biais qu'on charge des clés symétriques dans les terminaux et HSM — risque HNDL réel si les échanges sont capturés |
| **Authentification de carte hors ligne EMV** (SDA/DDA/CDA) | RSA, hiérarchie de CA des schémas | Dépend d'EMVCo et des schémas ; travaux en cours (y compris sur ECC puis PQC) ; contraintes fortes des puces |
| Remote key loading des TPE / DAB | RSA | Dépend des constructeurs et de TR-34 |
| Paiement mobile, tokenisation | ECC / RSA selon les acteurs | Dépendance aux wallets et aux TSP |
| **Messagerie interbancaire** (réseaux de place, SWIFT) | PKI propre, TLS, HSM | Suivre les feuilles de route des opérateurs |
| Virements instantanés, API DSP2 | TLS, eIDAS (QWAC, QSealC) | TLS hybride faisable ; certificats eIDAS dépendants des QTSP |

## Plan d'action spécifique

1. **Cartographier** chaque flux paiement : protocole de transport, gestion des clés, HSM, norme applicable ;
2. **Éliminer le 3DES résiduel** (blocs PIN format 0, clés double longueur) : c'est une dette déjà dénoncée, qui simplifie la suite ;
3. **Protéger le transport** : les flux paiement circulent sur TLS ou IPsec ; l'**hybridation de la couche transport** apporte une protection HNDL immédiate, même si la cryptographie applicative reste classique ;
4. **HSM de paiement** : obtenir des constructeurs une feuille de route écrite (firmware PQC, certification PCI PTS HSM, prise en charge des futures variantes de TR-34) ;
5. **Participer** aux groupes de travail de place et suivre EMVCo, PCI SSC, ISO TC68, X9 ;
6. **Contractualiser** : clauses PQC dans les contrats processeurs, schémas, prestataires de monétique.

!!! warning "Ne pas casser la certification"
    Toute modification d'un environnement certifié (PCI PIN, PCI PTS HSM, homologations des schémas) doit passer par le processus de changement et, si nécessaire, de re-certification. Les tests PQC sur ces environnements se font **exclusivement en laboratoire ou en environnement de certification**, jamais en production.
