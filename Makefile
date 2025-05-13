# Caminhos padrão
COMPOSE=docker compose
PROJECT_NAME=reverb

# Variáveis dinâmicas
DOMAIN=$(shell grep ^REVERB_DOMAIN .env | cut -d '=' -f2)
REDIS_HOST=$(shell grep ^REDIS_HOST .env | cut -d '=' -f2)

# ==========================
# :: Ambiente de Desenvolvimento ::
# ==========================

dev:
	@echo "🚀 Subindo ambiente local com Redis: $(REDIS_HOST)"
ifeq ($(REDIS_HOST),redis)
	$(COMPOSE) -f docker-compose.yml -f docker-compose.override.yml -f docker-compose.redis.yml --project-name $(PROJECT_NAME)-dev up --build -d
else
	$(COMPOSE) -f docker-compose.yml -f docker-compose.override.yml --project-name $(PROJECT_NAME)-dev up --build -d
endif
	@echo "✅ Ambiente local disponível em http://localhost"

stop-dev:
	@echo "⛔ Parando ambiente local..."
ifeq ($(REDIS_HOST),redis)
	$(COMPOSE) -f docker-compose.yml -f docker-compose.override.yml -f docker-compose.redis.yml --project-name $(PROJECT_NAME)-dev down
else
	$(COMPOSE) -f docker-compose.yml -f docker-compose.override.yml --project-name $(PROJECT_NAME)-dev down
endif

# ==========================
# :: Ambiente de Produção ::
# ==========================

prod:
	@if [ -z "$(DOMAIN)" ]; then \
		echo "❌ REVERB_DOMAIN não encontrado no .env. Execute 'make cert' primeiro."; \
		exit 1; \
	fi
	@echo "🔐 Verificando certificado SSL para $(DOMAIN)..."
	@if [ ! -f "/etc/letsencrypt/live/$(DOMAIN)/fullchain.pem" ]; then \
		echo "📄 Certificado não encontrado. Executando 'make cert'..."; \
		make cert; \
	fi
	@echo "🚀 Subindo ambiente de produção (HTTPS) para $(DOMAIN)..."
	$(COMPOSE) -f docker-compose.yml --project-name $(PROJECT_NAME)-prod up --build -d
	@echo "✅ Ambiente produção disponível em https://$(DOMAIN)"

stop-prod:
	@echo "⛔ Parando ambiente de produção..."
	$(COMPOSE) -f docker-compose.yml --project-name $(PROJECT_NAME)-prod down

# ==========================
# :: Utilitários ::
# ==========================

cert:
	@./generate-cert.sh

status:
	docker ps

info:
	@echo ""
	@echo "🔧 Ambiente atual:"
	@echo "🔹 REVERB_DOMAIN = $(DOMAIN)"
	@echo "🔹 REDIS_HOST    = $(REDIS_HOST)"
	@echo ""

clean:
	@echo "🔥 Limpando containers, volumes e órfãos..."
	$(COMPOSE) down -v --remove-orphans
