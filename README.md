# E-commerce HTTP API

A comprehensive E-commerce API built with Fastify and TypeScript, designed to teach students about HTTP requests, complex database relationships, pagination, and filtering.

## 🚀 Features

- **Complex Data Relationships**: Products, Categories, Brands, Suppliers, Users, Orders, Reviews
- **Advanced Pagination**: Built-in pagination for all list endpoints
- **Rich Filtering**: Search products by category, brand, price range, stock status, and more
- **RESTful Design**: Clean, intuitive API endpoints following REST principles
- **TypeScript**: Full type safety and IntelliSense support
- **SQLite Database**: Lightweight, file-based database perfect for learning

## 🗄️ Database Schema

The API includes a comprehensive E-commerce database with:

- **Products**: 15 sample products with prices, stock, ratings, and images
- **Categories**: Hierarchical category system (Electronics → Computers → Laptops)
- **Brands**: Product brands with descriptions and websites
- **Suppliers**: Vendor information and contact details
- **Users**: Customer accounts with addresses
- **Orders**: Order history with line items
- **Reviews**: Product ratings and customer feedback
- **Images**: Product photos with primary/secondary designation

## 📚 Learning Opportunities

This API is perfect for teaching students about:

- **HTTP Methods**: GET, POST, PUT, DELETE
- **Status Codes**: 200, 400, 404, 500
- **Query Parameters**: Pagination, filtering, sorting
- **Path Parameters**: Resource identification
- **Response Formats**: JSON with consistent structure
- **Error Handling**: Proper error responses and status codes
- **Database Relationships**: One-to-many, many-to-many relationships
- **Pagination**: Page-based navigation with metadata
- **Search & Filtering**: Complex query building

## 🛠️ Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd http-api-1
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Initialize the database**
   ```bash
   npm run init-db
   ```

4. **Start the development server**
   ```bash
   npm run dev
   ```

The API will be available at `http://localhost:3000`

## 📖 API Endpoints

### Health Checks
- `GET /health` - Basic health check
- `GET /health/db` - Database health check

### Products
- `GET /api/products` - List all products (paginated)
- `GET /api/products/:id` - Get product by ID
- `GET /api/products/:id/full` - Get product with all relations
- `GET /api/products/search` - Search and filter products
- `GET /api/products/featured` - Get featured products
- `GET /api/products/:id/reviews` - Get product reviews (paginated)

### Categories
- `GET /api/categories` - List all categories
- `GET /api/categories/:id` - Get category by ID
- `GET /api/categories/:id/children` - Get category with subcategories
- `GET /api/categories/:id/products` - Get products by category (paginated)

### Brands & Suppliers
- `GET /api/brands` - List all brands
- `GET /api/brands/:id` - Get brand by ID
- `GET /api/suppliers` - List all suppliers
- `GET /api/suppliers/:id` - Get supplier by ID

### Users & Orders
- `GET /api/users` - List all users (paginated)
- `GET /api/users/:id` - Get user by ID
- `GET /api/users/:id/orders` - Get user orders (paginated)
- `GET /api/orders/:id` - Get order with items

## 🔍 Example API Calls

### Basic Product Listing
```bash
curl "http://localhost:3000/api/products?page=1&limit=5"
```

### Product Search with Filters
```bash
curl "http://localhost:3000/api/products/search?category_id=1&min_price=100&max_price=500&in_stock=true&sort_by=price&sort_order=asc"
```

### Get Product with Full Details
```bash
curl "http://localhost:3000/api/products/1/full"
```

### Category Navigation
```bash
curl "http://localhost:3000/api/categories/1/children"
curl "http://localhost:3000/api/categories/1/products?page=1&limit=10"
```

### User Order History
```bash
curl "http://localhost:3000/api/users/1/orders?page=1&limit=5"
```

## 📊 Sample Data

The database comes pre-populated with:

- **45 Products**: Laptops, smartphones, gaming equipment, audio devices, smart home products, automotive accessories, pet supplies, eco-friendly items
- **23 Categories**: Electronics, Computers, Gaming, Audio, Home & Garden, Smart Home, Fashion, Sports, Fitness, Books, Automotive, Pet Supplies, Health & Wellness, Office
- **10 Brands**: TechPro, SmartLife, EcoTech, PowerMax, InnovateCorp, GameMaster, SoundWave, GreenLiving, PetCare Plus, AutoTech
- **10 Suppliers**: Various vendor companies across different regions
- **10 Users**: Sample customer accounts with diverse locations
- **16 Orders**: Sample order history with various statuses
- **45 Reviews**: Product ratings and feedback from verified purchases
- **45 Product Images**: Sample product photos for all items

## 🎯 Teaching Scenarios

### Beginner Level
- Basic GET requests to list products
- Understanding JSON responses
- Simple pagination (page/limit parameters)

### Intermediate Level
- Complex filtering (price ranges, categories, brands)
- Sorting and ordering results
- Working with nested data (products with categories)

### Advanced Level
- Building complex search queries with multiple filters
- Understanding database relationships (one-to-many, many-to-many)
- Implementing pagination in frontend applications
- Error handling and status codes
- Working with hierarchical category structures
- Complex product filtering (brand, supplier, price ranges, stock status)

## 🚀 Development

### Available Scripts
- `npm run dev` - Start development server with hot reload
- `npm run build` - Build TypeScript to JavaScript
- `npm run start` - Start production server
- `npm run init-db` - Initialize/reset database
- `npm run clean` - Clean build artifacts

### Database Management
- The database file is created at `./database/ecommerce.db`
- Run `npm run init-db` to reset the database with fresh sample data
- The database schema is defined in `./database/init.sql`

## 🔧 Configuration

- **Port**: Set via `PORT` environment variable (default: 3000)
- **Host**: Set via `HOST` environment variable (default: 0.0.0.0)
- **Database**: SQLite file at `./database/ecommerce.db`

## 📝 License

ISC License
