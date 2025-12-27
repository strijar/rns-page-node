ARG PYTHON_VERSION=3.13
FROM python:${PYTHON_VERSION}-alpine

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

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

WORKDIR /app

RUN apk add --no-cache gcc python3-dev musl-dev linux-headers

RUN pip install poetry
ENV POETRY_VIRTUALENVS_IN_PROJECT=true

COPY pyproject.toml poetry.lock* ./
COPY README.md ./
COPY rns_page_node ./rns_page_node

RUN poetry install --no-interaction --no-ansi

ENV PATH="/app/.venv/bin:$PATH"

ENTRYPOINT ["poetry", "run", "rns-page-node"]
