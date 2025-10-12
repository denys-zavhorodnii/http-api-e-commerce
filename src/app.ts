import Fastify, { FastifyInstance } from 'fastify';
import cors from '@fastify/cors';
import helmet from '@fastify/helmet';
import { db, ProductFilters, PaginationOptions } from './database';
import * as fs from 'fs';
import * as path from 'path';
import MarkdownIt from 'markdown-it';

const server: FastifyInstance = Fastify({
  logger: true,
  trustProxy: true,
});

// Register plugins
server.register(cors, {
  origin: true,
  credentials: true,
});

server.register(helmet, {
  contentSecurityPolicy: false,
});

// Health check route
server.get('/health', async (request, reply) => {
  return { status: 'ok', timestamp: new Date().toISOString() };
});

// Database health check
server.get('/health/db', async (request, reply) => {
  try {
    const products = await db.getAllProducts({ page: 1, limit: 1, offset: 0 });
    return { 
      status: 'ok', 
      database: 'connected',
      products_count: products.pagination.total,
      timestamp: new Date().toISOString() 
    };
  } catch (error) {
    reply.status(500);
    return { 
      status: 'error', 
      database: 'disconnected',
      error: error instanceof Error ? error.message : 'Unknown error',
      timestamp: new Date().toISOString() 
    };
  }
});

// ===== PRODUCT ROUTES =====

// Get all products with pagination
server.get('/api/products', async (request, reply) => {
  try {
    const { page = 1, limit = 10 } = request.query as { page?: number; limit?: number };
    const offset = (page - 1) * limit;
    
    const products = await db.getAllProducts({ page, limit, offset });
    return products;
  } catch (error) {
    reply.status(500);
    return { error: 'Failed to fetch products', details: error instanceof Error ? error.message : 'Unknown error' };
  }
});

// Get product by ID
server.get('/api/products/:id', async (request, reply) => {
  try {
    const { id } = request.params as { id: string };
    const productId = parseInt(id);
    
    if (isNaN(productId)) {
      reply.status(400);
      return { error: 'Invalid product ID' };
    }

    const product = await db.getProductById(productId);
    if (!product) {
      reply.status(404);
      return { error: 'Product not found' };
    }

    return product;
  } catch (error) {
    reply.status(500);
    return { error: 'Failed to fetch product', details: error instanceof Error ? error.message : 'Unknown error' };
  }
});

// Get product with all relations (brand, supplier, categories, images)
server.get('/api/products/:id/full', async (request, reply) => {
  try {
    const { id } = request.params as { id: string };
    const productId = parseInt(id);
    
    if (isNaN(productId)) {
      reply.status(400);
      return { error: 'Invalid product ID' };
    }

    const product = await db.getProductWithRelations(productId);
    if (!product) {
      reply.status(404);
      return { error: 'Product not found' };
    }

    return product;
  } catch (error) {
    reply.status(500);
    return { error: 'Failed to fetch product with relations', details: error instanceof Error ? error.message : 'Unknown error' };
  }
});

// Search and filter products
server.get('/api/products/search', async (request, reply) => {
  try {
    const { 
      page = '1', 
      limit = '10', 
      category_id, 
      brand_id, 
      min_price, 
      max_price, 
      in_stock, 
      is_featured, 
      search, 
      sort_by, 
      sort_order 
    } = request.query as any;
    
    const pageNum = parseInt(page) || 1;
    const limitNum = parseInt(limit) || 10;
    const offset = (pageNum - 1) * limitNum;
    
    const filters: ProductFilters = {
      category_id: category_id ? parseInt(String(category_id)) : undefined,
      brand_id: brand_id ? parseInt(String(brand_id)) : undefined,
      min_price: min_price ? parseFloat(String(min_price)) : undefined,
      max_price: max_price ? parseFloat(String(max_price)) : undefined,
      in_stock: in_stock === 'true',
      is_featured: is_featured === 'true',
      search: search as string,
      sort_by: sort_by as any,
      sort_order: sort_order as any
    };

    const products = await db.searchProducts(filters, { page: pageNum, limit: limitNum, offset });
    return products;
  } catch (error) {
    reply.status(500);
    return { error: 'Failed to search products', details: error instanceof Error ? error.message : 'Unknown error' };
  }
});

// Get featured products
server.get('/api/products/featured', async (request, reply) => {
  try {
    const { limit = 10 } = request.query as { limit?: number };
    const products = await db.getFeaturedProducts(limit);
    return { products, count: products.length };
  } catch (error) {
    reply.status(500);
    return { error: 'Failed to fetch featured products', details: error instanceof Error ? error.message : 'Unknown error' };
  }
});

// Get products by category
server.get('/api/categories/:id/products', async (request, reply) => {
  try {
    const { id } = request.params as { id: string };
    const { page = 1, limit = 10 } = request.query as { page?: number; limit?: number };
    
    const categoryId = parseInt(id);
    if (isNaN(categoryId)) {
      reply.status(400);
      return { error: 'Invalid category ID' };
    }

    const offset = (page - 1) * limit;
    const products = await db.getProductsByCategory(categoryId, { page, limit, offset });
    return products;
  } catch (error) {
    reply.status(500);
    return { error: 'Failed to fetch products by category', details: error instanceof Error ? error.message : 'Unknown error' };
  }
});

// ===== CATEGORY ROUTES =====

// Get all categories
server.get('/api/categories', async (request, reply) => {
  try {
    const categories = await db.getAllCategories();
    return { categories, count: categories.length };
  } catch (error) {
    reply.status(500);
    return { error: 'Failed to fetch categories', details: error instanceof Error ? error.message : 'Unknown error' };
  }
});

// Get category by ID
server.get('/api/categories/:id', async (request, reply) => {
  try {
    const { id } = request.params as { id: string };
    const categoryId = parseInt(id);
    
    if (isNaN(categoryId)) {
      reply.status(400);
      return { error: 'Invalid category ID' };
    }

    const category = await db.getCategoryById(categoryId);
    if (!category) {
      reply.status(404);
      return { error: 'Category not found' };
    }

    return category;
  } catch (error) {
    reply.status(500);
    return { error: 'Failed to fetch category', details: error instanceof Error ? error.message : 'Unknown error' };
  }
});

// Get category with children
server.get('/api/categories/:id/children', async (request, reply) => {
  try {
    const { id } = request.params as { id: string };
    const categoryId = parseInt(id);
    
    if (isNaN(categoryId)) {
      reply.status(400);
      return { error: 'Invalid category ID' };
    }

    const category = await db.getCategoryWithChildren(categoryId);
    if (!category) {
      reply.status(404);
      return { error: 'Category not found' };
    }

    return category;
  } catch (error) {
    reply.status(500);
    return { error: 'Failed to fetch category with children', details: error instanceof Error ? error.message : 'Unknown error' };
  }
});

// ===== BRAND ROUTES =====

// Get all brands
server.get('/api/brands', async (request, reply) => {
  try {
    const brands = await db.getAllBrands();
    return { brands, count: brands.length };
  } catch (error) {
    reply.status(500);
    return { error: 'Failed to fetch brands', details: error instanceof Error ? error.message : 'Unknown error' };
  }
});

// Get brand by ID
server.get('/api/brands/:id', async (request, reply) => {
  try {
    const { id } = request.params as { id: string };
    const brandId = parseInt(id);
    
    if (isNaN(brandId)) {
      reply.status(400);
      return { error: 'Invalid brand ID' };
    }

    const brand = await db.getBrandById(brandId);
    if (!brand) {
      reply.status(404);
      return { error: 'Brand not found' };
    }

    return brand;
  } catch (error) {
    reply.status(500);
    return { error: 'Failed to fetch brand', details: error instanceof Error ? error.message : 'Unknown error' };
  }
});

// ===== SUPPLIER ROUTES =====

// Get all suppliers
server.get('/api/suppliers', async (request, reply) => {
  try {
    const suppliers = await db.getAllSuppliers();
    return { suppliers, count: suppliers.length };
  } catch (error) {
    reply.status(500);
    return { error: 'Failed to fetch suppliers', details: error instanceof Error ? error.message : 'Unknown error' };
  }
});

// Get supplier by ID
server.get('/api/suppliers/:id', async (request, reply) => {
  try {
    const { id } = request.params as { id: string };
    const supplierId = parseInt(id);
    
    if (isNaN(supplierId)) {
      reply.status(400);
      return { error: 'Invalid supplier ID' };
    }

    const supplier = await db.getSupplierById(supplierId);
    if (!supplier) {
      reply.status(404);
      return { error: 'Supplier not found' };
    }

    return supplier;
  } catch (error) {
    reply.status(500);
    return { error: 'Failed to fetch supplier', details: error instanceof Error ? error.message : 'Unknown error' };
  }
});

// ===== USER ROUTES =====

// Get all users with pagination
server.get('/api/users', async (request, reply) => {
  try {
    const { page = 1, limit = 10 } = request.query as { page?: number; limit?: number };
    const offset = (page - 1) * limit;
    
    const users = await db.getAllUsers({ page, limit, offset });
    return users;
  } catch (error) {
    reply.status(500);
    return { error: 'Failed to fetch users', details: error instanceof Error ? error.message : 'Unknown error' };
  }
});

// Get user by ID
server.get('/api/users/:id', async (request, reply) => {
  try {
    const { id } = request.params as { id: string };
    const userId = parseInt(id);
    
    if (isNaN(userId)) {
      reply.status(400);
      return { error: 'Invalid user ID' };
    }

    const user = await db.getUserById(userId);
    if (!user) {
      reply.status(404);
      return { error: 'User not found' };
    }

    return user;
  } catch (error) {
    reply.status(500);
    return { error: 'Failed to fetch user', details: error instanceof Error ? error.message : 'Unknown error' };
  }
});

// ===== REVIEW ROUTES =====

// Get product reviews with pagination
server.get('/api/products/:id/reviews', async (request, reply) => {
  try {
    const { id } = request.params as { id: string };
    const { page = 1, limit = 10 } = request.query as { page?: number; limit?: number };
    
    const productId = parseInt(id);
    if (isNaN(productId)) {
      reply.status(400);
      return { error: 'Invalid product ID' };
    }

    const offset = (page - 1) * limit;
    const reviews = await db.getProductReviews(productId, { page, limit, offset });
    return reviews;
  } catch (error) {
    reply.status(500);
    return { error: 'Failed to fetch product reviews', details: error instanceof Error ? error.message : 'Unknown error' };
  }
});

// ===== ORDER ROUTES =====

// Get user orders with pagination
server.get('/api/users/:id/orders', async (request, reply) => {
  try {
    const { id } = request.params as { id: string };
    const { page = 1, limit = 10 } = request.query as { page?: number; limit?: number };
    
    const userId = parseInt(id);
    if (isNaN(userId)) {
      reply.status(400);
      return { error: 'Invalid user ID' };
    }

    const offset = (page - 1) * limit;
    const orders = await db.getUserOrders(userId, { page, limit, offset });
    return orders;
  } catch (error) {
    reply.status(500);
    return { error: 'Failed to fetch user orders', details: error instanceof Error ? error.message : 'Unknown error' };
  }
});

// Get order by ID with items
server.get('/api/orders/:id', async (request, reply) => {
  try {
    const { id } = request.params as { id: string };
    const orderId = parseInt(id);
    
    if (isNaN(orderId)) {
      reply.status(400);
      return { error: 'Invalid order ID' };
    }

    const order = await db.getOrderById(orderId);
    if (!order) {
      reply.status(404);
      return { error: 'Order not found' };
    }

    return order;
  } catch (error) {
    reply.status(500);
    return { error: 'Failed to fetch order', details: error instanceof Error ? error.message : 'Unknown error' };
  }
});

// ===== DOCUMENTATION ROUTE =====

// Render schema.md as HTML
server.get('/doc', async (request, reply) => {
  try {
    const md = new MarkdownIt({ html: true, linkify: true, typographer: true });
    const schemaPath = path.join(__dirname, '..', 'schema.md');
    const markdownContent = fs.readFileSync(schemaPath, 'utf-8');
    const htmlContent = md.render(markdownContent);
    
    const fullHtml = `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>API Documentation - E-commerce API</title>
  <style>
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }
    
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
      line-height: 1.6;
      color: #333;
      background: #f5f5f5;
      padding: 20px;
    }
    
    .container {
      max-width: 1200px;
      margin: 0 auto;
      background: white;
      padding: 40px;
      border-radius: 8px;
      box-shadow: 0 2px 10px rgba(0,0,0,0.1);
    }
    
    h1 {
      color: #2c3e50;
      border-bottom: 3px solid #3498db;
      padding-bottom: 15px;
      margin-bottom: 30px;
      font-size: 2.5em;
    }
    
    h2 {
      color: #34495e;
      margin-top: 40px;
      margin-bottom: 20px;
      padding-bottom: 10px;
      border-bottom: 2px solid #ecf0f1;
      font-size: 2em;
    }
    
    h3 {
      color: #2980b9;
      margin-top: 30px;
      margin-bottom: 15px;
      font-size: 1.5em;
    }
    
    h4 {
      color: #7f8c8d;
      margin-top: 20px;
      margin-bottom: 10px;
      font-size: 1.2em;
    }
    
    p {
      margin-bottom: 15px;
    }
    
    code {
      background: #f8f9fa;
      padding: 2px 6px;
      border-radius: 3px;
      font-family: 'Courier New', Courier, monospace;
      font-size: 0.9em;
      color: #e74c3c;
    }
    
    pre {
      background: #2c3e50;
      color: #ecf0f1;
      padding: 20px;
      border-radius: 5px;
      overflow-x: auto;
      margin: 15px 0;
      border-left: 4px solid #3498db;
    }
    
    pre code {
      background: none;
      color: #ecf0f1;
      padding: 0;
      font-size: 0.95em;
    }
    
    table {
      width: 100%;
      border-collapse: collapse;
      margin: 20px 0;
      background: white;
      box-shadow: 0 1px 3px rgba(0,0,0,0.1);
    }
    
    th {
      background: #3498db;
      color: white;
      padding: 12px;
      text-align: left;
      font-weight: 600;
    }
    
    td {
      padding: 12px;
      border-bottom: 1px solid #ecf0f1;
    }
    
    tr:hover {
      background: #f8f9fa;
    }
    
    a {
      color: #3498db;
      text-decoration: none;
      border-bottom: 1px solid transparent;
      transition: border-color 0.3s;
    }
    
    a:hover {
      border-bottom-color: #3498db;
    }
    
    ul, ol {
      margin: 15px 0;
      padding-left: 30px;
    }
    
    li {
      margin: 8px 0;
    }
    
    blockquote {
      border-left: 4px solid #3498db;
      padding-left: 20px;
      margin: 20px 0;
      color: #7f8c8d;
      background: #f8f9fa;
      padding: 15px 20px;
      border-radius: 0 5px 5px 0;
    }
    
    hr {
      border: none;
      border-top: 2px solid #ecf0f1;
      margin: 40px 0;
    }
    
    .header-link {
      opacity: 0;
      margin-left: 10px;
      font-size: 0.8em;
      transition: opacity 0.3s;
    }
    
    h2:hover .header-link,
    h3:hover .header-link,
    h4:hover .header-link {
      opacity: 1;
    }
    
    .api-endpoint {
      background: #ecf0f1;
      padding: 10px 15px;
      border-radius: 5px;
      margin: 10px 0;
      font-family: monospace;
    }
    
    .method-get {
      color: #27ae60;
      font-weight: bold;
    }
    
    .method-post {
      color: #f39c12;
      font-weight: bold;
    }
    
    .status-code {
      display: inline-block;
      padding: 3px 8px;
      border-radius: 3px;
      font-weight: 600;
      font-size: 0.9em;
    }
    
    .status-200 {
      background: #d4edda;
      color: #155724;
    }
    
    .status-400 {
      background: #fff3cd;
      color: #856404;
    }
    
    .status-404 {
      background: #f8d7da;
      color: #721c24;
    }
    
    .status-500 {
      background: #f8d7da;
      color: #721c24;
    }
    
    @media (max-width: 768px) {
      .container {
        padding: 20px;
      }
      
      h1 {
        font-size: 2em;
      }
      
      h2 {
        font-size: 1.5em;
      }
      
      table {
        font-size: 0.9em;
      }
      
      pre {
        padding: 15px;
        font-size: 0.85em;
      }
    }
    
    .nav-top {
      position: fixed;
      bottom: 30px;
      right: 30px;
      background: #3498db;
      color: white;
      padding: 10px 15px;
      border-radius: 50px;
      text-decoration: none;
      box-shadow: 0 2px 10px rgba(0,0,0,0.2);
      transition: background 0.3s;
    }
    
    .nav-top:hover {
      background: #2980b9;
      border-bottom: none;
    }
  </style>
</head>
<body>
  <div class="container">
    ${htmlContent}
  </div>
  <a href="#" class="nav-top">↑ Top</a>
  
  <script>
    // Smooth scroll for anchor links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
      anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
          target.scrollIntoView({ behavior: 'smooth' });
        } else {
          window.scrollTo({ top: 0, behavior: 'smooth' });
        }
      });
    });
    
    // Add status code styling
    document.querySelectorAll('code').forEach(code => {
      const text = code.textContent;
      if (text.match(/^(200|400|404|500)$/)) {
        code.classList.add('status-code', 'status-' + text);
      }
    });
  </script>
</body>
</html>
    `;
    
    return reply.type('text/html').send(fullHtml);
  } catch (error) {
    reply.status(500);
    return { 
      error: 'Failed to load documentation', 
      details: error instanceof Error ? error.message : 'Unknown error' 
    };
  }
});

// ===== UTILITY ROUTES =====

// Example API route
server.get('/api/hello', async (request, reply) => {
  return { message: 'Hello from E-commerce API!', timestamp: new Date().toISOString() };
});

// Example POST route
server.post('/api/echo', async (request, reply) => {
  return { 
    message: 'Echo response', 
    data: request.body,
    timestamp: new Date().toISOString() 
  };
});

// Start server
const start = async () => {
  try {
    // Initialize database
    await db.initialize();
    
    const port = process.env.PORT || 3010;
    const host = process.env.HOST || '0.0.0.0';
    
    await server.listen({ port: Number(port), host });
    
    console.log(`🚀 E-commerce API Server is running on http://${host}:${port}`);
    console.log(`📖 Documentation: http://${host}:${port}/doc`);
    console.log(`📊 Health check: http://${host}:${port}/health`);
    console.log(`🗄️  Database health: http://${host}:${port}/health/db`);
    console.log(`🛍️  Products: http://${host}:${port}/api/products`);
    console.log(`📂 Categories: http://${host}:${port}/api/categories`);
    console.log(`🏷️  Brands: http://${host}:${port}/api/brands`);
    console.log(`👥 Users: http://${host}:${port}/api/users`);
    console.log(`📝 Reviews: http://${host}:${port}/api/products/1/reviews`);
    console.log(`📦 Orders: http://${host}:${port}/api/users/1/orders`);
  } catch (err) {
    server.log.error(err);
    process.exit(1);
  }
};

start();
