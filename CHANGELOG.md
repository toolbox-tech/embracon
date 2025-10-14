## 4.5.3 (2025-10-14)

### Refactor

- **cache**: remove gitleaks args

## 4.5.2 (2025-10-14)

### Fix

- **cache**: gitleaks fetch-depth 0

## 4.5.1 (2025-10-14)

### Fix

- **cache**: gitleaks error

## 4.5.0 (2025-10-14)

### Feat

- **cache**: java cache

### Fix

- **cache**: docker sbom
- **cache**: gitleaks only current commit
- **cache**: cache error
- **cache**: docker tag
- **cache**: docker
- **cache**: gitleaks
- **cache**: docker hub repo
- **cache**: docker image tag
- **cache**: java version
- **cache**: last tomcat version
- **cache**: security
- **cache**: docker token
- **cache**: cache optimization
- **cache**: java gradlew generate

### Refactor

- **cache**: change step name build to build-java

## 4.4.1 (2025-09-24)

### Fix

- check img
- check img
- remove img if exists

## 4.4.0 (2025-09-24)

### Feat

- generate img language script
- github app token
- create language used image

### Fix

- move img
- permission
- commit
- change vars
- vars and secrets
- repo name

## 4.3.0 (2025-09-22)

### Feat

- trivy test

## 4.2.7 (2025-09-19)

### Fix

- **acr**: add image

## 4.2.6 (2025-09-19)

### Fix

- **acr**: azure login

## 4.2.5 (2025-09-19)

### Fix

- **acr**: login azure

## 4.2.4 (2025-09-19)

### Fix

- **acr**: prefix and sign

## 4.2.3 (2025-09-17)

### Fix

- **acr**: correct key

## 4.2.2 (2025-09-17)

### Fix

- **acr**: correct key

## 4.2.1 (2025-09-17)

### Fix

- **acr**: use local key to sign
- **acr**: fix sed

## 4.2.0 (2025-09-17)

### Feat

- **acr**: verify before sign

## 4.1.1 (2025-09-17)

### Fix

- **acr**: sign images

## 4.1.0 (2025-09-17)

### Feat

- **acr**: sign images with cosign

## 4.0.1 (2025-09-15)

### Fix

- build image permissions:   contents: write

## 4.0.0 (2025-09-15)

### Fix

- **acr**: change prefix

## 3.0.1 (2025-09-15)

### Fix

- **acr**: identity

## 3.0.0 (2025-09-15)

### Fix

- **acr**: enable-AzPSSession: true

## 2.0.0 (2025-09-15)

### Fix

- **acr**: action auth-type: IDENTITY

## 1.7.0 (2025-09-13)

### Feat

- atualiza workflow de build e add packagelock

### Fix

- remove npm ci duplicado do dockerfile
- ajusta caminho do Dockerfile no build pra usar o healthcheck.js

## 1.6.0 (2025-09-12)

### Feat

- **acr**: aks config to access acr

## 1.5.0 (2025-09-12)

### Feat

- **acr**: change hello-world to nginx

## 1.4.1 (2025-09-11)

### Fix

- **acr**: remove docker cache

## 1.4.0 (2025-09-11)

### Feat

- **acr**: docker cache

## 1.3.2 (2025-09-11)

### Fix

- **acr**: json output

## 1.3.1 (2025-09-11)

### Fix

- **acr**: corret output az acr

## 1.3.0 (2025-09-11)

### Feat

- **acr**: check using index digest

## 1.2.0 (2025-09-11)

### Feat

- **acr**: check digests

## 1.1.1 (2025-09-11)

### Fix

- **acr**: simplify process

## 1.1.0 (2025-09-11)

### Feat

- **acr**: checks digest and store in json file

## 1.0.0 (2025-09-10)

### Fix

- **bump**: major_version_zero = false
- **acr**: remove targetRepository and put repository name on acr like this $PREFIX$TARGET_REPO:$TAG
- **acr**: use jq to get digest

## 0.12.0 (2025-09-05)

### Feat

- **acr**: remove repos

## 0.11.2 (2025-09-05)

### Refactor

- **acr**: correct envs

## 0.11.1 (2025-09-05)

### Perf

- **acr**: create another job to clean images

## 0.11.0 (2025-09-05)

### Feat

- **acr**: remove images that not in json file but in acr

## 0.10.6 (2025-09-05)

### Refactor

- **acr**: remove private repos

### Perf

- **acr**: remove docker pull and push

## 0.10.5 (2025-09-05)

### Refactor

- **act**: test with just acr import

## 0.10.4 (2025-09-05)

### Refactor

- **acr**: test with just acr import

## 0.10.3 (2025-09-05)

### Refactor

- **acr**: get digest using bash commands

## 0.10.2 (2025-09-05)

### Perf

- **acr**: change the way to check diggest

## 0.10.1 (2025-09-05)

### Fix

- **acr**: correct digest

## 0.10.0 (2025-09-05)

### Feat

- **acr**: check digest before pull

## 0.9.0 (2025-09-05)

### Feat

- **acr**: check if exists docker image in acr before pull

## 0.8.3 (2025-09-05)

### Fix

- **acr**: use correct var and secret docker hub

## 0.8.2 (2025-09-05)

### Fix

- **acr**: add docker username and token

## 0.8.1 (2025-09-05)

### Fix

- **acr**: az acr import continue if error

## 0.8.0 (2025-09-05)

### Feat

- **acr**: using az acr import

## 0.7.6 (2025-09-05)

### Fix

- **acr**: continue if error

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
