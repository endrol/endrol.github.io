---
title: "Pythonの命名規則：完全ガイド"
emoji: "🐍"
type: "tech"
topics: ["python", "engineer", "programming", "pep8"]
published: true
---

一貫した命名規則に従うことは、読みやすくクリーンなPythonコードを書くうえで非常に重要です。PEP 8標準に基づいた総合ガイドをご紹介します。

## ファイル・スクリプト
Pythonファイルはすべて、アンダースコア区切りの小文字を使用します：

```python
my_script.py
data_processor.py
api_client.py
test_user_model.py
```

## クラス
クラス名はPascalCase（CapWords）を使用します：

```python
class UserAccount:
class DataProcessor:
class APIClient:
class HTTPResponse:
```

## 関数
関数名はアンダースコア区切りの小文字を使用します：

```python
def calculate_total():
def get_user_data():
def process_payment():
def send_email_notification():
```

## 変数
変数名はアンダースコア区切りの小文字を使用します：

```python
user_name = "john"
total_amount = 100.50
is_active = True
user_list = []
```

## パラメータ
関数のパラメータはアンダースコア区切りの小文字を使用します：

```python
def create_user(first_name, last_name, email_address):
def calculate_tax(gross_amount, tax_rate=0.1):
def send_message(recipient_id, message_text, is_urgent=False):
```

## 定数
定数はアンダースコア区切りの大文字（UPPERCASE）を使用します：

```python
MAX_RETRY_COUNT = 3
DEFAULT_TIMEOUT = 30
API_BASE_URL = "https://api.example.com"
```

## プライベート・内部要素
アクセス制限のレベルに応じて、先頭にアンダースコアを付けます：

```python
# 内部使用を示すシングルアンダースコア
_internal_helper()
_private_variable = "hidden"

# 名前修飾（マングリング）のためのダブルアンダースコア
__private_method()
```

## まとめ

PEP 8の命名規則に従うことで、Pythonコードはより読みやすくなり、Pythonコミュニティ全体の標準に沿ったものになります。一貫した命名は可読性を高めるだけでなく、他の開発者との共同作業をよりスムーズにします。
