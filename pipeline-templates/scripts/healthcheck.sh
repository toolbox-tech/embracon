#!/bin/bash
# Este script deve ser executado de dentro do container da aplicação para certificar que a imagem tem o curl instalado
# O curl é utilizado pelo k8s nas funções de callback de start e stop do container

info="http://$1.healthcheck.local:80/$1/actuator/info"
printf "Teste: $info\n"
curl -s $info

health="http://$1.healthcheck.local:80/$1/actuator/health"
printf "Teste: $health\n"
curl -s $health

metrics="http://$1.healthcheck.local:80/$1/actuator/metrics"
printf "Teste: $metrics\n"
curl -s $metrics

prometheus="http://$1.healthcheck.local:80/$1/actuator/prometheus"
printf "Teste: $prometheus\n"
curl -s $prometheus

exit 0
