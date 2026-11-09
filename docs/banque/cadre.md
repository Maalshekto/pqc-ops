# Cadre réglementaire

!!! info "Lecture"
    Aucun de ces textes n'écrit « migrez vers ML-KEM avant telle date ». Ils imposent en revanche une **gestion du risque cryptographique** et une **connaissance de ses actifs** qui rendent la préparation PQC indéfendable à ignorer devant un superviseur ou un auditeur.

## DORA — Règlement (UE) 2022/2554

Applicable depuis le **17 janvier 2025** aux entités financières de l'UE.

| Exigence | Lien avec PQC |
|---|---|
| Cadre de gestion du risque TIC (art. 5-16) | Le risque quantique est un risque TIC identifiable ; il doit figurer dans l'analyse de risques |
| Normes techniques (RTS) sur le cadre de gestion du risque TIC — politique de chiffrement et contrôles cryptographiques | Politique documentée, **gestion du cycle de vie des clés**, et mise à jour des contrôles cryptographiques en fonction de l'**évolution de la cryptanalyse** — ce qui couvre explicitement des menaces comme le quantique |
| Inventaire des actifs TIC et de leurs dépendances | Base naturelle du CBOM |
| Tests de résilience opérationnelle numérique | Intégrer les scénarios de bascule crypto et de rollback |
| Risque lié aux prestataires tiers (chapitre V) | Feuille de route PQC des fournisseurs critiques, clauses contractuelles |

## PCI DSS 4.0

- **Exigence 12.3.3** : inventaire des suites et protocoles cryptographiques utilisés, revu **au moins annuellement**, avec une **stratégie de réaction** à l'évolution des menaces (dont l'obsolescence d'algorithmes). C'est exactement ce que demande la préparation PQC.
- **Exigence 4.2.1** : cryptographie forte pour les données de titulaires en transit sur les réseaux publics.
- **Exigence 3.6 / 3.7** : gestion des clés.

## NIS 2

Les banques relevant du périmètre de DORA appliquent DORA en tant que *lex specialis*, mais NIS 2 et la feuille de route coordonnée de l'UE structurent les attentes générales en matière de cryptographie et de chaîne d'approvisionnement.

## Attentes des superviseurs

- **Feuille de route UE (2025)** : les cas d'usage **à haut risque**, dont le secteur financier, doivent être migrés **d'ici fin 2030**.
- **BCE / ACPR / ABE** : intérêt croissant pour le sujet dans les échanges de supervision et les questionnaires ; s'attendre à devoir présenter inventaire, analyse de risque et plan.
- **Instances internationales** (Comité de Bâle, Europol Quantum Safe Financial Forum, BRI) : publications appelant le secteur à s'organiser sans attendre.

## Matrice de preuves

| Preuve à produire | Livrable du programme |
|---|---|
| Inventaire cryptographique à jour | CBOM + rapport de couverture |
| Analyse de risque quantique | Matrice de [priorisation](../strategie/priorisation.md) |
| Plan de migration financé | [Feuille de route](../strategie/feuille-de-route.md) validée en comité |
| Politique cryptographique révisée | Document + règles [policy as code](../devsecops/policy-as-code.md) |
| Tests réalisés | [Rapports de tests](../tests/plan-de-tests.md) archivés |
| Maîtrise des tiers | Registre des tiers DORA + réponses PQC des fournisseurs |
