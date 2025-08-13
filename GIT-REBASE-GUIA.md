# 🔄 Guia Git Rebase - Embracon Toolbox

## 📚 Índice
1. [O que é Git Rebase](#-o-que-é-git-rebase)
2. [Quando usar Rebase](#-quando-usar-rebase)
3. [Passo a Passo Completo](#-passo-a-passo-completo)
4. [Comandos Essenciais](#-comandos-essenciais)
5. [Resolvendo Conflitos](#-resolvendo-conflitos)
6. [Boas Práticas](#-boas-práticas)
7. [Troubleshooting](#-troubleshooting)

---

## 🎯 O que é Git Rebase?

O **Git Rebase** é uma operação que **reorganiza o histórico** dos commits, "puxando" seus commits para trás no tempo e **reaplicando** eles em cima de uma base atualizada, mantendo a **ordem cronológica correta**.

### 🕒 **Analogia: Reorganização Cronológica**

Imagine uma **fila de eventos** onde o rebase "puxa" seus eventos para o **final da fila**:

#### **Antes do Rebase (Bagunçado):**
```
Timeline do Repositório:
Jan: A (main)
Feb: X (sua feature) ❌ Fora de ordem!
Mar: B (main)  
Apr: Y (sua feature) ❌ Fora de ordem!
Mai: C, D, E, F, G (main - commits novos)
```

#### **Depois do Rebase (Cronológico):**
```
Timeline do Repositório:
Jan: A (main)
Mar: B (main)
Mai: C, D, E, F, G (main - todos os commits)
Ago: X' (sua feature) ✅ Na ordem certa!
Ago: Y' (sua feature) ✅ Na ordem certa!
```

### 📊 **Visualização Gráfica**

#### **Estado Inicial:**
```
main:     A---B---C---D---E---F---G (17 commits novos)
          |
feature:  X---Y (seus 2 commits)
```

#### **Após Rebase:**
```
main:     A---B---C---D---E---F---G
                                  |
feature:                          X'---Y' (reaplicados cronologicamente)
```

---

## 🎯 Quando usar Rebase?

### ✅ **USE Rebase quando:**

#### **1. Sincronizar branch com main**
```bash
# Cenário: Sua branch está atrasada
# Status: "This branch is X commits behind main"
git rebase origin/main
```

#### **2. Histórico limpo**
```bash
# Você quer um histórico linear e organizado
# Sem commits de merge desnecessários
```

#### **3. Preparar Pull Request**
```bash
# Antes de abrir PR, organize seus commits
# Facilita o review
```

#### **4. Branch pessoal**
```bash
# Você é o único trabalhando na branch
# Seguro fazer rewrite do histórico
```

### ❌ **NÃO use Rebase quando:**

#### **1. Branch compartilhada**
```bash
# Outras pessoas trabalham na mesma branch
# Rebase + force push pode causar problemas
```

#### **2. Commits já na main**
```bash
# Commits já foram mergeados para main
# NUNCA rebase commits públicos
```

#### **3. Muitos conflitos**
```bash
# Se houver conflitos complexos
# Merge pode ser mais simples
```

---

## 🚀 Passo a Passo Completo

### **Cenário Comum: Branch atrasada**
```
Status: "This branch is 2 commits ahead of, 17 commits behind main"
```

### **Passo 1: Verificar status atual**
```bash
# Ver branches disponíveis
git branch -a

# Ver status da branch atual
git status

# Ver commits únicos da sua branch
git log --oneline main..HEAD
```

### **Passo 2: Buscar atualizações (OBRIGATÓRIO)**
```bash
# Baixar informações mais recentes do servidor
git fetch origin main
```

#### **Por que o fetch é obrigatório?**
- ✅ **Atualiza** informações locais sobre a main
- ✅ **Não modifica** sua branch ainda
- ✅ **Garante** que o rebase será feito na versão atual

#### **❌ Sem fetch:**
```bash
git rebase origin/main  # USA VERSÃO ANTIGA!
```

#### **✅ Com fetch:**
```bash
git fetch origin main   # Atualiza informações
git rebase origin/main  # USA VERSÃO ATUAL!
```

### **Passo 3: Executar o Rebase**
```bash
# Reaplica seus commits em cima da main atualizada
git rebase origin/main
```

#### **O que acontece internamente:**
1. **Salva** seus commits temporariamente
2. **Reseta** sua branch para origin/main
3. **Reaplica** cada commit seu, um por vez
4. **Cria novos** commit IDs (X', Y')

### **Passo 4: Push com segurança**
```bash
# Force push com verificação de segurança
git push --force-with-lease origin feature/sua-branch
```

#### **Por que `--force-with-lease`?**
- ✅ **Mais seguro** que `--force`
- ✅ **Verifica** se ninguém fez push antes
- ✅ **Previne** sobrescrever trabalho de outros

---

## ⚡ Comandos Essenciais

### **Sequência Padrão:**
```bash
# 1. Verificar status
git status
git log --oneline main..HEAD

# 2. Buscar atualizações (OBRIGATÓRIO)
git fetch origin main

# 3. Executar rebase
git rebase origin/main

# 4. Push seguro
git push --force-with-lease origin sua-branch
```

### **Comando Compacto:**
```bash
# Faz fetch + rebase em um comando
git pull --rebase origin main

# Depois push
git push --force-with-lease origin sua-branch
```

### **Verificação após rebase:**
```bash
# Ver histórico reorganizado
git log --oneline --graph -10

# Comparar com main
git log --oneline main..HEAD
```

---

## 🚨 Resolvendo Conflitos

### **Quando acontecem conflitos:**
```bash
git rebase origin/main

# Output:
# Auto-merging arquivo.txt
# CONFLICT (content): Merge conflict in arquivo.txt
# Resolve all conflicts manually, mark them as resolved with
# "git add/rm <conflicted_files>", then run "git rebase --continue".
```

### **Processo de resolução:**

#### **1. Identificar arquivos com conflito:**
```bash
# Ver arquivos com conflito
git status

# Arquivos marcados como "both modified"
```

#### **2. Editar arquivos manualmente:**
```bash
# Abrir arquivo no editor
code arquivo-com-conflito.txt
```

**Formato dos conflitos:**
```
<<<<<<< HEAD (versão da main)
código da main
=======
código da sua branch
>>>>>>> commit-message (sua versão)
```

**Resolver:**
- Escolher uma versão
- Ou combinar ambas
- Remover marcadores `<<<<<<<`, `=======`, `>>>>>>>`

#### **3. Marcar como resolvido:**
```bash
# Adicionar arquivos resolvidos
git add arquivo-resolvido.txt

# Continuar o rebase
git rebase --continue
```

#### **4. Se necessário, cancelar:**
```bash
# Abortar o rebase e voltar ao estado anterior
git rebase --abort
```

### **Exemplo prático de resolução:**

#### **Conflito:**
```javascript
<<<<<<< HEAD
const apiUrl = 'https://api.prod.embracon.com';
=======
const apiUrl = 'https://api.dev.embracon.com';
>>>>>>> feat: update api endpoint
```

#### **Resolução:**
```javascript
const apiUrl = 'https://api.prod.embracon.com';  // Manter versão da main
```

#### **Finalizar:**
```bash
git add config.js
git rebase --continue
```

---

## 🎯 Boas Práticas

### **✅ DOs (Faça):**

#### **1. Sempre fetch antes:**
```bash
git fetch origin main
git rebase origin/main
```

#### **2. Use --force-with-lease:**
```bash
git push --force-with-lease origin feature/branch
```

#### **3. Teste branch local:**
```bash
# Teste se tudo funciona após rebase
npm test
npm run build
```

#### **4. Commits pequenos e organizados:**
```bash
# Facilita resolução de conflitos
# Um commit = uma funcionalidade
```

#### **5. Rebase interativo para organizar:**
```bash
# Reorganizar últimos 3 commits
git rebase -i HEAD~3

# Opções: pick, squash, reword, drop
```

### **❌ DON'Ts (Não faça):**

#### **1. Rebase de branch compartilhada:**
```bash
# ❌ Se outros trabalham na branch
# Pode causar perda de trabalho
```

#### **2. Force push sem verificação:**
```bash
# ❌ PERIGOSO
git push --force origin branch

# ✅ SEGURO  
git push --force-with-lease origin branch
```

#### **3. Rebase de commits públicos:**
```bash
# ❌ NUNCA rebase commits que já estão na main
# Pode quebrar histórico para toda equipe
```

#### **4. Rebase com mudanças não commitadas:**
```bash
# ❌ Primeiro commitar ou stash
git status  # Deve estar limpo

# ✅ Limpar working directory primeiro
git add .
git commit -m "WIP: salvando progresso"
# ou
git stash push -m "WIP: mudanças temporárias"
```

---

## 🛠️ Troubleshooting

### **❌ Problema: "Cannot rebase: You have unstaged changes"**

#### **Causa:**
Arquivos modificados não commitados

#### **Solução:**
```bash
# Opção 1: Committar mudanças
git add .
git commit -m "WIP: progresso atual"
git rebase origin/main

# Opção 2: Usar stash
git stash push -m "WIP: mudanças temporárias"
git rebase origin/main
git stash pop
```

### **❌ Problema: "No such remote 'origin'"**

#### **Causa:**
Remote não configurado

#### **Solução:**
```bash
# Ver remotes configurados
git remote -v

# Adicionar remote se necessário
git remote add origin https://github.com/user/repo.git
```

### **❌ Problema: Muitos conflitos**

#### **Causa:**
Branches muito divergentes

#### **Solução 1: Cancelar e usar merge**
```bash
git rebase --abort
git merge origin/main
```

#### **Solução 2: Rebase em etapas**
```bash
# Rebase por partes
git rebase origin/main~10  # Últimos 10 commits
# Resolver conflitos
git rebase origin/main~5   # Próximos 5
# Resolver conflitos  
git rebase origin/main     # Restante
```

### **❌ Problema: "refusing to pull with rebase"**

#### **Causa:**
Configuração local conflitante

#### **Solução:**
```bash
# Configurar para branch específica
git config branch.feature/k8s.rebase true

# Ou global para todas as branches
git config --global pull.rebase true
```

### **❌ Problema: Push rejeitado após rebase**

#### **Causa:**
Histórico foi reescrito

#### **Solução:**
```bash
# Usar force-with-lease (SEGURO)
git push --force-with-lease origin feature/branch

# ⚠️  CUIDADO: Só se você tem certeza de que é sua branch
```

---

## 📋 Cheat Sheet de Comandos

### **Workflow Completo:**
```bash
# 1. Preparação
git status                           # Verificar se está limpo
git fetch origin main                # Buscar atualizações

# 2. Rebase
git rebase origin/main               # Reorganizar commits

# 3. Se houver conflitos
git status                           # Ver arquivos conflitantes
# Editar arquivos manualmente
git add arquivo-resolvido.txt        # Marcar como resolvido
git rebase --continue                # Continuar

# 4. Finalizar
git push --force-with-lease origin branch  # Push seguro
```

### **Comandos de emergência:**
```bash
# Cancelar rebase em andamento
git rebase --abort

# Ver histórico gráfico
git log --oneline --graph -10

# Comparar branches
git log --oneline main..HEAD        # Seus commits únicos
git log --oneline HEAD..main        # Commits só na main

# Verificar divergência
git status
git branch -vv                       # Ver tracking branches
```

### **Configurações úteis:**
```bash
# Configurar pull com rebase por padrão
git config --global pull.rebase true

# Configurar push com verificação
git config --global push.default simple

# Configurar editor para rebase interativo
git config --global core.editor "code --wait"
```

---

## 🎯 Cenários Práticos

### **Cenário 1: Branch pessoal atrasada**
```bash
# Situação: "2 commits ahead, 17 commits behind"
git fetch origin main
git rebase origin/main
git push --force-with-lease origin feature/minha-branch
```

### **Cenário 2: Organizar commits antes do PR**
```bash
# Combinar últimos 3 commits em 1
git rebase -i HEAD~3
# Escolher: pick, squash, reword, drop
git push --force-with-lease origin feature/branch
```

### **Cenário 3: Atualizar branch de longa duração**
```bash
# Branch com 1 mês de atraso
git fetch origin main
git rebase origin/main
# Resolver conflitos conforme aparecem
git push --force-with-lease origin feature/branch
```

### **Cenário 4: Emergência - desfazer rebase**
```bash
# Se deu algo errado
git reflog                           # Ver histórico de operações
git reset --hard HEAD@{n}           # Voltar para estado anterior
# onde n é o número da operação antes do rebase
```

---

## 🏆 Resumo Executivo

### **🎯 O que é Rebase:**
> "Reorganização cronológica que puxa seus commits para trás no tempo e os reaplica em cima de uma base atualizada"

### **🔑 Sequência Essencial:**
1. **`git fetch origin main`** - Atualizar informações
2. **`git rebase origin/main`** - Reorganizar commits  
3. **`git push --force-with-lease origin branch`** - Enviar resultado

### **✅ Vantagens:**
- Histórico linear e limpo
- Sem commits de merge desnecessários
- Commits aparecem em ordem cronológica
- Pull Request mais fácil de revisar

### **⚠️ Cuidados:**
- Sempre fetch antes do rebase
- Usar --force-with-lease no push
- Não rebase branches compartilhadas
- Nunca rebase commits públicos

### **🚨 Regra de Ouro:**
> "Se você é o único trabalhando na branch, rebase é seguro. Se outros também trabalham, use merge."

---

🎉 **Com esta documentação, você está pronto para usar Git Rebase com segurança e eficiência na Embracon!**
