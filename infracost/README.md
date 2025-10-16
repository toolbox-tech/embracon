# 💰 Infracost - Análise de Custos de Infraestrutura

## 🎯 **Visão Geral**

O **Infracost** é uma ferramenta open-source que fornece estimativas de custos para recursos de infraestrutura como código (IaC) antes mesmo da implantação. Integra-se facilmente com Terraform, CloudFormation e outros provedores de nuvem.

---

## 🚀 **O que é o Infracost?**

O Infracost ajuda engenheiros e equipes de DevOps a:

- 📊 **Estimar custos** antes da implantação
- 💡 **Comparar alternativas** de arquitetura
- 🔍 **Identificar recursos caros** antecipadamente
- 📈 **Monitorar mudanças** de custos em pull requests
- 💰 **Otimizar gastos** em nuvem

---

## 📁 **Arquivos neste Diretório**

### 📄 `infracost_test.tf`
Este arquivo contém a **configuração de teste do site oficial do Infracost**. É um exemplo prático que demonstra:

- ✅ **Recursos AWS básicos** (EC2, RDS, Load Balancer)
- ✅ **Configurações típicas** de produção
- ✅ **Casos de uso reais** para análise de custos
- ✅ **Exemplo completo** para aprendizado

**Propósito:** Arquivo de demonstração oficial para testar funcionalidades do Infracost e entender como a ferramenta calcula estimativas de custos.

---

## 🛠️ **Como Usar**

### **1. Instalação**
```bash
# Linux/macOS
curl -fsSL https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh | sh

# Windows (PowerShell)
iwr -useb https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.ps1 | iex
```

### **2. Configuração**
```bash
# Configure sua API key (gratuita)
infracost auth login

# Ou configure manualmente
export INFRACOST_API_KEY=seu_api_key_aqui
```

### **3. Análise de Custos**
```bash
# Analisar o arquivo de teste
infracost breakdown --path infracost_test.tf

# Gerar relatório detalhado
infracost breakdown --path infracost_test.tf --format table

# Salvar em arquivo
infracost breakdown --path infracost_test.tf --format json --out-file costs.json
```

---

## 📊 **Exemplo de Output**

```
Project: infracost_test.tf

 Name                                                 Monthly Qty  Unit                    Monthly Cost

 aws_instance.example
 ├─ Instance usage (Linux/UNIX, on-demand, t3.medium)        730  hours                         $30.37
 └─ root_block_device
    └─ Storage (general purpose SSD, gp2)                     20  GB                             $2.00

 aws_db_instance.example
 ├─ Database instance (on-demand, db.t3.micro)               730  hours                         $12.41
 └─ Storage (general purpose SSD, gp2)                        20  GB                             $2.30

 OVERALL TOTAL                                                                                  $47.08
```

---

## 🔧 **Integração CI/CD**

### **GitHub Actions**
```yaml
- name: Setup Infracost
  uses: infracost/actions/setup@v2
  with:
    api-key: ${{ secrets.INFRACOST_API_KEY }}

- name: Generate Infracost cost estimate baseline
  run: |
    infracost breakdown --path infracost_test.tf \
                        --format json \
                        --out-file /tmp/infracost-base.json

- name: Post Infracost comment
  run: |
    infracost comment github --path /tmp/infracost-base.json \
                             --repo $GITHUB_REPOSITORY \
                             --github-token ${{ secrets.GITHUB_TOKEN }} \
                             --pull-request ${{ github.event.pull_request.number }}
```

---

## ⚡ **Casos de Uso**

### **1. Revisão de Pull Requests**
- 📝 Comentários automáticos com estimativas de custos
- 📊 Comparação antes/depois das mudanças
- ⚠️ Alertas para aumentos significativos de custos

### **2. Planejamento de Arquitetura**
- 🏗️ Comparar diferentes tipos de instâncias
- 💾 Avaliar opções de storage
- 🌐 Analisar custos por região

### **3. Otimização de Custos**
- 🔍 Identificar recursos subutilizados
- 💡 Sugerir alternativas mais econômicas
- 📈 Monitorar tendências de gastos

---

## 🏆 **Benefícios**

### **Para Desenvolvedores:**
- ✅ **Visibilidade antecipada** de custos
- ✅ **Decisões informadas** sobre recursos
- ✅ **Feedback instantâneo** em mudanças

### **Para Equipes:**
- ✅ **Controle de orçamento** proativo
- ✅ **Colaboração** em otimizações
- ✅ **Transparência** nos gastos

### **Para Organização:**
- ✅ **Redução de custos** significativa
- ✅ **Governança** financeira melhorada
- ✅ **ROI** mensurável em infraestrutura

---

## 📚 **Recursos Adicionais**

- 🌐 **Site Oficial**: [infracost.io](https://www.infracost.io/)
- 📖 **Documentação**: [docs.infracost.io](https://www.infracost.io/docs/)
- 🐙 **GitHub**: [github.com/infracost/infracost](https://github.com/infracost/infracost)
- 💬 **Community**: [Slack do Infracost](https://www.infracost.io/community-chat)

---

## 🤝 **Contribuição**

Este diretório faz parte do **Toolbox Embracon** para demonstrar ferramentas de **FinOps** e **cost optimization** em infraestrutura como código.

**Desenvolvido com 💰 pela equipe Toolbox DevOps**