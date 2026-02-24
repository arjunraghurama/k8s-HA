# syntax=docker/dockerfile:1

FROM squidfunk/mkdocs-material:latest

WORKDIR /docs

COPY requirements.txt ./

RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 8000

CMD ["serve", "--dev-addr=0.0.0.0:8000"]
