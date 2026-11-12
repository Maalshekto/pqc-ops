# Polynômes et anneaux

> **Objectif** : comprendre l'anneau $R_q = \mathbb{Z}_q[X]/(X^{256}+1)$ dans lequel calculent ML-KEM et ML-DSA, ce qu'est un produit « négacyclique », et le théorème des restes chinois, qui est la clé de la NTT.
>
> **Prérequis** : [Arithmétique modulaire](arithmetique-modulaire.md).

## 1. Polynômes à coefficients modulo q

Un polynôme de $\mathbb{Z}_q[X]$ est une expression $f = f_0 + f_1 X + f_2 X^2 + \dots$, dont les coefficients sont dans $\mathbb{Z}_q$. En machine, c'est **un tableau de coefficients** : $X$ n'a pas de valeur, il sert seulement à marquer la position de chaque coefficient.

- **Addition** : coefficient par coefficient, modulo $q$. Pour deux polynômes de 256 coefficients : 256 additions.
- **Multiplication** : chaque coefficient multiplie chaque coefficient, et les termes de même degré s'additionnent :

$$
(a \cdot b)_k = \sum_{i + j = k} a_i \, b_j \pmod q
$$

C'est une **convolution**. Pour des polynômes de $n$ coefficients, elle coûte $n^2$ multiplications : 65 536 pour $n = 256$. La NTT existe pour éviter ce coût.

## 2. Calculer « modulo un polynôme »

Comme pour les entiers, on peut faire la **division euclidienne** d'un polynôme $f$ par un polynôme $P$ : $f = Q \cdot P + r$, avec $\deg r < \deg P$. Calculer **modulo $P$**, c'est remplacer chaque polynôme par son reste $r$. L'ensemble des restes, muni de l'addition et de la multiplication suivie de la réduction, forme l'**anneau quotient** $\mathbb{Z}_q[X]/(P)$.

En pratique, on n'effectue jamais de division : on se sert de l'égalité $P \equiv 0$. Modulo $X^2 - 2$, par exemple, $X^2 \equiv 2$ : on remplace partout $X^2$ par 2.

### L'anneau de ML-KEM : $X^{256} \equiv -1$

$$
R_q = \mathbb{Z}_q[X]/(X^{256} + 1), \qquad q = 3329
$$

Un élément de $R_q$ est un polynôme de degré au plus 255, soit 256 coefficients. Modulo $X^{256} + 1$, on a $X^{256} \equiv -1$ : un terme qui dépasse le degré 255 **revient au début avec un signe moins**. C'est un produit **négacyclique** : cyclique comme une rotation, mais avec un changement de signe à chaque tour.

$$
(a \cdot b)_k = \sum_{i + j = k} a_i b_j \;-\; \sum_{i + j = k + 256} a_i b_j \pmod q
$$

Multiplier par $X$ décale tous les coefficients d'un cran vers la droite. Le dernier coefficient revient en tête, avec son signe changé :

$$
X \cdot (f_0, f_1, \dots, f_{255}) = (-f_{255}, f_0, f_1, \dots, f_{254})
$$

### Un exemple à la main, en miniature

On prend $q = 5$ et $n = 4$, c'est-à-dire l'anneau $\mathbb{Z}_5[X]/(X^4 + 1)$, avec $X^4 \equiv -1$. Soit :

$$
a = 1 + 2X + 3X^3, \qquad b = 4 + X^2 + X^3
$$

Le produit développé vaut :

$$
a \cdot b = 4 + 8X + X^2 + 15X^3 + 2X^4 + 3X^5 + 3X^6
$$

On remplace $X^4 \to -1$, $X^5 \to -X$ et $X^6 \to -X^2$ :

$$
a \cdot b \equiv (4 - 2) + (8 - 3)X + (1 - 3)X^2 + 15X^3 \equiv 2 + 0X + 3X^2 + 0X^3 \pmod 5
$$

On retrouvera ce résultat, $2 + 3X^2$, par la NTT sur la page suivante.

## 3. Pourquoi $X^{256} + 1$ ?

| Propriété | Conséquence |
|---|---|
| Réduction triviale | $X^{256} = -1$ : on recopie avec un changement de signe, sans division |
| Le produit ne fait pas « exploser » les petits polynômes | Si $a$ et $b$ ont des coefficients petits (en représentant centré), $a \cdot b$ aussi : chaque coefficient est une somme de 256 produits, avec des signes ±, sans facteur multiplicatif supplémentaire. Le **bruit** de LWE reste maîtrisé. |
| $X^{256} + 1$ est le **polynôme cyclotomique** $\Phi_{512}$, irréductible sur $\mathbb{Q}$ | Sur les rationnels, l'anneau n'a pas de « raccourci » de structure connu qui aiderait un attaquant ; c'est le cadre étudié par la théorie (Ring-LWE). |
| **Mais** sur $\mathbb{Z}_q$, avec $q = 3329$, il se **factorise** | C'est ce qui rend possible la NTT : rapide pour l'implémentation, sans affaiblir la sécurité. |

Ce double visage est l'élément central de cette page : on travaille sur un polynôme **irréductible sur $\mathbb{Q}$**, ce qui sert la sécurité, mais **totalement décomposable modulo $q$**, ce qui sert la vitesse.

## 4. Le théorème des restes chinois

### Sur les entiers

Comme $15 = 3 \times 5$, avec 3 et 5 premiers entre eux, connaître $x \bmod 15$ revient à connaître le couple $(x \bmod 3, \; x \bmod 5)$. Additions et multiplications se font **composante par composante** :

$$
\mathbb{Z}_{15} \cong \mathbb{Z}_3 \times \mathbb{Z}_5
$$

### Sur les polynômes

Le même théorème vaut pour les polynômes. Si $P = P_1 \cdot P_2$, avec $P_1$ et $P_2$ premiers entre eux, alors :

$$
\mathbb{Z}_q[X]/(P) \;\cong\; \mathbb{Z}_q[X]/(P_1) \;\times\; \mathbb{Z}_q[X]/(P_2), \qquad f \mapsto (f \bmod P_1,\; f \bmod P_2)
$$

**Un produit dans le grand anneau devient deux produits dans des anneaux deux fois plus petits.** Comme un produit naïf coûte le carré du nombre de coefficients, couper en deux divise déjà le coût par deux. En répétant la coupe sur 7 niveaux, on obtient la NTT.

### Le cas qui nous intéresse : $X^{2k} - c^2 = (X^k - c)(X^k + c)$

On coupe $f = f_{\text{bas}} + X^k f_{\text{haut}}$ (les $k$ premiers coefficients, puis les $k$ suivants). Modulo $X^k - c$, on remplace $X^k$ par $c$ ; modulo $X^k + c$, par $-c$ :

$$
r_1 = f \bmod (X^k - c) = f_{\text{bas}} + c\, f_{\text{haut}}, \qquad r_2 = f \bmod (X^k + c) = f_{\text{bas}} - c\, f_{\text{haut}}
$$

Le retour est tout aussi simple, à condition de pouvoir diviser par 2 et par $c$, ce que permet un corps :

$$
f_{\text{bas}} = \frac{r_1 + r_2}{2}, \qquad f_{\text{haut}} = \frac{r_1 - r_2}{2c}
$$

Ces deux formules sont le **papillon** de la NTT et le papillon de la NTT inverse.

**Sur l'exemple miniature** : modulo 5, on a $2^2 = 4 \equiv -1$, donc $X^4 + 1 = X^4 - 2^2 = (X^2 - 2)(X^2 + 2)$. Avec $a = 1 + 2X + 3X^3$, on a $a_{\text{bas}} = 1 + 2X$ et $a_{\text{haut}} = 0 + 3X$, d'où :

$$
a \bmod (X^2 - 2) = (1 + 2X) + 2 \cdot 3X = 1 + 3X, \qquad a \bmod (X^2 + 2) = (1 + 2X) - 2 \cdot 3X = 1 + X
$$

(tous les calculs se font modulo 5 : $8X = 3X$ et $-4X = X$).

## 5. Vecteurs et matrices de polynômes

ML-KEM ne travaille pas avec un seul polynôme, mais avec des **vecteurs** de $k$ polynômes (on parle de **module** sur $R_q$) et une **matrice** $k \times k$ de polynômes. Pour ML-KEM-768, $k = 3$ :

| Objet | Contenu | Taille encodée (12 bits par coefficient) |
|---|---|---|
| Un polynôme | 256 coefficients | 384 octets |
| Vecteur secret $\mathbf{s}$ | 3 polynômes | 1 152 octets |
| Matrice publique $\mathbf{A}$ | 3 × 3 = 9 polynômes | Jamais transmise : régénérée à partir d'une graine de 32 octets |
| Clé publique $(\mathbf{t}, \rho)$ | 3 polynômes + graine | 3 × 384 + 32 = **1 184 octets** |

Un produit matrice-vecteur $\mathbf{A}\mathbf{s}$ demande 9 produits de polynômes : avec la multiplication naïve, ce serait $9 \times 65\,536 \approx 590\,000$ multiplications modulaires. C'est la NTT qui rend ce calcul envisageable, même sur une carte.

## Exercices

??? question "1. Dans $R_q$, que vaut $X^{256}$ ? Et $X^{512}$ ?"
    $X^{256} = -1$, donc $X^{512} = (-1)^2 = 1$. Multiplier par $X$ est donc une opération d'ordre 512 : il faut l'appliquer 512 fois pour revenir au point de départ.

??? question "2. Calculer $(1 + X^3) \cdot X^2$ dans $\mathbb{Z}_5[X]/(X^4 + 1)$."
    $X^2 + X^5 = X^2 + X \cdot X^4 = X^2 - X = 4X + X^2$ (modulo 5).

??? question "3. Pourquoi a-t-on besoin que $q$ soit premier pour le papillon inverse ?"
    Il faut diviser par 2 et par $c$. Dans un corps, tout élément non nul est inversible ; modulo un nombre composé, 2 ou $c$ pourraient ne pas l'être.

??? question "4. Retrouver $b \bmod (X^2 - 2)$ et $b \bmod (X^2 + 2)$ pour $b = 4 + X^2 + X^3$ (modulo 5)."
    $b_{\text{bas}} = 4$, $b_{\text{haut}} = 1 + X$. Donc $b \bmod (X^2 - 2) = 4 + 2(1 + X) = 6 + 2X = 1 + 2X$, et $b \bmod (X^2 + 2) = 4 - 2(1 + X) = 2 - 2X = 2 + 3X$.
