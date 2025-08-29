{{/*
Expand the name of the chart.
*/}}
{{- define "keycloak.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "keycloak.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "keycloak.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "keycloak.labels" -}}
helm.sh/chart: {{ include "keycloak.chart" . }}
{{ include "keycloak.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "keycloak.selectorLabels" -}}
app.kubernetes.io/name: {{ include "keycloak.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "keycloak.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "keycloak.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Database connection URL
*/}}
{{- define "keycloak.databaseUrl" -}}
{{- if .Values.postgresql.enabled }}
{{- printf "jdbc:postgresql://%s-postgresql:5432/%s" .Release.Name .Values.postgresql.auth.database }}
{{- else if .Values.database.host }}
{{- $port := .Values.database.port | default 5432 }}
{{- printf "jdbc:postgresql://%s:%v/%s" .Values.database.host $port .Values.database.name }}
{{- end }}
{{- end }}

{{/*
Database username
*/}}
{{- define "keycloak.databaseUsername" -}}
{{- if .Values.postgresql.enabled }}
{{- .Values.postgresql.auth.username }}
{{- else }}
{{- .Values.database.username }}
{{- end }}
{{- end }}

{{/*
Database password secret name
*/}}
{{- define "keycloak.databasePasswordSecretName" -}}
{{- if .Values.postgresql.enabled }}
{{- printf "%s-postgresql" .Release.Name }}
{{- else if .Values.database.existingSecret }}
{{- .Values.database.existingSecret }}
{{- else }}
{{- printf "%s-database" (include "keycloak.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Database password secret key
*/}}
{{- define "keycloak.databasePasswordSecretKey" -}}
{{- if .Values.postgresql.enabled }}
password
{{- else }}
{{- .Values.database.passwordKey | default "password" }}
{{- end }}
{{- end }}

{{/*
Admin credentials secret name
*/}}
{{- define "keycloak.adminSecretName" -}}
{{- if .Values.auth.existingSecret }}
{{- .Values.auth.existingSecret }}
{{- else }}
{{- printf "%s-admin" (include "keycloak.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Keycloak hostname
*/}}
{{- define "keycloak.hostname" -}}
{{- .Values.networking.hostname }}
{{- end }}

{{/*
OIDC Issuer URL
*/}}
{{- define "keycloak.oidcIssuerUrl" -}}
{{- if .Values.networking.httpEnabled }}
{{- printf "http://%s/realms/%s" (include "keycloak.hostname" .) .Values.keycloak.defaultRealm }}
{{- else }}
{{- printf "https://%s/realms/%s" (include "keycloak.hostname" .) .Values.keycloak.defaultRealm }}
{{- end }}
{{- end }}
