FROM debian:bookworm-slim

# Instala curl, ping e cliente PostgreSQL
RUN apt-get update && \
    apt-get install -y \
      curl \
      iputils-ping \
      postgresql-client \
      ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY ping_coletor.sh .

RUN chmod +x ping_coletor.sh
ENTRYPOINT ["./ping_coletor.sh"]
