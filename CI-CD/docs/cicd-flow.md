# Fluxo de CI/CD

Este documento descreve o fluxo de integração contínua (CI) e entrega contínua (CD) utilizado neste projeto.

## Sumário

- [Visão Geral](#visão-geral)
- [Pipeline de CI](#pipeline-de-ci)
- [Pipeline de CD](#pipeline-de-cd)
- [Boas Práticas](#boas-práticas)

## Visão Geral

O objetivo do CI/CD é automatizar os processos de build, testes e deploy, garantindo entregas rápidas e seguras.

## Pipeline de CI

1. **Build:** Compilação e validação do código.
2. **Testes:** Execução dos testes automatizados.
3. **Análise de Qualidade:** Verificação de padrões e cobertura de código.

## Pipeline de CD

1. **Deploy em Ambiente de Homologação:** Publicação automática para testes.
2. **Deploy em Produção:** Publicação controlada após aprovação.

## Boas Práticas

- Manter o pipeline sempre verde.
- Automatizar o máximo possível.
- Revisar e documentar mudanças.
