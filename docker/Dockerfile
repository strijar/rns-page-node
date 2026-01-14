ARG PYTHON_VERSION=3.13
FROM python:${PYTHON_VERSION}-alpine AS builder

RUN apk add --no-cache \
    gcc \
    musl-dev \
    libffi-dev \
    cargo \
    pkgconfig \
    python3-dev \
    linux-headers

RUN pip install --no-cache-dir poetry

WORKDIR /app
COPY pyproject.toml poetry.lock* README.md ./
COPY rns_page_node ./rns_page_node

RUN poetry config virtualenvs.in-project true && \
    poetry install --no-interaction --no-ansi --only main && \
    poetry build --format wheel && \
    .venv/bin/pip install dist/*.whl

FROM python:${PYTHON_VERSION}-alpine

ARG VERSION
ARG VCS_REF
ARG BUILD_DATE

LABEL org.opencontainers.image.created=$BUILD_DATE \
      org.opencontainers.image.title="RNS Page Node" \
      org.opencontainers.image.description="A simple way to serve pages and files over the Reticulum network." \
      org.opencontainers.image.url="https://git.quad4.io/RNS-Things/rns-page-node" \
      org.opencontainers.image.documentation="https://git.quad4.io/RNS-Things/rns-page-node/src/branch/main/README.md" \
      org.opencontainers.image.source="https://git.quad4.io/RNS-Things/rns-page-node" \
      org.opencontainers.image.version=$VERSION \
      org.opencontainers.image.revision=$VCS_REF \
      org.opencontainers.image.vendor="RNS-Things" \
      org.opencontainers.image.licenses="GPL-3.0" \
      org.opencontainers.image.authors="Sudo-Ivan" \
      org.opencontainers.image.base.name="python:${PYTHON_VERSION}-alpine"

RUN addgroup -S app && adduser -S app -G app

WORKDIR /app

COPY --from=builder /app/.venv /app/.venv
ENV PATH="/app/.venv/bin:$PATH"

RUN mkdir -p pages files node-config && \
    chown -R app:app /app

USER app
VOLUME ["/app/pages", "/app/files", "/app/node-config"]

ENTRYPOINT ["rns-page-node"]
