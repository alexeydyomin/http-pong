FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y curl gnupg && \
    curl -fsSL https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x871920D1991BC93C | \
    gpg2 --dearmor -o /etc/apt/trusted.gpg.d/ubuntu.gpg && \
    apt-get update





# Обновление и установка пакетов
RUN apt-get update && \
    apt-get install -y \
    python3-pip \
    python3-venv \
    python3-dev \
    build-essential && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


# создаем виртуальное окружение
RUN python3 -m venv /opt/venv

# активируем его для всех следующих RUN и CMD
ENV PATH="/opt/venv/bin:$PATH"

# Устанавливаем honcho и зависимости внутри виртуального окружения
COPY requirements.txt /app/
RUN pip install --upgrade pip \
    && pip install honcho \
    && pip install -r /app/requirements.txt

WORKDIR /app
COPY . /app

ENTRYPOINT ["honcho"]
CMD ["start"]

EXPOSE 5000
