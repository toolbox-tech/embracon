## 0.7.5 (2025-09-04)

### Fix

- **acr**: correct identity

## 0.7.4 (2025-09-04)

### Fix

- **acr**: docker pull and push
- **acr**: docker pull and push

## 0.7.3 (2025-09-04)

### Fix

- **acr**: private docker images workflow
- **acr**: managed identity

## 0.7.2 (2025-09-04)

### Fix

- **acr**: login to acr

## 0.7.1 (2025-09-04)

### Fix

- **acr**: out acr and resource group as vars

## 0.7.0 (2025-09-04)

### Feat

- **acr**: create workflow to mirror private docker images
- **acr**: workflow to pull public docker images to acr
- **acr**: start internalization of docker images using claude sonnet

### Fix

- **acr**: remove unused files

## 0.6.1 (2025-08-29)

### Fix

- **akv**: change pod to deployment

### Refactor

- **k8s**: create folder kubernetes-tools
- **k8s**: move folders dashboard and keycloak to kubernetes-templates

## 0.6.0 (2025-08-29)

### Feat

- **dashboard**: use RBAC and Entra ID to log in dashboard
- **k8s**: keycloak helm

### Fix

- **nodejs**: maintainer email

## 0.5.0 (2025-08-21)

### Feat

- **akv**: implement complete RBAC solution for External Secrets with Azure Key Vault

## 0.4.3 (2025-08-17)

### Fix

- **bump**: add on PR in actions

## 0.4.2 (2025-08-17)

### Fix

- **bump**: add on push in main

## 0.4.1 (2025-08-17)

### Fix

- **bump**: github tokens

## 0.4.0 (2025-08-17)

### Feat

- **bump**: permissions
- **bump**: semver

### Refactor

- **bump**: test

## 0.3.0 (2025-08-15)

### Feat

- **semver**: create bump.yml to auto update change.log

## 0.2.0 (2025-08-15)

### Feat

- **semver**: create cz.toml file to manage semver

## 0.1.0 (2025-08-15)

### Feat

- **akv**: implement email-to-principal-id conversion for Azure Key Vault with RBAC
- **oidc**: create files to use oidc with gh and azure
- **akv**: rbac assignment using terraform
- **akv**: multiple secrets
- **akv**: new external secret
- **akv**: terraform
- **akv**: terraform
- **akv**: terraform files
- **akv**: change paths and files
- **akv**: wif
- **akv**: using app registration and policies
- **guide**: create a guide to implement external secrets on aks and oke using akv
- **kind**: secret store
- **kind**: use external secret as env
- **aks**: create terraform files for akv and kind with external secrets
- **secret-management**: create secret management module and workflows using github copilot
- **pipeline**: standards
- **pipeline**: build workflow
- **pipeline**: build action
- **pipeline**: gitleaks with fetch-depth: 0
- **pipeline**: trivy workflow
- **pipeline**: workflow trivy
- **pipeline**: pipeline java with cache and docker push
- **pipeline**: login and push docker image
- **pipeline**: use docker/build-push-action@v5
- **pipeline**: docker cache using buildx
- **pipeline**: composite action for cache
- **composite-action**: create composite action for cache
- **pipeline**: create a reusable workflow for cache
- **pipeline**: python pipeline
- **pipeline**: nodejs pipeline rename
- **pipeline**: Write a short and imperative summary of the code changes: (lower case and no period)  app and pipeline java. pipeline nodejs. cache layer in pipelines. pre-ccomit with commitizen and gitleaks only
- **veracode**: create java app and workflow veracode to test java app
- **veracode**: create java app and workflow veracode to test java app
- **pipeline**: reusable workflow
- **pipeline**: reusable workflow
- **pipeline**: gitleaks on gh actions using act with event.json
- **pipelines**: gitleaks and commitizen on pre-commit
- **pipelines**: pipelines to test ACT and veracode
- **ci-cd**: dockerfile template
- **ci-cd**: move cache
- **ci-cd**: Dependências (Maven, npm, pip) e camadas Docker
- **ci-cd**: pipelines cache and security
- **ci-cd**: create ci/cd standards
- **commitizen**: instalation
- **sdlc**: create folder for SDLC

### Fix

- **oidc**: remove auth-type
- **oidc**: contents read permission allowed and auth-type IDENTITY
- **oidc**: contents read permission allowed
- **actions**: remove push and pr from actions
- **akv**: client id and enable oidc json
- **kind**: using secretstore and externalsecrets
- **kind**: rename externa-secret file and put commands on bottom of readme
- **pipeline**: remove on push from java.yml
- **pipeline**: correct python.yml
- **pipeline**: remove push from nodejs.yml
- **pipeline**: docker hub pass
- **pipeline**: actions/checkout@v4 on build action
- **pipeline**: remove yml from security folder
- **pipeline**: add push
- **pipeline**: change mvn to docker and remove gitleaks.yml
- **pipeline**: mvn clean package -DskipTests
- **pipeline**: test docker mvn
- **pipeline**: use aquasecurity/trivy-action@0.28.0
- **pipeline**: cache on workflow trivy
- **pipeline**: skip test mvn
- **pipeline**: remove Set up JDK 17
- **pipeline**: rename docker image
- **pipeline**: nodejs-ci.yml change on to on: [pull_request, push, workflow_dispatch]
- **pipeline**: reusable variables
- **pipeline**: gitleaks pipeline gitleaks_license

### Refactor

- **akv**: change action branch to main
- **workflows**: remove pull_request
- **akv**: change folder AKE to AKS
- **akv**: remove oracle folder
- **gitignore**: remove todo.md from push
- **secret**: test using RBAC
- **pipeline**: remove gitleaks
- **pipeline**: add push on nodejs.yml
- **pipeline**: remove push and load local docker image
- **pipeline**: push on nodejs.yml
- **pipeline**: remove push evento from nodejs-ci.yml
- **cicd**: rename file
- **ci-cd**: docker.yaml name
- **ci-cd**: comments

### Perf

- **pipeline**: mvn in dockerfile
- **pipeline**: mvn on pipeline
- **pipeline**: mvn in dockerfile
