FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y iputils-ping postgresql-client && \
    apt-get clean

WORKDIR /app
COPY ping_coletor.sh .

RUN chmod +x ping_coletor.sh
ENTRYPOINT ["./ping_coletor.sh"]
