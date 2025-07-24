+++
title = 'Python Naming Convention'
date = 2025-07-24T11:49:53+09:00
tags = ["python", "engineer", "general", "AI-gen"]
+++


# Python Naming Conventions: A Complete Guide

Following consistent naming conventions is crucial for writing clean, readable Python code. Here's a comprehensive guide based on PEP 8 standards.

## Files & Scripts
Use lowercase with underscores for all Python files:

```python
my_script.py
data_processor.py
api_client.py
test_user_model.py
```

## Classes
Use PascalCase (CapWords) for class names:

```python
class UserAccount:
class DataProcessor:
class APIClient:
class HTTPResponse:
```

## Functions
Use lowercase with underscores for function names:

```python
def calculate_total():
def get_user_data():
def process_payment():
def send_email_notification():
```

## Variables
Use lowercase with underscores for variable names:

```python
user_name = "john"
total_amount = 100.50
is_active = True
user_list = []
```

## Parameters
Use lowercase with underscores for function parameters:

```python
def create_user(first_name, last_name, email_address):
def calculate_tax(gross_amount, tax_rate=0.1):
def send_message(recipient_id, message_text, is_urgent=False):
```

## Constants
Use UPPERCASE with underscores for constants:

```python
MAX_RETRY_COUNT = 3
DEFAULT_TIMEOUT = 30
API_BASE_URL = "https://api.example.com"
```

## Private/Internal Elements
Use leading underscores to indicate privacy levels:

```python
# Single leading underscore for internal use
_internal_helper()
_private_variable = "hidden"

# Double leading underscore for name mangling
__private_method()
```

## Conclusion

Following these PEP 8 naming conventions will make your Python code more readable and consistent with the broader Python community standards. Consistent naming not only improves code readability but also makes collaboration with other developers much smoother.