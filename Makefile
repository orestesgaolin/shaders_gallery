# Shaders Gallery - Development Commands

.PHONY: help install copy-shaders run build clean

help: ## Show this help message
	@echo "Shaders Gallery - Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

install: ## Install Flutter dependencies
	flutter pub get

copy-shaders: ## Copy shader files to assets directory
	dart scripts/copy_shaders.dart

run: copy-shaders ## Run the app (with shader copy)
	flutter run

build: copy-shaders ## Build the web app (with shader copy)
	flutter build web

clean: ## Clean build artifacts and assets
	flutter clean
	rm -rf assets/shaders/
	rm -rf build/

dev: install copy-shaders run ## Full development setup and run
