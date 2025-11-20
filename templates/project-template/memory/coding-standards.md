# Coding Standards

## General Principles

1. **Readability over cleverness**: Write code for humans first, computers second
2. **DRY (Don't Repeat Yourself)**: Extract common patterns into reusable functions
3. **SOLID principles**: Follow object-oriented design principles
4. **Fail fast**: Validate inputs early and throw meaningful errors
5. **Test-driven**: Write tests alongside code, not after

## Python Standards

### Style Guide
- Follow PEP 8
- Use Black formatter (line length: 88)
- Use type hints for all function signatures
- Docstrings in Google style format

### Example
```python
from typing import List, Optional

def calculate_total(items: List[float], discount: Optional[float] = None) -> float:
    """Calculate total price with optional discount.

    Args:
        items: List of item prices
        discount: Optional discount percentage (0-100)

    Returns:
        Total price after discount

    Raises:
        ValueError: If discount is not between 0 and 100
    """
    if discount is not None and not 0 <= discount <= 100:
        raise ValueError("Discount must be between 0 and 100")

    total = sum(items)
    if discount:
        total *= (1 - discount / 100)

    return round(total, 2)
```

### Import Organization
```python
# Standard library
import os
import sys
from typing import List

# Third-party
import numpy as np
import pandas as pd

# Local imports
from src.utils import helper
from src.models import User
```

## JavaScript/TypeScript Standards

### Style Guide
- Use Prettier for formatting
- Use ESLint with Airbnb config
- Prefer TypeScript over JavaScript for new code
- Use async/await over callbacks

### Example
```typescript
interface User {
  id: string;
  name: string;
  email: string;
}

/**
 * Fetch user by ID
 * @param userId - Unique user identifier
 * @returns User object or null if not found
 */
async function fetchUser(userId: string): Promise<User | null> {
  try {
    const response = await fetch(`/api/users/${userId}`);

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    return await response.json();
  } catch (error) {
    console.error('Failed to fetch user:', error);
    return null;
  }
}
```

## Git Commit Messages

Follow Conventional Commits:

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, no logic change)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

### Examples
```
feat(auth): add JWT token refresh mechanism

Implement automatic token refresh when access token expires.
Tokens are refreshed silently in the background.

Closes #123
```

```
fix(api): handle null values in user profile

Previously, null values in optional fields caused 500 errors.
Now they are properly handled and returned as null in JSON.
```

## Testing Standards

### Python Testing (pytest)
```python
import pytest
from src.calculator import calculate_total

def test_calculate_total_basic():
    """Test basic total calculation."""
    assert calculate_total([10.0, 20.0, 30.0]) == 60.0

def test_calculate_total_with_discount():
    """Test calculation with discount."""
    assert calculate_total([100.0], discount=10) == 90.0

def test_calculate_total_invalid_discount():
    """Test that invalid discount raises ValueError."""
    with pytest.raises(ValueError):
        calculate_total([100.0], discount=150)
```

### JavaScript Testing (Jest)
```javascript
describe('fetchUser', () => {
  it('should return user when found', async () => {
    const user = await fetchUser('123');
    expect(user).toHaveProperty('id', '123');
  });

  it('should return null when user not found', async () => {
    const user = await fetchUser('nonexistent');
    expect(user).toBeNull();
  });
});
```

## Documentation Standards

### README Structure
1. Project overview
2. Installation instructions
3. Usage examples
4. API documentation
5. Contributing guidelines
6. License

### Code Comments
```python
# Good: Explain WHY, not WHAT
# Use cached value to avoid expensive database query
cached_user = get_from_cache(user_id)

# Bad: Obvious comment
# Increment counter by 1
counter += 1
```

## Error Handling

### Python
```python
# Use specific exceptions
class UserNotFoundError(Exception):
    """Raised when user cannot be found."""
    pass

# Provide context in error messages
raise UserNotFoundError(f"User with ID {user_id} not found")
```

### JavaScript
```javascript
// Custom error classes
class ValidationError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'ValidationError';
  }
}

// Meaningful error messages
throw new ValidationError(`Invalid email format: ${email}`);
```

## API Design

### RESTful Endpoints
```
GET    /api/v1/users          # List users
GET    /api/v1/users/:id      # Get user
POST   /api/v1/users          # Create user
PUT    /api/v1/users/:id      # Update user
DELETE /api/v1/users/:id      # Delete user
```

### Response Format
```json
{
  "success": true,
  "data": {
    "id": "123",
    "name": "John Doe"
  },
  "meta": {
    "timestamp": "2025-11-20T10:00:00Z"
  }
}
```

### Error Response
```json
{
  "success": false,
  "error": {
    "code": "USER_NOT_FOUND",
    "message": "User with ID 123 not found",
    "details": {}
  }
}
```

## Security Best Practices

1. **Never log sensitive data**: Passwords, tokens, API keys
2. **Validate all inputs**: Sanitize user input to prevent injection
3. **Use parameterized queries**: Prevent SQL injection
4. **Hash passwords**: Use bcrypt or Argon2
5. **Secure headers**: Set CORS, CSP, HSTS headers
6. **Rate limiting**: Prevent abuse
7. **HTTPS only**: In production

## Performance Guidelines

1. **Database queries**: Use indexes, avoid N+1 queries
2. **Caching**: Cache expensive operations
3. **Async operations**: Use async/await for I/O
4. **Lazy loading**: Load data only when needed
5. **Compression**: Enable gzip for API responses

---

**Remember**: These are guidelines, not laws. Use judgment when exceptions make sense, but document why.
