FROM debian:bookworm-slim

# Instala dependências
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3 \
        python3-pip \
        python3-venv \
        curl \
        libpq-dev \
        gcc && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Define diretório de trabalho
WORKDIR /app

# Copia o script Python
COPY viaipe_agent.py .

# Cria ambiente virtual e instala pacotes Python nele
RUN python3 -m venv /opt/venv && \
    /opt/venv/bin/pip install --no-cache-dir requests psycopg2-binary

# Adiciona o venv ao PATH
ENV PATH="/opt/venv/bin:$PATH"

# Executa o script
CMD ["python3", "/app/viaipe_agent.py"]
