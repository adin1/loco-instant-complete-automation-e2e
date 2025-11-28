# OpenSearch Module

This module provides CRUD integration with OpenSearch for NestJS applications.

## Installation

```bash
npm install nestjs-opensearch @opensearch-project/opensearch
```

*nestjs-opensearch* is already configured as a dependency.

## Configuration

The OpenSearch client is configured in `opensearch.module.ts`. Update your environment variables or adjust as necessary:

- `OPENSEARCH_NODE` (default: `http://localhost:9200`)
- `OPENSEARCH_USERNAME` (default: `admin`)
- `OPENSEARCH_PASSWORD` (default: `admin`)

## Endpoints

Accessible at `/opensearch/{index}/{id}`

- **POST** `/opensearch/:index/:id` — Create document
  - Body: `{ "document": { ... } }`
- **GET** `/opensearch/:index/:id` — Get document
- **PUT** `/opensearch/:index/:id` — Update document
  - Body: `{ "document": { ... } }`
- **DELETE** `/opensearch/:index/:id` — Delete document

## DTO

Document bodies are validated with `class-validator`. Example body:

```json
{
  "document": {
    "field1": "value1",
    "field2": 42
  }
}
```

## Example Usage

To create a document in an index named `users` with id `123`:

```http
POST /opensearch/users/123
Content-Type: application/json

{
  "document": {
    "name": "Alice",
    "email": "alice@email.com"
  }
}
```

## Extending

Expand the `CreateOpensearchDto` for stricter typing as needed. See `opensearch/create-opensearch.dto.ts`.
