# ODSC East 2026 Workshop: Entity Resolved Knowledge Graphs, The Foundation for Effective GraphRAG
### Clair J. Sullivan, PhD
### clair@clairsullivan.com
#### Last modified: March 24, 2026

Workshop materials for building entity-resolved knowledge graphs (ERKGs) and using them to improve Retrieval-Augmented Generation (RAG) pipelines. The workshop uses Senzing for entity resolution, LanceDB for vector storage, NetworkX/PyVis for graph visualization, and multiple LLM providers (Anthropic Claude, OpenAI) for the RAG chatbot.

## File Descriptions

### Setup & Infrastructure

- **[SETUP.md](SETUP.md)**: Step-by-step instructions for getting the workshop environment running: cloning the repo, starting Docker services, initializing the Senzing database, and verifying everything works. Also includes troubleshooting tips.

- **[docker-compose.yml](docker-compose.yml)**: Defines the four-container workshop stack: PostgreSQL 15 (backing database of ER results), Senzing gRPC server (entity resolution engine), JupyterLab (notebook environment with all Python dependencies), and Portainer (optional container management UI).

- **[Dockerfile](Dockerfile)**: Builds the JupyterLab container from `jupyter/scipy-notebook`, adding system build tools and all required Python packages: `senzing-grpc`, `psycopg2-binary`, `lancedb`, `pandas`, `networkx`, `pyvis`, `sentence-transformers`, `dspy-ai`, `anthropic`, and `openai`.

- **[scripts/init_database.sh](scripts/init_database.sh)**: One-time initialization script that sets up the PostgreSQL database schema.  Auto-detects the Docker network, checks whether the database is already initialized, and runs a container to initialize it, if needed.

### Notebooks

Run these in order (`00` through `07`). The `07_*` notebooks are independent alternatives — pick the one(s) matching your preferred LLM provider / framework. 

- **[00_test_setup.ipynb](notebooks/00_test_setup.ipynb)**: Verifies the workshop environment: tests PostgreSQL connectivity, Senzing gRPC reachability, license validity, configuration management, LanceDB, NetworkX, and PyVis.  Also registers the CUSTOMERS, REFERENCE, and WATCHLIST data sources and runs a round-trip test (add record, retrieve entity, search by attributes, delete record).

- **[01_truth_set.ipynb](notebooks/01_truth_set.ipynb)**: Downloads the ER demo truth set (120 customers, 22 reference, 17 watchlist records) from GitHub, loads them into Senzing, and demonstrates entity resolution in action: record merging, entity lookup, attribute search, and cross-source matching.  Purges all data at the end to leave the database clean.

- **[02_load_oo+os_data_v4.ipynb](notebooks/02_load_oo+os_data_v4.ipynb)**: Loads the workshop's primary datasets and conducts ER: 316 Open Ownership records (UK corporate ownership data) and 24 Open Sanctions records (sanctions and PEP data), both in Senzing V4 FEATURES format.  Registers the OPEN-OWNERSHIP and OPEN-SANCTIONS data sources, loads records, and verifies entity resolution statistics (282 records resolved into 196 entities).

- **[03_explore_senzing_db.ipynb](notebooks/03_explore_senzing_db.ipynb)**: Explores the ER PostgreSQL database directly: examines all 16 tables, inspects raw source records, resolved entities, record-to-entity mappings with match keys, the feature library (names, addresses, IDs), relationship edges, match key analysis, and configuration history.  

- **[04_graph_visualization_v4.ipynb](notebooks/04_graph_visualization_v4.ipynb)**: Builds and visualizes the ERKG using NetworkX and PyVis. Exports all resolved entities, constructs an entity-level graph, then builds a two-layer "true combined" graph.  Produces interactive HTML visualizations with color-coded nodes by type and data source. Includes a subgraph explorer for drilling into individual entity neighborhoods.

- **[05_rag_raw_data.ipynb](notebooks/05_rag_raw_data.ipynb)**: RAG over the raw, non-entity-resolved source data.  Clears all existing LanceDB tables, loads the original Open Sanctions (24 records) and Open Ownership (316 records) datasets, converts each JSON record into a human-readable text description, and vectorizes them with `all-MiniLM-L6-v2`.  The `ask_raw_rag` function supports both Anthropic (Claude) and OpenAI (GPT) via a `provider` parameter. 

- **[06_vectorize_ER_data_v4.ipynb](notebooks/06_vectorize_ER_data_v4.ipynb)**: Creates vector embeddings for all 196 resolved entities.  Exports entity data, builds text descriptions (name, type, data sources, address, identifiers, risk topics), embeds them with the `all-MiniLM-L6-v2` sentence transformer (384 dimensions), and stores everything in LanceDB.  Drops all existing LanceDB tables before writing to ensure a clean state. 

- **[07_anthropic_rag_v4.ipynb](notebooks/07_anthropic_rag_v4.ipynb)**: ERKG-enhanced RAG using the Anthropic API directly.  Combines vector search (LanceDB) with knowledge graph expansion (NetworkX) to retrieve not just matching entities but also their graph neighbors and relationships, then queries Claude Sonnet 4.5.  Interactive chatbot session for exploring corporate ownership and sanctions data.

- **[07_openai_rag_v4.ipynb](notebooks/07_openai_rag_v4.ipynb)**: ERKG-enhanced RAG using the OpenAI API directly.  Same architecture as the Anthropic version (vector search + graph expansion) but uses OpenAI GPT 5.4 nano as the LLM backend. Interactive chatbot session included.

- **[07_dspy_anthropic_rag_v4.ipynb](notebooks/07_dspy_anthropic_rag_v4.ipynb)**: ERKG-enhanced RAG using DSPy with Claude as the backend.  Uses DSPy's `ChainOfThought` module for structured reasoning over the knowledge graph context.  Same retrieval pipeline (vector search + graph expansion) with DSPy managing the prompt engineering.

- **[07_dspy_openai_rag_v4.ipynb](notebooks/07_dspy_openai_rag_v4.ipynb)**: ERKG-enhanced RAG using DSPy with OpenAI GPT as the backend.  Same as the DSPy/Anthropic version but configured for the OpenAI API.  Demonstrates that the DSPy abstraction makes it easy to swap LLM providers.
