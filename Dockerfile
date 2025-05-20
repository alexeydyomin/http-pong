FROM ubuntu:latest

# Отключаем интерактивный режим для apt
ENV DEBIAN_FRONTEND=noninteractive

# Временно разрешаем ненадежные репозитории для установки необходимых пакетов
RUN echo "Acquire::AllowInsecureRepositories \"true\";" > /etc/apt/apt.conf.d/allow-insecure && \
    echo "Acquire::AllowDowngradeToInsecureRepositories \"true\";" >> /etc/apt/apt.conf.d/allow-insecure && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gnupg \
    gpg && \
    rm -rf /var/lib/apt/lists/*

# Добавляем ключи Ubuntu в правильном формате
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x871920D1991BC93C | gpg --dearmor -o /etc/apt/keyrings/ubuntu-archive-keyring.gpg && \
    chmod a+r /etc/apt/keyrings/ubuntu-archive-keyring.gpg

# Восстанавливаем стандартные источники с указанием подписанных репозиториев
RUN echo "deb [signed-by=/etc/apt/keyrings/ubuntu-archive-keyring.gpg] http://archive.ubuntu.com/ubuntu jammy main restricted universe multiverse" > /etc/apt/sources.list && \
    echo "deb [signed-by=/etc/apt/keyrings/ubuntu-archive-keyring.gpg] http://archive.ubuntu.com/ubuntu jammy-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb [signed-by=/etc/apt/keyrings/ubuntu-archive-keyring.gpg] http://archive.ubuntu.com/ubuntu jammy-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb [signed-by=/etc/apt/keyrings/ubuntu-archive-keyring.gpg] http://security.ubuntu.com/ubuntu jammy-security main restricted universe multiverse" >> /etc/apt/sources.list

# Теперь можно нормально обновлять и устанавливать пакеты
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    python3 \
    python3-venv \
    python3-pip && \
    rm -rf /var/lib/apt/lists/*

# Создаем виртуальное окружение
RUN python3 -m venv /opt/venv

# Активируем его для всех следующих RUN и CMD
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