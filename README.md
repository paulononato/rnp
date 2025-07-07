# **RNP - Ambiente de Teste com PostgreSQL**

Este ambiente foi criado para fins de teste e coleta de dados com um banco PostgreSQL pronto para uso. Ele utiliza Docker e Docker Compose e executa um script de inicialização para criar a estrutura da base.

---

## **Requisitos mínimos**

- Linux com Docker e Docker Compose instalados
- Versões validadas:
  - Docker Engine: **28.3.1**
  - Docker Compose: **v2.38.1**

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

### 2. Subir o ambiente Postgres

```bash
cd rnp/postgres
docker compose up -d
```
## [INFO] **Detalhes do PostgreSQL**

- Host interno (entre containers): `postgres`
- Porta exposta: `5432`
- Banco de dados: `docker-db`
- Usuário: `docker-user`
- Senha: `docker-pass`

### 3. Subir o agent

```bash
cd rnp/agent
docker compose up -d
```
### 4. Subir o Grafana

```bash
cd rnp/grafana
docker compose up -d
```
### 5. Acesasr o Grafana na porta 3000
http://[ip_do_docker]:3000
Acessar com as credenciais:

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
https://github.com/paulononato/rnp/blob/main/grafana/rnp.json
blob:https://github.com/d3eb68bd-45f6-4542-a6b4-56b2f0eebfc6
