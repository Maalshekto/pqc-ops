# Mathématiques de la PQC

Cette section explique les mathématiques sur lesquelles reposent les algorithmes post-quantiques à base de **réseaux euclidiens** (ML-KEM, ML-DSA). Elle part des notions de base, sans supposer plus qu'un souvenir de l'arithmétique et des polynômes du lycée, et va jusqu'à la NTT et au problème LWE.

Elle accompagne le projet [pqc-javacard](https://github.com/Maalshekto/pqc-javacard), où chaque notion est **implémentée et testée** sur une Java Card : chaque page indique l'étape correspondante.

## Parcours

| Page | Ce qu'on y apprend | Dans pqc-javacard |
|---|---|---|
| [Arithmétique modulaire](arithmetique-modulaire.md) | Calculer modulo q, inverses, ordre d'un élément, racines de l'unité, pourquoi q = 3329 | Étape 2.1 (`ModQ`) |
| [Polynômes et anneaux](polynomes.md) | L'anneau $R_q = \mathbb{Z}_q[X]/(X^{256}+1)$, produit négacyclique, théorème des restes chinois | Étape 2.2 |
| [La NTT](ntt.md) | Multiplier deux polynômes en ≈ 3 600 multiplications au lieu de 65 536 ; le papillon ; un exemple complet à la main | Étape 2.2 (`NTT`) |
| [Réseaux euclidiens et LWE](reseaux-lwe.md) | Pourquoi ces calculs sont difficiles à inverser, même pour un ordinateur quantique ; le chiffrement de Regev ; la structure de ML-KEM | Suite du jalon 2 |

Les pages se lisent dans l'ordre : chacune s'appuie sur les précédentes.

## Notations

| Notation | Signification |
|---|---|
| $a \bmod q$ | Reste de la division de $a$ par $q$, dans $[0, q)$ |
| $a \equiv b \pmod q$ | $a$ et $b$ ont le même reste modulo $q$ ($q$ divise $a - b$) |
| $\mathbb{Z}_q$ | Les entiers modulo $q$ : $\{0, 1, \dots, q-1\}$ avec $+$ et $\times$ modulo $q$ |
| $\mathbb{Z}_q[X]$ | Les polynômes à coefficients dans $\mathbb{Z}_q$ |
| $R_q$ | $\mathbb{Z}_q[X]/(X^{256}+1)$ : polynômes de degré < 256, calculés avec $X^{256} = -1$ |
| $\zeta$ | Racine de l'unité ; dans ML-KEM, $\zeta = 17$ |
| $\hat{f}$ | Le polynôme $f$ dans le **domaine NTT** |
| $\lceil x \rfloor$ | Arrondi à l'entier le plus proche |

## Pour aller plus loin

- **FIPS 203** (ML-KEM), sections 2 à 4 : la référence normative, précise et lisible une fois ces pages assimilées.
- O. Regev, *On Lattices, Learning with Errors, Random Linear Codes, and Cryptography* (2005) : l'article fondateur de LWE.
- C. Peikert, *A Decade of Lattice Cryptography* (2016) : une synthèse exigeante mais complète.
