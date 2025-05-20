FROM ubuntu:22.04

# Отключаем интерактивный режим для apt
ENV DEBIAN_FRONTEND=noninteractive

# Обновляем ключи, добавляем curl и gnupg, обновляем apt
RUN apt-get update && apt-get install -y curl gnupg ca-certificates apt-transport-https && \
    # Явно добавляем ключ для Ubuntu репозиториев (тот, что указан в логе)
    curl -fsSL https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x871920D1991BC93C | gpg --dearmor > /usr/share/keyrings/ubuntu-archive-keyring.gpg && \
    # Переподключаем источники, используя новый ключ (если надо, но для ubuntu:22.04 стандартный ключ уже есть) \
    apt-get update

# Продолжайте дальше с нужными установками
# Например:
RUN apt-get install -y build-essential

# Очистка кеша apt для уменьшения размера образа
RUN rm -rf /var/lib/apt/lists/*


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
