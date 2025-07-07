#!/bin/bash

# Configurações do banco de dados
DB_HOST="${DB_HOST:-postgres}"
DB_PORT="${DB_PORT:-5432}"
DB_NAME="${DB_NAME:-docker-db}"
DB_USER="${DB_USER:-docker-user}"
DB_PASSWORD="${DB_PASSWORD:-docker-pass}"
API_URL="${API_URL:-https://viaipe.rnp.br/api/norte}"
SLEEP_SECONDS="${SLEEP_SECONDS:-30}"  # padrão: 30 segundos

export PGPASSWORD="$DB_PASSWORD"

while true; do
    echo "Coletando dados da API do ViaIpe..."

    JSON=$(curl -s "$API_URL")

    echo "$JSON" | jq -c '.[]' | while read -r item; do
        client_id=$(echo "$item" | jq '.id')
        client_name=$(echo "$item" | jq -r '.name' | sed "s/'/''/g")

        avg_in=$(echo "$item" | jq '.data.interfaces[0].avg_in')
        avg_out=$(echo "$item" | jq '.data.interfaces[0].avg_out')
        bandwidth=$(awk "BEGIN {print ($avg_in + $avg_out)/1000000}")

        avg_loss=$(echo "$item" | jq '.data.smoke.avg_loss')
        avg_latency=$(echo "$item" | jq '.data.smoke.avg_val')
        availability=$(awk "BEGIN {print 100 - $avg_loss}")

        if (( $(echo "$avg_loss > 5 || $avg_latency > 200" | bc -l) )); then
            qualidade="Ruim"
        elif (( $(echo "$avg_loss > 1 || $avg_latency > 100" | bc -l) )); then
            qualidade="Moderada"
        else
            qualidade="Boa"
        fi

        psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" <<EOF
\set client_id $client_id
\set client_name '$client_name'
\set avg_in $avg_in
\set avg_out $avg_out
\set bandwidth $bandwidth
\set avg_latency $avg_latency
\set avg_loss $avg_loss
\set availability $availability
\set qualidade '$qualidade'

INSERT INTO viaipe_metrics (
    client_id, client_name, avg_in_bps, avg_out_bps,
    bandwidth_mbps, avg_latency_ms, avg_loss_percent,
    availability_percent, qualidade
) VALUES (
    :client_id, :client_name, :avg_in, :avg_out,
    :bandwidth, :avg_latency, :avg_loss,
    :availability, :qualidade
);
EOF

    done

    echo "Aguardando $SLEEP_SECONDS segundos para próxima coleta..."
    sleep "$SLEEP_SECONDS"
done
