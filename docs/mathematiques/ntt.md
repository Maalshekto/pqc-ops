# La NTT

> **Objectif** : comprendre comment la *Number Theoretic Transform* multiplie deux polynômes de $R_q$ en environ 3 600 multiplications au lieu de 65 536, d'où viennent le papillon et les tables `ZETAS` et `GAMMAS`, et pourquoi la NTT de ML-KEM est « incomplète ».
>
> **Prérequis** : [Arithmétique modulaire](arithmetique-modulaire.md), [Polynômes et anneaux](polynomes.md).
>
> **Dans pqc-javacard** : étape 2.2, `NTT.java`.

!!! tip "Si tu fais l'étape 2.2"
    Cette page explique les mathématiques, pas le code. Elle donne les formules, mais pas leur traduction en `short` avec `ModQ` : c'est l'objet des trous A, B et C.

## 1. L'idée : changer de représentation

Un polynôme de degré $< n$ peut se représenter de deux façons :

- par ses **coefficients** $f_0, \dots, f_{n-1}$ ;
- par ses **valeurs** en $n$ points distincts $x_0, \dots, x_{n-1}$. Elles le déterminent entièrement : deux polynômes de degré $< n$ qui coïncident en $n$ points sont égaux.

Dans la représentation par valeurs, multiplier est trivial : $(a \cdot b)(x_i) = a(x_i) \cdot b(x_i)$, soit **$n$ multiplications** au lieu de $n^2$. Toute la difficulté est de passer d'une représentation à l'autre rapidement :

$$
\text{coefficients} \xrightarrow{\;\text{NTT}\;} \text{valeurs} \xrightarrow{\;\text{produit point à point}\;} \text{valeurs} \xrightarrow{\;\text{NTT}^{-1}\;} \text{coefficients}
$$

C'est exactement l'idée de la **transformée de Fourier rapide** (FFT), transposée de $\mathbb{C}$ à $\mathbb{Z}_q$. Les racines complexes de l'unité $e^{2i\pi k/n}$ y sont remplacées par des racines de l'unité modulo $q$.

### Le lien avec le théorème des restes chinois

Évaluer $f$ en $x_i$, c'est calculer $f \bmod (X - x_i)$ : le reste de la division par $X - x_i$ est la constante $f(x_i)$. Si $P = \prod_i (X - x_i)$, le théorème des restes chinois de la [page précédente](polynomes.md#4-le-theoreme-des-restes-chinois) donne :

$$
\mathbb{Z}_q[X]/(P) \;\cong\; \prod_i \mathbb{Z}_q[X]/(X - x_i) \;=\; \mathbb{Z}_q^{\,n}
$$

Il faut donc choisir pour points d'évaluation **les racines de $P = X^n + 1$**, pour que le produit point à point calcule directement le produit **négacyclique**, sans réduction supplémentaire.

## 2. Un exemple complet : la NTT « complète » modulo 17

On prend $q = 17$ et $n = 4$, avec $X^4 \equiv -1$. Les racines de $X^4 + 1$ sont les éléments $x$ tels que $x^4 = -1$, donc d'ordre 8 : ce sont des racines primitives **8ᵉ** de l'unité. Elles existent, car $8 \mid 16 = q - 1$. Avec $\psi = 2$ (d'ordre 8 : $2^4 = 16 \equiv -1$), ce sont les **puissances impaires** de $\psi$ :

$$
\psi^1 = 2, \quad \psi^3 = 8, \quad \psi^5 = 15, \quad \psi^7 = 9
$$

La factorisation se fait en deux niveaux. Comme $4^2 = 16 \equiv -1$ et $8^2 = 64 \equiv 13 \equiv -4$ :

$$
X^4 + 1 = (X^2 - 4)(X^2 + 4) = (X - 2)(X + 2)\,(X - 8)(X + 8)
$$

Avec $a = 1 + 2X + 3X^3$ et $b = 4 + X^2 + X^3$ (les polynômes de la page précédente) :

| Point $x$ | 2 | 15 | 8 | 9 |
|---|---|---|---|---|
| $a(x)$ | 12 | 7 | 6 | 13 |
| $b(x)$ | 16 | 0 | 2 | 15 |
| $a(x) \cdot b(x)$ | 5 | 0 | 12 | 8 |

Le produit négacyclique calculé à la main vaut $a \cdot b = 2 + 5X + 15X^2 + 15X^3 \pmod{17}$. On peut vérifier qu'il prend bien les valeurs $5, 0, 12, 8$ en ces quatre points : quatre multiplications ont remplacé seize.

## 3. La factorisation de $X^{256} + 1$ modulo 3329

### Le principe : couper en deux, sept fois

Pour $q = 3329$, on part de $\zeta = 17$, racine primitive **256ᵉ** de l'unité, avec $\zeta^{128} \equiv -1$. On écrit donc :

$$
X^{256} + 1 = X^{256} - \zeta^{128} = (X^{128} - \zeta^{64})(X^{128} + \zeta^{64})
$$

Puis chaque facteur se coupe à son tour, sur le modèle $X^{2k} - c^2 = (X^k - c)(X^k + c)$ :

$$
X^{128} - \zeta^{64} = (X^{64} - \zeta^{32})(X^{64} + \zeta^{32}), \qquad
X^{128} + \zeta^{64} = X^{128} - \zeta^{192} = (X^{64} - \zeta^{96})(X^{64} + \zeta^{96})
$$

On utilise $-1 = \zeta^{128}$ pour réécrire $+\zeta^{64}$ en $-\zeta^{192}$, puis on prend la « racine carrée » $\zeta^{96}$. À chaque niveau, l'exposant est divisé par 2.

```text
niveau 0                    X²⁵⁶ + 1
                         /            \
niveau 1         X¹²⁸ − ζ⁶⁴          X¹²⁸ + ζ⁶⁴
                  /      \            /       \
niveau 2   X⁶⁴ − ζ³²  X⁶⁴ + ζ³²   X⁶⁴ − ζ⁹⁶  X⁶⁴ + ζ⁹⁶
                ...                     ...
niveau 7   128 facteurs  X² − γᵢ,   γᵢ = ζ^(2·BitRev₇(i) + 1)
```

Après 7 niveaux, on obtient 128 facteurs de degré 2, $X^2 - \gamma_i$, où les $\gamma_i$ sont les 128 racines de $X^{256}+1$… au carré. On a donc :

$$
R_q \;\cong\; \prod_{i=0}^{127} \mathbb{Z}_q[X]/(X^2 - \gamma_i)
$$

La NTT de $f$ est la liste de ses 128 restes $\hat{f}_i = f \bmod (X^2 - \gamma_i)$, chacun de la forme $\hat{f}_{2i} + \hat{f}_{2i+1} X$ : on retrouve 256 coefficients.

### Pourquoi s'arrêter au degré 2 : la NTT « incomplète »

Pour descendre jusqu'au degré 1, il faudrait couper $X^2 - \gamma_i$ en $(X - \sqrt{\gamma_i})(X + \sqrt{\gamma_i})$. Comme $\gamma_i$ est une puissance **impaire** de $\zeta$, sa racine carrée serait une racine primitive **512ᵉ** de l'unité. Or $512 \nmid 3328 = 2^8 \times 13$ : elle n'existe pas (voir [Pourquoi q = 3329](arithmetique-modulaire.md#4-pourquoi-q-3329)).

La NTT de ML-KEM s'arrête donc à des polynômes de degré 1. Le produit final n'est pas un simple produit de nombres, mais un **produit de base** (*base case multiplication*, FIPS 203, algorithme 12) dans chacun des 128 petits anneaux :

$$
(a_0 + a_1 X)(b_0 + b_1 X) = a_0 b_0 + (a_0 b_1 + a_1 b_0)X + a_1 b_1 X^2 \;\equiv\; (a_0 b_0 + \gamma\, a_1 b_1) + (a_0 b_1 + a_1 b_0)X \pmod{X^2 - \gamma}
$$

Ce sont 5 multiplications modulaires par paire. Le prix de la « NTT incomplète » est donc faible.

### D'où vient l'ordre « BitRev₇ » des tables

La NTT travaille **en place** : à chaque niveau, chaque bloc de coefficients est coupé en une moitié basse et une moitié haute, avec sa propre constante $c$. Si l'on numérote les blocs de gauche à droite sur tout l'arbre (1 pour la racine, 2 et 3 pour le niveau 1, 4 à 7 pour le niveau 2, etc.), la constante du bloc $k$ vaut :

$$
c_k = \zeta^{\mathrm{BitRev}_7(k)}
$$

où $\mathrm{BitRev}_7$ inverse l'ordre des 7 bits de $k$. Par exemple, $\mathrm{BitRev}_7(1) = \mathrm{BitRev}_7(0000001_2) = 1000000_2 = 64$, puis $\mathrm{BitRev}_7(2) = 32$ et $\mathrm{BitRev}_7(3) = 96$. On retrouve les exposants de l'arbre ci-dessus. C'est pour cette raison que FIPS 203 (annexe A) stocke la table `ZETAS` dans cet ordre : la NTT la lit alors **séquentiellement**, avec un simple compteur `k++`.

| $k$ | $\mathrm{BitRev}_7(k)$ | `ZETAS[k]` $= 17^{\mathrm{BitRev}_7(k)} \bmod 3329$ |
|---|---|---|
| 1 | 64 | 1729 |
| 2 | 32 | 2580 |
| 3 | 96 | 3289 |

Les feuilles suivent la même logique : $\gamma_i = \zeta^{2\,\mathrm{BitRev}_7(i) + 1}$, ce qui donne `GAMMAS` $= 17, 3312, 2761, 568, \dots$ Elles vont par paires opposées ($3312 = -17$), puisque les deux feuilles d'un même parent sont $X^2 - \gamma$ et $X^2 + \gamma$.

## 4. Le papillon

### NTT directe : Cooley-Tukey

Le [cas $X^{2k} - c^2$](polynomes.md#le-cas-qui-nous-interesse-x2k-c2-xk-cxk-c) de la page précédente donne, pour un bloc coupé en $f_{\text{bas}}$ et $f_{\text{haut}}$ :

$$
f \bmod (X^k - c) = f_{\text{bas}} + c\, f_{\text{haut}}, \qquad f \bmod (X^k + c) = f_{\text{bas}} - c\, f_{\text{haut}}
$$

Coefficient par coefficient, c'est le **papillon de Cooley-Tukey** : une multiplication, une addition et une soustraction, avec un résultat écrit à la place des deux entrées.

```text
  f_bas[j]  ──────●──────(+)────▶  f_bas[j] + c·f_haut[j]
                   ╲    ╱
                    ╲  ╱
                     ╳
                    ╱  ╲
                   ╱    ╲
  f_haut[j] ──(×c)●──────(−)────▶  f_bas[j] − c·f_haut[j]
```

Chaque niveau compte 128 papillons, et il y a 7 niveaux : **896 multiplications** par NTT.

### NTT inverse : Gentleman-Sande

Pour remonter l'arbre, on reconstruit $(f_{\text{bas}}, f_{\text{haut}})$ à partir des deux restes $r_1 = f_{\text{bas}} + c f_{\text{haut}}$ et $r_2 = f_{\text{bas}} - c f_{\text{haut}}$ :

$$
r_1 + r_2 = 2 f_{\text{bas}}, \qquad (r_2 - r_1) \cdot \left(-c^{-1}\right) = 2 f_{\text{haut}}
$$

C'est le **papillon de Gentleman-Sande** : une somme, une différence, puis une multiplication. Deux remarques expliquent le code de `invNtt` :

- **La constante est $-c^{-1}$, pas $c$.** Comme $\zeta^{256} = 1$ et $-1 = \zeta^{128}$, on a $-\zeta^{-e} = \zeta^{128 - e}$ : c'est encore une puissance de $\zeta$, et elle se trouve **dans la même table** `ZETAS`, lue à rebours (`k--`). Par exemple, pour le premier bloc du dernier niveau, $c = \zeta^1$ et $-c^{-1} = \zeta^{127}$ = `ZETAS[127]`.
- **On ne divise pas par 2 à chaque niveau.** Chacun des 7 niveaux double le résultat ; on corrige tout à la fin, en multipliant par $2^{-7} = 128^{-1} \equiv 3303$ (`N_INV`).

## 5. Le bilan

| Opération | Multiplications modulaires |
|---|---|
| Produit naïf (convolution négacyclique) | $256^2 = 65\,536$ |
| NTT de $a$, NTT de $b$ | $2 \times 896 = 1\,792$ |
| 128 produits de base | $128 \times 5 = 640$ |
| NTT inverse + facteur $128^{-1}$ | $896 + 256 = 1\,152$ |
| **Total par la NTT** | **3 584**, soit environ 18 fois moins |

En pratique, le gain est encore plus grand. ML-KEM **génère la matrice $\mathbf{A}$ directement dans le domaine NTT** (on tire $\hat{\mathbf{A}}$ et non $\mathbf{A}$) et garde le secret $\hat{\mathbf{s}}$ sous forme NTT dans la clé privée. Pour $\mathbf{A}\mathbf{s}$ avec $k = 3$, il suffit donc de 3 NTT, de 9 × 128 produits de base et de 3 NTT inverses.

!!! note "La NTT n'est pas une option d'optimisation"
    FIPS 203 **définit** les objets en domaine NTT : la clé publique contient $\hat{\mathbf{t}}$, et la graine $\rho$ produit $\hat{\mathbf{A}}$. Une implémentation sans NTT devrait quand même les calculer pour être interopérable. C'est pourquoi les tests d'interopérabilité du jalon 3 vérifient aussi la NTT.

## 6. Retour à l'exemple miniature : une NTT incomplète modulo 5

L'exemple $\mathbb{Z}_5[X]/(X^4+1)$ de la page précédente reproduit exactement la situation de ML-KEM, en tout petit. Modulo 5, on a $X^4 + 1 = (X^2 - 2)(X^2 + 2)$, mais **2 et 3 ne sont pas des carrés** modulo 5 (les carrés sont 0, 1 et 4). La factorisation s'arrête donc au degré 2, après un seul niveau.

**1. NTT** (déjà calculée [page précédente](polynomes.md#le-cas-qui-nous-interesse-x2k-c2-xk-cxk-c)) :

| | modulo $X^2 - 2$ | modulo $X^2 + 2$ (soit $X^2 - 3$) |
|---|---|---|
| $\hat{a}$ | $1 + 3X$ | $1 + X$ |
| $\hat{b}$ | $1 + 2X$ | $2 + 3X$ |

**2. Produits de base** :

$$
(1 + 3X)(1 + 2X) = 1 + 5X + 6X^2 \equiv 1 + 0X + 6 \cdot 2 = 13 \equiv 3 \pmod{X^2 - 2,\; 5}
$$

$$
(1 + X)(2 + 3X) = 2 + 5X + 3X^2 \equiv 2 + 0X + 3 \cdot 3 = 11 \equiv 1 \pmod{X^2 - 3,\; 5}
$$

**3. NTT inverse**, avec $r_1 = 3$, $r_2 = 1$ et $c = 2$ :

$$
f_{\text{bas}} = \frac{r_1 + r_2}{2} = \frac{4}{2} = 2, \qquad f_{\text{haut}} = \frac{r_1 - r_2}{2c} = \frac{2}{4} = 2 \times 4^{-1} = 2 \times 4 = 8 \equiv 3
$$

On obtient $f = f_{\text{bas}} + X^2 f_{\text{haut}} = 2 + 3X^2$ : **c'est bien le résultat** du calcul direct de la page précédente.

## 7. Le temps constant

La NTT est **naturellement régulière** : les boucles, les indices et les constantes ne dépendent que de la position, jamais des valeurs. Les seuls risques de fuite sont dans l'arithmétique modulaire elle-même : réductions conditionnelles, multiplications. C'est pour cette raison que `ModQ` est écrit sans branchement.

Sur carte, une autre attaque vise la NTT : l'**analyse de consommation** (*single-trace attacks*, attaques par propagation de croyance sur les papillons). Elle a été démontrée en laboratoire contre des implémentations de Kyber. Les contre-mesures (masquage, mélange de l'ordre des papillons) dépassent le cadre de ce prototype pédagogique, mais il faut garder ce risque en tête pour le jalon 6.

## Exercices

??? question "1. Combien de niveaux aurait une NTT complète pour $X^{256} + 1$, et quelle racine de l'unité faudrait-il ?"
    8 niveaux, jusqu'à 256 facteurs de degré 1 ; il faudrait une racine primitive 512ᵉ de l'unité, donc $512 \mid q - 1$. C'était le cas de Kyber v1 avec $q = 7681$ ($7680 = 2^9 \times 15$).

??? question "2. Pourquoi la NTT directe peut-elle écrire ses résultats à la place de ses entrées ?"
    Chaque papillon lit deux cases ($f_{\text{bas}}[j]$, $f_{\text{haut}}[j]$) et écrit deux résultats qui ne servent qu'au niveau suivant. Aucune autre opération du même niveau ne lit ces cases. Il faut seulement mémoriser $c \cdot f_{\text{haut}}[j]$ avant d'écraser $f_{\text{bas}}[j]$. Sur une carte qui n'a que quelques kilo-octets de RAM, cette propriété est essentielle.

??? question "3. Vérifier que $\gamma_0 = 17$ et $\gamma_1 = 3312$ sont des racines carrées opposées."
    $3312 = 3329 - 17 = -17$. Les feuilles $X^2 - 17$ et $X^2 + 17$ sont donc les deux enfants de $X^4 - 17^2 = X^4 - 289$.

??? question "4. Pourquoi la NTT inverse multiplie-t-elle tout par 3303 à la fin, et non pas par $2^{-1}$ à chaque niveau ?"
    Le résultat est le même : $(2^{-1})^7 = 128^{-1} = 3303$. Mais 256 multiplications à la fin coûtent bien moins que $7 \times 256$ multiplications réparties sur les niveaux.

??? question "5. Avec $q = 17$ et les valeurs du § 2, retrouver $a(2)$ à la main."
    $a(2) = 1 + 2 \cdot 2 + 3 \cdot 2^3 = 1 + 4 + 24 = 29 \equiv 12 \pmod{17}$.
