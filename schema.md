# E-commerce API Schema Documentation

Complete API documentation for the E-commerce HTTP API built with Fastify and TypeScript.

All example responses below are taken from real API output, so field names and value types match what the server actually returns.

## Base URL

```
https://http-api-1.zavhorodnii.org/
```

> **Note**: The port can be configured via the `PORT` environment variable. Default is 3010.

---

## Table of Contents

- [Conventions](#conventions)
- [Documentation](#documentation)
- [Health Check Endpoints](#health-check-endpoints)
- [Product Endpoints](#product-endpoints)
- [Category Endpoints](#category-endpoints)
- [Brand Endpoints](#brand-endpoints)
- [Supplier Endpoints](#supplier-endpoints)
- [User Endpoints](#user-endpoints)
- [Review Endpoints](#review-endpoints)
- [Order Endpoints](#order-endpoints)
- [Utility Endpoints](#utility-endpoints)
- [Common Response Patterns](#common-response-patterns)
- [Error Handling](#error-handling)

---

## Conventions

A few things that apply to every endpoint:

- **Booleans are `1` / `0`, not `true` / `false`.** The data is stored in SQLite, which has no boolean type. Fields such as `is_active`, `is_featured`, `is_primary`, `is_verified_purchase` and `is_approved` are returned as the numbers `1` and `0`. Compare with `=== 1` or just use truthiness.
- **Dates are strings in `YYYY-MM-DD HH:MM:SS` format (UTC)**, e.g. `"2026-10-04 16:26:14"`. Health endpoints are the exception: they return ISO 8601 timestamps.
- **Paginated lists live in `data`.** See [Pagination Response](#pagination-response).
- **Non-paginated lists are keyed by resource name** (`products`, `categories`, `brands`, `suppliers`) plus a `count`.
- **Optional fields can be `null`** (for example `sale_price`, `parent_id`, `shipping_country`, `notes`).

---

## Documentation

### GET /doc

View this API documentation rendered as an HTML page in your browser.

**Query Parameters**: None

**Response**: HTML page with full API documentation

**Example**:
```bash
# Open in browser
open https://http-api-1.zavhorodnii.org/doc

# Or use curl
curl https://http-api-1.zavhorodnii.org/doc
```

---

## Health Check Endpoints

### GET /health

Basic health check to verify the API is running.

**Query Parameters**: None

**Response**: `200 OK`
```json
{
  "status": "ok",
  "timestamp": "2026-10-21T20:02:45.998Z"
}
```

**Example**:
```bash
curl https://http-api-1.zavhorodnii.org/health
```

---

### GET /health/db

Database health check to verify database connectivity and get product count.

**Query Parameters**: None

**Response**: `200 OK`
```json
{
  "status": "ok",
  "database": "connected",
  "products_count": 61,
  "timestamp": "2026-10-21T20:02:45.998Z"
}
```

**Error Response**: `500 Internal Server Error`
```json
{
  "status": "error",
  "database": "disconnected",
  "error": "Connection failed",
  "timestamp": "2026-10-21T20:02:45.998Z"
}
```

**Example**:
```bash
curl https://http-api-1.zavhorodnii.org/health/db
```

---

## Product Endpoints

### Product object

Every product endpoint returns objects with these fields:

| Field | Type | Description |
|-------|------|-------------|
| `id` | number | Product ID |
| `name` | string | Product name |
| `description` | string \| null | Product description |
| `sku` | string | Stock keeping unit (unique) |
| `price` | number | Regular price |
| `sale_price` | number \| null | Discounted price, `null` when the product is not on sale |
| `cost_price` | number \| null | Purchase cost |
| `brand_id` | number \| null | Brand ID (see `/api/brands/:id`) |
| `supplier_id` | number \| null | Supplier ID (see `/api/suppliers/:id`) |
| `stock_quantity` | number | Units in stock |
| `min_stock_level` | number | Reorder threshold |
| `weight` | number \| null | Weight |
| `dimensions` | string \| null | Dimensions as free text, e.g. `"14x9.5x0.7"` |
| `is_active` | `1` \| `0` | Only active products are returned by the API |
| `is_featured` | `1` \| `0` | Featured flag |
| `rating_average` | number | Average review rating, 0–5 |
| `rating_count` | number | Number of ratings |
| `created_at` | string | `YYYY-MM-DD HH:MM:SS` |
| `updated_at` | string | `YYYY-MM-DD HH:MM:SS` |

> There is **no `category_id`** on a product: a product can belong to several categories (many-to-many). Use `/api/products/:id/full` to get a product's categories, or `/api/categories/:id/products` to list products of a category.

---

### GET /api/products

Get all products with pagination.

**Query Parameters**:
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `page` | number | 1 | Page number (1-based) |
| `limit` | number | 10 | Number of items per page |

**Response**: `200 OK`
```json
{
  "data": [
    {
      "id": 1,
      "name": "TechPro Laptop Pro",
      "description": "High-performance laptop with 16GB RAM and 512GB SSD",
      "sku": "TP-LP-001",
      "price": 1299.99,
      "sale_price": 1199.99,
      "cost_price": 800,
      "brand_id": 1,
      "supplier_id": 1,
      "stock_quantity": 25,
      "min_stock_level": 5,
      "weight": 4.5,
      "dimensions": "14x9.5x0.7",
      "is_active": 1,
      "is_featured": 1,
      "rating_average": 4.6,
      "rating_count": 128,
      "created_at": "2026-10-04 16:26:14",
      "updated_at": "2026-10-04 16:26:14"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 1,
    "total": 61,
    "totalPages": 61,
    "hasNext": true,
    "hasPrev": false
  }
}
```

**Example**:
```bash
# Get first page with 10 items
curl "https://http-api-1.zavhorodnii.org/api/products?page=1&limit=10"

# Get second page with 20 items
curl "https://http-api-1.zavhorodnii.org/api/products?page=2&limit=20"
```

---

### GET /api/products/:id

Get a single product by ID.

**Path Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | number | Yes | Product ID |

**Response**: `200 OK`
```json
{
  "id": 1,
  "name": "TechPro Laptop Pro",
  "description": "High-performance laptop with 16GB RAM and 512GB SSD",
  "sku": "TP-LP-001",
  "price": 1299.99,
  "sale_price": 1199.99,
  "cost_price": 800,
  "brand_id": 1,
  "supplier_id": 1,
  "stock_quantity": 25,
  "min_stock_level": 5,
  "weight": 4.5,
  "dimensions": "14x9.5x0.7",
  "is_active": 1,
  "is_featured": 1,
  "rating_average": 4.6,
  "rating_count": 128,
  "created_at": "2026-10-04 16:26:14",
  "updated_at": "2026-10-04 16:26:14"
}
```

**Error Responses**:
- `400 Bad Request`: Invalid product ID
- `404 Not Found`: Product not found
- `500 Internal Server Error`: Server error

**Example**:
```bash
# Get product with ID 1
curl https://http-api-1.zavhorodnii.org/api/products/1

# Get product with ID 25
curl https://http-api-1.zavhorodnii.org/api/products/25
```

---

### GET /api/products/:id/full

Get a product with all related data: `brand`, `supplier`, `categories` and `images` are added to the [product object](#product-object).

**Path Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | number | Yes | Product ID |

**Response**: `200 OK`
```json
{
  "id": 1,
  "name": "TechPro Laptop Pro",
  "description": "High-performance laptop with 16GB RAM and 512GB SSD",
  "sku": "TP-LP-001",
  "price": 1299.99,
  "sale_price": 1199.99,
  "cost_price": 800,
  "brand_id": 1,
  "supplier_id": 1,
  "stock_quantity": 25,
  "min_stock_level": 5,
  "weight": 4.5,
  "dimensions": "14x9.5x0.7",
  "is_active": 1,
  "is_featured": 1,
  "rating_average": 4.6,
  "rating_count": 128,
  "created_at": "2026-10-04 16:26:14",
  "updated_at": "2026-10-04 16:26:14",
  "brand": {
    "id": 1,
    "name": "TechPro",
    "description": "Professional grade technology solutions",
    "logo_url": "https://placehold.co/200x200?text=techpro",
    "website": "https://techpro.com",
    "is_active": 1,
    "created_at": "2026-10-04 16:26:14"
  },
  "supplier": {
    "id": 1,
    "name": "TechSupply Co",
    "contact_person": "Mike Johnson",
    "email": "mike@techsupply.com",
    "phone": "555-1001",
    "address": "100 Industrial Blvd",
    "city": "Austin",
    "state": "TX",
    "zip_code": "73301",
    "country": "USA",
    "is_active": 1,
    "created_at": "2026-10-04 16:26:14"
  },
  "categories": [
    {
      "id": 2,
      "name": "Computers",
      "description": "Desktop and laptop computers",
      "parent_id": 1,
      "image_url": "https://picsum.photos/seed/computers/600/400",
      "is_active": 1,
      "created_at": "2026-10-04 16:26:14"
    },
    {
      "id": 1,
      "name": "Electronics",
      "description": "Electronic devices and components",
      "parent_id": null,
      "image_url": "https://picsum.photos/seed/electronics/600/400",
      "is_active": 1,
      "created_at": "2026-10-04 16:26:14"
    }
  ],
  "images": [
    {
      "id": 1,
      "product_id": 1,
      "image_url": "https://picsum.photos/seed/laptop-pro-1/800/600",
      "alt_text": "TechPro Laptop Pro Front View",
      "is_primary": 1,
      "sort_order": 1,
      "created_at": "2026-10-04 16:26:14"
    },
    {
      "id": 2,
      "product_id": 1,
      "image_url": "https://picsum.photos/seed/laptop-pro-2/800/600",
      "alt_text": "TechPro Laptop Pro Side View",
      "is_primary": 0,
      "sort_order": 2,
      "created_at": "2026-10-04 16:26:14"
    }
  ]
}
```

Notes:
- `brand` and `supplier` are omitted when the product has no `brand_id` / `supplier_id`.
- `images` are ordered by `is_primary` (primary first), then `sort_order`, then `id`.
- Image URLs are placeholder pictures and can be opened directly in a browser or `<img>` tag.

**Error Responses**:
- `400 Bad Request`: Invalid product ID
- `404 Not Found`: Product not found
- `500 Internal Server Error`: Server error

**Example**:
```bash
# Get full product details for product ID 1
curl https://http-api-1.zavhorodnii.org/api/products/1/full
```

---

### GET /api/products/search

Search and filter products with advanced options.

**Query Parameters**:
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `page` | number | 1 | Page number |
| `limit` | number | 10 | Items per page |
| `category_id` | number | - | Filter by category ID |
| `brand_id` | number | - | Filter by brand ID |
| `min_price` | number | - | Minimum price filter (inclusive) |
| `max_price` | number | - | Maximum price filter (inclusive) |
| `in_stock` | boolean | - | `true` returns only products with `stock_quantity > 0`. Any other value is ignored |
| `is_featured` | boolean | - | `true` returns only featured products. Any other value is ignored |
| `search` | string | - | Case-insensitive substring search in product name and description |
| `sort_by` | string | `created_at` | Sort field: `price`, `rating`, `name`, `created_at` (`rating` sorts by `rating_average`). Unknown values fall back to `created_at` |
| `sort_order` | string | `desc` | Sort order: `asc` or `desc` |

**Response**: `200 OK` (same shape as `GET /api/products`)
```json
{
  "data": [
    {
      "id": 1,
      "name": "TechPro Laptop Pro",
      "description": "High-performance laptop with 16GB RAM and 512GB SSD",
      "sku": "TP-LP-001",
      "price": 1299.99,
      "sale_price": 1199.99,
      "cost_price": 800,
      "brand_id": 1,
      "supplier_id": 1,
      "stock_quantity": 25,
      "min_stock_level": 5,
      "weight": 4.5,
      "dimensions": "14x9.5x0.7",
      "is_active": 1,
      "is_featured": 1,
      "rating_average": 4.6,
      "rating_count": 128,
      "created_at": "2026-10-04 16:26:14",
      "updated_at": "2026-10-04 16:26:14"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 1,
    "totalPages": 1,
    "hasNext": false,
    "hasPrev": false
  }
}
```

**Examples**:
```bash
# Search products with text query
curl "https://http-api-1.zavhorodnii.org/api/products/search?search=laptop"

# Filter by category
curl "https://http-api-1.zavhorodnii.org/api/products/search?category_id=2"

# Filter by price range
curl "https://http-api-1.zavhorodnii.org/api/products/search?min_price=100&max_price=500"

# Filter by brand and stock
curl "https://http-api-1.zavhorodnii.org/api/products/search?brand_id=1&in_stock=true"

# Complex search with multiple filters
curl "https://http-api-1.zavhorodnii.org/api/products/search?category_id=1&min_price=200&max_price=1000&in_stock=true&sort_by=price&sort_order=asc"

# Featured products only
curl "https://http-api-1.zavhorodnii.org/api/products/search?is_featured=true"

# Search and sort by rating
curl "https://http-api-1.zavhorodnii.org/api/products/search?search=wireless&sort_by=rating&sort_order=desc"
```

---

### GET /api/products/featured

Get featured products ordered by `rating_average` (highest first). Not paginated.

**Query Parameters**:
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `limit` | number | 10 | Maximum number of featured products |

**Response**: `200 OK`
```json
{
  "products": [
    {
      "id": 58,
      "name": "Ergonomic Office Chair",
      "description": "Adjustable office chair with lumbar support",
      "sku": "EO-OC-001",
      "price": 299.99,
      "sale_price": 279.99,
      "cost_price": 180,
      "brand_id": 23,
      "supplier_id": 23,
      "stock_quantity": 35,
      "min_stock_level": 7,
      "weight": 25,
      "dimensions": "28x24x42",
      "is_active": 1,
      "is_featured": 1,
      "rating_average": 4.8,
      "rating_count": 67,
      "created_at": "2026-10-04 16:26:14",
      "updated_at": "2026-10-04 16:26:14"
    }
  ],
  "count": 1
}
```

**Example**:
```bash
# Get 5 featured products
curl "https://http-api-1.zavhorodnii.org/api/products/featured?limit=5"

# Get all featured products (default 10)
curl https://http-api-1.zavhorodnii.org/api/products/featured
```

---

### GET /api/products/:id/reviews

Get approved reviews for a specific product with pagination. Each review also carries the reviewer's `username`, `first_name` and `last_name`.

**Path Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | number | Yes | Product ID |

**Query Parameters**:
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `page` | number | 1 | Page number |
| `limit` | number | 10 | Reviews per page |

**Response**: `200 OK`
```json
{
  "data": [
    {
      "id": 1,
      "product_id": 1,
      "user_id": 1,
      "rating": 5,
      "title": "Excellent laptop!",
      "comment": "This laptop exceeded my expectations. Fast performance and great build quality.",
      "is_verified_purchase": 1,
      "is_approved": 1,
      "created_at": "2026-10-04 16:26:14",
      "username": "john_doe",
      "first_name": "John",
      "last_name": "Doe"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 2,
    "totalPages": 1,
    "hasNext": false,
    "hasPrev": false
  }
}
```

> An unknown product ID returns `200` with an empty `data` array, not `404`.

**Example**:
```bash
# Get reviews for product 1
curl "https://http-api-1.zavhorodnii.org/api/products/1/reviews?page=1&limit=10"

# Get second page of reviews
curl "https://http-api-1.zavhorodnii.org/api/products/1/reviews?page=2&limit=5"
```

---

## Category Endpoints

### Category object

| Field | Type | Description |
|-------|------|-------------|
| `id` | number | Category ID |
| `name` | string | Category name |
| `description` | string \| null | Description |
| `parent_id` | number \| null | Parent category ID, `null` for top-level categories |
| `image_url` | string \| null | Category picture |
| `is_active` | `1` \| `0` | Only active categories are returned |
| `created_at` | string | `YYYY-MM-DD HH:MM:SS` |

### GET /api/categories

Get all categories as a flat list, sorted by name. Not paginated.

**Query Parameters**: None

**Response**: `200 OK`
```json
{
  "categories": [
    {
      "id": 5,
      "name": "Audio",
      "description": "Audio equipment and accessories",
      "parent_id": 1,
      "image_url": "https://picsum.photos/seed/audio/600/400",
      "is_active": 1,
      "created_at": "2026-10-04 16:26:14"
    },
    {
      "id": 20,
      "name": "Automotive",
      "description": "Automotive accessories and equipment",
      "parent_id": null,
      "image_url": "https://picsum.photos/seed/automotive/600/400",
      "is_active": 1,
      "created_at": "2026-10-04 16:26:14"
    }
  ],
  "count": 23
}
```

**Example**:
```bash
curl https://http-api-1.zavhorodnii.org/api/categories
```

---

### GET /api/categories/:id

Get a single category by ID.

**Path Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | number | Yes | Category ID |

**Response**: `200 OK`
```json
{
  "id": 1,
  "name": "Electronics",
  "description": "Electronic devices and components",
  "parent_id": null,
  "image_url": "https://picsum.photos/seed/electronics/600/400",
  "is_active": 1,
  "created_at": "2026-10-04 16:26:14"
}
```

**Error Responses**:
- `400 Bad Request`: Invalid category ID
- `404 Not Found`: Category not found
- `500 Internal Server Error`: Server error

**Example**:
```bash
curl https://http-api-1.zavhorodnii.org/api/categories/1
```

---

### GET /api/categories/:id/children

Get a category together with its direct subcategories (one level deep, sorted by name).

**Path Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | number | Yes | Category ID |

**Response**: `200 OK`
```json
{
  "id": 1,
  "name": "Electronics",
  "description": "Electronic devices and components",
  "parent_id": null,
  "image_url": "https://picsum.photos/seed/electronics/600/400",
  "is_active": 1,
  "created_at": "2026-10-04 16:26:14",
  "children": [
    {
      "id": 5,
      "name": "Audio",
      "description": "Audio equipment and accessories",
      "parent_id": 1,
      "image_url": "https://picsum.photos/seed/audio/600/400",
      "is_active": 1,
      "created_at": "2026-10-04 16:26:14"
    },
    {
      "id": 2,
      "name": "Computers",
      "description": "Desktop and laptop computers",
      "parent_id": 1,
      "image_url": "https://picsum.photos/seed/computers/600/400",
      "is_active": 1,
      "created_at": "2026-10-04 16:26:14"
    }
  ]
}
```

**Error Responses**:
- `400 Bad Request`: Invalid category ID
- `404 Not Found`: Category not found

**Example**:
```bash
# Get category tree for Electronics
curl https://http-api-1.zavhorodnii.org/api/categories/1/children
```

---

### GET /api/categories/:id/products

Get all products in a specific category with pagination. Products are full [product objects](#product-object).

**Path Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | number | Yes | Category ID |

**Query Parameters**:
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `page` | number | 1 | Page number |
| `limit` | number | 10 | Products per page |

**Response**: `200 OK`
```json
{
  "data": [
    {
      "id": 1,
      "name": "TechPro Laptop Pro",
      "description": "High-performance laptop with 16GB RAM and 512GB SSD",
      "sku": "TP-LP-001",
      "price": 1299.99,
      "sale_price": 1199.99,
      "cost_price": 800,
      "brand_id": 1,
      "supplier_id": 1,
      "stock_quantity": 25,
      "min_stock_level": 5,
      "weight": 4.5,
      "dimensions": "14x9.5x0.7",
      "is_active": 1,
      "is_featured": 1,
      "rating_average": 4.6,
      "rating_count": 128,
      "created_at": "2026-10-04 16:26:14",
      "updated_at": "2026-10-04 16:26:14"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 1,
    "total": 6,
    "totalPages": 6,
    "hasNext": true,
    "hasPrev": false
  }
}
```

> An unknown category ID returns `200` with an empty `data` array, not `404`.

**Example**:
```bash
# Get products in category 2 (Computers)
curl "https://http-api-1.zavhorodnii.org/api/categories/2/products?page=1&limit=10"
```

---

## Brand Endpoints

### GET /api/brands

Get all brands, sorted by name. Not paginated.

**Query Parameters**: None

**Response**: `200 OK`
```json
{
  "brands": [
    {
      "id": 10,
      "name": "AutoTech",
      "description": "Automotive technology and accessories",
      "logo_url": "https://placehold.co/200x200?text=autotech",
      "website": "https://autotech.com",
      "is_active": 1,
      "created_at": "2026-10-04 16:26:14"
    }
  ],
  "count": 10
}
```

**Example**:
```bash
curl https://http-api-1.zavhorodnii.org/api/brands
```

---

### GET /api/brands/:id

Get a single brand by ID.

**Path Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | number | Yes | Brand ID |

**Response**: `200 OK`
```json
{
  "id": 1,
  "name": "TechPro",
  "description": "Professional grade technology solutions",
  "logo_url": "https://placehold.co/200x200?text=techpro",
  "website": "https://techpro.com",
  "is_active": 1,
  "created_at": "2026-10-04 16:26:14"
}
```

**Error Responses**:
- `400 Bad Request`: Invalid brand ID
- `404 Not Found`: Brand not found
- `500 Internal Server Error`: Server error

**Example**:
```bash
curl https://http-api-1.zavhorodnii.org/api/brands/1
```

---

## Supplier Endpoints

### GET /api/suppliers

Get all suppliers, sorted by name. Not paginated.

**Query Parameters**: None

**Response**: `200 OK`
```json
{
  "suppliers": [
    {
      "id": 1,
      "name": "TechSupply Co",
      "contact_person": "Mike Johnson",
      "email": "mike@techsupply.com",
      "phone": "555-1001",
      "address": "100 Industrial Blvd",
      "city": "Austin",
      "state": "TX",
      "zip_code": "73301",
      "country": "USA",
      "is_active": 1,
      "created_at": "2026-10-04 16:26:14"
    }
  ],
  "count": 10
}
```

**Example**:
```bash
curl https://http-api-1.zavhorodnii.org/api/suppliers
```

---

### GET /api/suppliers/:id

Get a single supplier by ID.

**Path Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | number | Yes | Supplier ID |

**Response**: `200 OK`
```json
{
  "id": 1,
  "name": "TechSupply Co",
  "contact_person": "Mike Johnson",
  "email": "mike@techsupply.com",
  "phone": "555-1001",
  "address": "100 Industrial Blvd",
  "city": "Austin",
  "state": "TX",
  "zip_code": "73301",
  "country": "USA",
  "is_active": 1,
  "created_at": "2026-10-04 16:26:14"
}
```

**Error Responses**:
- `400 Bad Request`: Invalid supplier ID
- `404 Not Found`: Supplier not found
- `500 Internal Server Error`: Server error

**Example**:
```bash
curl https://http-api-1.zavhorodnii.org/api/suppliers/1
```

---

## User Endpoints

### GET /api/users

Get all users with pagination (newest first).

**Query Parameters**:
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `page` | number | 1 | Page number |
| `limit` | number | 10 | Users per page |

**Response**: `200 OK`
```json
{
  "data": [
    {
      "id": 1,
      "username": "john_doe",
      "email": "john@example.com",
      "first_name": "John",
      "last_name": "Doe",
      "phone": "555-0101",
      "address": "123 Main St",
      "city": "New York",
      "state": "NY",
      "zip_code": "10001",
      "country": "USA",
      "is_active": 1,
      "created_at": "2026-10-04 16:26:14",
      "updated_at": "2026-10-04 16:26:14"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 1,
    "total": 10,
    "totalPages": 10,
    "hasNext": true,
    "hasPrev": false
  }
}
```

**Example**:
```bash
curl "https://http-api-1.zavhorodnii.org/api/users?page=1&limit=10"
```

---

### GET /api/users/:id

Get a single user by ID.

**Path Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | number | Yes | User ID |

**Response**: `200 OK`
```json
{
  "id": 1,
  "username": "john_doe",
  "email": "john@example.com",
  "first_name": "John",
  "last_name": "Doe",
  "phone": "555-0101",
  "address": "123 Main St",
  "city": "New York",
  "state": "NY",
  "zip_code": "10001",
  "country": "USA",
  "is_active": 1,
  "created_at": "2026-10-04 16:26:14",
  "updated_at": "2026-10-04 16:26:14"
}
```

**Error Responses**:
- `400 Bad Request`: Invalid user ID
- `404 Not Found`: User not found
- `500 Internal Server Error`: Server error

**Example**:
```bash
curl https://http-api-1.zavhorodnii.org/api/users/1
```

---

### GET /api/users/:id/orders

Get all orders for a specific user with pagination (newest first). Order items are not included here; use `GET /api/orders/:id` for them.

**Path Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | number | Yes | User ID |

**Query Parameters**:
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `page` | number | 1 | Page number |
| `limit` | number | 10 | Orders per page |

**Response**: `200 OK`
```json
{
  "data": [
    {
      "id": 1,
      "order_number": "ORD-2024-001",
      "user_id": 1,
      "status": "delivered",
      "subtotal": 1299.99,
      "tax_amount": 104,
      "shipping_amount": 15,
      "total_amount": 1418.99,
      "shipping_address": "123 Main St",
      "shipping_city": "New York",
      "shipping_state": "NY",
      "shipping_zip_code": "10001",
      "shipping_country": null,
      "notes": null,
      "created_at": "2026-10-04 16:26:14",
      "updated_at": "2026-10-04 16:26:14"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 1,
    "total": 3,
    "totalPages": 3,
    "hasNext": true,
    "hasPrev": false
  }
}
```

`status` is one of `pending`, `processing`, `shipped`, `delivered`, `cancelled`.

> An unknown user ID returns `200` with an empty `data` array, not `404`.

**Example**:
```bash
# Get orders for user 1
curl "https://http-api-1.zavhorodnii.org/api/users/1/orders?page=1&limit=10"
```

---

## Order Endpoints

### GET /api/orders/:id

Get order details with the ordering `user` and all order `items`.

**Path Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | number | Yes | Order ID |

**Response**: `200 OK`
```json
{
  "id": 1,
  "order_number": "ORD-2024-001",
  "user_id": 1,
  "status": "delivered",
  "subtotal": 1299.99,
  "tax_amount": 104,
  "shipping_amount": 15,
  "total_amount": 1418.99,
  "shipping_address": "123 Main St",
  "shipping_city": "New York",
  "shipping_state": "NY",
  "shipping_zip_code": "10001",
  "shipping_country": null,
  "notes": null,
  "created_at": "2026-10-04 16:26:14",
  "updated_at": "2026-10-04 16:26:14",
  "user": {
    "id": 1,
    "username": "john_doe",
    "email": "john@example.com",
    "first_name": "John",
    "last_name": "Doe",
    "phone": "555-0101",
    "address": "123 Main St",
    "city": "New York",
    "state": "NY",
    "zip_code": "10001",
    "country": "USA",
    "is_active": 1,
    "created_at": "2026-10-04 16:26:14",
    "updated_at": "2026-10-04 16:26:14"
  },
  "items": [
    {
      "id": 1,
      "order_id": 1,
      "product_id": 1,
      "product_name": "TechPro Laptop Pro",
      "product_sku": "TP-LP-001",
      "quantity": 1,
      "unit_price": 1299.99,
      "total_price": 1299.99,
      "created_at": "2026-10-04 16:26:14"
    }
  ]
}
```

`product_name`, `product_sku` and `unit_price` are snapshots taken at order time, so they may differ from the current product.

**Error Responses**:
- `400 Bad Request`: Invalid order ID
- `404 Not Found`: Order not found
- `500 Internal Server Error`: Server error

**Example**:
```bash
curl https://http-api-1.zavhorodnii.org/api/orders/1
```

---

## Utility Endpoints

### GET /api/hello

Simple test endpoint returning a greeting message.

**Query Parameters**: None

**Response**: `200 OK`
```json
{
  "message": "Hello from E-commerce API!",
  "timestamp": "2026-10-21T20:02:45.998Z"
}
```

**Example**:
```bash
curl https://http-api-1.zavhorodnii.org/api/hello
```

---

### POST /api/echo

Echo endpoint that returns the request body.

**Request Body**: Any JSON

**Response**: `200 OK`
```json
{
  "message": "Echo response",
  "data": {
    "test": "your data here"
  },
  "timestamp": "2026-10-21T20:02:45.998Z"
}
```

**Example**:
```bash
curl -X POST https://http-api-1.zavhorodnii.org/api/echo \
  -H "Content-Type: application/json" \
  -d '{"test": "hello world"}'
```

---

## Common Response Patterns

### Pagination Response

All paginated endpoints (`/api/products`, `/api/products/search`, `/api/products/:id/reviews`, `/api/categories/:id/products`, `/api/users`, `/api/users/:id/orders`) return data in this format:

```json
{
  "data": [ /* array of items */ ],
  "pagination": {
    "page": 1,          // Current page number
    "limit": 10,        // Items per page
    "total": 61,        // Total number of items
    "totalPages": 7,    // Total number of pages
    "hasNext": true,    // Is there a page after this one?
    "hasPrev": false    // Is there a page before this one?
  }
}
```

`page` and `limit` are always numbers. Values that are missing or not valid positive integers fall back to the defaults (`page=1`, `limit=10`).

### List Response (Non-paginated)

Endpoints that return lists without pagination (`/api/products/featured`, `/api/categories`, `/api/brands`, `/api/suppliers`):

```json
{
  "brands": [ /* array of items */ ],
  "count": 10   // Number of items in the array
}
```

---

## Error Handling

### Error Response Format

All errors follow this format:

```json
{
  "error": "Error message description",
  "details": "Additional error details (optional)"
}
```

### HTTP Status Codes

| Code | Description | When Used |
|------|-------------|-----------|
| `200` | OK | Successful request |
| `400` | Bad Request | Invalid parameters (e.g., invalid ID format) |
| `404` | Not Found | Resource doesn't exist |
| `500` | Internal Server Error | Server-side error occurred |

### Common Error Examples

**Invalid ID Format** (`400`):
```json
{
  "error": "Invalid product ID"
}
```

**Resource Not Found** (`404`):
```json
{
  "error": "Product not found"
}
```

**Server Error** (`500`):
```json
{
  "error": "Failed to fetch products",
  "details": "Database connection error"
}
```

---

## Usage Examples

### JavaScript (Fetch API)

```javascript
// Get all products
const response = await fetch('https://http-api-1.zavhorodnii.org/api/products?page=1&limit=10');
const { data, pagination } = await response.json();
console.log(data, pagination.totalPages);

// Search products
const searchResponse = await fetch('https://http-api-1.zavhorodnii.org/api/products/search?search=laptop&min_price=500');
const searchData = await searchResponse.json();
console.log(searchData.data);

// Get product with full details
const productResponse = await fetch('https://http-api-1.zavhorodnii.org/api/products/1/full');
const product = await productResponse.json();
const primaryImage = product.images.find(img => img.is_primary === 1);
```

### Python (requests)

```python
import requests

# Get all products
response = requests.get('https://http-api-1.zavhorodnii.org/api/products', params={'page': 1, 'limit': 10})
body = response.json()
print(body['data'], body['pagination']['totalPages'])

# Search products
search_params = {
    'search': 'laptop',
    'min_price': 500,
    'max_price': 2000,
    'in_stock': 'true'
}
response = requests.get('https://http-api-1.zavhorodnii.org/api/products/search', params=search_params)
products = response.json()['data']

# Get product by ID
response = requests.get('https://http-api-1.zavhorodnii.org/api/products/1')
product = response.json()
```

### cURL

```bash
# Get products with pagination
curl "https://http-api-1.zavhorodnii.org/api/products?page=1&limit=5"

# Search with filters
curl "https://http-api-1.zavhorodnii.org/api/products/search?category_id=1&min_price=100&max_price=500&sort_by=price&sort_order=asc"

# Get product with full relations
curl https://http-api-1.zavhorodnii.org/api/products/1/full

# Get user orders
curl "https://http-api-1.zavhorodnii.org/api/users/1/orders?page=1&limit=10"

# POST request
curl -X POST https://http-api-1.zavhorodnii.org/api/echo \
  -H "Content-Type: application/json" \
  -d '{"message": "test"}'
```

---

## Tips for Using the API

1. **Pagination**: Always use pagination for large datasets. Default is 10 items per page. Use `hasNext` / `hasPrev` to drive "next" / "previous" buttons.
2. **Filtering**: Combine multiple filters for precise results (category + price range + stock status).
3. **Sorting**: Use `sort_by` and `sort_order` parameters for custom ordering.
4. **Full Product Data**: Use `/api/products/:id/full` to get all related data in one request.
5. **Error Handling**: Always check HTTP status codes and handle errors appropriately.
6. **Search**: The search parameter looks in both product names and descriptions.
7. **Boolean Parameters**: Use the string `'true'` for boolean query parameters; anything else is treated as "no filter".
8. **Boolean Fields**: Boolean fields in responses are `1` / `0`, not `true` / `false`.

---

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | 3010 | Server port |
| `HOST` | 0.0.0.0 | Server host |

### Database

- **Type**: SQLite
- **Location**: `./database/ecommerce.db`
- **Initialization**: `npm run init-db` (the server also re-runs `database/init.sql` on every start, so the data is reset to the seed set each time it boots)

---

## Support

For issues or questions, please refer to the main README.md or contact the development team.
