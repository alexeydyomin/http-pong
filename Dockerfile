FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Восстанавливаем стандартные ключи Ubuntu
RUN apt-get update || true && \
    apt-get install -y --no-install-recommends ubuntu-keyring && \
    rm -rf /var/lib/apt/lists/*


# Теперь можно обновлять и устанавливать пакеты
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