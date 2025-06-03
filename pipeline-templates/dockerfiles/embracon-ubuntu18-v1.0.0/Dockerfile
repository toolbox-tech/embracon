# Imagem oficial Embracon
# Criado por: alves.filipe, 03/05/2022
FROM ubuntu:18.04

# ADD BASHRC CONFIG
ENV DEBIAN_FRONTEND noninteractive

COPY . /app

WORKDIR /app

RUN apt update && apt install libaio1 libaio-dev -y

RUN sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y \
    alien \
    python3 \
    python3-dev \
    python3-pip \
    gunicorn \
    libmysqlclient-dev \
    python-dev && \
    rm /var/lib/apt/lists/lock && \
    pip3 install gunicorn awscli && \
    pip3 install -r requirements.txt


RUN ldconfig

EXPOSE 5000

CMD ["bash", "run.sh"]
