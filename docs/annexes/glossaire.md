# Glossaire

CBOM
:   *Cryptography Bill of Materials*. Inventaire des actifs cryptographiques (algorithmes, protocoles, clés, certificats) et de leurs liens avec les composants, formalisé notamment par CycloneDX 1.6+.

Crypto-agilité
:   Capacité d'un système à changer d'algorithme ou de paramètres cryptographiques sans refonte et sans interruption de service.

CRQC
:   *Cryptographically Relevant Quantum Computer*. Ordinateur quantique tolérant aux fautes capable de casser RSA et ECC de tailles réelles.

Hybridation
:   Combinaison d'un algorithme classique et d'un algorithme post-quantique de sorte que la sécurité soit préservée si l'un des deux reste sûr.

HNDL
:   *Harvest Now, Decrypt Later*. Collecte de données chiffrées aujourd'hui en vue de leur déchiffrement par un CRQC futur.

HelloRetryRequest (HRR)
:   Message TLS 1.3 par lequel le serveur demande au client de renvoyer un ClientHello avec une *key share* pour un autre groupe ; coûte un aller-retour.

KEM
:   *Key Encapsulation Mechanism*. Primitive permettant d'établir un secret partagé : une partie génère une paire de clés, l'autre encapsule un secret avec la clé publique.

Key share
:   Extension TLS 1.3 portant la contribution d'une partie à l'échange de clés pour un groupe donné.

Middlebox
:   Équipement intermédiaire sur le chemin réseau (pare-feu, IPS, proxy, répartiteur de charge, WAF) susceptible d'inspecter ou de modifier le trafic.

ML-KEM / ML-DSA / SLH-DSA
:   Algorithmes standardisés par le NIST dans les FIPS 203, 204 et 205.

PPK
:   *Postquantum Preshared Key* (RFC 8784). Clé symétrique pré-partagée mélangée à la dérivation de clés IKEv2 pour la rendre résistante au quantique.

PMTUD
:   *Path MTU Discovery*. Mécanisme de découverte de la taille maximale de paquet sur un chemin, reposant sur des messages ICMP.

Signature avec état
:   Schéma de signature (LMS, XMSS) dont la clé privée évolue à chaque signature ; la réutilisation d'un état compromet la sécurité.
