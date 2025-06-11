reset:
	docker compose down -v
	docker system prune --all --volumes --force
	docker compose up -d --force-recreate
