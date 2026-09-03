default:
    @just --list

tailwind:
    npx @tailwindcss/cli -i ./src/frontend/input.css -o ./src/mysite/static/css/output.css --watch=always

[parallel]
dev: tailwind runserver

build-css:
    npx @tailwindcss/cli -i ./src/frontend/input.css -o ./src/mysite/static/css/output.css --minify

runserver:
    uv run src/manage.py runserver

migrate:
    uv run src/manage.py migrate

makemigrations:
    uv run src/manage.py makemigrations

docker-build:
    docker build -t ghcr.io/bponce02/blog-site:latest .

docker-push: docker-build
    docker push ghcr.io/bponce02/blog-site:latest
