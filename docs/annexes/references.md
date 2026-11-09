# Références

!!! tip "Toujours revenir aux sources primaires"
    Les liens ci-dessous pointent vers les publications officielles. Vérifiez la version la plus récente avant toute décision.

## Standards

- NIST — [FIPS 203 : ML-KEM](https://csrc.nist.gov/pubs/fips/203/final)
- NIST — [FIPS 204 : ML-DSA](https://csrc.nist.gov/pubs/fips/204/final)
- NIST — [FIPS 205 : SLH-DSA](https://csrc.nist.gov/pubs/fips/205/final)
- NIST — [SP 800-208 : signatures à base de hachage avec état](https://csrc.nist.gov/pubs/sp/800/208/final)
- NIST — [IR 8547 : transition vers la cryptographie post-quantique](https://csrc.nist.gov/pubs/ir/8547/ipd)
- NIST — [Projet de standardisation PQC](https://csrc.nist.gov/projects/post-quantum-cryptography)

## IETF

- [RFC 9370 — Multiple Key Exchanges in IKEv2](https://www.rfc-editor.org/rfc/rfc9370)
- [RFC 9242 — Intermediate Exchange in IKEv2](https://www.rfc-editor.org/rfc/rfc9242)
- [RFC 8784 — Postquantum Preshared Keys for IKEv2](https://www.rfc-editor.org/rfc/rfc8784)
- [RFC 8879 — TLS Certificate Compression](https://www.rfc-editor.org/rfc/rfc8879)
- [draft-ietf-tls-ecdhe-mlkem — groupes hybrides TLS](https://datatracker.ietf.org/doc/draft-ietf-tls-ecdhe-mlkem/)
- [draft-ietf-tls-hybrid-design — conception de l'échange hybride](https://datatracker.ietf.org/doc/draft-ietf-tls-hybrid-design/)
- [Groupe de travail LAMPS — certificats ML-DSA, ML-KEM, composites](https://datatracker.ietf.org/wg/lamps/documents/)
- [Registre IANA des groupes TLS](https://www.iana.org/assignments/tls-parameters/tls-parameters.xhtml#tls-parameters-8)

## Agences et régulateurs

- ANSSI — [Publications sur la cryptographie post-quantique](https://cyber.gouv.fr/)
- BSI — [TR-02102 et recommandations PQC](https://www.bsi.bund.de/)
- Commission européenne — [Feuille de route coordonnée pour la transition PQC](https://digital-strategy.ec.europa.eu/)
- NSA — [CNSA 2.0](https://media.defense.gov/2022/Sep/07/2003071834/-1/-1/0/CSA_CNSA_2.0_ALGORITHMS_.PDF)
- [Règlement DORA (UE) 2022/2554](https://eur-lex.europa.eu/eli/reg/2022/2554/oj)
- PCI SSC — [PCI DSS v4.0.1](https://www.pcisecuritystandards.org/)

## Outils

- [OpenSSL 3.5](https://www.openssl.org/) — ML-KEM, ML-DSA, SLH-DSA natifs
- [Open Quantum Safe](https://openquantumsafe.org/) — liboqs, oqs-provider
- [strongSwan](https://www.strongswan.org/) — IKEv2 avec ML-KEM
- [OpenSSH](https://www.openssh.com/) — `mlkem768x25519-sha256`
- [testssl.sh](https://testssl.sh/), [sslyze](https://github.com/nabla-c0d3/sslyze), [ssh-audit](https://github.com/jtesta/ssh-audit)
- [CBOMkit](https://github.com/PQCA/cbomkit), [sonar-cryptography](https://github.com/PQCA/sonar-cryptography)
- [CycloneDX — CBOM](https://cyclonedx.org/capabilities/cbom/)
- [Semgrep](https://semgrep.dev/), [Open Policy Agent](https://www.openpolicyagent.org/), [Kyverno](https://kyverno.io/)
- [tldr.fail](https://tldr.fail/) — bogues de middleboxes face aux ClientHello volumineux

## Communauté

- [Post-Quantum Cryptography Alliance (Linux Foundation)](https://pqca.org/)
- [PKI Consortium — PQC Capabilities Matrix](https://pkic.org/)
- [Europol — Quantum Safe Financial Forum](https://www.europol.europa.eu/)
