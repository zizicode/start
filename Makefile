.PHONY: help install start stop restart status logs update clean backup health

help: ## Mostrar ayuda
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

install: ## Instalar y configurar todo el servidor
	@echo "Ejecutando instalación completa..."
	sudo ./scripts/setup-server.sh

start: ## Iniciar todos los servicios
	docker-compose up -d

stop: ## Detener todos los servicios
	docker-compose down

restart: ## Reiniciar todos los servicios
	docker-compose restart

status: ## Mostrar estado de todos los servicios
	@./scripts/manage-services.sh status

logs: ## Mostrar logs de todos los servicios
	docker-compose logs -f

logs-api: ## Mostrar logs solo del API
	docker-compose logs -f api

update: ## Actualizar imágenes y reiniciar servicios
	@./scripts/manage-services.sh update

clean: ## Limpiar recursos Docker no utilizados
	@./scripts/manage-services.sh clean

backup: ## Crear backup de configuraciones
	@./scripts/manage-services.sh backup

health: ## Verificar salud de todos los servicios
	@./scripts/health-check.sh

tailscale-status: ## Mostrar estado completo de Tailscale
	@./scripts/manage-services.sh tailscale

configure-funnel: ## Configurar Tailscale Funnel
	sudo ./scripts/configure-funnel.sh