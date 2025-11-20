# Coding Standards and Best Practices

## Purpose

This document defines **language-specific coding standards, conventions, and best practices** for all projects using the meta-env template. These standards ensure code consistency, maintainability, and quality across different technology stacks.

---

## I. Universal Principles (All Languages)

### 1.1 Code Organization

**File Naming**:
- Use consistent naming convention per language ecosystem
- Avoid special characters except `-`, `_`, `.`
- Descriptive names that reflect module purpose

**Directory Structure**:
- Separate source code (`src/`), tests (`tests/`), and configuration
- Group by feature/domain, not by file type (avoid deep `models/`, `views/`, `controllers/`)
- Keep directory depth under 5 levels

**File Size**:
- Maximum 500 lines per file (soft limit)
- Extract into modules when approaching limit
- Each file should have single clear responsibility

### 1.2 Code Style

**Formatting**:
- Use automated formatters (Black, Prettier, rustfmt)
- Enforce formatting in CI/CD and pre-commit hooks
- Never debate style in code reviews (tools decide)

**Naming Conventions**:
- Clear, descriptive names over short abbreviations
- Avoid single-letter variables except loop counters
- Name reveals intent: `getUserById` not `get`

**Comments**:
- Code should be self-documenting when possible
- Comment "why" not "what"
- Update comments when changing code
- Remove commented-out code (use version control)

### 1.3 Error Handling

**Explicit Error Handling**:
- Never silently swallow exceptions
- Log errors with sufficient context
- Use specific exception types, not generic

**Fail Fast**:
- Validate inputs early
- Throw exceptions on invalid state
- Don't continue execution with corrupt data

---

## II. Python Standards

### 2.1 Style Guide

**Base**: PEP 8 with modern Python practices

**Formatting**:
- **Tool**: Black (line length: 88)
- **Import Sorting**: isort with Black compatibility
- **Linting**: ruff (fast, comprehensive)

**Type Hints** (Required for Python 3.10+):
```python
def calculate_total(items: list[Item], discount: float = 0.0) -> Decimal:
    """Calculate total price with optional discount.

    Args:
        items: List of items to calculate total for
        discount: Discount percentage (0.0-1.0)

    Returns:
        Total price after discount

    Raises:
        ValueError: If discount is outside valid range
    """
    if not 0.0 <= discount <= 1.0:
        raise ValueError(f"Discount must be 0.0-1.0, got {discount}")

    subtotal = sum(item.price for item in items)
    return subtotal * (1 - Decimal(str(discount)))
```

### 2.2 File Organization

**Module Structure**:
```python
"""Module docstring explaining purpose."""

# Standard library imports
import os
import sys
from pathlib import Path

# Third-party imports
import requests
from sqlalchemy import create_engine

# Local application imports
from .models import User
from .utils import validate_email

# Constants
MAX_RETRY_ATTEMPTS = 3
DEFAULT_TIMEOUT = 30

# Module-level functions
def public_function():
    """Public API of module."""
    pass

def _private_helper():
    """Internal helper function."""
    pass

# Classes
class MyClass:
    """Class definition."""
    pass
```

### 2.3 Best Practices

**Data Classes** (Python 3.10+):
```python
from dataclasses import dataclass
from datetime import datetime

@dataclass
class User:
    id: int
    email: str
    created_at: datetime
    is_active: bool = True
```

**Context Managers**:
```python
# Good: Automatic resource cleanup
with open("file.txt") as f:
    data = f.read()

# Good: Database connections
with get_db_connection() as conn:
    result = conn.execute(query)
```

**List Comprehensions** (but readable):
```python
# Good: Simple comprehension
active_users = [u for u in users if u.is_active]

# Good: Generator for large datasets
user_ids = (u.id for u in users)

# Bad: Too complex, use regular loop
[process_item(x) for sublist in nested for x in sublist if x > 0 and is_valid(x)]
```

**Avoid Mutable Default Arguments**:
```python
# Bad
def add_item(item, items=[]):
    items.append(item)
    return items

# Good
def add_item(item, items=None):
    if items is None:
        items = []
    items.append(item)
    return items
```

### 2.4 Testing

**Framework**: pytest

**Structure**:
```python
import pytest
from myapp.calculator import calculate_total

class TestCalculateTotal:
    """Test suite for calculate_total function."""

    def test_empty_list_returns_zero(self):
        assert calculate_total([]) == 0

    def test_single_item(self):
        items = [Item(price=10.0)]
        assert calculate_total(items) == 10.0

    def test_discount_applied(self):
        items = [Item(price=100.0)]
        assert calculate_total(items, discount=0.1) == 90.0

    def test_invalid_discount_raises_error(self):
        with pytest.raises(ValueError):
            calculate_total([], discount=1.5)
```

**Fixtures**:
```python
@pytest.fixture
def sample_user():
    return User(id=1, email="test@example.com")

def test_user_creation(sample_user):
    assert sample_user.email == "test@example.com"
```

---

## III. JavaScript/TypeScript Standards

### 3.1 Style Guide

**Base**: Airbnb JavaScript Style Guide + TypeScript best practices

**Formatting**:
- **Tool**: Prettier (default config)
- **Linting**: ESLint with recommended rules
- **Type Checking**: TypeScript strict mode enabled

**TypeScript Configuration**:
```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "target": "ES2022",
    "lib": ["ES2022", "DOM", "DOM.Iterable"]
  }
}
```

### 3.2 Modern JavaScript/TypeScript

**Use Modern Syntax**:
```typescript
// Good: Arrow functions
const double = (x: number): number => x * 2;

// Good: Destructuring
const { name, email } = user;
const [first, ...rest] = array;

// Good: Template literals
const message = `Hello, ${name}!`;

// Good: Optional chaining
const city = user?.address?.city;

// Good: Nullish coalescing
const displayName = user.name ?? 'Anonymous';

// Good: Async/await over promises
async function fetchUser(id: string): Promise<User> {
  const response = await fetch(`/api/users/${id}`);
  if (!response.ok) throw new Error('Fetch failed');
  return response.json();
}
```

### 3.3 React Best Practices

**Functional Components + Hooks**:
```typescript
import { useState, useEffect } from 'react';

interface UserProfileProps {
  userId: string;
}

export function UserProfile({ userId }: UserProfileProps) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function loadUser() {
      try {
        const data = await fetchUser(userId);
        setUser(data);
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Unknown error');
      } finally {
        setLoading(false);
      }
    }

    loadUser();
  }, [userId]);

  if (loading) return <Spinner />;
  if (error) return <ErrorMessage message={error} />;
  if (!user) return null;

  return (
    <div>
      <h1>{user.name}</h1>
      <p>{user.email}</p>
    </div>
  );
}
```

**Custom Hooks**:
```typescript
function useUser(userId: string) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    let cancelled = false;

    async function load() {
      try {
        const data = await fetchUser(userId);
        if (!cancelled) {
          setUser(data);
        }
      } catch (err) {
        if (!cancelled) {
          setError(err instanceof Error ? err : new Error('Unknown error'));
        }
      } finally {
        if (!cancelled) {
          setLoading(false);
        }
      }
    }

    load();

    return () => {
      cancelled = true;
    };
  }, [userId]);

  return { user, loading, error };
}
```

### 3.4 Testing

**Framework**: Vitest (modern) or Jest (legacy)

**Component Testing**:
```typescript
import { render, screen } from '@testing-library/react';
import { UserProfile } from './UserProfile';

describe('UserProfile', () => {
  it('displays loading state initially', () => {
    render(<UserProfile userId="123" />);
    expect(screen.getByRole('progressbar')).toBeInTheDocument();
  });

  it('displays user data when loaded', async () => {
    render(<UserProfile userId="123" />);
    expect(await screen.findByText('John Doe')).toBeInTheDocument();
  });

  it('displays error on fetch failure', async () => {
    // Mock fetch to fail
    global.fetch = vi.fn(() => Promise.reject(new Error('Network error')));

    render(<UserProfile userId="123" />);
    expect(await screen.findByText(/Network error/)).toBeInTheDocument();
  });
});
```

---

## IV. Rust Standards

### 4.1 Style Guide

**Base**: Official Rust style guide

**Formatting**:
- **Tool**: rustfmt (default config)
- **Linting**: clippy with all warnings enabled
- **No Warnings**: All Clippy warnings must be fixed or explicitly allowed

**Cargo.toml**:
```toml
[package]
name = "my-app"
version = "0.1.0"
edition = "2021"

[dependencies]
serde = { version = "1.0", features = ["derive"] }
tokio = { version = "1.0", features = ["full"] }

[dev-dependencies]
criterion = "0.5"
```

### 4.2 Best Practices

**Error Handling**:
```rust
use anyhow::{Context, Result};

fn read_config(path: &str) -> Result<Config> {
    let contents = std::fs::read_to_string(path)
        .with_context(|| format!("Failed to read config from {}", path))?;

    serde_json::from_str(&contents)
        .with_context(|| "Failed to parse config JSON")
}
```

**Ownership & Borrowing**:
```rust
// Good: Borrow when possible
fn process_items(items: &[Item]) -> usize {
    items.iter().filter(|i| i.is_valid()).count()
}

// Good: Move when ownership transfer makes sense
fn consume_and_process(items: Vec<Item>) -> Result<()> {
    for item in items {
        // item is moved here
        store_item(item)?;
    }
    Ok(())
}
```

**Pattern Matching**:
```rust
match result {
    Ok(value) => println!("Success: {}", value),
    Err(e) => eprintln!("Error: {}", e),
}

// Use if-let for single pattern
if let Some(user) = find_user(id) {
    println!("Found: {}", user.name);
}
```

### 4.3 Testing

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_calculate_total() {
        let items = vec![
            Item { price: 10.0 },
            Item { price: 20.0 },
        ];
        assert_eq!(calculate_total(&items), 30.0);
    }

    #[test]
    #[should_panic(expected = "Invalid discount")]
    fn test_invalid_discount() {
        calculate_with_discount(&[], 1.5);
    }
}
```

---

## V. SQL Standards

### 5.1 Style Guide

**Formatting**:
- **Keywords**: UPPERCASE
- **Identifiers**: snake_case
- **Indentation**: 2 spaces
- **One clause per line** for readability

**Example**:
```sql
SELECT
  u.id,
  u.email,
  u.created_at,
  COUNT(o.id) AS order_count
FROM users u
LEFT JOIN orders o ON o.user_id = u.id
WHERE u.is_active = TRUE
  AND u.created_at >= '2025-01-01'
GROUP BY u.id, u.email, u.created_at
HAVING COUNT(o.id) > 0
ORDER BY u.created_at DESC
LIMIT 100;
```

### 5.2 Best Practices

**Indexing**:
```sql
-- Index frequently queried columns
CREATE INDEX idx_users_email ON users(email);

-- Composite index for multi-column queries
CREATE INDEX idx_orders_user_created ON orders(user_id, created_at);

-- Partial index for filtered queries
CREATE INDEX idx_active_users ON users(id) WHERE is_active = TRUE;
```

**Avoid N+1 Queries**:
```sql
-- Bad: Separate query per user
-- SELECT * FROM orders WHERE user_id = ?

-- Good: Single query with JOIN
SELECT
  u.id,
  u.name,
  JSON_AGG(o.*) AS orders
FROM users u
LEFT JOIN orders o ON o.user_id = u.id
GROUP BY u.id;
```

**Use Transactions**:
```sql
BEGIN;

UPDATE accounts SET balance = balance - 100 WHERE id = 1;
UPDATE accounts SET balance = balance + 100 WHERE id = 2;

COMMIT;
```

---

## VI. Docker Standards

### 6.1 Dockerfile Best Practices

**Multi-Stage Builds**:
```dockerfile
# Build stage
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

# Production stage
FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
EXPOSE 3000
CMD ["node", "dist/index.js"]
```

**Layer Optimization**:
```dockerfile
# Good: Copy package.json first (leverage cache)
COPY package.json package-lock.json ./
RUN npm ci

# Then copy source code
COPY . .

# Bad: Copy everything first (invalidates cache on any file change)
COPY . .
RUN npm ci
```

**Security**:
```dockerfile
# Run as non-root user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001
USER nextjs

# Use specific version tags
FROM node:20.10.0-alpine
```

### 6.2 Docker Compose

```yaml
version: '3.9'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgres://postgres:password@db:5432/myapp
    depends_on:
      - db
      - redis
    restart: unless-stopped

  db:
    image: postgres:15-alpine
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      - POSTGRES_PASSWORD=password
      - POSTGRES_DB=myapp
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data
    restart: unless-stopped

volumes:
  postgres_data:
  redis_data:
```

---

## VII. Git Commit Standards

### 7.1 Conventional Commits

**Format**: `<type>(<scope>): <subject>`

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Formatting, missing semicolons
- `refactor`: Code change that neither fixes bug nor adds feature
- `perf`: Performance improvement
- `test`: Adding missing tests
- `chore`: Updating build tasks, configs

**Examples**:
```
feat(auth): add JWT refresh token support

fix(api): handle timeout errors in user service

docs(readme): update installation instructions

refactor(database): extract query builders to separate module
```

### 7.2 Commit Message Body

**Format**:
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Example**:
```
feat(payments): integrate Stripe subscription management

- Add Stripe webhook handler for subscription events
- Implement subscription creation and cancellation
- Add database migrations for subscription table

Closes #123
Breaking change: Requires STRIPE_WEBHOOK_SECRET env var
```

---

## VIII. API Design Standards

### 8.1 RESTful API Conventions

**Endpoints**:
```
GET    /api/users           # List users
GET    /api/users/:id       # Get single user
POST   /api/users           # Create user
PUT    /api/users/:id       # Update user (full)
PATCH  /api/users/:id       # Update user (partial)
DELETE /api/users/:id       # Delete user

GET    /api/users/:id/orders  # Nested resources
```

**Response Format**:
```json
{
  "data": {
    "id": 123,
    "email": "user@example.com",
    "createdAt": "2025-01-15T10:30:00Z"
  },
  "meta": {
    "requestId": "abc-123"
  }
}
```

**Error Format**:
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid email format",
    "details": {
      "field": "email",
      "value": "invalid-email"
    }
  },
  "meta": {
    "requestId": "abc-123"
  }
}
```

### 8.2 API Versioning

**URL Versioning** (Recommended):
```
/api/v1/users
/api/v2/users
```

**Header Versioning** (Alternative):
```
Accept: application/vnd.myapp.v1+json
```

---

## IX. Documentation Standards

### 9.1 Code Documentation

**Functions/Methods**:
```python
def calculate_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """Calculate distance between two coordinates using Haversine formula.

    Args:
        lat1: Latitude of first point in degrees
        lon1: Longitude of first point in degrees
        lat2: Latitude of second point in degrees
        lon2: Longitude of second point in degrees

    Returns:
        Distance in kilometers

    Example:
        >>> calculate_distance(40.7128, -74.0060, 34.0522, -118.2437)
        3944.42
    """
```

**Classes**:
```typescript
/**
 * Manages user authentication and session handling.
 *
 * @example
 * ```typescript
 * const auth = new AuthManager(config);
 * const user = await auth.login(email, password);
 * ```
 */
class AuthManager {
  /**
   * Authenticates user with email and password.
   *
   * @param email - User's email address
   * @param password - User's password
   * @returns Authenticated user object
   * @throws {AuthenticationError} If credentials are invalid
   */
  async login(email: string, password: string): Promise<User> {
    // Implementation
  }
}
```

### 9.2 README Template

```markdown
# Project Name

Brief description of project purpose.

## Features

- Feature 1
- Feature 2
- Feature 3

## Installation

```bash
npm install
```

## Configuration

```bash
cp .env.example .env
# Edit .env with your settings
```

## Usage

```bash
npm run dev
```

## Testing

```bash
npm test
```

## Deployment

See [DEPLOYMENT.md](./DEPLOYMENT.md)

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md)

## License

MIT
```

---

## X. Security Standards

### 10.1 Input Validation

**Always Validate**:
```python
from pydantic import BaseModel, EmailStr, constr

class UserCreate(BaseModel):
    email: EmailStr
    password: constr(min_length=8, max_length=100)
    name: constr(min_length=1, max_length=255)
```

**Sanitize HTML**:
```typescript
import DOMPurify from 'dompurify';

function displayUserContent(html: string) {
  const clean = DOMPurify.sanitize(html);
  return <div dangerouslySetInnerHTML={{ __html: clean }} />;
}
```

### 10.2 Authentication

**Password Hashing**:
```python
import bcrypt

def hash_password(password: str) -> str:
    salt = bcrypt.gensalt(rounds=12)
    return bcrypt.hashpw(password.encode(), salt).decode()

def verify_password(password: str, hashed: str) -> bool:
    return bcrypt.checkpw(password.encode(), hashed.encode())
```

**JWT Tokens**:
```typescript
import jwt from 'jsonwebtoken';

function generateToken(userId: string): string {
  return jwt.sign(
    { userId },
    process.env.JWT_SECRET!,
    { expiresIn: '1h' }
  );
}

function verifyToken(token: string): { userId: string } {
  return jwt.verify(token, process.env.JWT_SECRET!) as { userId: string };
}
```

---

## XI. Performance Standards

### 11.1 Database Queries

**Use Indexes**:
```sql
-- Slow: Full table scan
SELECT * FROM users WHERE email = 'user@example.com';

-- Fast: Index on email
CREATE INDEX idx_users_email ON users(email);
```

**Limit Results**:
```sql
-- Always use LIMIT for listings
SELECT * FROM users ORDER BY created_at DESC LIMIT 100;
```

**Avoid SELECT ***:
```sql
-- Bad
SELECT * FROM users;

-- Good: Select only needed columns
SELECT id, email, name FROM users;
```

### 11.2 Caching

**Redis Caching**:
```python
import redis
import json

cache = redis.Redis(host='localhost', port=6379)

def get_user(user_id: int) -> User:
    # Try cache first
    cached = cache.get(f"user:{user_id}")
    if cached:
        return User(**json.loads(cached))

    # Fallback to database
    user = db.query(User).filter(User.id == user_id).first()

    # Cache for 1 hour
    cache.setex(
        f"user:{user_id}",
        3600,
        json.dumps(user.dict())
    )

    return user
```

---

## XII. Language-Specific Tooling Summary

| Language | Formatter | Linter | Type Checker | Test Framework |
|----------|-----------|--------|--------------|----------------|
| **Python** | black | ruff | mypy | pytest |
| **JavaScript** | Prettier | ESLint | - | Vitest/Jest |
| **TypeScript** | Prettier | ESLint | tsc | Vitest/Jest |
| **Rust** | rustfmt | clippy | rustc | cargo test |
| **Go** | gofmt | golangci-lint | go vet | go test |

---

**Version**: 1.0
**Last Updated**: 2025-11-20
**Maintainer**: Meta-Env Project
**Review Cycle**: Quarterly
