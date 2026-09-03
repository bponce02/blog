default:
    @just --list

tailwind:
    npx @tailwindcss/cli -i ./src/mysite/static/css/input.css -o ./src/mysite/static/css/output.css --watch=always

[parallel]
dev: tailwind runserver

build-css:
    npx @tailwindcss/cli -i ./src/mysite/static/css/input.css -o ./src/mysite/static/css/output.css --minify

runserver:
    cd src && uv run manage.py runserver
