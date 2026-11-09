# SSH

SSH est le cas le plus simple : l'échange de clés hybride est **activé par défaut** dans OpenSSH depuis la version 9.0 (`sntrup761x25519-sha512`) et la version 10.0 (`mlkem768x25519-sha256` par défaut). Le travail consiste surtout à **retrouver les clients et serveurs anciens**, et les équipements à SSH embarqué (commutateurs, appliances, mainframes, SFTP partenaires).

## Configuration serveur

```text
# /etc/ssh/sshd_config.d/10-pqc.conf
KexAlgorithms mlkem768x25519-sha256,sntrup761x25519-sha512,curve25519-sha256
```

Pour **exiger** le post-quantique (bastions, environnements sensibles) une fois l'inventaire des clients réalisé, retirer `curve25519-sha256`.

## Configuration client

```text
# ~/.ssh/config ou /etc/ssh/ssh_config.d/10-pqc.conf
Host *.banque.example
    KexAlgorithms mlkem768x25519-sha256,sntrup761x25519-sha512
```

Les versions récentes d'OpenSSH (10.1+) **avertissent** l'utilisateur lorsqu'une connexion n'utilise pas d'échange de clés post-quantique : c'est un bon indicateur pour repérer les serveurs restants.

## Audit

```bash
# Algorithmes négociés pour une connexion
ssh -v admin@serveur.banque.example 2>&1 | grep "kex: algorithm"
# debug1: kex: algorithm: mlkem768x25519-sha256

# Audit d'un parc
for h in $(cat serveurs-ssh.txt); do
  printf '%s;' "$h"
  ssh-keyscan -T 3 "$h" >/dev/null 2>&1 && \
  ssh -o BatchMode=yes -o ConnectTimeout=3 -v "$h" true 2>&1 \
    | awk '/kex: algorithm:/ {print $NF; exit}'
done
```

`ssh-audit` donne une vue plus complète (algorithmes proposés, versions, recommandations).

## Clés d'hôte et clés utilisateur

Les **signatures** SSH (clés d'hôte, clés utilisateur, certificats SSH) restent en Ed25519/ECDSA/RSA : il n'y a pas encore de standard PQC largement déployé pour l'authentification SSH. Ce n'est pas une urgence HNDL (l'authentification n'est pas rétroactivement exploitable). À suivre pour la vague « signatures ».

## Pièges

- **Bibliothèques SSH tierces** (libssh, Paramiko, JSch, Apache MINA SSHD, Go `x/crypto/ssh`) : le support PQC arrive avec retard. Les outils d'automatisation (Ansible, outils de transfert de fichiers, ordonnanceurs) en dépendent.
- **Équipements réseau** : l'accès SSH aux commutateurs et routeurs est souvent le dernier à migrer — dépendance constructeur.
- **SFTP partenaires** : nombreux serveurs tiers anciens. À inventorier et à intégrer dans les exigences contractuelles.
