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
    nome VARCHAR(255),
    ip VARCHAR(50),
    banda_mbps INTEGER,
    uptime_percent FLOAT,
    downtime_percent FLOAT,
    qualidade VARCHAR(50),
    timestamp TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
