# Service Account Issuer Discovery no Kubernetes

---

## 1. O que é Service Account Issuer Discovery?

É um recurso do Kubernetes que permite que sistemas externos (fora do cluster) possam **validar tokens de ServiceAccount** emitidos pelo cluster, de maneira padronizada, usando o protocolo OIDC (OpenID Connect).

Quando ativado, o Kubernetes publica um **documento de configuração OIDC** e uma chave pública JWKS, permitindo que qualquer sistema compatível com OIDC valide tokens do cluster.

---

## 2. Como funciona na prática?

- O **API Server** do Kubernetes serve dois endpoints:
  1. **/.well-known/openid-configuration**  
     → Esse documento JSON descreve como o cluster pode ser usado como um provedor OIDC.
  2. **/openid/v1/jwks**  
     → Publica as chaves públicas usadas para assinar os tokens JWT de ServiceAccounts.

- O endpoint de issuer (em geral o endpoint da API do cluster, ex: `https://<api-server>/`) deve estar configurado corretamente e acessível via HTTPS.

- Um sistema externo pode acessar esses endpoints e verificar:
  - O configuration document (descobre regras, endpoints, etc.)
  - O JWKS (baixa as chaves públicas)

---

## 3. Fluxo típico de uso

1. **Um pod** recebe um token de ServiceAccount JWT via projeção.
2. **O pod** apresenta esse token a um sistema externo (ex: um serviço web, CI/CD, API de nuvem).
3. **O sistema externo** acessa o endpoint do issuer do cluster (`https://<issuer>/.well-known/openid-configuration`), descobre o endereço do JWKS e baixa as chaves públicas.
4. **O sistema externo** valida a assinatura do token JWT usando a chave pública.
5. Se a assinatura e claims forem válidas, o serviço externo confia que aquele pod/ServiceAccount é legítimo.

---

## 4. Para que serve na prática?

- **Federar autenticação**: Permite que sistemas de fora do cluster reconheçam tokens de ServiceAccount como identidade válida.
- **SSO/Kubernetes como IdP**: O cluster pode ser usado como um Identity Provider (IdP) OIDC para outros sistemas.
- **Zero Trust**: Permite fluxos seguros onde um pod pode provar sua identidade para recursos externos (cloud, bancos, APIs etc).

---

## 5. Requisitos importantes

- O issuer tem que ser **HTTPS**.
- O endpoint tem que servir o documento OIDC no caminho correto.
- O JWKS deve ser acessível também via HTTPS.
- Os endpoints não precisam ser públicos, mas podem ser espelhados/cached em um endpoint público se necessário (flag `--service-account-jwks-uri`).

---

## 6. RBAC padrão

- O ClusterRole **system:service-account-issuer-discovery** já existe e é ligado por padrão ao grupo **system:serviceaccounts**, permitindo que pods acessem o discovery.
- Admins podem ajustar para permitir que outros grupos (ex: system:authenticated) acessem também, dependendo do cenário de segurança.

---

## 7. Resumo visual

```plaintext
Pod (com SA token JWT) 
        |
        v
Sistema Externo <-- Consulta --> /.well-known/openid-configuration  e  /openid/v1/jwks
        |
    Valida token JWT
```

---

## 8. Exemplo prático de endpoint OIDC discovery

Supondo que seu issuer é `https://my-k8s-api.example.com`

- **Configuração:**  
  `https://my-k8s-api.example.com/.well-known/openid-configuration`
- **JWKS:**  
  `https://my-k8s-api.example.com/openid/v1/jwks`

---

## 9. Quando usar Service Account Issuer Discovery?

- Quando você quer permitir que sistemas externos confiem nos tokens de ServiceAccount emitidos pelo seu cluster Kubernetes — por exemplo, para autenticação de workloads no GCP, AWS, Azure, Vault, CI/CD, etc.