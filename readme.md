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
