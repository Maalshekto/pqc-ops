# Policy as code

La politique cryptographique de l'établissement doit exister **sous une forme exécutable**, versionnée et revue comme du code. Elle est appliquée à trois moments : en CI, à l'admission dans les clusters, et lors des audits périodiques.

## Exemple OPA / Rego (Conftest)

Règle appliquée aux manifestes décrivant la configuration TLS d'un service (format interne d'exemple) :

```rego
package pqc.tls

import rego.v1

hybrides := {"X25519MLKEM768", "SecP256r1MLKEM768", "SecP384r1MLKEM1024"}
obsoletes := {"X25519Kyber768Draft00"}

# Le premier groupe doit être hybride pour les services exposés
deny contains msg if {
  input.kind == "TlsPolicy"
  input.spec.exposition in {"internet", "partenaire"}
  not input.spec.groups[0] in hybrides
  msg := sprintf("%s : le premier groupe TLS doit être hybride ML-KEM (trouvé : %v)",
                 [input.metadata.name, input.spec.groups[0]])
}

# TLS 1.3 obligatoire pour l'hybride
deny contains msg if {
  input.kind == "TlsPolicy"
  not "TLSv1.3" in input.spec.protocols
  msg := sprintf("%s : TLS 1.3 requis", [input.metadata.name])
}

# Groupes pré-standard interdits
deny contains msg if {
  input.kind == "TlsPolicy"
  some g in input.spec.groups
  g in obsoletes
  msg := sprintf("%s : groupe obsolète %s", [input.metadata.name, g])
}

# Exception valide uniquement si référencée et non expirée
deny contains msg if {
  input.kind == "TlsPolicy"
  input.spec.exception
  time.parse_rfc3339_ns(input.spec.exception.expire) < time.now_ns()
  msg := sprintf("%s : exception %s expirée", [input.metadata.name, input.spec.exception.id])
}
```

## Exemple Kyverno

Refuser les `Gateway` / `Ingress` annotés comme exposés sans groupe hybride (l'annotation dépend de votre contrôleur ; exemple générique) :

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: pqc-ingress-hybride
spec:
  validationFailureAction: Audit   # passer à Enforce après la phase de mesure
  rules:
    - name: groupes-hybrides
      match:
        any:
          - resources:
              kinds: [Ingress]
              selectors:
                - matchLabels: { exposition: internet }
      validate:
        message: "Les Ingress exposés doivent proposer X25519MLKEM768 en premier."
        pattern:
          metadata:
            annotations:
              banque.example/tls-groups: "X25519MLKEM768*"
```

## Gestion des exceptions

Une politique sans processus d'exception est contournée. Chaque exception doit :

- [ ] Porter un **identifiant**, un **propriétaire** et une **date d'expiration** ;
- [ ] Être justifiée (dépendance fournisseur, matériel, partenaire) ;
- [ ] Être acceptée par le niveau de risque adéquat (propriétaire métier, RSSI) ;
- [ ] Apparaître dans le CBOM et le tableau de bord ;
- [ ] Être **automatiquement rejetée à expiration** (cf. règle Rego ci-dessus).
