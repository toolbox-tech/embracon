FROM ubuntu:20.04

# ADD BASHRC CONFIG

ENV DEBIAN_FRONTEND noninteractive

COPY . /app

WORKDIR /app


# Atualiza e instala o Ubuntu
RUN apt update && apt install -y --no-install-recommends \
    libaio1 \
    libaio-dev \
    alien \
    git \
    libmysqlclient-dev

# Instala o R e os modulos necessários
RUN apt install -y --no-install-recommends \
    r-base \
    r-cran-caret \
    r-cran-glmnet

# Instala o Python 3
RUN apt-get install -y --no-install-recommends \
    python3 \
    python3-dev \
    python3-pip \
    gunicorn \
    python-dev

# Instala os modulos do Python 3 necessários e os modulos do arquivo requirements.txt
RUN pip3 install \
    gunicorn \
    awscli \
    && pip3 install  -r requirements.txt


RUN ldconfig

EXPOSE 5000

CMD ["bash", "run.sh"]
