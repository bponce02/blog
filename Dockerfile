# ---- Stage 1: build Tailwind CSS ----
FROM node:22-slim AS frontend
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
# Tailwind scans src/ templates for class names, so it needs the source tree.
COPY src ./src
RUN npx @tailwindcss/cli -i ./src/frontend/input.css -o ./src/mysite/static/css/output.css --minify

# ---- Stage 2: Python app ----
FROM python:3.12-slim-bookworm
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

ARG PUID=1000
ARG PGID=1000
RUN groupadd -g ${PGID} wagtail && \
    useradd -u ${PUID} -g wagtail -m wagtail

EXPOSE 8000
ENV PYTHONUNBUFFERED=1 \
    PORT=8000 \
    DJANGO_SETTINGS_MODULE=mysite.settings.production \
    PATH="/app/.venv/bin:$PATH"

RUN apt-get update --yes --quiet && apt-get install --yes --quiet --no-install-recommends \
    build-essential \
    libpq-dev \
    libjpeg62-turbo-dev \
    zlib1g-dev \
    libwebp-dev \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install dependencies from the lockfile (cached unless pyproject/lock change).
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev --no-install-project

# Copy the project, then the CSS built in stage 1.
COPY --chown=wagtail:wagtail src ./src
COPY --from=frontend --chown=wagtail:wagtail /app/src/mysite/static/css/output.css ./src/mysite/static/css/output.css

RUN chown -R wagtail:wagtail /app
USER wagtail
WORKDIR /app/src

# Collectstatic + migrate at startup, then serve. (Same trade-off as before:
# fine for a single-instance personal site; use a release phase if that changes.)
CMD set -xe; python manage.py collectstatic --noinput --clear; python manage.py migrate --noinput; gunicorn mysite.wsgi:application
