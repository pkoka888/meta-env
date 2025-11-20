# Testing & Quality Assurance Skill

## Description
Generates comprehensive unit tests, integration tests, e2e tests with high coverage and edge case handling.

## Auto-Activation Triggers
- User mentions: "test", "testing", "coverage", "unit test", "integration test"
- Files matching: `tests/**/*.py`, `tests/**/*.js`, `tests/**/*.test.ts`
- Commands: `/test`, `/coverage`, `/e2e`

## Capabilities
- Unit test generation (pytest, jest, vitest)
- Integration test creation
- E2E test scenarios (Playwright, Cypress)
- Test coverage analysis
- Edge case identification
- Mock and fixture generation
- Test documentation

## Workflow

### 1. Test Planning
When testing is requested:
1. Analyze codebase structure
2. Identify testable units
3. Determine test types needed (unit, integration, e2e)
4. Check existing test coverage
5. Create test plan

### 2. Unit Test Generation

**Python (pytest)**:
```python
import pytest
from src.module import function_to_test

class TestFunctionName:
    """Test suite for function_to_test."""

    def test_happy_path(self):
        """Test normal operation with valid inputs."""
        result = function_to_test(valid_input)
        assert result == expected_output

    def test_edge_case_empty_input(self):
        """Test behavior with empty input."""
        result = function_to_test("")
        assert result == expected_empty_result

    def test_edge_case_null_input(self):
        """Test behavior with None input."""
        with pytest.raises(ValueError):
            function_to_test(None)

    def test_edge_case_large_input(self):
        """Test behavior with very large input."""
        large_input = "x" * 10000
        result = function_to_test(large_input)
        assert result is not None

    @pytest.mark.parametrize("input_val,expected", [
        ("test1", "result1"),
        ("test2", "result2"),
        ("test3", "result3"),
    ])
    def test_multiple_inputs(self, input_val, expected):
        """Test multiple input scenarios."""
        assert function_to_test(input_val) == expected
```

**JavaScript/TypeScript (Jest/Vitest)**:
```typescript
import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { functionToTest } from './module';

describe('functionToTest', () => {
  it('should handle normal input correctly', () => {
    const result = functionToTest('valid input');
    expect(result).toBe('expected output');
  });

  it('should handle empty input', () => {
    const result = functionToTest('');
    expect(result).toBe('');
  });

  it('should throw error on null input', () => {
    expect(() => functionToTest(null)).toThrow(TypeError);
  });

  it('should handle edge case: very long string', () => {
    const longString = 'x'.repeat(10000);
    const result = functionToTest(longString);
    expect(result).toBeDefined();
  });
});
```

### 3. Integration Test Creation
```python
# tests/integration/test_api_workflow.py
import pytest
from fastapi.testclient import TestClient
from src.main import app

@pytest.fixture
def client():
    return TestClient(app)

class TestUserWorkflow:
    """Test complete user workflow."""

    def test_user_registration_and_login(self, client):
        # Register user
        response = client.post("/api/users/register", json={
            "email": "test@example.com",
            "password": "SecurePass123!"
        })
        assert response.status_code == 201

        # Login
        response = client.post("/api/auth/login", json={
            "email": "test@example.com",
            "password": "SecurePass123!"
        })
        assert response.status_code == 200
        token = response.json()["access_token"]

        # Access protected resource
        response = client.get(
            "/api/users/profile",
            headers={"Authorization": f"Bearer {token}"}
        )
        assert response.status_code == 200
```

### 4. E2E Test Scenarios (Playwright)
```typescript
// tests/e2e/user-journey.spec.ts
import { test, expect } from '@playwright/test';

test.describe('User Registration Journey', () => {
  test('should allow user to register and complete onboarding', async ({ page }) => {
    // Navigate to app
    await page.goto('http://localhost:3000');

    // Click register
    await page.click('text=Sign Up');

    // Fill registration form
    await page.fill('input[name="email"]', 'test@example.com');
    await page.fill('input[name="password"]', 'SecurePass123!');
    await page.fill('input[name="confirmPassword"]', 'SecurePass123!');

    // Submit
    await page.click('button[type="submit"]');

    // Verify redirect to dashboard
    await expect(page).toHaveURL('/dashboard');

    // Verify welcome message
    await expect(page.locator('h1')).toContainText('Welcome');
  });
});
```

### 5. Coverage Analysis
After running tests:
```bash
# Python
pytest --cov=src --cov-report=html --cov-report=term

# JavaScript
npm run test:coverage
```

Generate coverage report in `docs/testing/coverage-report.md`

### 6. Mock Generation
```python
# tests/mocks/database_mock.py
from unittest.mock import MagicMock

class MockDatabase:
    """Mock database for testing."""

    def __init__(self):
        self.data = {}

    def get(self, key):
        return self.data.get(key)

    def set(self, key, value):
        self.data[key] = value

    def delete(self, key):
        if key in self.data:
            del self.data[key]
```

## Test Categories

### 1. Unit Tests
- **Purpose**: Test individual functions/methods
- **Scope**: Single function/class
- **Dependencies**: Mocked
- **Speed**: Fast (<1ms per test)

### 2. Integration Tests
- **Purpose**: Test component interactions
- **Scope**: Multiple components/modules
- **Dependencies**: Real or lightweight mocks
- **Speed**: Medium (10-100ms per test)

### 3. E2E Tests
- **Purpose**: Test complete user workflows
- **Scope**: Full application stack
- **Dependencies**: Real (running application)
- **Speed**: Slow (1-10s per test)

## Edge Cases to Always Test
1. **Null/None inputs**
2. **Empty inputs** (empty string, empty array, empty object)
3. **Boundary values** (min, max, 0, -1)
4. **Invalid types** (string when number expected)
5. **Very large inputs** (stress testing)
6. **Concurrent access** (race conditions)
7. **Network failures** (timeouts, errors)
8. **Permission errors** (unauthorized access)

## Test Documentation
For each test file, include:
```markdown
# Test Suite: [Module Name]

## Purpose
[What is being tested and why]

## Coverage
- Function A: ✅ 100%
- Function B: ✅ 95%
- Function C: ⚠️ 75%

## Test Scenarios
1. Happy path
2. Edge case: null input
3. Edge case: invalid type
4. Error handling

## Known Issues
- [ ] Missing test for async error handling
- [ ] Need to add performance benchmark tests

## Running Tests
```bash
pytest tests/test_module.py -v
```
```

## Best Practices
- Follow AAA pattern (Arrange, Act, Assert)
- One assertion per test (when possible)
- Clear, descriptive test names
- Test behavior, not implementation
- Aim for >80% code coverage
- Fast tests (parallelize when possible)
- Deterministic (no random failures)
- Independent tests (no shared state)
