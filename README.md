# PQC-Ops

Guide opérationnel de **migration vers la cryptographie post-quantique (PQC)** du point de vue d'un·e DevSecOps
habilité·e à conduire la migration et les tests réseau et infrastructure **en contexte bancaire**.

Site publié : https://maalshekto.github.io/pqc-ops/

## Contenu

| Dossier | Description |
|---|---|
| `docs/` | Sources du site (MkDocs Material) |
| `lab/` | Laboratoire Docker (Debian 13 / OpenSSL 3.5) : nginx avec profils TLS hybride, certificats ML-DSA |
| `scripts/pqc-tls-scan.sh` | Scan d'une liste de cibles : groupe négocié, support `X25519MLKEM768`, TLS 1.2… (CSV) |
| `scripts/semgrep-pqc.yaml` | Règles Semgrep de détection d'usages crypto vulnérables au quantique |

## Prévisualiser en local

```bash
python3 -m venv .venv && . .venv/bin/activate
pip install -r requirements.txt
mkdocs serve        # http://127.0.0.1:8000
```

## Publication

Le workflow `.github/workflows/pages.yml` construit le site (`mkdocs build --strict`) et le déploie sur GitHub Pages
à chaque push sur `main`. Dans les paramètres du dépôt : **Settings → Pages → Source : GitHub Actions**.

## Avertissement

Les commandes de scan et de test ne doivent être exécutées que sur des systèmes pour lesquels vous disposez
d'une autorisation écrite. Le contenu reflète l'état de l'art fin 2026 : vérifiez les sources primaires.
