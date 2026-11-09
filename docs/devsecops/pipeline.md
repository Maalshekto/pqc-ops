# Pipeline CI/CD

## Étapes ajoutées au pipeline

| Étape | Outil | Bloquant ? |
|---|---|---|
| Détection d'API cryptographiques vulnérables | Semgrep (règles maison) | Avertissement puis bloquant (à l'échéance définie) |
| Version des bibliothèques crypto | SCA (Dependency-Track, Trivy, Grype…) | Bloquant sous le minimum défini |
| Génération du CBOM | CBOMkit / sonar-cryptography, CycloneDX | Non (publication) |
| Lint des configurations TLS/SSH/IPsec | OPA / Conftest | Bloquant |
| Test TLS du déploiement de revue | `pqc-tls-scan.sh` | Bloquant pour les services exposés |

## Règles Semgrep

Le dépôt contient un jeu de règles d'exemple : [`scripts/semgrep-pqc.yaml`](https://github.com/Maalshekto/pqc-ops/blob/main/scripts/semgrep-pqc.yaml).

```yaml
rules:
  - id: java-quantum-vulnerable-keypair
    languages: [java]
    severity: WARNING
    message: >
      Génération de clé $ALG vulnérable à un ordinateur quantique.
      Passer par le service crypto centralisé (crypto-agilité) et prévoir ML-KEM / ML-DSA.
    metadata: { category: pqc, cwe: "CWE-327" }
    patterns:
      - pattern: KeyPairGenerator.getInstance("$ALG", ...)
      - metavariable-regex:
          metavariable: $ALG
          regex: (?i)^(RSA|EC|DSA|DH|X25519|Ed25519|XDH|EdDSA)$
```

```bash
semgrep scan --config scripts/semgrep-pqc.yaml --sarif -o semgrep-pqc.sarif .
```

## Exemple GitHub Actions

```yaml
name: pqc-checks
on: [pull_request]
jobs:
  crypto:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Détection des usages crypto vulnérables
        run: |
          pipx run semgrep scan --config scripts/semgrep-pqc.yaml \
            --sarif -o semgrep-pqc.sarif --error || echo "::warning::usages crypto à revoir"

      - name: Lint des configurations TLS (policy as code)
        run: |
          conftest test --policy policy/ deploy/**/*.yaml

      - name: Publier les résultats
        uses: github/codeql-action/upload-sarif@v3
        with: { sarif_file: semgrep-pqc.sarif }
```

!!! tip "Adoption progressive"
    Commencer en mode **avertissement** pour mesurer le stock, publier un tableau de bord par équipe, puis rendre bloquant pour le **code nouveau** uniquement, avant de traiter l'existant par vagues.

## Tests TLS post-déploiement

Dans l'environnement de revue ou de préproduction, après déploiement :

```bash
./scripts/pqc-tls-scan.sh <<< "app-review-${CI_MERGE_REQUEST_IID}.preprod.banque.example:443" \
  | tee resultat.csv
grep -q ';X25519MLKEM768;' resultat.csv || { echo "Échange hybride non négocié"; exit 1; }
```

## Images et socles

- Socles conteneurs à jour : Debian 13, Ubuntu 24.04+ avec OpenSSL 3.5 selon disponibilité, RHEL 10, UBI récentes, images *distroless* reconstruites ;
- Interdire les images embarquant OpenSSL 1.1.1 (fin de vie) ou des versions figées ;
- Bibliothèques langages : JDK et BouncyCastle récents, Go ≥ 1.24, Python lié à OpenSSL 3.5, .NET récent.
