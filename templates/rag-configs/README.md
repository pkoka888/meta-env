# RAG System Configurations

This directory contains comprehensive configuration templates for Retrieval-Augmented Generation (RAG) systems.

## Configuration Files

### 1. LangChain Configuration (`langchain-config.json`)

Complete RAG pipeline configuration using LangChain framework.

**Key Components**:
- **LLM**: Ollama with fallback to cloud providers
- **Embeddings**: Local embeddings with cloud fallback
- **Vector Store**: ChromaDB configuration
- **Retrieval**: Search and reranking settings
- **Document Processing**: Multiple loader types
- **Chain**: Conversational retrieval chain
- **Monitoring**: Prometheus and logging

**Example Usage**:

```python
import json
from langchain.vectorstores import Chroma
from langchain.embeddings import OllamaEmbeddings
from langchain.llms import Ollama
from langchain.chains import ConversationalRetrievalChain

# Load configuration
with open('templates/rag-configs/langchain-config.json') as f:
    config = json.load(f)

# Initialize embeddings
embeddings = OllamaEmbeddings(
    model=config['embeddings']['model'],
    base_url=config['embeddings']['base_url']
)

# Initialize vector store
vectorstore = Chroma(
    persist_directory=config['vector_store']['persist_directory'],
    embedding_function=embeddings,
    collection_name=config['vector_store']['collection_name']
)

# Initialize LLM
llm = Ollama(
    model=config['llm']['model'],
    base_url=config['llm']['base_url'],
    temperature=config['llm']['temperature']
)

# Create RAG chain
qa_chain = ConversationalRetrievalChain.from_llm(
    llm=llm,
    retriever=vectorstore.as_retriever(
        search_kwargs={"k": config['retrieval']['k']}
    ),
    return_source_documents=True
)

# Query
result = qa_chain({
    "question": "What is RAG?",
    "chat_history": []
})
print(result['answer'])
```

### 2. ChromaDB Configuration (`chromadb-config.json`)

Vector database configuration for persistent storage.

**Key Components**:
- **Server**: HTTP server settings
- **Client**: Persistent client configuration
- **Collections**: Multiple collection templates
- **Indexing**: Batch processing settings
- **Performance**: Cache and connection pooling
- **Backup**: Automated backup configuration
- **Monitoring**: Health checks and metrics

**Example Usage**:

```python
import chromadb
from chromadb.config import Settings
import json

# Load configuration
with open('templates/rag-configs/chromadb-config.json') as f:
    config = json.load(f)

# Initialize client
client = chromadb.Client(Settings(
    chroma_db_impl=config['client']['settings']['chroma_db_impl'],
    persist_directory=config['client']['settings']['persist_directory'],
    anonymized_telemetry=config['client']['settings']['anonymized_telemetry']
))

# Create collection
collection = client.get_or_create_collection(
    name=config['collections']['default']['name'],
    metadata=config['collections']['default']['metadata']
)

# Add documents
collection.add(
    documents=["This is a document", "This is another document"],
    metadatas=[{"source": "doc1"}, {"source": "doc2"}],
    ids=["id1", "id2"]
)

# Query
results = collection.query(
    query_texts=["search query"],
    n_results=config['query']['n_results']
)
```

### 3. Embedding Configuration (`embedding-config.json`)

Embedding model and processing pipeline configuration.

**Key Components**:
- **Models**: Primary, code, multilingual, and fallback models
- **Preprocessing**: Text cleaning and chunking
- **Batch Processing**: Concurrent processing settings
- **Caching**: Redis caching for embeddings
- **Optimization**: GPU acceleration and quantization
- **Quality**: Deduplication and validation
- **Monitoring**: Metrics and logging

**Example Usage**:

```python
import json
from langchain.embeddings import OllamaEmbeddings
from langchain.text_splitter import RecursiveCharacterTextSplitter

# Load configuration
with open('templates/rag-configs/embedding-config.json') as f:
    config = json.load(f)

# Initialize embeddings
embeddings = OllamaEmbeddings(
    model=config['models']['primary']['name'],
    base_url=config['models']['primary']['base_url']
)

# Initialize text splitter
text_splitter = RecursiveCharacterTextSplitter(
    chunk_size=config['preprocessing']['chunking']['chunk_size'],
    chunk_overlap=config['preprocessing']['chunking']['chunk_overlap'],
    separators=config['preprocessing']['chunking']['separators']
)

# Process document
text = "Your long document text here..."
chunks = text_splitter.split_text(text)

# Generate embeddings
vectors = embeddings.embed_documents(chunks)
print(f"Generated {len(vectors)} embeddings")
```

## Setup Instructions

### 1. Install Dependencies

```bash
# Python dependencies
pip install langchain chromadb sentence-transformers ollama redis

# Start Ollama
ollama pull llama3:8b
ollama pull nomic-embed-text

# Start Redis (for caching)
docker run -d -p 6379:6379 redis:latest

# Start ChromaDB (optional, if using server mode)
docker run -d -p 8000:8000 chromadb/chroma:latest
```

### 2. Configure Environment Variables

```bash
# .env file
ANTHROPIC_API_KEY=your-key-here
OPENAI_API_KEY=your-key-here
OPENROUTER_API_KEY=your-key-here
LANGCHAIN_API_KEY=your-key-here
```

### 3. Initialize RAG System

```python
from rag_system import RAGSystem

# Initialize with configuration
rag = RAGSystem(config_path='templates/rag-configs/langchain-config.json')

# Load documents
rag.load_documents('./data/docs/')

# Query
response = rag.query("What is the main topic?")
print(response)
```

## Advanced Features

### Hybrid Search

Combine semantic and keyword search:

```python
retriever = vectorstore.as_retriever(
    search_type="mmr",  # Maximum Marginal Relevance
    search_kwargs={
        "k": 4,
        "fetch_k": 20,
        "lambda_mult": 0.5
    }
)
```

### Reranking

Improve relevance with cross-encoder reranking:

```python
from langchain.retrievers import ContextualCompressionRetriever
from langchain.retrievers.document_compressors import CrossEncoderReranker

compressor = CrossEncoderReranker(
    model_name="cross-encoder/ms-marco-MiniLM-L-6-v2",
    top_n=3
)

compression_retriever = ContextualCompressionRetriever(
    base_compressor=compressor,
    base_retriever=vectorstore.as_retriever()
)
```

### Custom Metadata Filtering

Filter documents by metadata:

```python
results = vectorstore.similarity_search(
    "query text",
    k=4,
    filter={"source": "documentation", "version": "2.0"}
)
```

## Performance Optimization

### 1. Batch Processing

Process multiple queries efficiently:

```python
queries = ["query1", "query2", "query3"]
results = vectorstore.similarity_search_batch(queries, k=4)
```

### 2. Caching

Enable Redis caching for embeddings:

```python
from langchain.cache import RedisCache
import redis

cache = RedisCache(redis.Redis(host='localhost', port=6379, db=2))
```

### 3. GPU Acceleration

Enable GPU for faster embeddings:

```python
embeddings = OllamaEmbeddings(
    model="nomic-embed-text",
    base_url="http://localhost:11434",
    model_kwargs={"device": "cuda"}
)
```

## Monitoring and Observability

### Prometheus Metrics

```python
from prometheus_client import Counter, Histogram

query_counter = Counter('rag_queries_total', 'Total RAG queries')
query_latency = Histogram('rag_query_duration_seconds', 'RAG query duration')

@query_latency.time()
def query_rag(question):
    query_counter.inc()
    return qa_chain({"question": question, "chat_history": []})
```

### Logging

```python
import logging

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('logs/rag.log'),
        logging.StreamHandler()
    ]
)
```

## Troubleshooting

### Common Issues

1. **Ollama Connection Failed**
   ```bash
   # Check Ollama status
   ollama list
   curl http://localhost:11434/api/tags
   ```

2. **ChromaDB Persistence Issues**
   ```python
   # Ensure directory exists
   import os
   os.makedirs('./data/chroma_db', exist_ok=True)
   ```

3. **Out of Memory**
   - Reduce batch_size in configuration
   - Use smaller embedding models
   - Enable quantization

## Best Practices

1. **Document Chunking**: Keep chunks between 500-1500 characters
2. **Overlap**: Use 10-20% overlap for context preservation
3. **Metadata**: Add rich metadata for filtering
4. **Versioning**: Version your embeddings when updating models
5. **Monitoring**: Track query latency and relevance scores
6. **Testing**: Regularly evaluate retrieval quality

## Resources

- [LangChain Documentation](https://python.langchain.com/)
- [ChromaDB Documentation](https://docs.trychroma.com/)
- [Ollama Models](https://ollama.com/library)
- [Sentence Transformers](https://www.sbert.net/)
