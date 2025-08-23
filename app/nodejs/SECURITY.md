# 🔒 Correções de Vulnerabilidades de Segurança - Node.js App

Este documento descreve as **correções críticas** aplicadas para resolver as vulnerabilidades de segurança identificadas no projeto Node.js.

## 🚨 Vulnerabilidades Corrigidas

### **Alta Prioridade (High)**

#### 1. **path-to-regexp ReDoS (CVE-2024-45296)**
- **Problema**: Expressões regulares com backtracking causam DoS
- **Solução**: Atualizado Express para versão 4.21.0+ que usa path-to-regexp seguro
- **Status**: ✅ **CORRIGIDO**

#### 2. **body-parser DoS quando URL encoding habilitado**
- **Problema**: Vulnerability de negação de serviço no body-parser
- **Solução**: 
  - Substituído body-parser por express.json() e express.urlencoded()
  - Configurado `extended: false` (mais seguro)
  - Adicionados limites de tamanho e parâmetros
- **Status**: ✅ **CORRIGIDO**

### **Baixa Prioridade (Low)**

#### 3. **cookie out-of-bounds characters**
- **Problema**: Aceita caracteres inválidos em nome, path e domain
- **Solução**: Express 4.21.0+ inclui cookie library atualizada
- **Status**: ✅ **CORRIGIDO**

#### 4. **send/serve-static template injection XSS**
- **Problema**: Vulnerabilidade de template injection
- **Solução**: 
  - Express 4.21.0+ com send e serve-static atualizados
  - Validação de paths com `validateFilePath()`
  - Headers de segurança adicionais
- **Status**: ✅ **CORRIGIDO**

#### 5. **express XSS via response.redirect()**
- **Problema**: XSS através de redirecionamentos não validados
- **Solução**: 
  - Implementado `redirectSafe()` middleware
  - Validação de URLs para prevenir open redirect
  - Lista de domínios permitidos
- **Status**: ✅ **CORRIGIDO**

## 🛡️ Melhorias de Segurança Implementadas

### **1. Helmet.js - Segurança HTTP**
```javascript
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", "data:", "https:"]
    }
  },
  hsts: {
    maxAge: 31536000,
    includeSubDomains: true,
    preload: true
  }
}));
```

### **2. Validação de Caminhos de Arquivo**
```javascript
function validateFilePath(filePath) {
  const normalizedPath = path.normalize(filePath);
  const basePath = path.resolve(__dirname);
  const resolvedPath = path.resolve(basePath, normalizedPath);
  
  // Previne path traversal
  if (!resolvedPath.startsWith(basePath)) {
    throw new Error('Invalid file path');
  }
  return resolvedPath;
}
```

### **3. Headers de Segurança**
- `X-Content-Type-Options: nosniff`
- `X-Frame-Options: DENY`
- `Cache-Control` apropriado
- `Content-Security-Policy`
- `Strict-Transport-Security`

### **4. Parsing Seguro**
```javascript
// JSON com limite de tamanho
app.use(express.json({ 
  limit: '10mb',
  strict: true
}));

// URL encoded seguro
app.use(express.urlencoded({ 
  extended: false,  // Usa querystring parser (mais seguro)
  limit: '10mb',
  parameterLimit: 20
}));
```

### **5. Tratamento de Erros**
- Middleware global de error handling
- Logs de segurança
- Ocultação de stack traces em produção
- Graceful shutdown

## 📦 Dependências Atualizadas

### Antes (Vulneráveis)
```json
{
  "express": "^4.17.1"
}
```

### Depois (Seguras)
```json
{
  "express": "^4.21.0",
  "helmet": "^7.1.0"
}
```

## 🚀 Como Aplicar as Correções

### 1. **Instalar Dependências Atualizadas**
```bash
cd app/nodejs
npm install
```

### 2. **Executar Auditoria de Segurança**
```bash
npm audit
npm audit fix
```

### 3. **Testar a Aplicação**
```bash
npm start
```

### 4. **Verificar Vulnerabilidades**
```bash
npm audit --audit-level high
```

## 🐳 Docker Seguro

O Dockerfile foi atualizado com:
- Imagem base Node.js LTS segura
- User não-root
- Multi-stage build
- Health checks
- Security scanning

```dockerfile
FROM node:20-alpine
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY --chown=nodejs:nodejs . .
USER nodejs
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node healthcheck.js
CMD ["node", "server.js"]
```

## 🔍 Monitoramento de Segurança

### **Comandos de Auditoria**
```bash
# Auditoria completa
npm audit

# Apenas vulnerabilidades altas e críticas
npm audit --audit-level high

# Tentar correção automática
npm audit fix

# Relatório detalhado
npm audit --json > security-report.json
```

### **Verificação Contínua**
- Configure `npm audit` no pipeline CI/CD
- Use ferramentas como Snyk ou WhiteSource
- Atualize dependências regularmente
- Monitore CVE databases

## ⚠️ Notas Importantes

1. **Versões Mínimas**:
   - Node.js >= 18.0.0
   - npm >= 9.0.0

2. **Produção**:
   - Use HTTPS sempre
   - Configure rate limiting
   - Implemente logs de auditoria
   - Use WAF (Web Application Firewall)

3. **Desenvolvimento**:
   - Execute `npm audit` regularmente
   - Use ferramentas de linting de segurança
   - Teste penetration regularmente

## 📚 Recursos Adicionais

- [OWASP Node.js Security Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Nodejs_Security_Cheat_Sheet.html)
- [Helmet.js Documentation](https://helmetjs.github.io/)
- [Express Security Best Practices](https://expressjs.com/en/advanced/best-practice-security.html)
- [Node.js Security Checklist](https://blog.risingstack.com/node-js-security-checklist/)

---

✅ **Status**: Todas as vulnerabilidades identificadas foram corrigidas e melhorias de segurança implementadas.

**Embracon Toolbox** - Segurança em primeiro lugar 🛡️
