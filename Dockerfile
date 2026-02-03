FROM jupyter/scipy-notebook:latest

USER root

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

USER ${NB_UID}

# Install Python packages for the workshop
RUN pip install --no-cache-dir \
    senzing-grpc \
    psycopg2-binary \
    lancedb \
    pandas \
    networkx \
    pyvis \
    python-dotenv

# Set working directory
WORKDIR /workspace
