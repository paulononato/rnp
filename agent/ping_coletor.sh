#!/bin/bash

# Configurações (podem vir do docker-compose)
DB_HOST="${DB_HOST:-postgres}"
DB_PORT="${DB_PORT:-5432}"
DB_NAME="${DB_NAME:-docker-db}"
DB_USER="${DB_USER:-docker-user}"
DB_PASSWORD="${DB_PASSWORD:-docker-pass}"

SITES=(${TARGETS:-"google.com github.com uol.com.br"})
PACKET_COUNT="${PACKET_COUNT:-30}"
SLEEP_SECONDS="${SLEEP_SECONDS:-60}"

export PGPASSWORD="$DB_PASSWORD"

while true; do
    NOW=$(date +"%Y-%m-%d %H:%M:%S")

    for SITE in "${SITES[@]}"; do
        PING_RESULT=$(ping -c "$PACKET_COUNT" -W 3 "$SITE" 2>/dev/null)

        if echo "$PING_RESULT" | grep -q "received"; then
            AVG_LINE=$(echo "$PING_RESULT" | grep 'rtt' || echo "")
            if [ -n "$AVG_LINE" ]; then
                AVG_MS=$(echo "$AVG_LINE" | awk -F '/' '{print $5}')
                PACKET_LOSS=0.0
            else
                AVG_MS="NULL"
                PACKET_LOSS=100.0
            fi
        else
            AVG_MS="NULL"
            PACKET_LOSS=100.0
        fi

        psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "
            INSERT INTO ping_metrics (target, response_time_ms, packet_loss_percent, created_at)
            VALUES ('$SITE', $AVG_MS, $PACKET_LOSS, '$NOW');
        "
    done

    sleep "$SLEEP_SECONDS"
done
