# RAG (Retrieval-Augmented Generation) Skill

## Description
Implements and manages RAG systems using local LLMs (Ollama), vector databases, and embedding models.

## Auto-Activation Triggers
- User mentions: "rag", "retrieval", "embeddings", "vector database", "semantic search"
- Files matching: `src/rag/**/*`, `embeddings/**/*`
- Commands: `/rag`, `/embed`, `/search`

## Capabilities
- RAG architecture design
- Vector database setup (ChromaDB, Weaviate, Qdrant)
- Document chunking and embedding
- Semantic search implementation
- Context retrieval optimization
- LangChain / LlamaIndex integration
- Ollama local LLM integration

## RAG Architecture

```
┌─────────────────────────────────────────────────┐
│ User Query                                      │
└─────────────────┬───────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────┐
│ 1. Embed Query (nomic-embed-text)              │
└─────────────────┬───────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────┐
│ 2. Retrieve Relevant Docs (Vector DB)          │
│    - ChromaDB / Qdrant / Weaviate              │
│    - Top-k similarity search                   │
└─────────────────┬───────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────┐
│ 3. Rerank Results (optional)                   │
│    - Cohere Rerank / Cross-encoder             │
└─────────────────┬───────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────┐
│ 4. Generate Response (Ollama LLM)              │
│    - llama3, mistral, qwen2.5-coder            │
│    - Context window: Retrieved docs + Query    │
└─────────────────┬───────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────┐
│ Response to User                                │
└─────────────────────────────────────────────────┘
```

## Implementation

### 1. Setup Script

**scripts/setup-rag.sh**:
```bash
#!/bin/bash

echo "🔧 Setting up RAG environment..."

# Install Python dependencies
pip install langchain chromadb ollama sentence-transformers

# Pull Ollama models
ollama pull llama3:8b
ollama pull nomic-embed-text

# Create directories
mkdir -p data/documents data/embeddings data/vector_db

echo "✅ RAG environment setup complete"
```

### 2. Document Processing

**src/rag/document_processor.py**:
```python
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain.document_loaders import DirectoryLoader, TextLoader
from typing import List
import os

class DocumentProcessor:
    """Process documents for RAG system."""

    def __init__(self, chunk_size: int = 1000, chunk_overlap: int = 200):
        self.text_splitter = RecursiveCharacterTextSplitter(
            chunk_size=chunk_size,
            chunk_overlap=chunk_overlap,
            length_function=len,
            separators=["\n\n", "\n", ". ", " ", ""]
        )

    def load_documents(self, directory: str) -> List:
        """Load documents from directory."""
        loader = DirectoryLoader(
            directory,
            glob="**/*.{txt,md,py,js,ts}",
            loader_cls=TextLoader,
            show_progress=True
        )
        return loader.load()

    def chunk_documents(self, documents: List) -> List:
        """Split documents into chunks."""
        return self.text_splitter.split_documents(documents)

    def process_directory(self, directory: str) -> List:
        """Load and chunk all documents in directory."""
        print(f"📂 Loading documents from {directory}...")
        docs = self.load_documents(directory)
        print(f"✅ Loaded {len(docs)} documents")

        print("✂️ Chunking documents...")
        chunks = self.chunk_documents(docs)
        print(f"✅ Created {len(chunks)} chunks")

        return chunks
```

### 3. Vector Store Setup

**src/rag/vector_store.py**:
```python
from langchain.vectorstores import Chroma
from langchain.embeddings import OllamaEmbeddings
from typing import List

class VectorStore:
    """Manage vector database for RAG."""

    def __init__(self, collection_name: str = "documents"):
        self.embeddings = OllamaEmbeddings(
            model="nomic-embed-text",
            base_url="http://localhost:11434"
        )
        self.collection_name = collection_name
        self.vector_db = None

    def create_from_documents(self, documents: List, persist_directory: str):
        """Create vector store from documents."""
        print("🔢 Creating embeddings...")
        self.vector_db = Chroma.from_documents(
            documents=documents,
            embedding=self.embeddings,
            collection_name=self.collection_name,
            persist_directory=persist_directory
        )
        print(f"✅ Vector store created at {persist_directory}")

    def load(self, persist_directory: str):
        """Load existing vector store."""
        self.vector_db = Chroma(
            collection_name=self.collection_name,
            embedding_function=self.embeddings,
            persist_directory=persist_directory
        )
        print(f"✅ Vector store loaded from {persist_directory}")

    def similarity_search(self, query: str, k: int = 4) -> List:
        """Search for similar documents."""
        if not self.vector_db:
            raise ValueError("Vector store not initialized")

        return self.vector_db.similarity_search(query, k=k)

    def similarity_search_with_score(self, query: str, k: int = 4):
        """Search with relevance scores."""
        if not self.vector_db:
            raise ValueError("Vector store not initialized")

        return self.vector_db.similarity_search_with_score(query, k=k)
```

### 4. RAG Chain

**src/rag/rag_chain.py**:
```python
from langchain.llms import Ollama
from langchain.chains import RetrievalQA
from langchain.prompts import PromptTemplate

class RAGChain:
    """RAG question-answering chain."""

    def __init__(self, vector_store, model: str = "llama3:8b"):
        self.llm = Ollama(
            model=model,
            base_url="http://localhost:11434",
            temperature=0.7
        )
        self.vector_store = vector_store

        # Custom prompt template
        self.prompt_template = """Use the following context to answer the question.
If you don't know the answer, say so - don't make up information.

Context: {context}

Question: {question}

Answer:"""

        self.PROMPT = PromptTemplate(
            template=self.prompt_template,
            input_variables=["context", "question"]
        )

    def create_chain(self):
        """Create RAG chain."""
        return RetrievalQA.from_chain_type(
            llm=self.llm,
            chain_type="stuff",
            retriever=self.vector_store.vector_db.as_retriever(
                search_kwargs={"k": 4}
            ),
            chain_type_kwargs={"prompt": self.PROMPT},
            return_source_documents=True
        )

    def query(self, question: str) -> dict:
        """Query the RAG system."""
        chain = self.create_chain()
        result = chain({"query": question})

        return {
            "answer": result["result"],
            "source_documents": result["source_documents"]
        }
```

### 5. Complete RAG System

**src/rag/rag_system.py**:
```python
from .document_processor import DocumentProcessor
from .vector_store import VectorStore
from .rag_chain import RAGChain
import os

class RAGSystem:
    """Complete RAG system orchestration."""

    def __init__(
        self,
        documents_dir: str = "data/documents",
        vector_db_dir: str = "data/vector_db",
        model: str = "llama3:8b"
    ):
        self.documents_dir = documents_dir
        self.vector_db_dir = vector_db_dir
        self.model = model

        self.processor = DocumentProcessor()
        self.vector_store = VectorStore()
        self.rag_chain = None

    def initialize(self, force_rebuild: bool = False):
        """Initialize or load RAG system."""
        if force_rebuild or not os.path.exists(self.vector_db_dir):
            print("🔄 Building RAG system from scratch...")

            # Process documents
            chunks = self.processor.process_directory(self.documents_dir)

            # Create vector store
            self.vector_store.create_from_documents(chunks, self.vector_db_dir)
        else:
            print("📥 Loading existing RAG system...")
            self.vector_store.load(self.vector_db_dir)

        # Create RAG chain
        self.rag_chain = RAGChain(self.vector_store, model=self.model)
        print("✅ RAG system ready")

    def query(self, question: str) -> dict:
        """Query the RAG system."""
        if not self.rag_chain:
            raise ValueError("RAG system not initialized. Call initialize() first.")

        print(f"\n❓ Question: {question}\n")
        result = self.rag_chain.query(question)

        print(f"💡 Answer: {result['answer']}\n")
        print(f"📚 Sources ({len(result['source_documents'])} documents):")
        for i, doc in enumerate(result['source_documents'], 1):
            print(f"  {i}. {doc.metadata.get('source', 'Unknown')}")

        return result

    def add_documents(self, new_docs_dir: str):
        """Add new documents to existing RAG system."""
        print(f"📂 Adding documents from {new_docs_dir}...")

        # Process new documents
        chunks = self.processor.process_directory(new_docs_dir)

        # Add to vector store
        self.vector_store.vector_db.add_documents(chunks)

        print("✅ Documents added successfully")
```

### 6. Usage Example

**examples/rag_demo.py**:
```python
from src.rag.rag_system import RAGSystem

# Initialize RAG system
rag = RAGSystem(
    documents_dir="data/documents",
    vector_db_dir="data/vector_db",
    model="llama3:8b"
)

# Build or load
rag.initialize(force_rebuild=False)

# Query
result = rag.query("How do I implement authentication in FastAPI?")

# Add more documents
rag.add_documents("data/new_docs")
```

## Advanced Techniques

### 1. Hybrid Search (Keyword + Semantic)
Combine BM25 (keyword) with vector search for better retrieval.

### 2. Reranking
Use cross-encoder models to rerank retrieved documents.

### 3. Query Expansion
Expand user query with synonyms, related terms.

### 4. Contextual Compression
Compress retrieved context to fit in LLM context window.

### 5. Multi-Query RAG
Generate multiple queries from user question for better coverage.

## Best Practices
- **Chunk Size**: 500-1500 tokens (depends on domain)
- **Overlap**: 10-20% of chunk size
- **Top-k**: 3-5 documents (balance relevance vs context length)
- **Embedding Model**: nomic-embed-text (best for local, open-source)
- **LLM**: llama3:8b for speed, llama3:70b for quality
- **Metadata**: Store source, timestamp, author for citation
- **Evaluation**: Use RAGAS framework to measure RAG quality
- **Caching**: Cache embeddings to avoid recomputation

## Monitoring
- Track query latency
- Monitor embedding quality (similarity distributions)
- Measure answer relevance
- Log failed queries for improvement
