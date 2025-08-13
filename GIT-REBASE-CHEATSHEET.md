# ⚡ Git Rebase - Cheat Sheet Rápido

## 🎯 Conceito Básico
**Rebase = "Puxar commits para trás e reaplicar em ordem cronológica"**

```
ANTES:  main: A---B---C---D---E (novos)
             |
        feat: X---Y (seus commits)

DEPOIS: main: A---B---C---D---E---X'---Y' (cronológico!)
```

## ⚡ Comandos Essenciais

### **Sequência Padrão (90% dos casos):**
```bash
git fetch origin main                    # 1. Buscar atualizações
git rebase origin/main                   # 2. Reorganizar
git push --force-with-lease origin feat # 3. Enviar (seguro)
```

### **Comando Compacto:**
```bash
git pull --rebase origin main           # fetch + rebase
git push --force-with-lease origin feat # push seguro
```

## 🚨 Resolvendo Conflitos

```bash
# Se aparecer conflito:
git status                    # Ver arquivos conflitantes
# Editar arquivos manualmente (remover <<<< ==== >>>>)
git add arquivo-resolvido.txt # Marcar como resolvido
git rebase --continue         # Continuar

# Em caso de emergência:
git rebase --abort           # Cancelar tudo
```

## ✅ Quando Usar

- ✅ **Branch pessoal** (só você trabalha)
- ✅ **Sincronizar com main** 
- ✅ **Antes de Pull Request**
- ✅ **Histórico limpo** sem merges

## ❌ Quando NÃO Usar

- ❌ **Branch compartilhada** (outros também trabalham)
- ❌ **Commits já na main** (públicos)
- ❌ **Muitos conflitos** (use merge)

## 🛠️ Troubleshooting

```bash
# Arquivos não commitados
git stash                    # Salvar mudanças
git rebase origin/main       # Fazer rebase
git stash pop               # Restaurar mudanças

# Ver histórico após rebase
git log --oneline --graph -10

# Desfazer rebase (emergência)
git reflog                  # Ver operações
git reset --hard HEAD@{n}   # Voltar ao estado anterior
```

## 🎯 Cenários Comuns

### **Branch atrasada:**
```bash
# Status: "X commits behind main"
git fetch origin main && git rebase origin/main
```

### **Organizar commits:**
```bash
# Combinar últimos 3 commits
git rebase -i HEAD~3        # pick, squash, reword, drop
```

### **Atualizar branch antiga:**
```bash
# Branch com semanas de atraso
git fetch origin main       # Buscar tudo novo
git rebase origin/main      # Aplicar sobre base atual
```

## 🔑 Regras de Ouro

1. **Sempre `fetch` antes** do rebase
2. **Use `--force-with-lease`** no push
3. **Só rebase branches pessoais**
4. **Working directory limpo** antes do rebase

## 💡 Dica Final

> **"Se você é o único na branch, rebase é seguro. Se outros também trabalham, use merge."**

---

🚀 **Salve este cheat sheet para consulta rápida!**
