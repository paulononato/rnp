-- Tabela para métricas de ping e HTTP
CREATE TABLE IF NOT EXISTS ping_metrics (
    id SERIAL PRIMARY KEY,
    target VARCHAR(255) NOT NULL,
    response_time_ms FLOAT,
    packet_loss_percent FLOAT,
    http_status_code INTEGER,
    http_load_time_ms FLOAT,
    created_at TIMESTAMP NOT NULL
);

-- Tabela para métricas da API ViaIpe
CREATE TABLE IF NOT EXISTS viaipe_metrics (
    id SERIAL PRIMARY KEY,
    client_id TEXT,
    client_name VARCHAR(255),
    avg_in_bps FLOAT,
    avg_out_bps FLOAT,
    bandwidth_mbps FLOAT,
    avg_latency_ms FLOAT,
    avg_loss_percent FLOAT,
    availability_percent FLOAT,
    qualidade VARCHAR(50),
    collected_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
