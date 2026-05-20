# 📁 Project Folder Structure - पूरा Breakdown

---

## 🎯 Quick Overview

```
Project/
├── main.py                    ← Entry Point (सब कुछ यहाँ से start होता है)
├── requirements.txt           ← सभी dependencies
├── app/                       ← मुख्य application folder
│   ├── core/                  ← Core functionality
│   ├── models/                ← Database tables
│   ├── schemas/               ← Request/Response validation
│   ├── routers/               ← API endpoints
│   ├── services/              ← Business logic
│   ├── repositories/          ← Database operations
│   ├── rag/                   ← PDF search और retrieval
│   ├── llm/                   ← AI models (ChatGPT, etc.)
│   └── utils/                 ← Helper functions
├── tests/                     ← Testing files
├── uploads/                   ← Uploaded PDFs यहाँ save होते हैं
├── chroma_Db/                 ← Vector database (embeddings)
└── venv/                      ← Virtual environment
```

---

# 📂 हर Folder का Detailed Explanation

---

## 1️⃣ **app/core/** - Core/Basic Functionality

### 📍 Purpose:
Application की **foundation** सेटअप करना। Configuration, database, errors, और security यहाँ है।

### 📄 Files:

#### **a) config.py** - Settings/Configuration
```python
# क्या करता है?
- सभी Environment Variables (API Keys, Database URL) को एक जगह define करता है
- अलग-अलग providers के लिए configuration

# क्यों जरूरत है?
- Production में sensitive data (.env file) को code में hard-code न करना पड़े
- आसानी से development/production switching

# Variables:
DATABASE_URL       → Database का address
LLM_PROVIDER       → कौन सा AI model use करें (openrouter, azure, ollama, etc.)
OPENROUTER_API_KEY → OpenRouter API की key
AZURE_OPENAI_*     → Azure की keys
OLLAMA_*           → Local AI model के लिए

# Example:
.env file में:
    DATABASE_URL=postgresql://user:pass@localhost/dbname
    OPENROUTER_API_KEY=xxx123
```

#### **b) database.py** - Database Connection Setup
```python
# क्या करता है?
- Database से connection बनाता है
- Database tables को create करता है
- Database sessions manage करता है

# क्यों जरूरत है?
- हर request के लिए नया database connection चाहिए
- Connection को safely close करना चाहिए (error आए तो rollback करो)

# Key Functions:
1. engine = create_engine(DATABASE_URL)
   → Database से connection pool बनाता है
   
2. SessionLocal = sessionmaker()
   → हर request के लिए नया session
   
3. Base = declarative_base()
   → SQLAlchemy models के लिए base class
   
4. get_db()
   → FastAPI में Dependency Injection के लिए
   
5. initialize_database()
   → Server start होने पर सभी tables create करता है

# Usage Example:
@app.post("/create-user")
async def create_user(user_data, db: Session = Depends(get_db)):
    # get_db() automatically एक database session देता है
    db.add(new_user)
    db.commit()
    # Session automatically close हो जाता है
```

#### **c) exceptions.py** - Error Handling
```python
# क्या करता है?
- Custom errors define करता है
- Errors को JSON में convert करके return करता है

# क्यों जरूरत है?
- सभी errors को एक consistent format में return करना चाहिए
- User को proper error message मिले

# Custom Exceptions:
1. AppException(status_code, detail)
   - Base exception class
   
2. ResourceNotFoundError("User")
   - "User not found" (404) error
   
3. UnauthorizedError()
   - "Unauthorized" (403) error
   
4. ValidationError(detail)
   - "Invalid data" (422) error

# Exception Handlers:
1. app_exception_handler()
   → अपने custom exceptions को handle करता है
   
2. validation_exception_handler()
   → Request validation errors को handle करता है
   
3. sqlalchemy_exception_handler()
   → Database errors को handle करता है
   
4. general_exception_handler()
   → सभी unexpected errors को handle करता है

# Usage Example:
# किसी endpoint में:
if not user:
    raise ResourceNotFoundError("User")

# Automatically exception handler call होगा
# Response: {"detail": "User not found"} (status: 404)
```

#### **d) logging.py** - Logging Setup
```python
# क्या करता है?
- सभी logs को file में save करता है
- Logs को organize करता है

# क्यों जरूरत है?
- Debugging के लिए हर काम का record होना चाहिए
- Production में errors को track करने के लिए

# Configuration:
logger.add("app.log", rotation="10 MB", retention="7 days")
- File: app.log में logs save होते हैं
- Rotation: 10 MB से ज्यादा हुआ तो नई file
- Retention: 7 दिन बाद पुरानी logs delete कर दो

# Usage:
logger.info("कुछ सामान्य information")
logger.warning("Warning: कुछ ध्यान देने वाली बात")
logger.error("Error: कुछ गलत हुआ")
```

#### **e) middleware.py** - Request/Response Processing
```python
# क्या करता है?
- सभी incoming requests और outgoing responses को process करता है

# क्यों जरूरत है?
- Logging: हर request/response का record रखना
- Rate Limiting: Excessive requests को block करना
- Security: Authentication check करना

# Middlewares:
1. LoggingMiddleware
   - हर request को log करता है
   - Response time calculate करता है
   
2. RateLimitMiddleware
   - एक IP से ज्यादा requests को रोकता है
   - DoS attacks से बचाता है
```

#### **f) security.py** - Password Protection
```python
# क्या करता है?
- Passwords को encrypt करता है (bcrypt)
- Password को verify करता है

# क्यों जरूरत है?
- Passwords को plain text में store करना unsafe है
- Database hack हुआ तो भी passwords safe रहेंगे

# Functions:
1. hash_password(password)
   - Plain password को encrypted hash में convert करता है
   - 72 bytes से ज्यादा को trim करता है
   
2. verify_password(plain_password, hashed_password)
   - Login करते समय: दिया गया password hash से match है?

# Usage:
# Registration:
user.hashed_password = hash_password(user_password)
db.add(user)
db.commit()

# Login:
if verify_password(entered_password, stored_hash):
    print("Login successful!")
else:
    print("Wrong password!")
```

---

## 2️⃣ **app/models/** - Database Tables Definition

### 📍 Purpose:
Database की **tables को define करना** (SQLAlchemy ORM)

### 📄 Files:

#### **a) user.py** - Users Table
```python
# क्या represent करता है?
सभी registered users का data

# Database Table:
┌─────────────────────────────────────┐
│ USERS TABLE                         │
├─────────────────────────────────────┤
│ id (PK)          │ username        │
│ email            │ hashed_password │
│ conversations →  │ (relationship)  │
└─────────────────────────────────────┘

# Fields:
- id: Unique identifier
- username: Login name (unique)
- email: Email address (unique)
- hashed_password: Encrypted password
- conversations: Relationship (एक user के कई conversations)

# क्यों जरूरत है?
- User authentication के लिए
- किसका conversation है यह track करने के लिए
```

#### **b) conversation.py** - Conversations Table
```python
# क्या represent करता है?
Users के साथ Chat conversations

# Example:
User: John
├─ Conversation 1: "Python Learning"
├─ Conversation 2: "Document Analysis"
└─ Conversation 3: "Code Review"

# Database Table:
┌──────────────────────────────────────┐
│ CONVERSATIONS TABLE                  │
├──────────────────────────────────────┤
│ id (PK)  │ user_id (FK)  │ title    │
│ created_at │ updated_at   │ messages │
└──────────────────────────────────────┘

# क्यों जरूरत है?
- Chat history को organize करने के लिए
- Multiple conversations simultaneously रख सकते हैं
```

#### **c) message.py** - Messages Table
```python
# क्या represent करता है?
Conversation में individual messages

# Example:
Conversation: "Python Learning"
├─ Message 1: role="user", content="Loop कैसे लिखते हैं?"
├─ Message 2: role="assistant", content="Python में for loop..."
├─ Message 3: role="user", content="While loop के बारे में?"
└─ Message 4: role="assistant", content="While loop..."

# Database Table:
┌──────────────────────────────────────┐
│ MESSAGES TABLE                       │
├──────────────────────────────────────┤
│ id (PK)│conversation_id│role       │
│ content│created_at    │provider    │
└──────────────────────────────────────┘

# Fields:
- id: Unique message ID
- conversation_id: किस conversation में है
- role: "user" या "assistant"
- content: Message का text
- provider: कौन सा LLM use किया (openrouter, azure, etc.)
- created_at: Timestamp

# क्यों जरूरत है?
- Conversation history maintain करने के लिए
- LLM को पुरानी messages दिखाने के लिए (context के लिए)
```

#### **d) document.py** - Documents Table
```python
# क्या represent करता है?
Uploaded PDF files का metadata

# Database Table:
┌──────────────────────────────────────┐
│ DOCUMENTS TABLE                      │
├──────────────────────────────────────┤
│ id (PK) │ user_id │ filename       │
│ file_path│upload_date│embeddings_id│
└──────────────────────────────────────┘

# Fields:
- id: Unique document ID
- user_id: किसका document है
- filename: Original PDF file का नाम
- file_path: Server पर कहाँ है
- upload_date: कब upload हुआ

# क्यों जरूरत है?
- RAG के लिए कौन सी PDFs हैं track करना
- Document किसने upload की यह जानना
```

---

## 3️⃣ **app/schemas/** - Request/Response Validation

### 📍 Purpose:
API से आने वाले requests और जाने वाले responses को **validate करना** (Pydantic)

### 📄 Files:

#### **a) user.py** - User Schemas
```python
# क्या करता है?
User registration और response के लिए validation

# Schemas:

1. UserCreate (Request में आता है)
   {
     "username": "john_doe",
     "email": "john@example.com",
     "password": "secret123"
   }
   
2. UserResponse (API से return होता है)
   {
     "id": 1,
     "username": "john_doe",
     "email": "john@example.com"
     // password नहीं दिखाएंगे (security के लिए)
   }

# क्यों जरूरत है?
- Invalid data को block करना (wrong email, missing fields)
- Response को consistent format में देना
- API documentation auto-generate करना (swagger)
```

#### **b) conversation.py** - Conversation Schemas
```python
# Schemas:

1. CreateConversationRequest
   {
     "user_id": 1,
     "first_message": "Hello, help me with Python",
     "provider": "openrouter"
   }
   
2. ConversationResponse
   {
     "conversation_id": 5,
     "title": "Python Learning",
     "created_at": "2025-05-20T10:30:00"
   }
```

#### **c) message.py** - Message Schemas
```python
# Schemas:

1. MessageCreate
   {
     "content": "What is a function?",
     "conversation_id": 5
   }
   
2. MessageResponse
   {
     "id": 123,
     "conversation_id": 5,
     "role": "user",
     "content": "What is a function?"
   }
```

#### **d) responses.py** - Common Response Schemas
```python
# Schemas:

1. HealthResponse (health check के लिए)
   {
     "status": "healthy",
     "version": "1.0.0"
   }
   
2. ErrorResponse
   {
     "detail": "User not found"
   }
```

---

## 4️⃣ **app/routers/** - API Endpoints

### 📍 Purpose:
**HTTP endpoints define करना** (GET, POST, etc.)

### 📄 Files:

#### **a) users.py** - User Endpoints
```
Endpoints:
├─ POST /users
│  └─ नया user register करना
│     Input: username, email, password
│     Output: user_id (यह save करो!)
│
└─ GET /users/{user_id}
   └─ किसी user की information
      Input: user_id
      Output: user details
```

#### **b) conversations.py** - Conversation Endpoints
```
Endpoints:
├─ POST /conversations
│  └─ नया conversation शुरू करना
│     Input: user_id, first_message, provider
│     Output: conversation_id, LLM response
│
├─ GET /conversations/{conversation_id}
│  └─ Conversation की history देखना
│     Input: conversation_id
│     Output: सभी messages
│
└─ DELETE /conversations/{conversation_id}
   └─ Conversation delete करना
```

#### **c) messages.py** - Message Endpoints
```
Endpoints:
├─ POST /conversations/{id}/messages
│  └─ Message भेजना (chat)
│     Input: conversation_id, message text
│     Output: LLM का response
│
└─ GET /conversations/{id}/messages
   └─ सभी messages देखना
      Input: conversation_id
      Output: message history
```

#### **d) documents.py** - Document Endpoints
```
Endpoints:
├─ POST /documents/upload
│  └─ PDF upload करना
│     Input: file (PDF)
│     Output: document_id
│
├─ GET /documents
│  └─ सभी uploaded documents देखना
│     Output: document list
│
└─ DELETE /documents/{doc_id}
   └─ Document delete करना
```

#### **e) health.py** - Health Check
```
Endpoints:
├─ GET /health
│  └─ Server healthy है या नहीं check करना
│     Output: {"status": "healthy"}
```

---

## 5️⃣ **app/services/** - Business Logic

### 📍 Purpose:
**Complex operations को handle करना** (Database operations, API calls, etc.)

### 📄 Files:

#### **a) chat_service.py** - Chat Logic
```python
# क्या करता है?
Message को process करके LLM response देना

# Step-by-step:
1. Conversation verify करो (मौजूद है या नहीं)
2. Message history fetch करो
3. RAG से relevant documents निकालो
4. LLM को call करो (ChatGPT, etc.)
5. Response को database में save करो
6. User को response दो

# क्यों जरूरत है?
- Router में सीधे यह logic न रखना पड़े
- Code को reusable बनाना
- Testing आसान बनाना
```

#### **b) conversation_service.py** - Conversation Logic
```python
# क्या करता है?
Conversation को create, update, delete करना

# Functions:
- create_conversation(user_id, title)
- get_conversations(user_id)
- delete_conversation(conversation_id)
```

#### **c) rag_service.py** - RAG (Retrieval-Augmented Generation)
```python
# क्या करता है?
PDF documents में से relevant information निकालना

# Process:
1. User का question आता है
2. Vector database में search करते हैं
3. Related documents निकालते हैं
4. LLM को उन documents के साथ दे देते हैं

# क्यों जरूरत है?
- LLM को सिर्फ relevant information दो
- Large documents में specific info निकालना
```

#### **d) token_service.py** - Token Management
```python
# क्या करता है?
Authentication tokens को manage करना

# Functions:
- generate_token(user_id)
- verify_token(token)
- refresh_token(token)
```

---

## 6️⃣ **app/repositories/** - Database Operations

### 📍 Purpose:
**Database से data को fetch/save करना** (Data Access Layer)

### 📄 Files:

#### **a) user_repo.py** - User Operations
```python
# Functions:

1. create(db, username, email, password)
   → नया user बनाना
   
2. get_by_id(db, user_id)
   → किसी user को ID से खोजना
   
3. get_by_username(db, username)
   → किसी user को username से खोजना
   
4. get_all(db)
   → सभी users fetch करना
   
5. update(db, user_id, data)
   → User information update करना

# क्यों जरूरत है?
- Database queries को एक जगह रखना
- Code को DRY (Don't Repeat Yourself) बनाना
```

#### **b) conversation_repo.py** - Conversation Operations
```python
# Functions:

1. create(db, user_id, title)
   → नया conversation
   
2. get_by_id(db, conversation_id)
   → Conversation को ID से खोजना
   
3. get_by_user_id(db, user_id)
   → किसी user के सभी conversations
   
4. delete(db, conversation_id)
   → Conversation delete करना
```

#### **c) message_repo.py** - Message Operations
```python
# Functions:

1. create(db, conversation_id, role, content, provider)
   → नया message save करना
   
2. get_messages(db, conversation_id)
   → किसी conversation के सभी messages
   
3. get_latest(db, conversation_id, limit=10)
   → हाल के messages (context के लिए)
```

#### **d) document_repo.py** - Document Operations
```python
# Functions:

1. save_document(db, user_id, filename, filepath)
   → Document metadata save करना
   
2. get_documents(db, user_id)
   → किसी user की सभी documents
   
3. delete_document(db, doc_id)
   → Document delete करना
```

---

## 7️⃣ **app/rag/** - PDF Search और Retrieval

### 📍 Purpose:
**PDF files में से relevant information को खोजना** (RAG = Retrieval-Augmented Generation)

### 📄 Files:

#### **a) embeddings.py** - Text को Vectors में Convert करना
```python
# क्या करता है?
Text को numerical vectors में convert करना

# Model: sentence-transformers/all-MiniLM-L6-v2
- यह एक pre-trained model है
- हर sentence को 384 dimensions में convert करता है
- Same meaning वाले sentences के vectors similar होते हैं

# Example:
Text: "What is Python?"
Vector: [0.234, -0.123, 0.456, ..., 0.789] (384 numbers)

Text: "Python is a programming language"
Vector: [0.245, -0.131, 0.450, ..., 0.792] (similar!)

# क्यों जरूरत है?
- Vector database में search करने के लिए
- Semantic similarity निकालने के लिए
```

#### **b) vectordb.py** - Vector Database Management
```python
# क्या करता है?
Document embeddings को vector database में store करना

# Vector Database: Chroma
- Location: chroma_Db/ folder
- PDFs को embeddings में convert करके store करता है

# Process:
1. PDF upload होता है
2. PDF को chunks में divide करते हैं
3. हर chunk को embedding में convert करते हैं
4. Chroma database में store करते हैं

# क्यों जरूरत है?
- तेजी से relevant documents खोजना
- Large PDFs में specific information निकालना
```

#### **c) pdf_loader.py** - PDF को Text में Convert करना
```python
# क्या करता है?
PDF files को text में convert करना

# Process:
1. PDF file को पढ़ना
2. सभी text को extract करना
3. Chunks में divide करना (हर chunk ~500 words)

# Example:
PDF: "machine-learning.pdf"
  ↓
Text chunks:
  - Chunk 1: "Introduction to Machine Learning..."
  - Chunk 2: "Supervised learning includes..."
  - Chunk 3: "Unsupervised learning includes..."

# क्यों जरूरत है?
- Vector database को text feed करने के लिए
```

#### **d) retriever.py** - Query से Relevant Docs खोजना
```python
# क्या करता है?
User का question दिया जाए तो relevant documents return करना

# Process:
1. User का question: "Python में loops कैसे काम करते हैं?"
2. Question को embedding में convert करो
3. Vector database में similar embeddings खोजो
4. Related documents return करो

# क्यों जरूरत है?
- LLM को relevant context देना
- Accurate responses देने के लिए
```

---

## 8️⃣ **app/llm/** - AI Models (ChatGPT, etc.)

### 📍 Purpose:
**Multiple AI providers को manage करना** (OpenRouter, Azure, HuggingFace, Ollama)

### 📄 Files:

#### **a) factory.py** - Provider Selection
```python
# क्या करता है?
सही LLM provider को select करना

# Supported Providers:
1. OpenRouter (default)
   - Multiple models available
   - API: https://openrouter.ai
   
2. Azure OpenAI
   - Microsoft's ChatGPT deployment
   
3. HuggingFace
   - Open-source models
   
4. Ollama
   - Local AI models (offline)

# Usage:
provider = "openrouter"
llm = LLMFactory.get_llm(provider)
response = llm.chat([messages])

# क्यों जरूरत है?
- एक provider down हो तो दूसरा use कर सकते हैं
- Different use cases के लिए different models
```

#### **b) providers/openrouter_provider.py** - OpenRouter
```python
# क्या करता है?
OpenRouter API के through ChatGPT को call करना

# कैसे काम करता है?
1. API key load करो (.env से)
2. Message history को format करो
3. OpenRouter API को request भेजो
4. Response get करो

# क्यों जरूरत है?
- Cost-effective (multiple models available)
- Reliable और scalable
```

#### **c) providers/azure_provider.py** - Azure OpenAI
```python
# क्या करता है?
Azure के OpenAI deployment को use करना

# कैसे काम करता है?
1. Azure credentials load करो
2. Azure endpoint को query करो
3. Response return करो

# क्यों जरूरत है?
- Organizations के लिए enterprise solution
- On-premises deployment possible
```

#### **d) providers/huggingface_provider.py** - HuggingFace
```python
# क्या करता है?
HuggingFace के open-source models को use करना

# उपलब्ध models:
- Mistral
- Llama 2
- और कई सारे

# क्यों जरूरत है?
- Free और open-source
- Data privacy (कोई external API नहीं)
```

#### **e) providers/ollama_provider.py** - Ollama (Local)
```python
# क्या करता है?
Local machine पर AI models को run करना

# Setup:
1. Ollama install करो (ollama.ai से)
2. Model download करो: ollama pull llama3
3. Server start करो

# क्यों जरूरत है?
- कोई internet नहीं चाहिए
- Privacy (data locally store होता है)
- Offline mode
```

---

## 9️⃣ **app/utils/** - Helper Functions

### 📍 Purpose:
**Utility functions जो multiple places पर use होती हैं**

### 📄 Important Files:

#### **a) prompt_builder.py** - Message Formatting
```python
# क्या करता है?
Chat messages को LLM के लिए format करना

# Process:
1. पुरानी conversation history
2. RAG से निकली relevant information
3. User का नया message
4. सब को एक prompt में format करना

# क्यों जरूरत है?
- LLM को सही format में context देना
```

---

## 🔟 **uploads/** - Uploaded Files

### 📍 Purpose:
**User द्वारा upload की गई PDF files यहाँ save होती हैं**

```
uploads/
├─ user_1_document.pdf
├─ user_2_research.pdf
└─ user_3_notes.pdf
```

---

## 1️⃣1️⃣ **chroma_Db/** - Vector Database

### 📍 Purpose:
**PDF embeddings को store करना** (Vector search के लिए)

```
chroma_Db/
├─ data/
│  ├─ document_embeddings_001
│  ├─ document_embeddings_002
│  └─ ...
└─ (Chroma internal files)
```

---

## 1️⃣2️⃣ **tests/** - Testing Files

### 📍 Purpose:
**Code को test करना** (pytest)

```
tests/
├─ test_users.py
├─ test_conversations.py
├─ test_messages.py
└─ test_documents.py

# Run करना:
pytest tests/
pytest tests/test_users.py -v
```

---

## 📊 Complete Request Flow (Visual)

```
1. CLIENT REQUEST
   ↓
   POST /conversations/5/messages
   {
     "content": "Summarize the document",
     "provider": "openrouter"
   }

2. MIDDLEWARE
   ↓
   ├─ LoggingMiddleware: Request को log करता है
   └─ RateLimitMiddleware: Rate check करता है

3. ROUTER (routers/messages.py)
   ↓
   @router.post("/conversations/{id}/messages")
   def send_message(id, request):

4. SERVICE (services/chat_service.py)
   ↓
   ChatService.chat(db, conversation_id, provider, message)
   
   ├─ ConversationRepository.get_by_id() 
   │  └─ Database से conversation fetch करता है
   │
   ├─ MessageRepository.get_messages()
   │  └─ Previous messages को context के लिए fetch करता है
   │
   ├─ RAG Retriever
   │  └─ PDF से relevant information निकालता है
   │
   └─ LLMFactory.get_llm(provider)
      └─ AI model को call करता है

5. DATABASE LAYER
   ├─ repositories/
   │  ├─ conversation_repo.py
   │  ├─ message_repo.py
   │  └─ document_repo.py
   │
   └─ models/
      ├─ conversation.py
      ├─ message.py
      └─ document.py

6. RAG LAYER (rag/)
   ├─ pdf_loader.py: PDF को text में convert
   ├─ embeddings.py: Text को vectors में convert
   ├─ vectordb.py: Vector database से search
   └─ retriever.py: Relevant documents return

7. LLM LAYER (llm/)
   ├─ factory.py: Provider selection
   └─ providers/: API calls

8. RESPONSE CONSTRUCTION
   ├─ schemas/: Response को format करना
   └─ Exception handlers: Error handling

9. MIDDLEWARE (return trip)
   └─ LoggingMiddleware: Response को log करता है

10. CLIENT
    ↓
    {
      "message_id": 456,
      "content": "Document summary: ...",
      "status": 200
    }
```

---

## 📋 Folder Purpose Summary Table

| Folder | Purpose | Key Files |
|--------|---------|-----------|
| **core/** | Foundation setup | config, database, exceptions, middleware |
| **models/** | DB tables | user, conversation, message, document |
| **schemas/** | Input/Output validation | user, conversation, message, responses |
| **routers/** | HTTP endpoints | users, conversations, messages, documents |
| **services/** | Business logic | chat_service, conversation_service, rag_service |
| **repositories/** | DB operations | user_repo, conversation_repo, message_repo |
| **rag/** | PDF search | pdf_loader, embeddings, vectordb, retriever |
| **llm/** | AI models | factory, openrouter, azure, huggingface, ollama |
| **uploads/** | PDF storage | user uploaded files |
| **chroma_Db/** | Vector DB | embeddings storage |
| **tests/** | Testing | test files |

---

## 🎯 Key Concepts

### 1. **Separation of Concerns**
```
Each layer has one responsibility:
├─ Router: Request को accept करना
├─ Service: Business logic
├─ Repository: Database operations
└─ Model: Data structure
```

### 2. **Dependency Injection**
```python
@router.post("/users")
def create_user(user_data: UserCreate, db: Session = Depends(get_db)):
    # db automatically inject होता है
```

### 3. **RAG Pipeline**
```
PDF → PDF Loader → Embeddings → Vector DB → Retriever → LLM
```

### 4. **Multi-Provider LLM**
```
Same API, Different providers:
├─ OpenRouter (paid)
├─ Azure (enterprise)
├─ HuggingFace (free)
└─ Ollama (local)
```

---

## 🚀 Quick Start

```bash
# 1. Dependencies install
pip install -r requirements.txt

# 2. Configuration
cp .env.example .env
# और .env में API keys add करो

# 3. Server start
python main.py

# 4. API docs देखो
http://localhost:8000/docs

# 5. Health check
curl http://localhost:8000/health
```

---

## 📞 अगर कोई Folder समझ न आए

**app/core/** - Server को setup करने के लिए (foundation)
**app/models/** - Database की structure define करने के लिए
**app/schemas/** - Input/Output को validate करने के लिए
**app/routers/** - API endpoints define करने के लिए
**app/services/** - Complex operations के लिए
**app/repositories/** - Database से data लेने के लिए
**app/rag/** - PDFs में search करने के लिए
**app/llm/** - AI models को call करने के लिए

---

**अब आप किसी को भी पूरे project को समझा सकते हो! 🎉**






















# 📚 FastAPI Chat with RAG - पूरा Code Explanation और Middleware Guide

---

## 🎯 Table of Contents
1. [Middleware क्या है?](#middleware-क्या-है)
2. [हमारे Project में Middleware](#हमारे-project-में-middleware)
3. [Project Architecture](#project-architecture)
4. [Database Schema](#database-schema)
5. [Request-Response Flow](#request-response-flow)
6. [Code Examples और Explanation](#code-examples-और-explanation)

---

## 🛡️ Middleware क्या है?

### सरल भाषा में समझें:

**Middleware = एक Filter या Guard जो request आने के समय और response जाने के समय काम करता है।**

```
Client (Browser/Mobile) 
    ↓ Request भेजता है
    ↓
[MIDDLEWARE - पहले यहाँ रुकता है]
    ↓ अगर OK है तो आगे भेजता है
    ↓
API Server (FastAPI) - असली काम करता है
    ↓ Response देता है
    ↓
[MIDDLEWARE - फिर से यहाँ रुकता है]
    ↓ Processing करके वापस भेजता है
    ↓
Client को Response मिलता है
```

### Middleware के फायदे:

| फायदा | उदाहरण |
|-------|--------|
| **Security** | User authenticate है या नहीं check करना |
| **Logging** | सभी requests को log करना (किसने, कब, क्या किया) |
| **Rate Limiting** | एक IP से ज्यादा requests तो block करना |
| **Performance** | Response time measure करना |
| **Caching** | Repeated requests को fast deliver करना |

### Real-Life उदाहरण:
```
Bank का ATM जैसे है:
- ATM = Server
- Security Guard = Middleware (पहले ID check करता है)
- Actual Cash withdrawal = API operation
- Guard = फिर से verify करता है (log करता है)
```

---

## 🚀 हमारे Project में Middleware

हमारे FastAPI application में **2 middlewares** हैं:

### 1️⃣ **LoggingMiddleware** - सभी requests और responses को log करता है

**Purpose:** हर request और response का record रखना ताकि:
- किसने access किया
- कब access किया
- कितना समय लगा
- कौन सा endpoint

**Code:**
```python
# app/core/middleware.py

class LoggingMiddleware(BaseHTTPMiddleware):
    """Log all requests and responses"""
    
    async def dispatch(self, request: Request, call_next):
        # Request आने का time record करो
        start_time = time.time()
        
        # Request को log करो
        logger.info(
            f"Request: {request.method} {request.url.path} | "
            f"Client: {request.client.host if request.client else 'unknown'}"
        )
        # Output: Request: GET /health | Client: 192.168.1.1
        
        # असली API को call करो
        response = await call_next(request)
        
        # Response का time calculate करो
        process_time = time.time() - start_time
        
        # Response को log करो (status code और time के साथ)
        logger.info(
            f"Response: {request.method} {request.url.path} | "
            f"Status: {response.status_code} | Duration: {process_time:.2f}s"
        )
        # Output: Response: GET /health | Status: 200 | Duration: 0.02s
        
        return response
```

**यह middleware क्या करता है:**
```
1. Request आता है → start_time record करो
2. Request की details log करो (GET /health, Client IP)
3. असली endpoint को call करो
4. Response मिला → process_time calculate करो (कितना समय लगा)
5. Response की details log करो (Status code, time)
6. Response भेज दो
```

---

### 2️⃣ **RateLimitMiddleware** - एक IP से ज्यादा requests को block करता है

**Purpose:** Denial of Service (DoS) attacks को रोकना
- अगर एक IP 1 minute में 100 से ज्यादा requests भेजे तो block करना
- यह बहुत aggressive bot attacks को रोकता है

**Code:**
```python
class RateLimitMiddleware(BaseHTTPMiddleware):
    """Simple rate limiter based on IP address"""
    
    def __init__(self, app, requests_per_minute: int = 60):
        super().__init__(app)
        self.requests_per_minute = requests_per_minute  # Limit: 60 requests/minute
        self.requests = defaultdict(list)  # {IP: [request_time1, request_time2, ...]}
    
    async def dispatch(self, request: Request, call_next):
        # Client का IP address निकालो
        client_ip = request.client.host if request.client else "unknown"
        current_time = time.time()
        
        # पुरानी requests को remove करो (60 seconds से पहले की)
        self.requests[client_ip] = [
            req_time for req_time in self.requests[client_ip]
            if current_time - req_time < 60
        ]
        # Example: अगर 1 minute से पहले की requests हैं तो रखो
        
        # Check करो: क्या limit exceed हुई?
        if len(self.requests[client_ip]) >= self.requests_per_minute:
            # ज्यादा requests है, तो block करो
            logger.warning(f"Rate limit exceeded for IP: {client_ip}")
            return JSONResponse(
                status_code=429,  # 429 = Too Many Requests
                content={"detail": "Too many requests"}
            )
        
        # नया request का time record करो
        self.requests[client_ip].append(current_time)
        
        # Request को allow करो
        response = await call_next(request)
        return response
```

**Example Scenario:**
```
IP: 192.168.1.1 एक minute में:
Request 1-60: ✅ Allowed (60 requests OK)
Request 61: ❌ Blocked → 429 Too Many Requests

अगर 10 seconds बाद फिर से आता है:
Request 1-50: ✅ Allowed (पुरानी requests expire हो गईं)
```

---

## 📐 Project Architecture

### Directory Structure:
```
Project/
├── main.py                 # Entry point (FastAPI app define होता है)
├── app/
│   ├── core/              # Core functionality
│   │   ├── middleware.py   # ⭐ सभी middleware यहाँ
│   │   ├── exceptions.py   # ⭐ Error handling
│   │   ├── database.py     # ⭐ Database connection
│   │   ├── logging.py      # ⭐ Logger setup
│   │   └── config.py       # ⭐ Configuration
│   │
│   ├── models/             # Database models (SQLAlchemy)
│   │   ├── user.py         # Users table
│   │   ├── conversation.py # Conversations table
│   │   ├── message.py      # Messages table
│   │   └── document.py     # Documents table
│   │
│   ├── schemas/            # Request/Response schemas (Pydantic)
│   │   ├── user.py         # User schemas
│   │   ├── conversation.py # Conversation schemas
│   │   ├── message.py      # Message schemas
│   │   └── responses.py    # Response models
│   │
│   ├── routers/            # API endpoints
│   │   ├── users.py        # User endpoints
│   │   ├── conversations.py # Conversation endpoints
│   │   ├── messages.py     # Message endpoints
│   │   └── documents.py    # Document endpoints
│   │
│   ├── services/           # Business logic
│   ├── repositories/       # Database operations
│   ├── rag/               # RAG (Retrieval Augmented Generation)
│   └── llm/               # Language Model integration
│
├── tests/                  # Test files
├── uploads/               # PDF uploads यहाँ save होते हैं
├── chroma_Db/            # Vector database (document embeddings)
└── requirements.txt      # Python dependencies
```

---

## 🗄️ Database Schema

### 1. **Users Table** - सभी users की information

```sql
CREATE TABLE users (
    id          INTEGER PRIMARY KEY,           -- Unique ID
    username    VARCHAR(255) UNIQUE NOT NULL,  -- Login username
    email       VARCHAR(255) UNIQUE NOT NULL,  -- Email address
    hashed_password VARCHAR(255) NOT NULL      -- Password (encrypted)
);
```

**Python Model:**
```python
# app/models/user.py

class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, nullable=False)
    email = Column(String, unique=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    
    # Relationship: एक user के कई conversations हो सकते हैं
    conversations = relationship(
        "Conversation",
        back_populates="user"
    )
```

**Example Data:**
```
id | username    | email              | hashed_password
---|-------------|--------------------|-----------------------------------------
1  | john_doe    | john@example.com   | $2b$12$abcd1234...
2  | jane_smith  | jane@example.com   | $2b$12$efgh5678...
```

---

### 2. **Conversations Table** - User के साथ Chat conversations

```sql
CREATE TABLE conversations (
    id        INTEGER PRIMARY KEY,
    user_id   INTEGER FOREIGN KEY,    -- कौन user है
    title     VARCHAR(255),           -- Conversation का title
    created_at TIMESTAMP,             -- कब create हुआ
    updated_at TIMESTAMP              -- आखिरी update कब
);
```

**Relationship:**
```
User (1) ──────── (Many) Conversations
|                 |
| john_doe has    | - Conversation 1: "Python Learning"
|                 | - Conversation 2: "AI Questions"
|                 | - Conversation 3: "Code Review"
```

---

### 3. **Messages Table** - Conversation में messages

```sql
CREATE TABLE messages (
    id              INTEGER PRIMARY KEY,
    conversation_id INTEGER FOREIGN KEY,  -- कौन सी conversation में
    role            VARCHAR(50),          -- "user" या "assistant"
    content         TEXT,                 -- Message का content
    created_at      TIMESTAMP             -- कब भेजा गया
);
```

**Example Flow:**
```
Conversation ID: 1 (Title: "Python Learning")
├─ Message 1: role="user", content="Python में loop कैसे लिखते हैं?"
├─ Message 2: role="assistant", content="Python में for loop..."
├─ Message 3: role="user", content="While loop के बारे में बताओ"
└─ Message 4: role="assistant", content="While loop यह है..."
```

---

### 4. **Documents Table** - Uploaded PDF documents

```sql
CREATE TABLE documents (
    id           INTEGER PRIMARY KEY,
    user_id      INTEGER FOREIGN KEY,    -- किसका document
    filename     VARCHAR(255),           -- File का नाम
    file_path    VARCHAR(255),           -- Server पर कहाँ है
    upload_date  TIMESTAMP               -- कब upload हुआ
);
```

---

## 📡 Request-Response Flow

### Complete Example: "Hello कहो"

```
STEP 1: Frontend से Request
┌─────────────────────────────────────┐
│ POST /conversations/1/messages      │
│ {                                   │
│   "content": "Hello",               │
│   "role": "user"                    │
│ }                                   │
└─────────────────────────────────────┘
              ↓
         [Request भेजता है]
              ↓
┌─────────────────────────────────────┐
│ MIDDLEWARE 1: LoggingMiddleware     │
│ - Request को log करता है           │
│ - start_time record करता है        │
└─────────────────────────────────────┘
              ↓
         [Check करता है]
              ↓
┌─────────────────────────────────────┐
│ MIDDLEWARE 2: RateLimitMiddleware   │
│ - IP address check करता है         │
│ - अगर ज्यादा requests तो block     │
└─────────────────────────────────────┘
              ↓
         [अगर OK है तो]
              ↓
┌─────────────────────────────────────┐
│ ROUTER: @app.post("/messages")      │
│ - Request को validate करता है      │
│ - Database में entry create करता   │
│ - LLM को भेजता है response के लिए │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│ SERVICE LAYER                       │
│ - Business logic execute करता है   │
│ - Database से data fetch करता है   │
│ - RAG से relevant docs निकालता है  │
│ - LLM API को call करता है          │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│ DATABASE LAYER                      │
│ - Query execute करता है            │
│ - Data insert/update करता है       │
│ - Result return करता है            │
└─────────────────────────────────────┘
              ↓
         [Response मिलता है]
              ↓
┌─────────────────────────────────────┐
│ MIDDLEWARE 2: LoggingMiddleware     │
│ - Response को log करता है          │
│ - process_time calculate करता है   │
│ - {status, time} log करता है       │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│ RESPONSE to Frontend                │
│ {                                   │
│   "message_id": 123,                │
│   "content": "Response text",       │
│   "status": 200                     │
│ }                                   │
└─────────────────────────────────────┘
```

---

## 💻 Code Examples और Explanation

### Example 1: main.py में Middleware कैसे add होता है?

```python
# main.py

from fastapi import FastAPI
from app.core.middleware import RateLimitMiddleware, LoggingMiddleware

app = FastAPI(
    title="Chat with RAG API",
    version="1.0.0"
)

# ⭐ Middleware को app में add करना
# Important: नीचे के middleware पहले execute होते हैं!
app.add_middleware(LoggingMiddleware)  # यह दूसरा चलेगा
app.add_middleware(RateLimitMiddleware, requests_per_minute=100)  # यह पहला चलेगा

# Middleware का order:
# 1. Request आता है → RateLimitMiddleware → LoggingMiddleware → API
# 2. Response आता है → LoggingMiddleware → RateLimitMiddleware → Client
```

**Why order matters?**
```
अगर order गलत हो तो:
- Rate limit block करेगा ❌
- Logging नहीं होगी (blocked request log नहीं होगा)

सही order में:
- Request आता है
- Rate limit check होता है (allow/block करता है)
- Logging होता है (सभी requests/responses का)
- Response जाता है
```

---

### Example 2: Exception Handling (Error Processing)

```python
# app/core/exceptions.py

# Custom Exception बनाना
class AppException(Exception):
    """Base application exception"""
    def __init__(self, status_code: int, detail: str):
        self.status_code = status_code
        self.detail = detail
        super().__init__(self.detail)

# Specific exceptions
class ResourceNotFoundError(AppException):
    def __init__(self, resource: str):
        super().__init__(
            status_code=404,
            detail=f"{resource} not found"
        )

class UnauthorizedError(AppException):
    def __init__(self, detail: str = "Unauthorized"):
        super().__init__(
            status_code=403,
            detail=detail
        )

# Exception Handler (middleware की तरह काम करता है)
async def app_exception_handler(request: Request, exc: AppException):
    logger.warning(f"AppException: {exc.detail} | Path: {request.url.path}")
    return JSONResponse(
        status_code=exc.status_code,
        content={"detail": exc.detail}
    )

# main.py में add करना:
app.add_exception_handler(AppException, app_exception_handler)
```

**Usage Example:**
```python
# किसी endpoint में:
@app.get("/users/{user_id}")
async def get_user(user_id: int):
    user = db.get_user(user_id)
    
    if not user:
        raise ResourceNotFoundError("User")  # ← Exception throw करो
        # → Automatically handler call होगा
        # → Response: {"detail": "User not found"} (status: 404)
    
    return user
```

---

### Example 3: Database Models का Flow

```python
# Database Models define करना (SQLAlchemy)
from sqlalchemy import Column, Integer, String, create_engine
from sqlalchemy.orm import relationship, Session
from app.core.database import Base

class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True)
    username = Column(String, unique=True, nullable=False)
    email = Column(String, unique=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    
    # Relationship: एक user के कई conversations
    conversations = relationship("Conversation", back_populates="user")

class Conversation(Base):
    __tablename__ = "conversations"
    
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    title = Column(String)
    
    # Relationship: एक conversation एक user के पास
    user = relationship("User", back_populates="conversations")
    messages = relationship("Message", back_populates="conversation")
```

**Relationship explain:**
```
User Table             Conversation Table
┌──────┐              ┌──────────────────┐
│ id=1 │────(1:N)───→│ id=1, user_id=1  │
│ John │             │ id=2, user_id=1  │
└──────┘             └──────────────────┘

John के 2 conversations हैं
```

---

### Example 4: Schema और Validation

```python
# Request/Response को define करना (Pydantic)
from pydantic import BaseModel, EmailStr

class UserCreate(BaseModel):
    """नया user create करने के लिए schema"""
    username: str  # Required
    email: EmailStr  # Valid email होना चाहिए
    password: str  # Required

class UserResponse(BaseModel):
    """Database से user return करने के लिए schema"""
    id: int
    username: str
    email: str
    # password नहीं दिखाएंगे (security के लिए)
    
    class Config:
        from_attributes = True  # SQLAlchemy model को dict में convert करना

# Usage:
@app.post("/users", response_model=UserResponse)
async def create_user(user_data: UserCreate):
    # user_data automatically validate होगा
    # अगर email invalid है तो error दे देगा
    new_user = User(
        username=user_data.username,
        email=user_data.email,
        hashed_password=hash_password(user_data.password)
    )
    db.add(new_user)
    db.commit()
    return new_user

# Client से request:
# POST /users
# {
#   "username": "john_doe",
#   "email": "john@example.com",
#   "password": "secret123"
# }
#
# Response:
# {
#   "id": 1,
#   "username": "john_doe",
#   "email": "john@example.com"
# }
```

---

### Example 5: Routers (API Endpoints)

```python
# app/routers/users.py

from fastapi import APIRouter, Depends
from app.schemas.user import UserCreate, UserResponse
from app.services.user_service import UserService

router = APIRouter(prefix="/users", tags=["Users"])
user_service = UserService()

@router.get("/{user_id}", response_model=UserResponse)
async def get_user(user_id: int):
    """किसी user की information लाना"""
    user = user_service.get_user(user_id)
    if not user:
        raise ResourceNotFoundError("User")
    return user

@router.post("/", response_model=UserResponse)
async def create_user(user_data: UserCreate):
    """नया user create करना"""
    # Validation automatically होगी (Pydantic)
    # Email, username unique होने चाहिए
    user = user_service.create_user(user_data)
    return user

# main.py में add करना:
# app.include_router(router, tags=["Users"])
```

---

## 🎯 Middleware का Real-Life Use Cases

### Use Case 1: Authentication Check (Login verification)
```python
class AuthenticationMiddleware(BaseHTTPMiddleware):
    """यह check करता है: क्या user login है?"""
    
    async def dispatch(self, request: Request, call_next):
        # Protected routes के लिए
        if request.url.path.startswith("/api/protected"):
            token = request.headers.get("Authorization")
            if not token:
                return JSONResponse(
                    status_code=401,
                    content={"detail": "Not authenticated"}
                )
        
        response = await call_next(request)
        return response
```

### Use Case 2: CORS Handling (Cross-Origin Resource Sharing)
```python
# Different domain से requests allow करना
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://example.com", "https://app.example.com"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

### Use Case 3: Request ID Tracking
```python
import uuid

class RequestIDMiddleware(BaseHTTPMiddleware):
    """हर request को unique ID देता है (debugging के लिए)"""
    
    async def dispatch(self, request: Request, call_next):
        request_id = str(uuid.uuid4())
        request.state.request_id = request_id
        
        response = await call_next(request)
        response.headers["X-Request-ID"] = request_id
        return response

# अब हर response में X-Request-ID header होगा
# जिससे logs में सभी requests को track कर सकते हैं
```

---

## 📊 Quick Reference Table

| Component | Purpose | Location |
|-----------|---------|----------|
| **Middleware** | Request/Response को filter करना | `app/core/middleware.py` |
| **Exceptions** | Errors को handle करना | `app/core/exceptions.py` |
| **Models** | Database tables define करना | `app/models/` |
| **Schemas** | Request/Response validation | `app/schemas/` |
| **Routers** | API endpoints define करना | `app/routers/` |
| **Services** | Business logic implement करना | `app/services/` |
| **Repositories** | Database operations करना | `app/repositories/` |

---

## 🚀 Quick Start

```bash
# 1. Dependencies install करो
pip install -r requirements.txt

# 2. Server start करो
python main.py
# या
uvicorn app.main:app --reload

# 3. API documentation देखो
# Browser खोलो: http://localhost:8000/docs

# 4. Health check करो
curl http://localhost:8000/health
```

---

## 📝 Summary

### Middleware क्या है?
- **Request और response के बीच का filter**
- **Security, logging, performance check के लिए**
- **हर request/response यहाँ pass होता है**

### हमारे Project में:
1. **LoggingMiddleware** - सभी requests/responses को log करता है
2. **RateLimitMiddleware** - Excessive requests को block करता है

### Project Structure:
```
Request → Middleware → Router → Service → Repository → Database
                ↓
            Response ← Middleware ← Router ← Service ← Repository
```

---

**अगर कोई सवाल हो तो पूछो! 😊**
