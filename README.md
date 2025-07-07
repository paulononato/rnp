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

Caso esteja usando o Docker Compose clássico:

```bash
docker-compose up -d
```

---

## **Detalhes do PostgreSQL**

- Host interno (entre containers): `postgres`
- Porta exposta: `5432`
- Banco de dados: `docker-db`
- Usuário: `docker-user`
- Senha: `docker-pass`

### Acesso via terminal:

```bash
docker exec -it postgres psql -U docker-user -d docker-db
```

---

## **Conectividade entre containers**

O container está conectado à rede `rnp-network`, permitindo que outros containers se comuniquem via o hostname `postgres`.

Para usar essa rede em outro `docker-compose.yml`, adicione:

```yaml
networks:
  default:
    external: true
    name: rnp-network
```

---

## **Parar o ambiente**

```bash
docker compose down
```

---

## **Estrutura do diretório**

```
postgres/
├── docker-compose.yml
└── 01-init.sql
```

---

## **Licença**

Uso interno e experimental.
