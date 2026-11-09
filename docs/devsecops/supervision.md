# Supervision

Le KPI central de la vague 1 est simple : **quelle part des connexions est réellement protégée par un échange de clés hybride ?** Pour le mesurer, il faut journaliser le groupe négocié.

## Journaliser le groupe négocié

=== "nginx"

    ```nginx
    log_format pqc '$remote_addr [$time_iso8601] "$host" $ssl_protocol '
                   '$ssl_cipher curve=$ssl_curve "$http_user_agent"';
    access_log /var/log/nginx/tls.log pqc;
    ```

    `$ssl_curve` renvoie `X25519MLKEM768` lorsque l'hybride est négocié (avec OpenSSL 3.5).

=== "HAProxy"

    ```haproxy
    # Selon version : fetch ssl_fc_curve (ou équivalent) — vérifier la documentation
    log-format "%ci %{+Q}[ssl_fc_sni] %sslv %sslc curve=%[ssl_fc_curve]"
    ```

=== "Envoy"

    ```yaml
    # Selon version : %DOWNSTREAM_TLS_VERSION% et le groupe négocié si exposé
    access_log:
      - name: envoy.access_loggers.stdout
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.access_loggers.stream.v3.StdoutAccessLog
          log_format:
            text_format_source:
              inline_string: "%DOWNSTREAM_REMOTE_ADDRESS% %DOWNSTREAM_TLS_VERSION% %DOWNSTREAM_TLS_CIPHER%\n"
    ```

=== "SSH"

    ```bash
    # Le KEX négocié apparaît dans les journaux sshd en niveau VERBOSE ou DEBUG selon la version
    journalctl -u ssh --since today | grep -i "kex"
    ```

## Tableau de bord

Indicateurs recommandés :

| Panneau | Requête (pseudo) | Lecture |
|---|---|---|
| Part du trafic hybride | `count(curve=~"MLKEM") / count(*)` par service | Progression de la vague 1 |
| Clients non hybrides | Top User-Agent / ASN où `curve !~ MLKEM` | Cibles de communication ou exceptions |
| TLS 1.2 résiduel | `count(protocol="TLSv1.2")` par service | Prérequis non rempli |
| Groupes obsolètes | `curve="X25519Kyber768Draft00"` | Doit tendre vers 0 |
| Taux d'échec de handshake | Métriques du LB / proxy | Détection de régression middleboxes |

## Alertes

- **Régression** : chute brutale de la part hybride sur un service (changement de configuration, rollback, équipement intercalé) ;
- **Hausse des échecs de handshake** après un changement ;
- **Expiration** prochaine d'une exception de la politique ;
- **Scan planifié** : un service exposé ne propose plus `X25519MLKEM768`.

## Scans planifiés

Exécuter `pqc-tls-scan.sh` (ou testssl.sh) **chaque semaine** sur l'ensemble du périmètre exposé, comparer au résultat précédent et alimenter automatiquement le CBOM. Le scan planifié doit lui-même être couvert par un ordre de mission permanent et connu du SOC.
