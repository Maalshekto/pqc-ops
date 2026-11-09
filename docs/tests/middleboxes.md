# Middleboxes et MTU

C'est **le** sujet à risque d'une migration TLS hybride. L'expérience des déploiements à grande échelle (navigateurs, CDN) a montré que certains équipements intermédiaires rompent la connexion lorsque le ClientHello ne tient plus dans un seul segment TCP.

## Pourquoi le ClientHello grossit

| ClientHello | Taille typique |
|---|---|
| Classique (X25519 seul) | ~250 à 600 o |
| Hybride `X25519MLKEM768` + X25519 | **~1 500 à 1 900 o** |

Au-delà d'environ 1 400 o de charge utile TCP (MSS courant), le ClientHello est **découpé en au moins deux segments TCP**. Avec un MTU réduit (tunnels), le découpage est encore plus marqué.

## Défaillances observées

| Symptôme | Cause probable |
|---|---|
| Connexion qui reste bloquée puis expire | L'équipement attend un ClientHello complet dans le premier paquet et ne transmet pas le reste (bogue de réassemblage) |
| `RST` immédiat après le ClientHello | Signature IDS/IPS ou WAF interprétant le ClientHello tronqué comme malformé |
| Échec uniquement depuis certains sites | MTU / PMTUD cassé (ICMP *fragmentation needed* filtré) sur un chemin particulier |
| Échec uniquement en HTTP/3 | Pare-feu limitant la taille des datagrammes UDP ou n'acceptant pas un Initial QUIC sur plusieurs datagrammes |
| Échec sur le flux inspecté, succès en contournement | Proxy d'inspection TLS ne prenant pas en charge les groupes hybrides **et** ne gérant pas le repli correctement |

## Inventaire des équipements à tester

- [ ] Pare-feux périmétriques et internes (inspection applicative / DPI activée)
- [ ] IDS/IPS, sondes NDR
- [ ] WAF (appliance et cloud)
- [ ] Proxies sortants avec **déchiffrement TLS** (poste de travail, serveurs)
- [ ] Répartiteurs de charge (mode L4 et L7)
- [ ] Protections anti-DDoS, CDN
- [ ] Passerelles API, passerelles B2B
- [ ] Équipements DLP
- [ ] Optimiseurs WAN, SD-WAN

!!! warning "Proxies d'inspection TLS"
    Un proxy qui déchiffre le trafic **termine** le TLS : la session entre le client et le proxy, puis entre le proxy et le serveur, n'est hybride que si le **proxy** le prend en charge des deux côtés. Un proxy non compatible dégrade silencieusement toute la chaîne en classique. C'est un point à vérifier explicitement et à inscrire dans le CBOM.

## Méthode de test

```bash
# 1. Référence : connexion directe (sans l'équipement), hybride
openssl s_client -connect cible-directe:443 -groups X25519MLKEM768 -brief </dev/null

# 2. Même test à travers l'équipement
openssl s_client -connect cible-via-equipement:443 -groups X25519MLKEM768 -brief </dev/null

# 3. Forcer un ClientHello très fragmenté (MTU réduit côté client)
sudo ip link set dev eth0 mtu 576
openssl s_client -connect cible-via-equipement:443 -groups X25519MLKEM768 -brief </dev/null
sudo ip link set dev eth0 mtu 1500

# 4. Vérifier la découverte du MTU (PMTUD) : ICMP "frag needed" doit passer
ping -M do -s 1472 cible-via-equipement   # 1472 + 28 = 1500
ping -M do -s 1400 cible-via-equipement
```

**Capturer des deux côtés de l'équipement** (avant / après) et comparer : nombre de segments, retransmissions, présence du ServerHello, éventuels `RST` émis par l'équipement lui-même (TTL ou adresse MAC différents de ceux du serveur).

## Remédiations

1. **Mise à jour** du logiciel de l'équipement (la plupart des constructeurs ont corrigé ces défauts) ;
2. **Désactivation ciblée** de la règle d'inspection fautive, documentée et validée par la sécurité ;
3. **Correction PMTUD** : laisser passer ICMP type 3 code 4 (IPv4) et ICMPv6 type 2 ; *MSS clamping* sur les tunnels ;
4. En dernier recours et temporairement : profil de repli classique pour le flux concerné, **tracé comme une exception** avec date d'échéance.
