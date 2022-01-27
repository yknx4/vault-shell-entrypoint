# vault-shell-entrypoint
Shell entrypoint for containers to load env variables from vault secrets dir.

This scripts will find `.env` files stored in `/vault/secrets` and source them to load env variables.
You can override the location with the env var `$VAULT_SECRETS_DIR`

## Example

### Kubernetes Vault Injector

1.- Inject some variables into the pod. [Example](https://www.vaultproject.io/docs/platform/k8s/injector)
```yaml
  template:
    metadata:
      labels:
        name: myapp
      annotations:
        vault.hashicorp.com/agent-inject: 'true'
        vault.hashicorp.com/role: 'myapp-role'
        vault.hashicorp.com/agent-inject-secret-db.env: 'database/creds/mydb'
        vault.hashicorp.com/agent-inject-template-db.env: |
          {{ with secret "database/creds/mydb" -}}
            export DATABASE_URL=postgres://{{ .Data.username }}:{{ .Data.password }}@host:5432/myapp
          {{- end }}
        vault.hashicorp.com/agent-inject-secret-config.env: 'secret/myapp/data/config'
        vault.hashicorp.com/agent-inject-template-config.env: |
          {{ with secret "secret/myapp/data/config" -}}
            {{ range $key, $value := .Data.data }}
              export {{ $key }}={{ $value }}
            {{ end }}
          {{- end }}
```
2.- Replace command on your Dockerfile (I also recommend using tini)
```Dockerfile
  FROM debian:slim

  ADD https://raw.githubusercontent.com/yknx4/vault-shell-entrypoint/main/vault-entrypoint.sh /vault-entrypoint.sh
  RUN chmod +x /vault-entrypoint.sh

  ENV TINI_VERSION v0.19.0
  RUN wget --no-check-certificate --no-cookies --quiet https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-amd64 \
      && wget --no-check-certificate --no-cookies --quiet https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-amd64.sha256sum \
      && echo "$(cat tini-amd64.sha256sum)" | sha256sum -c \
      && mv /tini-amd64 /tini
  RUN chmod +x /tini

  ENTRYPOINT ["/tini", "--", "/vault-entrypoint.sh"]
  # ENTRYPOINT ["/tini", "--", "/vault-entrypoint.sh", "/your/app/entry"]
```