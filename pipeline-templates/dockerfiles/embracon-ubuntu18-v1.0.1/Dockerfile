# Imagem oficial Embracon
# Criado por: alves.filipe, 03/05/2022
FROM ubuntu:18.04

# ADD BASHRC CONFIG

COPY docker/config/oracle-instantclient-sqlplus.rpm /tmp/
COPY docker/config/oracle-instantclient-devel.rpm /tmp/
COPY docker/config/oracle-instantclient-basic.rpm /tmp/


ENV DEBIAN_FRONTEND noninteractive


COPY . /app

WORKDIR /app

RUN apt update && apt install libaio1 libaio-dev -y 

RUN sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y \
    alien \
    git \
    python3 \
    python3-dev \
    python3-pip \
    gunicorn \
    libmysqlclient-dev \
    python-dev && \
    pip3 install  gunicorn awscli && \
    pip3 install  -r requirements.txt

RUN alien -i /tmp/oracle-instantclient-basic.rpm
RUN alien -i /tmp/oracle-instantclient-devel.rpm
RUN alien -i /tmp/oracle-instantclient-sqlplus.rpm

ENV LD_LIBRARY_PATH=/usr/lib/oracle/12.2/client64/lib/${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
RUN ldconfig

EXPOSE 5000

CMD ["python3", "manage.py", "run_celery"]
