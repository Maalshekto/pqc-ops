# Réseaux euclidiens et LWE

> **Objectif** : comprendre ce qu'est un réseau euclidien, pourquoi certains problèmes y sont difficiles même pour un ordinateur quantique, comment le problème LWE (*Learning With Errors*) permet de chiffrer, et comment ML-KEM assemble tout cela.
>
> **Prérequis** : les trois pages précédentes, en particulier la notion d'élément « petit » (représentant centré, voir [Arithmétique modulaire](arithmetique-modulaire.md#deux-facons-de-representer-un-element)).
>
> **Dans pqc-javacard** : suite du jalon 2 (génération de clés, encapsulation, décapsulation de ML-KEM-768).

## 1. Les réseaux euclidiens

### Définition

Un **réseau** (*lattice*) de dimension $n$ est l'ensemble des combinaisons linéaires **à coefficients entiers** de $n$ vecteurs indépendants $\mathbf{b}_1, \dots, \mathbf{b}_n$ de $\mathbb{R}^n$, qui forment une **base** du réseau :

$$
\mathcal{L}(\mathbf{b}_1, \dots, \mathbf{b}_n) = \left\{ \sum_{i=1}^{n} x_i \mathbf{b}_i \;:\; x_i \in \mathbb{Z} \right\}
$$

C'est une grille régulière de points, éventuellement inclinée. Point essentiel : **un même réseau a une infinité de bases**. Dans le schéma ci-dessous, la base courte $(\mathbf{g}_1, \mathbf{g}_2)$ (traits pleins) et la base longue $(\mathbf{b}_1, \mathbf{b}_2)$ (pointillés) engendrent exactement les mêmes points, car $\mathbf{b}_1 = \mathbf{g}_1 + \mathbf{g}_2$ et $\mathbf{b}_2 = 2\mathbf{g}_1 + \mathbf{g}_2$, et la transformation est inversible sur les entiers (son déterminant vaut $-1$).

<figure markdown>
<svg viewBox="0 0 480 300" width="100%" style="max-width:480px" role="img" aria-label="Réseau en deux dimensions avec une bonne base courte et une mauvaise base longue engendrant les mêmes points">
<defs><marker id="fl-a" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="6" markerHeight="6" orient="auto"><path d="M0,0L10,5L0,10z" style="fill:var(--md-primary-fg-color)"/></marker>
<marker id="fl-b" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="6" markerHeight="6" orient="auto"><path d="M0,0L10,5L0,10z" style="fill:var(--md-accent-fg-color)"/></marker></defs>
<circle cx="30" cy="70" r="3" fill="currentColor" opacity="0.55"/>
<circle cx="30" cy="190" r="3" fill="currentColor" opacity="0.55"/>
<circle cx="54" cy="22" r="3" fill="currentColor" opacity="0.55"/>
<circle cx="54" cy="142" r="3" fill="currentColor" opacity="0.55"/>
<circle cx="54" cy="262" r="3" fill="currentColor" opacity="0.55"/>
<circle cx="78" cy="94" r="3" fill="currentColor" opacity="0.55"/>
<circle cx="78" cy="214" r="3" fill="currentColor" opacity="0.55"/>
<circle cx="102" cy="46" r="3" fill="currentColor" opacity="0.55"/>
<circle cx="102" cy="166" r="3" fill="currentColor" opacity="0.55"/>
<circle cx="102" cy="286" r="3" fill="currentColor" opacity="0.55"/>
<circle cx="126" cy="118" r="3" fill="currentColor" opacity="0.55"/>
<circle cx="126" cy="238" r="3" fill="currentColor" opacity="0.55"/>
<circle cx="150" cy="70" r="3" fill="currentColor" opacity="0.55"/>
<circle cx="150" cy="190" r="3" fill="currentColor" opacity="0.55"/>
<circle cx="174" cy="22" r="3" fill="currentColor" opacity="0.55"/>
<circle cx="174" cy="142" r="3" fill="currentColor" opacity="0.55"/>
<circle cx="174" cy="262" r="3" fill="currentColor" opacity="0.55"/>
<circle cx="198" cy="94" r="3" fill="currentColor" opacity="0.55"/>
<circle cx="198" cy="214" r="3" fill="currentColor" opacity="0.55"/>
<circle cx="222" cy="46" r="3" fill="currentColor" opacity="0.55"/>
<circle cx="222" cy="166" r="3" fill="currentColor" opacity="0.55"/>
<circle cx="222" cy="286" r="3" fill="currentColor" opacity="0.55"/>
<circle cx="246" cy="118" r="3" fill="currentColor" opacity="0.55"/>
<circle cx="246" cy="238" r="3" fill="currentColor" opacity="0.55"/>
<circle cx="270" cy="70" r="3" fill="currentColor" opacity="0.55"/>
<circle cx="270" cy="190" r="3" fill="currentColor" opacity="0.55"/>
<circle cx="294" cy="22" r="3" fill="currentColor" opacity="0.55"/>
<circle cx="294" cy="142" r="3" fill="currentColor" opacity="0.55"/>
<circle cx="294" cy="262" r="3" fill="currentColor" opacity="0.55"/>
<circle cx="318" cy="94" r="3" fill="currentColor" opacity="0.55"/>
<circle cx="318" cy="214" r="3" fill="currentColor" opacity="0.55"/>
<circle cx="342" cy="46" r="3" fill="currentColor" opacity="0.55"/>
<circle cx="342" cy="166" r="3" fill="currentColor" opacity="0.55"/>
<circle cx="342" cy="286" r="3" fill="currentColor" opacity="0.55"/>
<circle cx="366" cy="118" r="3" fill="currentColor" opacity="0.55"/>
<circle cx="366" cy="238" r="3" fill="currentColor" opacity="0.55"/>
<circle cx="390" cy="70" r="3" fill="currentColor" opacity="0.55"/>
<circle cx="390" cy="190" r="3" fill="currentColor" opacity="0.55"/>
<circle cx="414" cy="22" r="3" fill="currentColor" opacity="0.55"/>
<circle cx="414" cy="142" r="3" fill="currentColor" opacity="0.55"/>
<circle cx="414" cy="262" r="3" fill="currentColor" opacity="0.55"/>
<circle cx="438" cy="94" r="3" fill="currentColor" opacity="0.55"/>
<circle cx="438" cy="214" r="3" fill="currentColor" opacity="0.55"/>
<circle cx="462" cy="46" r="3" fill="currentColor" opacity="0.55"/>
<circle cx="462" cy="166" r="3" fill="currentColor" opacity="0.55"/>
<circle cx="462" cy="286" r="3" fill="currentColor" opacity="0.55"/>
<line x1="150" y1="190" x2="222" y2="166" style="stroke:var(--md-primary-fg-color)" stroke-width="2.5"  marker-end="url(#fl-a)"/>
<line x1="150" y1="190" x2="174" y2="142" style="stroke:var(--md-primary-fg-color)" stroke-width="2.5"  marker-end="url(#fl-a)"/>
<line x1="150" y1="190" x2="246" y2="118" style="stroke:var(--md-accent-fg-color)" stroke-width="2.5" stroke-dasharray="6 4" marker-end="url(#fl-b)"/>
<line x1="150" y1="190" x2="318" y2="94" style="stroke:var(--md-accent-fg-color)" stroke-width="2.5" stroke-dasharray="6 4" marker-end="url(#fl-b)"/>
<circle cx="150" cy="190" r="4.5" fill="currentColor"/>
<path d="M81.6,217.6L93.6,229.6M81.6,229.6L93.6,217.6" stroke="currentColor" stroke-width="2.5"/>
<text x="97.6" y="239.6" font-size="13" fill="currentColor">cible t</text>
<text x="228" y="180" font-size="14" font-weight="bold" style="fill:var(--md-primary-fg-color)">g₁</text>
<text x="152" y="142" font-size="14" font-weight="bold" style="fill:var(--md-primary-fg-color)">g₂</text>
<text x="238" y="110" font-size="14" font-weight="bold" style="fill:var(--md-accent-fg-color)">b₁</text>
<text x="324" y="88" font-size="14" font-weight="bold" style="fill:var(--md-accent-fg-color)">b₂</text>
</svg>
<figcaption>Un réseau de dimension 2 : une bonne base (courte, presque orthogonale) et une mauvaise base (longue, presque parallèle) des mêmes points. La croix est un point cible quelconque du plan.</figcaption>
</figure>

### Les problèmes difficiles

| Problème | Énoncé | Analogue |
|---|---|---|
| **SVP** (*Shortest Vector Problem*) | Trouver le vecteur non nul le plus court du réseau | — |
| **CVP** (*Closest Vector Problem*) | Étant donné un point cible $\mathbf{t}$, trouver le point du réseau le plus proche | Décoder un message bruité |
| **BDD** (*Bounded Distance Decoding*) | CVP avec la promesse que $\mathbf{t}$ est **très proche** du réseau | C'est la forme qui intéresse LWE |

En dimension 2, tout est facile : on voit la réponse sur le dessin. Mais la difficulté tient à la base dont on dispose :

- avec une **bonne base**, on résout CVP en écrivant $\mathbf{t}$ dans la base, puis en **arrondissant** les coordonnées à l'entier le plus proche (algorithme de Babai) ;
- avec une **mauvaise base**, le même arrondi donne un point du réseau éloigné de $\mathbf{t}$ : les vecteurs presque parallèles amplifient l'erreur d'arrondi.

**Transformer une mauvaise base en bonne base**, c'est la **réduction de réseau**. L'algorithme LLL (1982) le fait en temps polynomial, mais seulement avec une qualité médiocre, exponentielle en la dimension. BKZ fait mieux en résolvant SVP dans des sous-blocs de dimension $\beta$, mais son coût croît exponentiellement avec $\beta$. En dimension 2, c'est instantané. En dimension 768, la dimension effective de ML-KEM-768, tous les algorithmes connus demandent un temps astronomique.

### Et l'ordinateur quantique ?

L'algorithme de Shor casse RSA et les courbes elliptiques parce que ces problèmes cachent une **période** dans un groupe commutatif, et que la transformée de Fourier quantique la trouve efficacement. Les problèmes de réseaux n'ont pas cette structure : la meilleure approche connue (le **crible**, *sieving*) passe de $2^{0{,}292\,\beta}$ opérations en classique à environ $2^{0{,}265\,\beta}$ en quantique (Laarhoven, 2015). Le gain ressemble à celui de Grover sur la recherche exhaustive : il se compense en augmentant un peu les paramètres.

!!! warning "Une hypothèse, pas une preuve"
    Personne ne sait **prouver** qu'aucun algorithme quantique efficace n'existe pour ces problèmes. C'est une hypothèse étudiée depuis plus de 25 ans. En avril 2024, Yilei Chen a annoncé un algorithme quantique polynomial pour LWE. Une erreur y a été trouvée en une dizaine de jours, et l'annonce a été retirée. L'épisode montre que la confiance repose sur l'examen de la communauté, d'où l'intérêt de l'**agilité cryptographique** et des modes **hybrides** (ML-KEM + X25519) pendant la transition.

## 2. Le problème LWE

### Sans bruit : un système linéaire facile

On choisit un secret $\mathbf{s} \in \mathbb{Z}_q^n$ et on publie des équations linéaires aléatoires $\mathbf{b} = \mathbf{A}\mathbf{s} \bmod q$, avec $\mathbf{A}$ une matrice aléatoire $m \times n$. Retrouver $\mathbf{s}$, c'est résoudre un système linéaire : le **pivot de Gauss** le fait en $O(n^3)$ opérations. Ce problème n'a aucun intérêt cryptographique.

### Avec un petit bruit : un problème difficile

**LWE** (Regev, 2005) ajoute à chaque équation une **petite erreur** $e_i$ :

$$
\mathbf{b} = \mathbf{A}\mathbf{s} + \mathbf{e} \pmod q, \qquad \mathbf{e} \text{ petit}
$$

- **LWE-recherche** : étant donné $(\mathbf{A}, \mathbf{b})$, retrouver $\mathbf{s}$.
- **LWE-décision** : distinguer $(\mathbf{A}, \mathbf{b})$ d'un couple $(\mathbf{A}, \mathbf{u})$ où $\mathbf{u}$ est **uniformément aléatoire**. C'est cette forme qui sert à prouver la sécurité : un chiffré LWE est indiscernable de bruit pur.

**Pourquoi le bruit change tout** : le pivot de Gauss combine des équations, en les multipliant par des coefficients quelconques de $\mathbb{Z}_q$. À chaque combinaison, les erreurs sont multipliées et additionnées. Après quelques étapes, l'erreur accumulée couvre tout $\mathbb{Z}_q$ et le résultat n'a plus aucun sens.

**Le lien avec les réseaux** : les vecteurs $\mathbf{A}\mathbf{x} \bmod q$, pour $\mathbf{x}$ entier, forment un réseau (dit « $q$-aire »). $\mathbf{A}\mathbf{s}$ en est un point, et $\mathbf{b} = \mathbf{A}\mathbf{s} + \mathbf{e}$ est un point **très proche** de ce réseau. Retrouver $\mathbf{s}$, c'est résoudre **BDD**, et la seule base publique, $\mathbf{A}$, est une mauvaise base.

**La garantie théorique** : Regev a montré que résoudre LWE en moyenne, pour un $\mathbf{A}$ aléatoire, permettrait de résoudre des problèmes de réseaux **dans le pire cas**, c'est-à-dire pour **tous** les réseaux. Cette réduction « pire cas → cas moyen » est rare en cryptographie : elle signifie qu'il n'y a pas de « mauvaises clés » faciles à casser par malchance.

### Le bruit dans ML-KEM : la loi binomiale centrée

ML-KEM tire ses petits polynômes (secret, erreurs) coefficient par coefficient avec la loi **binomiale centrée** $\mathrm{CBD}_\eta$ : on tire $2\eta$ bits aléatoires, et on calcule $(a_1 + \dots + a_\eta) - (b_1 + \dots + b_\eta)$. Pour $\eta = 2$ (ML-KEM-768) :

| Valeur | −2 | −1 | 0 | 1 | 2 |
|---|---|---|---|---|---|
| Probabilité | 1/16 | 4/16 | 6/16 | 4/16 | 1/16 |

Le tirage ne demande que des bits et des additions, sans table ni rejet : il s'exécute naturellement **en temps constant**, ce qui est idéal sur une carte. Les valeurs négatives sont stockées sous leur forme canonique : $-1 \to 3328$.

## 3. Chiffrer avec LWE : le schéma de Regev

On chiffre **un bit** $m \in \{0, 1\}$. L'idée : la clé publique est une instance LWE, et le chiffrement en fabrique une autre, dont seul le détenteur de $\mathbf{s}$ peut retirer le masque.

| Étape | Calcul |
|---|---|
| **Clé privée** | $\mathbf{s}$, petit |
| **Clé publique** | $(\mathbf{A}, \mathbf{b} = \mathbf{A}\mathbf{s} + \mathbf{e})$ |
| **Chiffrement** | Tirer un petit $\mathbf{r}$ ; $\mathbf{u} = \mathbf{A}^\top \mathbf{r}$, $\;v = \langle \mathbf{b}, \mathbf{r} \rangle + m \cdot \lceil q/2 \rceil$ |
| **Déchiffrement** | $w = v - \langle \mathbf{u}, \mathbf{s} \rangle$ ; si $w$ est plus proche de $\lceil q/2 \rceil$ que de 0, alors $m = 1$ |

**Pourquoi ça marche** : on développe $w$.

$$
w = \langle \mathbf{A}\mathbf{s} + \mathbf{e}, \mathbf{r} \rangle + m \lceil q/2 \rceil - \langle \mathbf{A}^\top \mathbf{r}, \mathbf{s} \rangle = \underbrace{\langle \mathbf{e}, \mathbf{r} \rangle}_{\text{petit}} + m \lceil q/2 \rceil
$$

Les termes $\mathbf{r}^\top \mathbf{A} \mathbf{s}$ s'annulent exactement. Il reste le message, placé « loin » (à 0 ou à $q/2$), plus un **bruit petit**. Tant que $|\langle \mathbf{e}, \mathbf{r} \rangle| < q/4$, l'arrondi retrouve $m$. Sans $\mathbf{s}$, $v$ est masqué par $\langle \mathbf{b}, \mathbf{r} \rangle$, qui ressemble à de l'aléa par l'hypothèse LWE-décision.

### Un exemple complet modulo 17

On prend $q = 17$, $n = 2$, $m = 3$ équations, $\lceil q/2 \rceil = 9$.

**Génération de clés** : $\mathbf{s} = (2, 5)$ et $\mathbf{e} = (1, -1, 0)$.

$$
\mathbf{A} = \begin{pmatrix} 3 & 7 \\ 1 & 12 \\ 9 & 4 \end{pmatrix}, \qquad
\mathbf{A}\mathbf{s} = \begin{pmatrix} 41 \\ 62 \\ 38 \end{pmatrix} \equiv \begin{pmatrix} 7 \\ 11 \\ 4 \end{pmatrix}, \qquad
\mathbf{b} = \mathbf{A}\mathbf{s} + \mathbf{e} = \begin{pmatrix} 8 \\ 10 \\ 4 \end{pmatrix}
$$

**Chiffrement** avec $\mathbf{r} = (1, 0, 1)$, c'est-à-dire la somme des lignes 1 et 3 :

$$
\mathbf{u} = \mathbf{A}^\top \mathbf{r} = (3 + 9,\; 7 + 4) = (12, 11), \qquad \langle \mathbf{b}, \mathbf{r} \rangle = 8 + 4 = 12
$$

| Message | $v$ | $w = v - \langle \mathbf{u}, \mathbf{s} \rangle$ | Décodage |
|---|---|---|---|
| $m = 0$ | $12$ | $12 - 11 = 1$ | proche de 0 → **0** |
| $m = 1$ | $12 + 9 = 21 \equiv 4$ | $4 - 11 = -7 \equiv 10$ | proche de 9 → **1** |

(avec $\langle \mathbf{u}, \mathbf{s} \rangle = 24 + 55 = 79 \equiv 11$). Dans les deux cas, l'écart à la valeur attendue est $\langle \mathbf{e}, \mathbf{r} \rangle = 1 + 0 = 1$ : c'est exactement le bruit prévu par le calcul.

## 4. De LWE à ML-KEM

### Le problème des tailles : Ring-LWE et Module-LWE

Avec LWE « simple », la matrice $\mathbf{A}$ compte $n^2$ éléments : pour $n = 768$, cela fait des centaines de kilo-octets. La solution consiste à donner une **structure** à $\mathbf{A}$ :

| Variante | Objets | Taille de $\mathbf{A}$ |
|---|---|---|
| **LWE** (Regev, 2005) | Vecteurs de $\mathbb{Z}_q^n$ | $n^2$ entiers |
| **Ring-LWE** (Lyubashevsky, Peikert, Regev, 2010) | Un polynôme de $R_q$ : la multiplication par $a$ est une matrice $n \times n$ « négacyclique », décrite par ses $n$ coefficients | $n$ entiers |
| **Module-LWE** (Langlois, Stehlé, 2015) | Matrice $k \times k$ de polynômes de $R_q$ | $k^2 n$ entiers |

**ML-KEM** est **M**odule-**L**attice : avec $n = 256$ et $k = 3$, on travaille en dimension effective $k \times n = 768$. Le paramètre $k$ règle la sécurité **sans changer l'arithmétique** : la même NTT et le même $R_q$ servent pour ML-KEM-512, 768 et 1024. C'est un compromis entre l'efficacité de Ring-LWE et la prudence de LWE, puisqu'on ajoute moins de structure qu'avec un seul polynôme.

### K-PKE, le cœur de ML-KEM

C'est le schéma de Regev, transposé dans $R_q^k$, avec des polynômes à la place des nombres. On note $\hat{\cdot}$ les objets en domaine NTT (voir [La NTT](ntt.md)) :

| Étape | Calcul (FIPS 203, algorithmes 13 à 15) |
|---|---|
| **Génération de clés** | $\hat{\mathbf{A}}$ dérivée d'une graine $\rho$ ; $\mathbf{s}, \mathbf{e} \leftarrow \mathrm{CBD}_{\eta_1}$ ; $\hat{\mathbf{t}} = \hat{\mathbf{A}} \circ \hat{\mathbf{s}} + \hat{\mathbf{e}}$ |
| **Chiffrement** de $m$ (256 bits) | $\mathbf{r} \leftarrow \mathrm{CBD}_{\eta_1}$, $\mathbf{e}_1, e_2 \leftarrow \mathrm{CBD}_{\eta_2}$ ; $\mathbf{u} = \mathbf{A}^\top \mathbf{r} + \mathbf{e}_1$ ; $v = \mathbf{t}^\top \mathbf{r} + e_2 + \lceil q/2 \rfloor \cdot m$ |
| **Déchiffrement** | $w = v - \mathbf{s}^\top \mathbf{u}$ ; chaque coefficient est arrondi vers 0 ou $\lceil q/2 \rfloor = 1665$ |

Le message $m$ fait 256 bits : **un bit par coefficient** du polynôme $v$. Le bruit résiduel vaut ici :

$$
w - \lceil q/2 \rfloor m = \mathbf{e}^\top \mathbf{r} + e_2 - \mathbf{s}^\top \mathbf{e}_1 \; (+ \text{erreurs de compression})
$$

Tous ces termes sont des produits de petits polynômes, et on a vu sur la page [Polynômes et anneaux](polynomes.md#3-pourquoi-x256-1) que $X^{256} + 1$ ne les fait pas exploser.

**La compression** : pour réduire le chiffré, on ne garde que les bits de poids fort des coefficients : $d_u = 10$ bits pour $\mathbf{u}$ et $d_v = 4$ bits pour $v$ (ML-KEM-768), au lieu de 12. L'arrondi ajoute un bruit supplémentaire, qui est pris en compte dans le calcul de la probabilité d'échec.

### L'échec de déchiffrement

Le bruit est aléatoire. Très rarement, un coefficient dépasse $q/4$, et le bit correspondant est mal déchiffré. FIPS 203 dimensionne les paramètres pour que cela n'arrive presque jamais :

| | ML-KEM-512 | ML-KEM-768 | ML-KEM-1024 |
|---|---|---|---|
| $k$ | 2 | 3 | 4 |
| $\eta_1$ / $\eta_2$ | 3 / 2 | 2 / 2 | 2 / 2 |
| $d_u$ / $d_v$ | 10 / 4 | 10 / 4 | 11 / 5 |
| Clé d'encapsulation | 800 o | 1 184 o | 1 568 o |
| Clé de décapsulation | 1 632 o | 2 400 o | 3 168 o |
| Chiffré | 768 o | 1 088 o | 1 568 o |
| Probabilité d'échec | $2^{-139}$ | $2^{-164}$ | $2^{-174}$ |
| Catégorie NIST | 1 (≈ AES-128) | 3 (≈ AES-192) | 5 (≈ AES-256) |

Ces échecs ne sont pas qu'un problème de fiabilité : un attaquant qui sait provoquer et observer des échecs peut en tirer de l'information sur $\mathbf{s}$. C'est l'une des raisons de l'étape suivante.

### De K-PKE à ML-KEM : la transformation de Fujisaki-Okamoto

K-PKE seul n'est sûr que contre un attaquant **passif** (IND-CPA). Un attaquant qui envoie des chiffrés **forgés** et observe les réactions pourrait retrouver la clé, coefficient par coefficient. ML-KEM ajoute donc une variante de la **transformation de Fujisaki-Okamoto** (FO) :

1. **Encapsulation** : on tire un message aléatoire $m$, on dérive de $m$ (par SHA-3) **l'aléa du chiffrement** et le secret partagé, puis on chiffre $m$ avec K-PKE. Le chiffrement devient déterministe en fonction de $m$.
2. **Décapsulation** : on déchiffre $m'$, puis on **rechiffre** $m'$ et on compare le résultat au chiffré reçu. S'ils diffèrent, on renvoie un secret **pseudo-aléatoire** dérivé d'une valeur secrète $z$ (« rejet implicite »), sans signaler d'erreur.

La comparaison et la sélection doivent se faire **en temps constant** : sinon, on reconstruit exactement l'oracle que FO devait supprimer. Plus généralement, toute opération dont la durée dépend d'une donnée secrète fait fuir la clé : en 2024, l'attaque *KyberSlash* a exploité des divisions à durée variable dans l'implémentation de référence. Toute cette mécanique repose sur SHA3 et SHAKE : c'est pour ça que le jalon 1 de pqc-javacard (Keccak) précédait ML-KEM.

## 5. Un mot sur ML-DSA

ML-DSA (FIPS 204) repose sur les mêmes fondations, avec quelques différences :

| | ML-KEM | ML-DSA |
|---|---|---|
| Module $q$ | 3329 | $8\,380\,417 = 2^{23} - 2^{13} + 1$ |
| Anneau | $\mathbb{Z}_q[X]/(X^{256} + 1)$ | Le même degré, $n = 256$ |
| NTT | Incomplète (7 niveaux) | **Complète** (8 niveaux) : $512 \mid q - 1$, avec $\zeta = 1753$ |
| Hypothèses | Module-LWE | Module-LWE et Module-SIS (trouver une **courte** combinaison nulle) |
| Principe | Chiffrement de Regev + FO | Fiat-Shamir « avec avortements » (Lyubashevsky) : une preuve de connaissance de $\mathbf{s}$, rendue non interactive par hachage |

L'idée des « avortements » : une signature $\mathbf{z} = \mathbf{y} + c\,\mathbf{s}_1$ laisserait fuir $\mathbf{s}_1$ si sa distribution dépendait du secret. Le signataire **rejette** donc et recommence tant que $\mathbf{z}$ sort d'une zone sûre, en moyenne 4 à 5 tentatives selon le niveau de sécurité. Ces boucles de durée variable sont acceptables, car le nombre de tours ne révèle rien sur la clé. Mais elles compliquent l'implémentation sur une carte (jalon 4). Le module de 23 bits oblige aussi à repenser l'arithmétique 16 bits de `ModQ`.

## Exercices

??? question "1. Dans l'exemple modulo 17, que se passe-t-il si l'on prend $\mathbf{r} = (1, 1, 1)$ pour chiffrer $m = 1$ ?"
    $\mathbf{u} = (3+1+9,\; 7+12+4) = (13, 23) \equiv (13, 6)$, $\langle \mathbf{b}, \mathbf{r} \rangle = 22 \equiv 5$, $v = 5 + 9 = 14$. $\langle \mathbf{u}, \mathbf{s} \rangle = 26 + 30 = 56 \equiv 5$. Donc $w = 14 - 5 = 9$ : le bruit $\langle \mathbf{e}, \mathbf{r} \rangle = 1 - 1 + 0 = 0$, et $m = 1$ est retrouvé exactement.

??? question "2. Avec $q = 17$, à partir de quelle valeur du bruit $|\langle \mathbf{e}, \mathbf{r} \rangle|$ le déchiffrement peut-il échouer ?"
    Le décodage compare $w$ à 0 et à 9. La frontière est à mi-chemin, vers $q/4 \approx 4{,}25$ : un bruit de 5 ou plus en valeur absolue peut inverser le bit. C'est pour garder ce bruit petit devant $q/4$ que les tirages de ML-KEM sont si concentrés ($\eta = 2$).

??? question "3. Pourquoi ne peut-on pas utiliser un secret $\mathbf{s}$ uniforme dans $\mathbb{Z}_q$ au lieu d'un petit secret ?"
    Le déchiffrement calcule $\mathbf{s}^\top \mathbf{u}$, qui fait apparaître le terme $\mathbf{s}^\top \mathbf{e}_1$. Avec un $\mathbf{s}$ uniforme, ce terme serait uniforme lui aussi : il couvrirait tout $\mathbb{Z}_q$ et masquerait le message. Le LWE classique tolère un secret uniforme (le problème reste aussi difficile), mais le chiffrement à la Regev-ML-KEM a besoin de $\mathbf{s}$ et de $\mathbf{e}_1$ petits **tous les deux**.

??? question "4. Pourquoi la matrice $\mathbf{A}$ n'est-elle jamais transmise ?"
    Elle est entièrement déterminée par la graine $\rho$ de 32 octets, via SHAKE128 : chacun la régénère. Cela économise 9 × 384 = 3 456 octets par clé publique. Cela empêche aussi le générateur des clés de choisir une matrice piégée, puisque $\mathbf{A}$ est « nothing-up-my-sleeve ».

??? question "5. Un ordinateur quantique rend-il obsolète la clé publique ML-KEM que j'enregistre aujourd'hui ?"
    Pas avec les algorithmes connus : leur gain est seulement polynomial dans l'exposant ($0{,}292 \to 0{,}265$), et il est absorbé par les paramètres. C'est la différence essentielle avec RSA et ECDH, dont les échanges enregistrés aujourd'hui seront déchiffrables (*harvest now, decrypt later*).
