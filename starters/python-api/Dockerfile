# Python API — Platform Service
# Build stage (minimal for Python)
FROM python:3.12-slim AS builder
ARG GIT_SHA=unknown
ARG SERVICE_NAME=python-api
ARG RUNTIME=python

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Runtime stage
FROM python:3.12-slim
ARG GIT_SHA=unknown
ARG SERVICE_NAME=python-api
ARG RUNTIME=python

LABEL org.opencontainers.image.revision="${GIT_SHA}"
LABEL platform.service="${SERVICE_NAME}"
LABEL platform.runtime="${RUNTIME}"

RUN useradd -m app
USER app
WORKDIR /app

COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin
COPY app ./app
COPY requirements.txt .

ENV PYTHONUNBUFFERED=1
ENV PORT=3000
EXPOSE 3000

# PORT overridden at runtime via K8s/Helm
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "3000"]
