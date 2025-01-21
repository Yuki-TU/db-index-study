.DEFAULT_GOAL := help

.PHONY: db
db: ## dbに入る
	@docker compose exec db mysql sample -u root

.PHONY: up
up: ## コンテナ起動
	@docker compose up -d

.PHONY: migrate
migrate:  ## マイグレーション
	@docker compose exec -T bastion mysqldef -u admin -p password -h db -P 3306 sample < ./schema.sql

.PHONY: down
down: ## コンテナ停止
	@docker compose down

.PHONY: insert
insert: ## データ挿入
	@docker compose exec -T bastion ./insert.sh

.PHONY: help
help: ## ヘルプ
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
