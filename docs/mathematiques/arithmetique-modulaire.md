# Arithmétique modulaire

> **Objectif** : savoir calculer modulo un nombre premier $q$, comprendre ce que sont l'ordre d'un élément et une racine de l'unité, et pourquoi ML-KEM a choisi $q = 3329$.
>
> **Dans pqc-javacard** : étape 2.1, `ModQ.java`.

## 1. Congruences

Deux entiers $a$ et $b$ sont **congrus modulo $q$** si $q$ divise leur différence :

$$
a \equiv b \pmod q \iff q \mid (a - b)
$$

C'est l'arithmétique de l'horloge : $14 \equiv 2 \pmod{12}$. On peut additionner et multiplier des congruences membre à membre : si $a \equiv a'$ et $b \equiv b'$, alors $a + b \equiv a' + b'$ et $a \times b \equiv a' \times b'$. C'est ce qui permet de **réduire modulo $q$ à chaque étape** d'un calcul, au lieu d'une seule fois à la fin. Les valeurs intermédiaires restent ainsi petites, ce qui est indispensable sur une carte 16 bits.

L'ensemble $\mathbb{Z}_q = \{0, 1, \dots, q-1\}$, muni de l'addition et de la multiplication modulo $q$, est l'objet de base de toute la cryptographie à base de réseaux.

### Deux façons de représenter un élément

| Représentant | Intervalle | Exemple pour $q = 3329$ | Usage |
|---|---|---|---|
| Canonique | $[0, q)$ | $-1 \to 3328$ | Stockage, calcul |
| Centré | $\left(-\frac{q}{2}, \frac{q}{2}\right]$ | $3328 \to -1$ | Mesurer la « taille » d'un bruit |

Le représentant centré compte beaucoup pour LWE : on dira qu'un élément est **petit** si son représentant centré est proche de 0. Ainsi, $3328$ est petit (c'est $-1$), alors que $1664$ est grand.

## 2. Inverses : pourquoi $q$ doit être premier

Dans $\mathbb{Z}_q$, l'**inverse** de $a$ est le nombre $a^{-1}$ tel que $a \times a^{-1} \equiv 1 \pmod q$. Il existe si et seulement si $\gcd(a, q) = 1$.

Si $q$ est **premier**, tout élément non nul est inversible : $\mathbb{Z}_q$ est un **corps**. On peut alors diviser, ce que la NTT inverse utilise : elle termine par une division par 128.

Il y a deux façons de calculer un inverse :

- **Algorithme d'Euclide étendu** : il trouve $u, v$ tels que $a u + q v = 1$ (identité de Bézout), et donc $a^{-1} = u \bmod q$. Exemple : $3 \times 5 = 15 = 2 \times 7 + 1$, donc $3^{-1} \equiv 5 \pmod 7$.
- **Petit théorème de Fermat** : pour $q$ premier et $a \not\equiv 0$, on a $a^{q-1} \equiv 1$, donc $a^{-1} \equiv a^{q-2}$.

Dans ML-KEM, on a besoin de $128^{-1} \bmod 3329 = 3303$. Vérification : $128 \times 3303 = 422\,784 = 127 \times 3329 + 1$. Cette constante est calculée une fois pour toutes et écrite dans le code (`N_INV`).

## 3. Ordre d'un élément et racines de l'unité

### L'ordre

Les éléments non nuls de $\mathbb{Z}_q$ forment un groupe pour la multiplication, noté $\mathbb{Z}_q^*$, qui a $q - 1$ éléments. L'**ordre** d'un élément $a$ est le plus petit $k > 0$ tel que $a^k \equiv 1$.

Le **théorème de Lagrange** donne une contrainte forte : **l'ordre de tout élément divise $q - 1$**.

De plus, $\mathbb{Z}_q^*$ est **cyclique** : il existe un **générateur** $g$, d'ordre exactement $q - 1$, dont les puissances parcourent tous les éléments non nuls. Pour $q = 3329$, $g = 3$ en est un.

### Les racines de l'unité

Un élément $\zeta$ est une **racine $n$-ième de l'unité** si $\zeta^n \equiv 1$. Elle est **primitive** si son ordre est exactement $n$. Dans ce cas, $\zeta^0, \zeta^1, \dots, \zeta^{n-1}$ sont $n$ valeurs distinctes.

> **Théorème.** Dans $\mathbb{Z}_q$ avec $q$ premier, il existe une racine primitive $n$-ième de l'unité **si et seulement si $n$ divise $q - 1$**.
>
> *Preuve.* Si $n \mid q-1$, alors $\zeta = g^{(q-1)/n}$ est d'ordre $n$. Réciproquement, l'ordre de $\zeta$ divise $q - 1$ (Lagrange).

C'est la propriété qui rend la NTT possible : elle a besoin de racines de l'unité d'ordre 256.

Une conséquence utile : si $\zeta$ est d'ordre pair $2m$, alors $\zeta^m \equiv -1$. En effet, $(\zeta^m)^2 = 1$, donc $\zeta^m = \pm 1$, et $\zeta^m \neq 1$ puisque l'ordre de $\zeta$ est $2m$. Ce « $-1$ » est le point de départ de la factorisation de $X^{256} + 1$.

## 4. Pourquoi $q = 3329$

$$
q - 1 = 3328 = 2^8 \times 13
$$

| Propriété | Conséquence |
|---|---|
| $q$ est premier | $\mathbb{Z}_q$ est un corps : tout coefficient non nul est inversible |
| $256 = 2^8$ divise $q - 1$ | Il existe des racines primitives 256ᵉ de l'unité : $\zeta = 17$ en est une, avec $17^{128} \equiv -1$ |
| $512 = 2^9$ **ne divise pas** $q - 1$ | Pas de racine 512ᵉ : la NTT de ML-KEM s'arrête un niveau avant la fin (voir [La NTT](ntt.md)) |
| $q < 2^{12}$ | Un coefficient tient sur 12 bits ; la clé est compacte |
| $2q = 6658 < 2^{15}$ | La somme de deux coefficients tient dans un `short` signé : c'est ce qui rend possible l'implémentation 16 bits sur carte |

Avec Kyber version 1, le module valait 7681, ce qui permettait une NTT complète. Il a été réduit à 3329 dans la version 2 : la clé publique et le chiffré sont plus petits, au prix d'une NTT « incomplète ».

## 5. Réduire vite et en temps constant

Un `%` est lent sur de nombreux processeurs, et sur une carte il peut ne pas exister pour les valeurs 32 bits. Surtout, son temps d'exécution peut dépendre des valeurs. On utilise donc des réductions spécialisées :

| Technique | Idée | Utilisée où |
|---|---|---|
| **Réduction conditionnelle** | $x \in [0, 2q)$ : soustraire $q$, puis rajouter $q$ masqué selon le signe | pqc-javacard (`ModQ.csub`) |
| **Barrett** | $a \bmod q = a - \left\lfloor \frac{a \cdot m}{2^k} \right\rfloor q$ avec $m = \left\lfloor \frac{2^k}{q} \right\rfloor$ précalculé : une division remplacée par une multiplication et un décalage | Implémentations de référence |
| **Montgomery** | Travailler sur $a R \bmod q$ (avec $R = 2^{16}$) ; la réduction $\mathrm{REDC}(T) = \frac{T + (T q' \bmod R)\, q}{R}$, où $q' = -q^{-1} \bmod R$, ne divise que par une puissance de 2 | Implémentations optimisées (AVX2, ARM) |

Barrett et Montgomery supposent qu'on sait calculer un **produit complet** de deux nombres de 16 bits (32 bits). Une Java Card classique n'a pas d'`int`, donc pas ce produit : c'est pour ça que pqc-javacard multiplie bit à bit (« doubler puis ajouter »), en réduisant à chaque pas.

!!! warning "Temps constant"
    Toute opération dont le temps ou la consommation dépend d'une valeur secrète la laisse fuir : par un chronométrage, à distance, ou par une mesure de consommation électrique (SPA) sur une carte. Les réductions ci-dessus s'écrivent **sans branchement** : on utilise des masques construits à partir du bit de signe.

## Exercices

??? question "1. Calculer $5^{-1} \bmod 3329$ par Euclide étendu."
    $3329 = 665 \times 5 + 4$, puis $5 = 1 \times 4 + 1$. En remontant : $1 = 5 - 4 = 5 - (3329 - 665 \times 5) = 666 \times 5 - 3329$. Donc $5^{-1} \equiv 666$. Vérification : $5 \times 666 = 3330 = 3329 + 1$.

??? question "2. Quel est l'ordre de $-1$ ? Et celui de $17^2$ ?"
    $(-1)^2 = 1$ : l'ordre de $-1$ est 2. Pour $17^2$ : $(17^2)^k = 17^{2k} = 1$ si et seulement si $256 \mid 2k$, donc $k = 128$. Plus généralement, l'ordre de $\zeta^j$ est $n / \gcd(n, j)$.

??? question "3. Combien y a-t-il de racines primitives 256ᵉ de l'unité modulo 3329 ?"
    Ce sont les $\zeta^j$ avec $\gcd(j, 256) = 1$, c'est-à-dire $j$ impair : il y en a $\varphi(256) = 128$. FIPS 203 a choisi $\zeta = 17$, la plus petite.

??? question "4. Pourquoi ne peut-on pas utiliser $q = 3329$ avec des polynômes de 512 coefficients et une NTT complète ?"
    Une NTT complète pour $X^{512} + 1$ demanderait une racine primitive 1024ᵉ de l'unité, donc $1024 \mid q - 1$. Or $q - 1 = 2^8 \times 13$.
