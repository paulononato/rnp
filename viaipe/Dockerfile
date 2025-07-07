FROM python:3.11-slim

# Instala dependências necessárias
RUN apt-get update && \
    apt-get install -y curl && \
    pip install --no-cache-dir psycopg2-binary requests

# Cria diretório de trabalho
WORKDIR /app

# Copia o script
COPY viaipe_agent.py .

# Comando para executar o agente
CMD ["python", "viaipe_agent.py"]
