# Fondamentaux

Avant de toucher à une configuration, il faut savoir précisément **ce qui est menacé, par quoi le remplacer, et sous quelles contraintes réglementaires**.

| Page | Ce que vous y trouverez |
|---|---|
| [La menace quantique](menace.md) | Shor, Grover, HNDL, inégalité de Mosca, ce qui est cassé et ce qui ne l'est pas |
| [Algorithmes standardisés](algorithmes.md) | ML-KEM, ML-DSA, SLH-DSA, FN-DSA, HQC, LMS/XMSS — tailles, niveaux, usages |
| [Normes et réglementation](reglementation.md) | NIST, ANSSI, BSI, feuille de route UE, CNSA 2.0, échéances |

!!! tip "En une phrase"
    Tout ce qui repose sur la factorisation (RSA) ou le logarithme discret (DH, ECDH, ECDSA, EdDSA) devra être remplacé ; la cryptographie symétrique (AES-256) et les fonctions de hachage (SHA-256/384, SHA-3) restent sûres moyennant des tailles adéquates.
