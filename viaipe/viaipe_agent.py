import requests
import psycopg2
import time

import os

DB_HOST = os.getenv("DB_HOST", "postgres")
DB_PORT = os.getenv("DB_PORT", "5432")
DB_NAME = os.getenv("DB_NAME", "docker-db")
DB_USER = os.getenv("DB_USER", "docker-user")
DB_PASSWORD = os.getenv("DB_PASSWORD", "docker-pass")
API_URL = os.getenv("API_URL", "https://viaipe.rnp.br/api/norte")
SLEEP_SECONDS = int(os.getenv("SLEEP_SECONDS", 3600))


def calcular_qualidade(avg_loss, avg_latency):
    if avg_loss > 5 or avg_latency > 200:
        return "Ruim"
    elif avg_loss > 1 or avg_latency > 100:
        return "Moderada"
    return "Boa"


def main():
    while True:
        print("Coletando dados da API do ViaIpe...")

        try:
            response = requests.get(API_URL, timeout=10)
            response.raise_for_status()
            data = response.json()
        except Exception as e:
            print(f"Erro ao buscar dados da API: {e}")
            time.sleep(SLEEP_SECONDS)
            continue

        try:
            conn = psycopg2.connect(
                host=DB_HOST,
                port=DB_PORT,
                dbname=DB_NAME,
                user=DB_USER,
                password=DB_PASSWORD
            )
            cursor = conn.cursor()

            for item in data:
                client_id = item.get("id")
                client_name = item.get("name", "").replace("'", "''")

                interfaces = item.get("data", {}).get("interfaces", [])
                smoke = item.get("data", {}).get("smoke", {})

                avg_in = interfaces[0].get("avg_in", 0) if interfaces else 0
                avg_out = interfaces[0].get("avg_out", 0) if interfaces else 0
                avg_loss = smoke.get("avg_loss", 0)
                avg_latency = smoke.get("avg_val", 0)

                bandwidth = (avg_in + avg_out) / 1_000_000
                availability = 100 - avg_loss
                qualidade = calcular_qualidade(avg_loss, avg_latency)

                cursor.execute("""
                    INSERT INTO viaipe_metrics (
                        client_id, client_name, avg_in_bps, avg_out_bps,
                        bandwidth_mbps, avg_latency_ms, avg_loss_percent,
                        availability_percent, qualidade
                    ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
                """, (
                    client_id, client_name, avg_in, avg_out,
                    bandwidth, avg_latency, avg_loss,
                    availability, qualidade
                ))

            conn.commit()
            cursor.close()
            conn.close()
            print("Dados inseridos com sucesso.")

        except Exception as e:
            print(f"Erro ao inserir no banco: {e}")

        print(f"Aguardando {SLEEP_SECONDS} segundos para próxima coleta...")
        time.sleep(SLEEP_SECONDS)


if __name__ == "__main__":
    main()
