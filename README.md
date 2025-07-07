# **RNP - Ambiente de Teste com PostgreSQL**

Este ambiente foi criado para fins de validação e coleta de dados com um banco PostgreSQL pronto para uso. 
O ambiente utiliza arquitetura Docker e Docker Compose.

A solução possui 4 containers:
- postgres - Utilizado para banco de dados
- agent    - SO Linux com os recursos de ip-utils (PING) e CURL, para obter dados de performance de pacotes e páginas web, respectivamente.
- grafana  - container para provisionar uma instância do Grafana e visualizar dados.
- viaipe-agent - SO Linux com um script em Python para tratar os dados da API e gravar no banco de dados. Foi escolhido python tenho mais prática para manipular json, tratar caracteres, e inserir no banco de dados.

O container do agente possui um shell script chamado ping_coletor.sh que envia 30 pacotes para os destinos, a cada 30 segundos, calcula as perdas e tempos de resposta, e envia os resultados para o banco de dados postgres.
Foi criada uma tabela no postgres com arquitetura de simples leitura para o grafana interpretar. A tabela principal tem o nome ping_metrics e possui as colunas id, target, response_time_ms, packet_loss_percent, http_status_code, http_load_time_ms, created_at.

Deixei o container do grafana para ser acessado pela web no endereço:
http://homolog.elevartech.com.br:3000
Usuario: admin 
Password: adminrnp

---

## **Requisitos mínimos**

- Linux com Docker e Docker Compose instalados
- Versões validadas:
  - Docker Engine: **28.3.1**
  - Docker Compose: **v2.38.1**
## **Dependências **

O container agent precisa dos seguintes componentes: curl, iputils-ping, postgresql-client, ca-certificates
O container viaipe-agent precisa dos seguintes componentes: python3, python3-pip, python3-venv, curl, libpq-dev, gcc.

---

## **Instalação do Docker e Compose no Ubuntu**

```bash
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

---

## **Passos para execução**

### 1. Clonar o repositório

```bash
git clone https://github.com/paulononato/rnp.git
```

### 2. Acessar o diretorio rnp/infra e executar o docker compose

Executar o docker compose

```bash
docker compose up -d
```
## [INFO] **Detalhes do PostgreSQL**

- Host interno (entre containers): `postgres`
- Porta exposta: `5432`
- Banco de dados: `docker-db`
- Usuário: `docker-user`
- Senha: `docker-pass`

### 5. Acesasr o Grafana na porta 3000
http://[ip_do_docker]:3000

Deixei o container do grafana para ser acessado pela web no endereço:
http://homolog.elevartech.com.br:3000
Usuario: admin 
Password: adminrnp


### 6. Conectar Grafana a fonte de dados Postgres
1- Menu Grafana
2- Connections
3- Data sources
4- Add Datasource (Pesquisar por Postgresql)
5- Preencher com os dados:
Host URL: postgres:5432
database name: docker-db
Username: docker-user
Password: docker-pass

### 7. Importar o JSON do painel criado
1- Acessar o Menu Dashboards
2- Apertar o botão NEW, em seguida IMPORT
3- Fazer upload do JSON abaixo.

O jSON está no repositório e pode  pode ser baixado do link: 
Atenção: É necessário alterar o UID do DataSource do JSON. O UID tem que ser o mesmo do datasource que você conectou no passo 6.

https://github.com/paulononato/rnp/blob/main/grafana/rnp.json
blob:https://github.com/d3eb68bd-45f6-4542-a6b4-56b2f0eebfc6
