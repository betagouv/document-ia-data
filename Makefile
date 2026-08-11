VENV := .venv
DBT := $(VENV)/bin/dbt

.PHONY: help install deps db-up db-down debug build run test lint docs clean

help:
	@grep -E '^[a-z-]+:.*?##' $(MAKEFILE_LIST) | sed 's/:.*##/\t/'

install: ## Crée le virtualenv et installe dbt
	python3 -m venv $(VENV)
	$(VENV)/bin/pip install --upgrade pip
	$(VENV)/bin/pip install -r requirements.txt
	$(DBT) deps

deps: ## Installe les packages dbt déclarés dans packages.yml
	$(DBT) deps

debug: ## Vérifie la configuration et la connexion
	$(DBT) debug

build: ## Exécute seeds, modèles, snapshots et tests
	$(DBT) build

run: ## Exécute les modèles
	$(DBT) run

test: ## Exécute les tests
	$(DBT) test

lint: ## Lint les modèles SQL avec sqlfluff
	$(VENV)/bin/sqlfluff lint models/

docs: ## Génère et sert la documentation
	$(DBT) docs generate
	$(DBT) docs serve

clean: ## Supprime les artefacts dbt
	$(DBT) clean
