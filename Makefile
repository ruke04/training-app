.PHONY: help build up down restart logs test clean db-shell db-users db-delete-users db-delete-all-users rebuild status backend-logs frontend-logs db-logs api-docs

# Default target
help:
	@echo "Available commands:"
	@echo "  make build        - Build all Docker images"
	@echo "  make up           - Start all services (detached)"
	@echo "  make down         - Stop all services"
	@echo "  make restart      - Restart all services"
	@echo "  make rebuild      - Rebuild and restart all services"
	@echo "  make logs         - Follow logs from all services"
	@echo "  make backend-logs - Follow backend logs only"
	@echo "  make frontend-logs - Follow frontend logs only"
	@echo "  make db-logs      - Follow database logs only"
	@echo "  make status       - Show status of all services"
	@echo "  make test         - Run Robot Framework tests"
	@echo "  make db-shell     - Open PostgreSQL shell"
	@echo "  make db-users     - List all users in database"
	@echo "  make db-delete-users USERNAME=username - Delete a specific user"
	@echo "  make db-delete-all-users - Delete ALL users from database"
	@echo "  make api-docs     - Open Swagger UI in browser"
	@echo "  make clean        - Stop services and remove volumes"

# Build all services
build:
	docker compose build

# Start all services in detached mode
up:
	docker compose up -d

# Stop all services
down:
	docker compose down

# Restart all services
restart:
	docker compose restart

# Rebuild and restart all services
rebuild:
	docker compose down
	docker compose build
	docker compose up -d

# Follow logs from all services
logs:
	docker compose logs -f

# Follow backend logs
backend-logs:
	docker compose logs -f backend

# Follow frontend logs
frontend-logs:
	docker compose logs -f frontend

# Follow database logs
db-logs:
	docker compose logs -f db

# Show status of all services
status:
	docker compose ps

# Run Robot Framework tests
test:
	robot -d robot-tests/test_results robot-tests/test

# Open PostgreSQL shell
db-shell:
	docker compose exec db psql -U app -d training

# List all users in database
db-users:
	docker compose exec db psql -U app -d training -c "SELECT id, username, created_at FROM users ORDER BY id;"

# Delete a specific user from database
db-delete-users:
	@if [ -z "$(USERNAME)" ]; then \
		echo "Error: USERNAME is required. Usage: make db-delete-users USERNAME=username"; \
		exit 1; \
	fi
	docker compose exec db psql -U app -d training -c "DELETE FROM users WHERE username = '$(USERNAME)';"
	@echo "User '$(USERNAME)' deleted (if it existed)."

# Delete ALL users from database
db-delete-all-users:
	docker compose exec -T db psql -U app -d training -c "DELETE FROM users;"
	@echo "All users deleted from database."

# Open API documentation in browser
api-docs:
	@echo "Opening Swagger UI at http://localhost:8080/api/api-docs"
	@open http://localhost:8080/api/api-docs || xdg-open http://localhost:8080/api/api-docs || echo "Please open http://localhost:8080/api/api-docs in your browser"

# Clean up: stop services and remove volumes
clean:
	docker compose down -v
	rm -rf robot-tests/test_results

