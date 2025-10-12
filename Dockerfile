FROM python:3.14-slim

WORKDIR /app

COPY ./app/ .

RUN pip install --no-cache-dir -r requirements.txt

CMD ["nanodjango", "run", "app.py"]
