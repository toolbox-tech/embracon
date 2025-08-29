<p align="center">
  <img src="../../img/tbx.png" alt="Logo Toolbox" width="400"/>
</p>

# 🚀 Node.js Secure Application - Embracon Toolbox

Esta aplicação Node.js foi **totalmente atualizada** com correções críticas de segurança e melhores práticas empresariais.

## 🔒 **Vulnerabilidades Corrigidas** 

✅ **path-to-regexp ReDoS** - Atualizado para versão segura  
✅ **body-parser DoS** - Substituído por express nativo  
✅ **XSS via redirect** - Implementado redirectSafe middleware  
✅ **Template injection** - Headers e validação de paths  
✅ **Cookie vulnerabilities** - Express 4.21.0+ com cookies seguros  

> **📄 Para detalhes completos, consulte: [SECURITY.md](./SECURITY.md)**

## ⚡ Quick Start

### Execução Local
```bash
# Instalar dependências
npm install

# Executar aplicação
npm start

# Verificar segurança
npm audit
```

### Docker (Recomendado)
```bash
# Build da imagem segura
docker build -t embracon-nodejs-secure .

# Executar container
docker run -p 8080:8080 embracon-nodejs-secure

# Com health check
docker run -p 8080:8080 --health-cmd="node healthcheck.js" embracon-nodejs-secure
```

## 🛡️ Recursos de Segurança

### **Helmet.js Protection**
- Content Security Policy (CSP)
- HTTP Strict Transport Security (HSTS)
- X-Frame-Options, X-Content-Type-Options
- Proteção contra clickjacking e MIME sniffing

### **Input Validation**
- Validação de paths para prevenir directory traversal
- Limits de tamanho para JSON e URL encoded
- Sanitização de parâmetros de entrada

### **Secure Headers**
```javascript
res.setHeader('X-Content-Type-Options', 'nosniff');
res.setHeader('X-Frame-Options', 'DENY');
res.setHeader('Cache-Control', 'public, max-age=3600');
```

## 🐳 Docker Security

### **Multi-stage Build**
- Stage de build separado para otimização
- Imagem final mínima (Node.js 20 Alpine)
- Usuário não-root (nodejs:1001)

### **Health Checks**
```bash
# Verificar saúde do container
docker ps --format "table {{.Names}}\t{{.Status}}"

# Logs de health check
docker logs container-name
```

## 📊 Monitoramento

### **Logs de Segurança**
- Tentativas de path traversal
- Requests maliciosos
- Erros de validação
- Performance metrics

### **Health Endpoints**
- `GET /` - Página principal
- `GET /profile` - Perfil com imagem
- Health check interno para Docker

---

## ⚠️ **IMPORTANTE**

Esta aplicação agora atende aos **padrões de segurança corporativa** e pode ser utilizada em ambientes de produção com confiança.

**Embracon Toolbox** - Segurança e qualidade em primeiro lugar 🛡️
