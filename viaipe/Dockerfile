FROM debian:bookworm-slim

# Instala dependências necessárias
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3 \
        python3-pip \
        curl \
        libpq-dev \
        gcc \
        && apt-get clean && rm -rf /var/lib/apt/lists/*

# Define o diretório de trabalho
WORKDIR /app

# Copia o script Python
COPY viaipe_agent.py .

# Instala as dependências Python
RUN pip install --no-cache-dir requests psycopg2-binary

# Comando de execução
CMD ["python3", "viaipe_agent.py"]
