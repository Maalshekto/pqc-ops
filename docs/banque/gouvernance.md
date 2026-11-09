# Gouvernance et habilitation

## Rôles (RACI simplifié)

| Activité | DevSecOps PQC | Architecte sécurité / crypto | Réseau / Infra | Propriétaire applicatif | RSSI | SOC |
|---|---|---|---|---|---|---|
| Politique cryptographique | C | **R** | C | I | **A** | I |
| Outillage CBOM et scans | **R/A** | C | C | I | I | I |
| Configuration TLS/SSH/IPsec | **R** | C | **R** | C | A | I |
| Tests réseau et infrastructure | **R** | C | C | C | **A** | I |
| Décision de mise en production | C | C | C | **A** | C | I |
| Exceptions à la politique | C | C | I | **R** | **A** | I |
| Détection et supervision | C | I | C | I | A | **R** |

*R : réalise, A : approuve, C : consulté, I : informé.*

## Habilitation et ordre de mission

Mener des scans et des tests sur un SI bancaire requiert une **habilitation formelle**, distincte des droits techniques. Avant toute intervention hors laboratoire :

- [ ] **Ordre de mission** signé (RSSI ou délégataire) : objectifs, périmètre IP/DNS précis, exclusions, fenêtres horaires, outils, intensité ;
- [ ] **Information du SOC** et des équipes d'exploitation, avec un canal de contact pendant l'intervention ;
- [ ] **Vérification contractuelle** pour les systèmes hébergés ou infogérés (accord du prestataire, du fournisseur cloud) ;
- [ ] **Procédure d'arrêt** immédiate en cas d'impact ;
- [ ] **Traçabilité** : poste et adresses source identifiés, journaux conservés ;
- [ ] **Protection des résultats** : un CBOM et des résultats de scans sont des documents **sensibles** (cartographie des faiblesses) — classification, chiffrement, diffusion restreinte.

!!! danger "Captures réseau"
    Les captures peuvent contenir des données personnelles et bancaires (en-têtes, métadonnées, voire données en clair sur des flux mal protégés). Elles relèvent du RGPD et du secret bancaire : finalité définie, minimisation (filtrer sur les handshakes, tronquer avec `-s`), durée de conservation courte, stockage chiffré.

## Gestion des changements

Chaque bascule suit le processus de changement de l'établissement (ITIL ou équivalent) :

1. **Demande de changement** référencée, avec analyse d'impact et plan de rollback ;
2. **Comité de changement** : présentation des résultats de tests de l'environnement précédent ;
3. **Fenêtre de déploiement** adaptée aux pics métier (pas de bascule en fin de mois, en période de paie, ni pendant les arrêtés comptables) ;
4. **Canari et surveillance renforcée**, avec critères de rollback automatiques ;
5. **Clôture** avec rapport, mise à jour du CBOM et retour d'expérience.

## Compétences

Le profil attendu combine :

- **Cryptographie appliquée** : primitives, protocoles (TLS 1.3, IKEv2, SSH), PKI, gestion des clés, compréhension des KEM et des schémas hybrides ;
- **Réseau** : TCP/IP, MTU/PMTUD, analyse de captures, comportement des équipements de sécurité ;
- **Automatisation** : IaC, CI/CD, policy as code, scripts ;
- **Contexte réglementaire** : DORA, PCI DSS, exigences ANSSI ;
- **Communication** : expliquer le risque à des métiers et à une direction, négocier avec des fournisseurs.
