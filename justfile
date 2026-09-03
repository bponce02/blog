default:
    @just --list

tailwind:
    npx @tailwindcss/cli -i ./src/mysite/static/css/input.css -o ./src/mysite/static/css/output.css --watch=always

[parallel]
dev: tailwind runserver

build-css:
    npx @tailwindcss/cli -i ./src/mysite/static/css/input.css -o ./src/mysite/static/css/output.css --minify

runserver:
    uv run src/manage.py runserver

migrate:
    uv run src/manage.py migrate

makemigrations:
    uv run src/manage.py makemigrations
