#!/bin/bash

DB_HOST="${DB_HOST:-postgres}"
DB_PORT="${DB_PORT:-5432}"
DB_NAME="${DB_NAME:-docker-db}"
DB_USER="${DB_USER:-docker-user}"
DB_PASSWORD="${DB_PASSWORD:-docker-pass}"

SITES=(${TARGETS:-"google.com github.com uol.com.br"})
PACKET_COUNT="${PACKET_COUNT:-30}"
SLEEP_SECONDS="${SLEEP_SECONDS:-60}"

export PGPASSWORD="$DB_PASSWORD"

run_check_for_site() {
    SITE=$1
    NOW=$(date +"%Y-%m-%d %H:%M:%S")

    # --- PING ---
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

    # --- HTTP ---
    HTTP_DATA=$(curl -o /dev/null -s -w "%{http_code} %{time_total}" --max-time 5 "http://$SITE")
    HTTP_STATUS=$(echo "$HTTP_DATA" | awk '{print $1}')
    HTTP_TIME=$(echo "$HTTP_DATA" | awk '{print $2}')
    if [ -z "$HTTP_STATUS" ]; then
        HTTP_STATUS="NULL"
        HTTP_TIME="NULL"
    else
        HTTP_TIME=$(awk "BEGIN {print $HTTP_TIME * 1000}")  # converte para ms
    fi

    # --- INSERT ---
    psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "
        INSERT INTO ping_metrics (
            target, response_time_ms, packet_loss_percent,
            http_status_code, http_load_time_ms, created_at
        ) VALUES (
            '$SITE', $AVG_MS, $PACKET_LOSS, $HTTP_STATUS, $HTTP_TIME, '$NOW'
        );
    "
}

while true; do
    for SITE in "${SITES[@]}"; do
        run_check_for_site "$SITE" &
    done

    wait
    sleep "$SLEEP_SECONDS"
done
