# Kubernetes et service mesh

Le trafic est-ouest d'un cluster est rarement exposé à Internet, mais il traverse souvent des réseaux physiques partagés, des liens inter-datacenters et des fournisseurs cloud. Le mTLS généralisé par un service mesh est un **levier de crypto-agilité puissant** : une seule configuration pilote des milliers de connexions.

## Couches à couvrir

| Couche | Composant | Point de contrôle |
|---|---|---|
| Entrée (nord-sud) | Ingress controller (nginx, HAProxy, Envoy Gateway) | Bibliothèque TLS et groupes configurés |
| Est-ouest | Service mesh (Istio, Linkerd, Cilium) | Groupes TLS du proxy, certificats de charge de travail |
| Plan de contrôle | API server, etcd, kubelet | Écrits en Go : hybride par défaut à partir de Go 1.24 si le binaire est compilé avec |
| Données au repos | Secrets etcd, volumes chiffrés | Symétrique : AES-256 suffisant ; vérifier le chiffrement des clés (KMS) |
| Chaîne d'approvisionnement | Signature d'images (cosign, Notation) | Signatures classiques aujourd'hui, à suivre |

## Istio

Les versions récentes d'Istio proposent une politique de conformité dédiée au post-quantique, qui restreint les groupes TLS des proxys Envoy à des groupes hybrides ML-KEM :

```yaml
# Exemple — vérifier le nom exact de la variable et des valeurs dans la documentation de votre version
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
spec:
  values:
    pilot:
      env:
        COMPLIANCE_POLICY: "pqc"
```

## Composants Go

De nombreux composants cloud native (Kubernetes, etcd, Prometheus, Vault, Consul, Traefik, CoreDNS…) sont écrits en Go. Avec **Go 1.24+**, `crypto/tls` propose `X25519MLKEM768` par défaut. Vérifier :

```bash
# Version de Go utilisée pour compiler un binaire
go version -m /usr/local/bin/composant | head -1
```

et que la configuration TLS du composant ne **restreint pas explicitement** `CurvePreferences`, ce qui désactiverait l'hybride.

## Contrôle d'admission

Intégrer des règles de **policy as code** (Kyverno, OPA Gatekeeper) qui refusent par exemple les Ingress ou les configurations de proxy sans groupe hybride, et les images construites avec des bibliothèques crypto obsolètes. Voir [Policy as code](../devsecops/policy-as-code.md).
