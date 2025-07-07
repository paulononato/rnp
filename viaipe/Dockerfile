FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y curl jq bc postgresql-client && \
    apt-get clean

WORKDIR /app

COPY viaipe_agent.sh .

RUN chmod +x viaipe_agent.sh

CMD ["./viaipe_agent.sh"]
