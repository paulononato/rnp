FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y curl jq bc postgresql-client ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY viaipe_agent.sh .

RUN chmod +x viaipe_agent.sh

CMD ["./viaipe_agent.sh"]
