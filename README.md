# RNP - Ambiente de Teste com PostgreSQL

Este ambiente foi criado para fins de validação e coleta de dados com um banco PostgreSQL pronto para uso. A solução utiliza Docker e Docker Compose.

## Arquitetura

A aplicação é composta por quatro containers integrados em uma rede Docker:

- **postgres**: Banco de dados PostgreSQL.
- **viaipe-agent**: Container Linux com script Python que consome a API do ViaIpe, trata os dados e os insere no banco.
- **ping-client**: Container Linux com `ping` e `curl`, executando o script `ping_coletor.sh` que realiza testes de rede e envia os dados para o banco.
- **grafana**: Interface web para visualização dos dados via dashboards.

Fluxo de dados:
1. O `ping-client` coleta dados de conectividade (latência, perda, HTTP) e envia para o banco.
2. O `viaipe-agent` consome periodicamente a API pública do ViaIpe e insere os dados tratados no banco.
3. O `grafana` se conecta ao PostgreSQL e exibe os dados dos dois agentes em painéis interativos.

## Container `ping-client`

Executa o shell script `ping_coletor.sh` que:
- Envia 30 pacotes ICMP a cada 30 segundos para os destinos definidos.
- Calcula perda de pacotes, tempo médio de resposta e também coleta status HTTP e tempo de carregamento.
- Insere os dados na tabela `ping_metrics`.

### Estrutura da Tabela `ping_metrics`

Esta tabela armazena as métricas coletadas pelos pings e requisições HTTP realizadas pelo `ping-client`.

| Coluna               | Tipo           | Descrição                                                                 |
|----------------------|----------------|---------------------------------------------------------------------------|
| `id`                 | integer        | Identificador único (chave primária).                                     |
| `target`             | text           | Endereço de destino do ping ou requisição HTTP.                           |
| `response_time_ms`   | double precision | Tempo médio de resposta do ping em milissegundos.                       |
| `packet_loss_percent`| double precision | Porcentagem de perda de pacotes do ping.                                |
| `http_status_code`   | integer        | Código de status HTTP retornado na requisição (ex: 200, 404, etc.).       |
| `http_load_time_ms`  | double precision | Tempo de carregamento da página em milissegundos.                       |
| `created_at`         | timestamp      | Momento em que os dados foram coletados.                                  |

---

## Container `viaipe-agent`

Executa o script Python `viaipe_agent.py`, que:
- Consome a API pública do ViaIpe: https://viaipe.rnp.br/api/norte
- Trata os dados (bandwidth, latência, perdas, disponibilidade)
- Calcula uma classificação de qualidade (Boa, Moderada, Ruim)
- Insere na tabela `viaipe_metrics` do banco PostgreSQL

### Estrutura da Tabela `viaipe_metrics`

Esta tabela armazena os dados obtidos da API do ViaIpe com informações de banda, latência, perda e disponibilidade.

| Coluna                | Tipo                 | Descrição                                                                 |
|-----------------------|----------------------|---------------------------------------------------------------------------|
| `id`                  | integer              | Identificador único (chave primária).                                     |
| `client_id`           | text                 | Identificador do cliente na API do ViaIpe.                                |
| `client_name`         | varchar(255)         | Nome do cliente.                                                          |
| `avg_in_bps`          | double precision     | Média de tráfego de entrada em bps.                                       |
| `avg_out_bps`         | double precision     | Média de tráfego de saída em bps.                                         |
| `bandwidth_mbps`      | double precision     | Banda média total (entrada + saída) convertida para Mbps.                 |
| `avg_latency_ms`      | double precision     | Latência média em milissegundos.                                          |
| `avg_loss_percent`    | double precision     | Porcentagem média de perda de pacotes.                                    |
| `availability_percent`| double precision     | Disponibilidade calculada (100 - perda).                                  |
| `qualidade`           | varchar(50)          | Classificação da qualidade com base na latência e perda.                  |
| `collected_at`        | timestamp            | Timestamp da coleta dos dados.  

## Acesso ao Grafana

O Grafana dessa solução está disponível via web:

http://homolog.elevartech.com.br:3000  
Usuário: admin  
Senha: adminrnp

## Requisitos

- Linux com Docker e Docker Compose instalados

### Versões testadas

- Docker Engine: 28.3.1  
- Docker Compose: v2.38.1

## Dependências

**Container `agent`**:
- curl
- iputils-ping
- postgresql-client
- ca-certificates

**Container `viaipe-agent`**:
- python3
- python3-pip
- python3-venv
- curl
- libpq-dev
- gcc

## Instalação do Docker e Docker Compose no Ubuntu

```bash
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

## Passos para execução

1. **Clonar o repositório**

```bash
git clone https://github.com/paulononato/rnp.git
```

2. **Executar o Docker Compose**

```bash
cd rnp/infra
docker compose up -d
```

### Dados de conexão do PostgreSQL

- Host interno: postgres  
- Porta: 5432  
- Banco: docker-db  
- Usuário: docker-user  
- Senha: docker-pass

3. **Acessar o Grafana**

http://[ip_do_host]:3000  
Usuário: admin  
Senha: adminrnp

O Grafana dessa solução está disponível via web:

http://homolog.elevartech.com.br:3000  
Usuário: admin  
Senha: adminrnp


## Conectar Grafana ao PostgreSQL

1. Vá até o menu lateral do Grafana  
2. Acesse `Connections > Data sources > Add data source`  
3. Selecione **PostgreSQL**  
4. Preencha os dados:

- Host: postgres:5432  
- Database: docker-db  
- Username: docker-user  
- Password: docker-pass

## Importar JSON do Dashboard

1. No Grafana, vá em `Dashboards > New > Import`  
2. Faça upload do JSON localizado no repositório:

https://github.com/paulononato/rnp/blob/main/grafana/rnp.json
https://github.com/paulononato/rnp/blob/main/grafana/viaipe.json

**Importante**: Altere o `uid` do datasource no JSON para ser igual ao UID criado no passo anterior (ao configurar o PostgreSQL).

![Dashboard 1](https://i.postimg.cc/g099KYWC/img01.png)

![Dashboard 2](https://i.postimg.cc/3R7PPnW9/img02.png)
