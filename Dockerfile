FROM ubuntu:22.04

# Отключаем интерактивный режим для apt
ENV DEBIAN_FRONTEND=noninteractive

# Обновляем ключи, добавляем curl и gnupg, обновляем apt
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    gnupg \
    gpg \
    ca-certificates \
    apt-transport-https && \
    rm -rf /var/lib/apt/lists/*

# Явно добавляем ключ для Ubuntu репозиториев
RUN curl -fsSL https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x871920D1991BC93C | gpg --dearmor > /usr/share/keyrings/ubuntu-archive-keyring.gpg && \
    apt-get update

# Устанавливаем необходимые пакеты
RUN apt-get install -y --no-install-recommends \
    build-essential \
    python3 \
    python3-venv \
    python3-pip && \
    rm -rf /var/lib/apt/lists/*

# создаем виртуальное окружение
RUN python3 -m venv /opt/venv

# активируем его для всех следующих RUN и CMD
ENV PATH="/opt/venv/bin:$PATH"

# Устанавливаем honcho и зависимости внутри виртуального окружения
COPY requirements.txt /app/
RUN pip install --upgrade pip && \
    pip install honcho && \
    pip install -r /app/requirements.txt

WORKDIR /app
COPY . /app

ENTRYPOINT ["honcho"]
CMD ["start"]

EXPOSE 5000