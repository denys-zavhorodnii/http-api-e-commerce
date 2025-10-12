# E-commerce API Schema Documentation

Complete API documentation for the E-commerce HTTP API built with Fastify and TypeScript.

## Base URL

```
https://http-api-1.zavhorodnii.org/
```

> **Note**: The port can be configured via the `PORT` environment variable. Default is 3010.

---

## Table of Contents

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

## Documentation

### GET /doc

View this API documentation rendered as a beautiful HTML page in your browser.

**Query Parameters**: None

**Response**: HTML page with full API documentation

**Example**:
```bash
# Open in browser
open https://http-api-1.zavhorodnii.org/doc

# Or use curl
curl https://http-api-1.zavhorodnii.org/doc
```

**Features**:
- **Responsive Design**: Works on desktop, tablet, and mobile
- **Syntax Highlighting**: Code blocks with proper formatting
- **Table of Contents**: Easy navigation with anchor links
- **Smooth Scrolling**: Click links to jump to sections
- **"Back to Top" Button**: Quick navigation to the top
- **Styled Tables**: Easy-to-read parameter and response tables
- **Color-Coded Status Codes**: Visual distinction for HTTP status codes

> **Tip**: This is the best way to explore the API! Open https://http-api-1.zavhorodnii.org/doc in your browser for an interactive experience.

---

## Health Check Endpoints

### GET /health

Basic health check to verify the API is running.

**Query Parameters**: None

**Response**: `200 OK`
```json
{
  "status": "ok",
  "timestamp": "2025-10-12T10:30:00.000Z"
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
  "products_count": 45,
  "timestamp": "2025-10-12T10:30:00.000Z"
}
```

**Error Response**: `500 Internal Server Error`
```json
{
  "status": "error",
  "database": "disconnected",
  "error": "Connection failed",
  "timestamp": "2025-10-12T10:30:00.000Z"
}
```

**Example**:
```bash
curl https://http-api-1.zavhorodnii.org/health/db
```

---

## Product Endpoints

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
  "products": [
    {
      "id": 1,
      "name": "Premium Wireless Headphones",
      "description": "High-quality noise-cancelling headphones",
      "price": 299.99,
      "stock_quantity": 50,
      "category_id": 3,
      "brand_id": 1,
      "supplier_id": 1,
      "sku": "WH-1000XM4",
      "rating": 4.8,
      "is_featured": true,
      "created_at": "2025-01-15T10:00:00.000Z",
      "updated_at": "2025-01-15T10:00:00.000Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 45,
    "total_pages": 5
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
  "name": "Premium Wireless Headphones",
  "description": "High-quality noise-cancelling headphones",
  "price": 299.99,
  "stock_quantity": 50,
  "category_id": 3,
  "brand_id": 1,
  "supplier_id": 1,
  "sku": "WH-1000XM4",
  "rating": 4.8,
  "is_featured": true,
  "created_at": "2025-01-15T10:00:00.000Z",
  "updated_at": "2025-01-15T10:00:00.000Z"
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

Get a product with all related data (brand, supplier, categories, images).

**Path Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | number | Yes | Product ID |

**Response**: `200 OK`
```json
{
  "id": 1,
  "name": "Premium Wireless Headphones",
  "description": "High-quality noise-cancelling headphones",
  "price": 299.99,
  "stock_quantity": 50,
  "sku": "WH-1000XM4",
  "rating": 4.8,
  "is_featured": true,
  "brand": {
    "id": 1,
    "name": "TechPro",
    "description": "Premium technology brand",
    "website": "https://techpro.example.com"
  },
  "supplier": {
    "id": 1,
    "name": "Global Electronics Supply Co.",
    "contact_name": "John Smith",
    "email": "john@globalsupply.com",
    "phone": "+1-555-0100",
    "address": "123 Industrial Park, Tech City, TC 12345"
  },
  "categories": [
    {
      "id": 3,
      "name": "Audio Equipment",
      "description": "High-quality audio devices",
      "parent_id": 1
    }
  ],
  "images": [
    {
      "id": 1,
      "image_url": "https://example.com/images/headphones-1.jpg",
      "alt_text": "Premium Wireless Headphones",
      "is_primary": true,
      "display_order": 1
    }
  ],
  "created_at": "2025-01-15T10:00:00.000Z",
  "updated_at": "2025-01-15T10:00:00.000Z"
}
```

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
| `min_price` | number | - | Minimum price filter |
| `max_price` | number | - | Maximum price filter |
| `in_stock` | boolean | - | Filter by stock availability (true/false) |
| `is_featured` | boolean | - | Filter featured products (true/false) |
| `search` | string | - | Search in product name and description |
| `sort_by` | string | - | Sort field: `price`, `rating`, `name`, `created_at` |
| `sort_order` | string | `asc` | Sort order: `asc` or `desc` |

**Response**: `200 OK`
```json
{
  "products": [
    {
      "id": 5,
      "name": "Gaming Laptop Pro",
      "description": "High-performance gaming laptop",
      "price": 1299.99,
      "stock_quantity": 15,
      "category_id": 2,
      "brand_id": 1,
      "supplier_id": 1,
      "sku": "GLT-PRO-2024",
      "rating": 4.7,
      "is_featured": true
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 8,
    "total_pages": 1
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

Get featured products (limited list of highlighted items).

**Query Parameters**:
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `limit` | number | 10 | Maximum number of featured products |

**Response**: `200 OK`
```json
{
  "products": [
    {
      "id": 1,
      "name": "Premium Wireless Headphones",
      "price": 299.99,
      "rating": 4.8,
      "is_featured": true
    }
  ],
  "count": 5
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

Get reviews for a specific product with pagination.

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
  "reviews": [
    {
      "id": 1,
      "product_id": 1,
      "user_id": 1,
      "rating": 5,
      "title": "Amazing sound quality!",
      "comment": "Best headphones I've ever owned. The noise cancellation is incredible.",
      "is_verified_purchase": true,
      "created_at": "2025-02-01T14:30:00.000Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 15,
    "total_pages": 2
  }
}
```

**Example**:
```bash
# Get reviews for product 1
curl "https://http-api-1.zavhorodnii.org/api/products/1/reviews?page=1&limit=10"

# Get second page of reviews
curl "https://http-api-1.zavhorodnii.org/api/products/1/reviews?page=2&limit=5"
```

---

## Category Endpoints

### GET /api/categories

Get all categories (flat list).

**Query Parameters**: None

**Response**: `200 OK`
```json
{
  "categories": [
    {
      "id": 1,
      "name": "Electronics",
      "description": "Electronic devices and gadgets",
      "parent_id": null,
      "slug": "electronics"
    },
    {
      "id": 2,
      "name": "Computers",
      "description": "Desktop and laptop computers",
      "parent_id": 1,
      "slug": "computers"
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
  "description": "Electronic devices and gadgets",
  "parent_id": null,
  "slug": "electronics"
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

Get a category with all its subcategories (hierarchical structure).

**Path Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | number | Yes | Category ID |

**Response**: `200 OK`
```json
{
  "id": 1,
  "name": "Electronics",
  "description": "Electronic devices and gadgets",
  "parent_id": null,
  "slug": "electronics",
  "children": [
    {
      "id": 2,
      "name": "Computers",
      "description": "Desktop and laptop computers",
      "parent_id": 1,
      "slug": "computers"
    },
    {
      "id": 3,
      "name": "Audio Equipment",
      "description": "Headphones, speakers, and audio devices",
      "parent_id": 1,
      "slug": "audio-equipment"
    }
  ]
}
```

**Example**:
```bash
# Get category tree for Electronics
curl https://http-api-1.zavhorodnii.org/api/categories/1/children
```

---

### GET /api/categories/:id/products

Get all products in a specific category with pagination.

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
  "products": [
    {
      "id": 1,
      "name": "Premium Wireless Headphones",
      "price": 299.99,
      "category_id": 3
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 12,
    "total_pages": 2
  }
}
```

**Example**:
```bash
# Get products in category 1
curl "https://http-api-1.zavhorodnii.org/api/categories/1/products?page=1&limit=10"
```

---

## Brand Endpoints

### GET /api/brands

Get all brands.

**Query Parameters**: None

**Response**: `200 OK`
```json
{
  "brands": [
    {
      "id": 1,
      "name": "TechPro",
      "description": "Premium technology brand",
      "website": "https://techpro.example.com",
      "logo_url": "https://example.com/logos/techpro.png"
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
  "description": "Premium technology brand specializing in consumer electronics",
  "website": "https://techpro.example.com",
  "logo_url": "https://example.com/logos/techpro.png"
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

Get all suppliers.

**Query Parameters**: None

**Response**: `200 OK`
```json
{
  "suppliers": [
    {
      "id": 1,
      "name": "Global Electronics Supply Co.",
      "contact_name": "John Smith",
      "email": "john@globalsupply.com",
      "phone": "+1-555-0100",
      "address": "123 Industrial Park, Tech City, TC 12345"
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
  "name": "Global Electronics Supply Co.",
  "contact_name": "John Smith",
  "email": "john@globalsupply.com",
  "phone": "+1-555-0100",
  "address": "123 Industrial Park, Tech City, TC 12345"
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

Get all users with pagination.

**Query Parameters**:
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `page` | number | 1 | Page number |
| `limit` | number | 10 | Users per page |

**Response**: `200 OK`
```json
{
  "users": [
    {
      "id": 1,
      "email": "john.doe@example.com",
      "first_name": "John",
      "last_name": "Doe",
      "phone": "+1-555-0101",
      "address": "123 Main St, Apt 4B",
      "city": "New York",
      "state": "NY",
      "zip_code": "10001",
      "country": "USA",
      "created_at": "2025-01-01T10:00:00.000Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 10,
    "total_pages": 1
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
  "email": "john.doe@example.com",
  "first_name": "John",
  "last_name": "Doe",
  "phone": "+1-555-0101",
  "address": "123 Main St, Apt 4B",
  "city": "New York",
  "state": "NY",
  "zip_code": "10001",
  "country": "USA",
  "created_at": "2025-01-01T10:00:00.000Z"
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

Get all orders for a specific user with pagination.

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
  "orders": [
    {
      "id": 1,
      "user_id": 1,
      "order_date": "2025-02-15T10:30:00.000Z",
      "status": "completed",
      "total_amount": 599.98,
      "shipping_address": "123 Main St, Apt 4B, New York, NY 10001",
      "payment_method": "credit_card"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 3,
    "total_pages": 1
  }
}
```

**Example**:
```bash
# Get orders for user 1
curl "https://http-api-1.zavhorodnii.org/api/users/1/orders?page=1&limit=10"
```

---

## Order Endpoints

### GET /api/orders/:id

Get order details with all order items.

**Path Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | number | Yes | Order ID |

**Response**: `200 OK`
```json
{
  "id": 1,
  "user_id": 1,
  "order_date": "2025-02-15T10:30:00.000Z",
  "status": "completed",
  "total_amount": 599.98,
  "shipping_address": "123 Main St, Apt 4B, New York, NY 10001",
  "payment_method": "credit_card",
  "items": [
    {
      "id": 1,
      "order_id": 1,
      "product_id": 1,
      "quantity": 2,
      "price": 299.99,
      "subtotal": 599.98
    }
  ]
}
```

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
  "timestamp": "2025-10-12T10:30:00.000Z"
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
  "timestamp": "2025-10-12T10:30:00.000Z"
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

All paginated endpoints return data in this format:

```json
{
  "products": [ /* array of items */ ],
  "pagination": {
    "page": 1,          // Current page number
    "limit": 10,        // Items per page
    "total": 45,        // Total number of items
    "total_pages": 5    // Total number of pages
  }
}
```

### List Response (Non-paginated)

Endpoints that return lists without pagination:

```json
{
  "brands": [ /* array of items */ ],
  "count": 10   // Total number of items
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
const data = await response.json();
console.log(data.products);

// Search products
const searchResponse = await fetch('https://http-api-1.zavhorodnii.org/api/products/search?search=laptop&min_price=500');
const searchData = await searchResponse.json();

// Get product with full details
const productResponse = await fetch('https://http-api-1.zavhorodnii.org/api/products/1/full');
const product = await productResponse.json();
```

### Python (requests)

```python
import requests

# Get all products
response = requests.get('https://http-api-1.zavhorodnii.org/api/products', params={'page': 1, 'limit': 10})
data = response.json()
print(data['products'])

# Search products
search_params = {
    'search': 'laptop',
    'min_price': 500,
    'max_price': 2000,
    'in_stock': True
}
response = requests.get('https://http-api-1.zavhorodnii.org/api/products/search', params=search_params)
products = response.json()

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

1. **Pagination**: Always use pagination for large datasets. Default is 10 items per page.
2. **Filtering**: Combine multiple filters for precise results (category + price range + stock status).
3. **Sorting**: Use `sort_by` and `sort_order` parameters for custom ordering.
4. **Full Product Data**: Use `/api/products/:id/full` to get all related data in one request.
5. **Error Handling**: Always check HTTP status codes and handle errors appropriately.
6. **Search**: The search parameter looks in both product names and descriptions.
7. **Boolean Parameters**: Use string values `'true'` or `'false'` for boolean query parameters.

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
- **Initialization**: `npm run init-db`

---

## Support

For issues or questions, please refer to the main README.md or contact the development team.

