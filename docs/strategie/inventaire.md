# Inventaire cryptographique et CBOM

> On ne migre pas ce qu'on ne voit pas.

## Quatre sources complémentaires

Aucune méthode ne suffit seule. Il faut croiser :

| Source | Ce qu'elle révèle | Angle mort |
|---|---|---|
| **Scan réseau actif** | Protocoles, suites, groupes, certificats réellement exposés | Flux non joignables depuis le point de scan, chiffrement applicatif |
| **Capture passive** (miroir de port, sondes NDR) | Ce qui est réellement **négocié** en production, clients compris | Volume, confidentialité des captures, trafic intra-hôte |
| **Analyse statique du code et des dépendances** | Appels crypto, bibliothèques, algorithmes codés en dur | Configuration à l'exécution, binaires tiers |
| **Inventaire déclaratif** (PKI, HSM, CMDB, fournisseurs) | Clés, certificats, contrats, produits sur étagère | Fiabilité dépendant de la qualité des données |

## Scan réseau

Le script [`scripts/pqc-tls-scan.sh`](https://github.com/Maalshekto/pqc-ops/blob/main/scripts/pqc-tls-scan.sh) du dépôt teste, pour une liste de cibles, la version TLS négociée, le groupe d'échange de clés et la prise en charge de `X25519MLKEM768`, et produit un CSV.

```bash
# Prérequis : OpenSSL >= 3.5
./scripts/pqc-tls-scan.sh cibles.txt > inventaire-tls.csv
```

Pour un inventaire plus large des suites et des certificats :

```bash
# testssl.sh : protocoles, suites, groupes, chaîne de certificats, en JSON
testssl.sh --jsonfile-pretty resultats.json --severity LOW https://appli.interne.banque.example

# nmap : balayage d'une plage, uniquement sur périmètre autorisé
nmap -p 443,8443,636,993,5671 --script ssl-enum-ciphers,ssl-cert -oX tls.xml 10.20.0.0/24

# SSH : algorithmes d'échange de clés proposés par le serveur
ssh-audit bastion.interne.banque.example
```

!!! danger "Habilitation"
    Un scan actif sur un SI bancaire est une **opération sensible** : il peut déclencher le SOC, perturber des équipements anciens (TPE, automates, mainframes) ou violer un contrat d'infogérance. Toujours : ordre de mission écrit, périmètre IP précis, fenêtre horaire, information préalable du SOC et des exploitants. Voir [Gouvernance et habilitation](../banque/gouvernance.md).

## Capture passive

Extraire les groupes proposés par les clients et ceux choisis par les serveurs dans une capture :

```bash
# Groupes négociés (ServerHello) — 0x11ec = X25519MLKEM768, 0x001d = x25519, 0x0017 = secp256r1
tshark -r capture.pcapng -Y "tls.handshake.type == 2" \
  -T fields -e ip.src -e tls.handshake.extensions_key_share_group \
  | sort | uniq -c | sort -rn
```

En production, privilégiez les métadonnées fournies par vos sondes NDR ou par les journaux des terminaisons TLS (voir [Supervision](../devsecops/supervision.md)) plutôt que des captures complètes.

## Analyse du code

- **Semgrep** avec des règles ciblant les API cryptographiques (exemples dans [Pipeline CI/CD](../devsecops/pipeline.md)) ;
- **CBOMkit / sonar-cryptography** (IBM, open source) : détection des usages crypto en Java et Python et génération de CBOM ;
- **SCA** classique : versions d'OpenSSL, BouncyCastle, Go, JDK — un composant récent est souvent la condition préalable à PQC.

## Le format CBOM

CycloneDX (depuis la version 1.6) définit un type de composant `cryptographic-asset` qui décrit algorithmes, protocoles, certificats et clés, et les relie aux composants qui les utilisent.

```json
{
  "bomFormat": "CycloneDX",
  "specVersion": "1.6",
  "components": [
    {
      "type": "cryptographic-asset",
      "bom-ref": "crypto/protocol/tls13@api-paiement",
      "name": "TLS 1.3 — api-paiement.banque.example:443",
      "cryptoProperties": {
        "assetType": "protocol",
        "protocolProperties": {
          "type": "tls",
          "version": "1.3",
          "cipherSuites": [
            { "name": "TLS_AES_256_GCM_SHA384", "identifiers": ["0x13", "0x02"] }
          ]
        },
        "oid": "1.3.6.1.5.5.7.3.1"
      }
    },
    {
      "type": "cryptographic-asset",
      "bom-ref": "crypto/algorithm/x25519mlkem768",
      "name": "X25519MLKEM768",
      "cryptoProperties": {
        "assetType": "algorithm",
        "algorithmProperties": {
          "primitive": "kem",
          "parameterSetIdentifier": "768",
          "nistQuantumSecurityLevel": 3,
          "cryptoFunctions": ["encapsulate", "decapsulate"]
        }
      }
    }
  ]
}
```

## Attributs minimaux par actif

Pour pouvoir prioriser, chaque entrée de l'inventaire doit porter, au-delà de la technique :

- [x] Application / service et **propriétaire métier**
- [x] Exposition : Internet, partenaires, interne, intra-datacenter
- [x] **Classification** et **durée de confidentialité** des données transportées
- [x] Algorithmes : échange de clés, signature, chiffrement symétrique, hachage
- [x] Bibliothèque / produit et version, fournisseur
- [x] Emplacement des clés (fichier, HSM, KMS cloud) et durée de vie des certificats
- [x] Capacité de changement : configuration, mise à jour, développement, remplacement matériel
