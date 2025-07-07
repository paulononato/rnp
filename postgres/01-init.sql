CREATE TABLE IF NOT EXISTS ping_metrics (
    id SERIAL PRIMARY KEY,
    target VARCHAR(255) NOT NULL,
    response_time_ms FLOAT,
    packet_loss_percent FLOAT,
    http_status_code INTEGER,
    http_load_time_ms FLOAT,
    created_at TIMESTAMP NOT NULL
);
